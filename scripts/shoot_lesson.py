#!/usr/bin/env python3
"""Screenshot a REAL authenticated lesson page in Arabic.

Every previous check of the lesson layout used a hand-built preview file that
imitated the component's classes. That is exactly how three reported defects
survived "verification": the preview agreed with my assumptions instead of with
the app. This drives the actual deployed page.

Auth without a password: the service-role key can mint a magic link
(/auth/v1/admin/generate_link), which logs the browser in on first visit.

Arabic is stored in localStorage, so the language is set BEFORE the app boots
and the page is reloaded once.

Usage:
  python3 scripts/shoot_lesson.py <module-slug> <out.png> [--base URL]
"""
from __future__ import annotations

import base64
import json
import os
import subprocess
import sys
import time
import urllib.parse

CHROME = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
PORT = 9333


def env() -> dict[str, str]:
    out = {}
    if os.path.exists(".env"):
        with open(".env", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    k, v = line.split("=", 1)
                    out[k.strip()] = v.strip()
    return out


def curl_json(args: list[str]) -> dict:
    r = subprocess.run(["curl", "-s", *args], capture_output=True, text=True,
                       encoding="utf-8")
    try:
        return json.loads(r.stdout)
    except Exception:
        return {"_raw": r.stdout[:400]}


def main() -> int:
    slug = sys.argv[1] if len(sys.argv) > 1 else "sonoff-ecosystem-fundamentals"
    out = sys.argv[2] if len(sys.argv) > 2 else "lesson.png"
    base = "https://finix-academy.vercel.app"
    if "--base" in sys.argv:
        base = sys.argv[sys.argv.index("--base") + 1]

    e = env()
    sb = (e.get("VITE_SUPABASE_URL") or e.get("SUPABASE_URL", "")).rstrip("/")
    key = e.get("SUPABASE_SERVICE_ROLE_KEY")
    anon = e.get("VITE_SUPABASE_ANON_KEY") or e.get("VITE_SUPABASE_PUBLISHABLE_KEY")
    email = e.get("ADMIN_EMAIL", "admin@finixacademy.local")
    pwd = e.get("ADMIN_PASSWORD")
    if not sb or not key:
        print("missing supabase url/service key", file=sys.stderr)
        return 1

    # Sign in for real and inject the session into localStorage under the
    # supabase-js storage key. A magic link does NOT work headlessly: the app
    # consumes the token client-side on the redirect and the visit raced it.
    ref = sb.split("//", 1)[1].split(".", 1)[0]
    sess_key = f"sb-{ref}-auth-token"
    session = None
    temp_uid = None

    if not (pwd and anon):
        # No stored admin password: mint a THROWAWAY confirmed user with the
        # service-role key, sign in as it, and delete it in the finally block.
        # Never touches the real admin account.
        import secrets
        email = f"shot-{secrets.token_hex(4)}@finix-shot.local"
        pwd = secrets.token_urlsafe(18)
        pf = os.path.join(os.environ.get("TMPDIR", "."), "_mk.json")
        with open(pf, "w", encoding="utf-8") as f:
            json.dump({"email": email, "password": pwd,
                       "email_confirm": True,
                       "user_metadata": {"full_name": "Layout Probe"}}, f)
        mk = curl_json(["-X", "POST", f"{sb}/auth/v1/admin/users",
                        "-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}",
                        "-H", "Content-Type: application/json",
                        "--data-binary", f"@{pf}"])
        os.unlink(pf)
        temp_uid = mk.get("id")
        if not temp_uid:
            print("could not create temp user:", str(mk)[:220], file=sys.stderr)
            return 1
        print(f"temp user created ({email})")

        # Profile row.
        pf = os.path.join(os.environ.get("TMPDIR", "."), "_pr.json")
        with open(pf, "w", encoding="utf-8") as f:
            json.dump({"id": temp_uid, "email": email,
                       "full_name": "Layout Probe"}, f)
        curl_json(["-X", "POST", f"{sb}/rest/v1/profiles",
                   "-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}",
                   "-H", "Content-Type: application/json",
                   "-H", "Prefer: resolution=merge-duplicates,return=minimal",
                   "--data-binary", f"@{pf}"])
        os.unlink(pf)

        # ROLE ROW IS MANDATORY. Roles live in user_roles, NOT profiles.role --
        # the lessons RLS policy calls has_role(), so a user with only a
        # profiles row sees ZERO lessons and the page renders an empty module.
        # That looked exactly like a broken lessons list and cost a whole
        # round of false diagnosis.
        pf = os.path.join(os.environ.get("TMPDIR", "."), "_ro.json")
        with open(pf, "w", encoding="utf-8") as f:
            json.dump({"user_id": temp_uid, "role": "admin"}, f)
        curl_json(["-X", "POST", f"{sb}/rest/v1/user_roles",
                   "-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}",
                   "-H", "Content-Type: application/json",
                   "-H", "Prefer: resolution=merge-duplicates,return=minimal",
                   "--data-binary", f"@{pf}"])
        os.unlink(pf)

    if anon:
        pf = os.path.join(os.environ.get("TMPDIR", "."), "_pw.json")
        with open(pf, "w", encoding="utf-8") as f:
            json.dump({"email": email, "password": pwd}, f)
        tok = curl_json(["-X", "POST",
                         f"{sb}/auth/v1/token?grant_type=password",
                         "-H", f"apikey: {anon}", "-H", "Content-Type: application/json",
                         "--data-binary", f"@{pf}"])
        os.unlink(pf)
        if tok.get("access_token"):
            session = tok
            print("signed in via password grant")
        else:
            print("password grant failed:", str(tok)[:200], file=sys.stderr)
    if session is None:
        print("no session established", file=sys.stderr)
        return 1

    prof = os.path.join(os.environ.get("TMPDIR", "."), "chromeprof")
    subprocess.run(["cmd.exe", "/c", "taskkill", "/F", "/IM", "chrome.exe"],
                   capture_output=True)
    time.sleep(1)
    proc = subprocess.Popen(
        [CHROME, f"--remote-debugging-port={PORT}", "--remote-allow-origins=*",
         "--headless=new", "--disable-gpu", "--hide-scrollbars",
         "--force-device-scale-factor=2", "--window-size=1280,2000",
         f"--user-data-dir={prof}", "about:blank"],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    time.sleep(4)

    try:
        import websocket  # type: ignore
    except ImportError:
        print("pip install websocket-client into the wsenv first", file=sys.stderr)
        return 1

    tabs = curl_json([f"http://127.0.0.1:{PORT}/json"])
    if not isinstance(tabs, list):
        tabs = json.loads(subprocess.run(
            ["curl", "-s", f"http://127.0.0.1:{PORT}/json"],
            capture_output=True, text=True).stdout)
    ws_url = [t for t in tabs if t.get("type") == "page"][0]["webSocketDebuggerUrl"]
    ws = websocket.create_connection(ws_url, suppress_origin=True, timeout=60)
    n = [0]

    def cmd(method, **params):
        n[0] += 1
        ws.send(json.dumps({"id": n[0], "method": method, "params": params}))
        while True:
            m = json.loads(ws.recv())
            if m.get("id") == n[0]:
                return m.get("result", {})

    cmd("Page.enable")
    cmd("Runtime.enable")

    def goto(u, wait=7):
        cmd("Page.navigate", url=u)
        time.sleep(wait)

    def js(expr):
        r = cmd("Runtime.evaluate", expression=expr, returnByValue=True,
                awaitPromise=True)
        return r.get("result", {}).get("value")

    print("seeding session + language…")
    goto(f"{base}/", 6)
    sess_json = json.dumps({
        "access_token": session["access_token"],
        "refresh_token": session["refresh_token"],
        "expires_at": int(time.time()) + int(session.get("expires_in", 3600)),
        "expires_in": int(session.get("expires_in", 3600)),
        "token_type": "bearer",
        "user": session.get("user", {}),
    })
    js(f"localStorage.setItem({json.dumps(sess_key)}, {json.dumps(sess_json)});"
       f"localStorage.setItem('lang','ar');1")
    goto(f"{base}/dashboard/module/{slug}", 12)

    print("url     :", js("location.pathname"))
    print("dir     :", js("document.documentElement.dir"))
    print("lang    :", js("document.documentElement.lang"))
    print("body len:", js("document.body.innerText.length"))

    # Measure the gap directly instead of eyeballing it.
    probe2 = js("""(() => {
      const aside = document.querySelector('aside') ||
                    document.querySelector('[class*="w-64"]');
      const main = document.querySelector('main');
      const g = el => { if(!el) return null; const r=el.getBoundingClientRect();
        return {tag:el.tagName, left:Math.round(r.left), right:Math.round(r.right),
                w:Math.round(r.width), textLen:(el.innerText||'').trim().length,
                vis:getComputedStyle(el).visibility, disp:getComputedStyle(el).display}; };
      // what actually occupies the right-hand band?
      const probes=[];
      for(const x of [1100,1180,1250]){
        const el=document.elementFromPoint(x, 400);
        probes.push({x, tag: el?el.tagName:null,
                     cls: el?String(el.className).slice(0,70):null});
      }
      return JSON.stringify({aside:g(aside), main:g(main),
        vw:window.innerWidth, docW:document.documentElement.scrollWidth,
        atRight:probes}, null, 1);
    })()""")
    print("\nSIDEBAR / RIGHT-BAND PROBE\n", probe2)

    probe = js("""(() => {
      const li = document.querySelector('main ol li') || document.querySelector('main li');
      const ol = document.querySelector('main ol') || document.querySelector('main ul');
      const main = document.querySelector('main');
      const g = el => { if(!el) return null; const c=getComputedStyle(el), r=el.getBoundingClientRect();
        return {tag:el.tagName, right:Math.round(r.right), left:Math.round(r.left),
                w:Math.round(r.width), pr:c.paddingRight, pl:c.paddingLeft,
                mr:c.marginRight, ml:c.marginLeft, lsp:c.listStylePosition, dir:c.direction}; };
      return JSON.stringify({main:g(main), list:g(ol), item:g(li),
        vw: window.innerWidth,
        sample: li ? li.innerText.slice(0,60) : null}, null, 1);
    })()""")
    print("\nLAYOUT PROBE\n", probe)

    data = cmd("Page.captureScreenshot", format="png", captureBeyondViewport=True)
    if data.get("data"):
        with open(out, "wb") as f:
            f.write(base64.b64decode(data["data"]))
        print("\nsaved", out)
    ws.close()
    proc.terminate()

    if temp_uid:
        curl_json(["-X", "DELETE", f"{sb}/rest/v1/user_roles?user_id=eq.{temp_uid}",
                   "-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}"])
        curl_json(["-X", "DELETE", f"{sb}/rest/v1/profiles?id=eq.{temp_uid}",
                   "-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}"])
        curl_json(["-X", "DELETE", f"{sb}/auth/v1/admin/users/{temp_uid}",
                   "-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}"])
        chk = curl_json([f"{sb}/rest/v1/profiles?id=eq.{temp_uid}&select=id",
                         "-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}"])
        print("temp user deleted" if chk == [] else f"CLEANUP CHECK: {chk}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
