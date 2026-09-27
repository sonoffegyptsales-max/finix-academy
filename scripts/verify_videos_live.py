#!/usr/bin/env python3
"""Verify video resources on the LIVE lesson pages, not just in the database.

The database can be perfect while the page shows nothing: the render path
filters external URLs out of the signing batch and out of the <video> tag, so
a filtering regression or an unmounted section would leave lesson_media rows
intact and trainees videoless. This drives the real deployed app with a real
session (same approach as shoot_lesson.py: throwaway confirmed user + admin
role row) and reads the rendered YouTube anchors out of each module's DOM.

  $LOCALAPPDATA/Temp/wsenv2/Scripts/python.exe scripts/verify_videos_live.py
"""
from __future__ import annotations

import json
import os
import re
import secrets
import subprocess
import sys
import time

CHROME = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
PORT = 9333
BASE = "https://finix-academy.vercel.app"


def env() -> dict[str, str]:
    out = {}
    with open(".env", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                out[k.strip()] = v.strip()
    return out


def curl_json(args: list[str]):
    r = subprocess.run(["curl", "-s", *args], capture_output=True, text=True,
                       encoding="utf-8")
    try:
        return json.loads(r.stdout)
    except Exception:
        return {"_raw": r.stdout[:400]}


def main() -> int:
    e = env()
    sb = (e.get("VITE_SUPABASE_URL") or e["SUPABASE_URL"]).rstrip("/")
    key = e["SUPABASE_SERVICE_ROLE_KEY"]
    anon = e.get("VITE_SUPABASE_ANON_KEY") or e.get("VITE_SUPABASE_PUBLISHABLE_KEY")
    auth = ["-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}"]

    # ---- expected: module slug -> set of youtube video ids
    media = curl_json([
        f"{sb}/rest/v1/lesson_media?kind=eq.video"
        f"&select=storage_path,lessons(title,modules(slug))&limit=200", *auth])
    vid_rx = re.compile(r"(?:v=|youtu\.be/)([\w-]{6,})")
    expected: dict[str, set[str]] = {}
    for m in media:
        slug = m["lessons"]["modules"]["slug"]
        mt = vid_rx.search(m["storage_path"])
        if mt:
            expected.setdefault(slug, set()).add(mt.group(1))
    total = sum(len(v) for v in expected.values())
    print(f"{total} videos across {len(expected)} modules in the database\n")

    # ---- throwaway user with role row (roles live in user_roles, NOT
    # profiles.role; without it RLS hides every lesson and the page is empty)
    email = f"vid-{secrets.token_hex(4)}@finix-shot.local"
    pwd = secrets.token_urlsafe(18)
    tmp = os.environ.get("TMPDIR", ".")

    def post(url_path, payload, extra=None):
        pf = os.path.join(tmp, "_vv.json")
        with open(pf, "w", encoding="utf-8") as f:
            json.dump(payload, f)
        r = curl_json(["-X", "POST", f"{sb}{url_path}", *auth,
                       "-H", "Content-Type: application/json",
                       *(extra or []), "--data-binary", f"@{pf}"])
        os.unlink(pf)
        return r

    mk = post("/auth/v1/admin/users",
              {"email": email, "password": pwd, "email_confirm": True,
               "user_metadata": {"full_name": "Video Probe"}})
    uid = mk.get("id")
    if not uid:
        print("could not create temp user:", str(mk)[:200], file=sys.stderr)
        return 1
    merge = ["-H", "Prefer: resolution=merge-duplicates,return=minimal"]
    post("/rest/v1/profiles",
         {"id": uid, "email": email, "full_name": "Video Probe"}, merge)
    post("/rest/v1/user_roles", {"user_id": uid, "role": "admin"}, merge)

    pf = os.path.join(tmp, "_vv.json")
    with open(pf, "w", encoding="utf-8") as f:
        json.dump({"email": email, "password": pwd}, f)
    tok = curl_json(["-X", "POST", f"{sb}/auth/v1/token?grant_type=password",
                     "-H", f"apikey: {anon}",
                     "-H", "Content-Type: application/json",
                     "--data-binary", f"@{pf}"])
    os.unlink(pf)
    if not tok.get("access_token"):
        print("password grant failed:", str(tok)[:200], file=sys.stderr)
        return 1

    # ---- boot Chrome once, seed the session, then walk every module
    prof = os.path.join(tmp, "chromeprof_vv")
    subprocess.run(["cmd.exe", "/c", "taskkill", "/F", "/IM", "chrome.exe"],
                   capture_output=True)
    time.sleep(1)
    proc = subprocess.Popen(
        [CHROME, f"--remote-debugging-port={PORT}", "--remote-allow-origins=*",
         "--headless=new", "--disable-gpu", f"--user-data-dir={prof}",
         "about:blank"],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    time.sleep(4)

    import websocket  # type: ignore
    tabs = json.loads(subprocess.run(
        ["curl", "-s", f"http://127.0.0.1:{PORT}/json"],
        capture_output=True, text=True).stdout)
    ws = websocket.create_connection(
        [t for t in tabs if t.get("type") == "page"][0]["webSocketDebuggerUrl"],
        suppress_origin=True, timeout=60)
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

    def goto(u, wait=10):
        cmd("Page.navigate", url=u)
        time.sleep(wait)

    def js(expr):
        r = cmd("Runtime.evaluate", expression=expr, returnByValue=True,
                awaitPromise=True)
        return r.get("result", {}).get("value")

    ref = sb.split("//", 1)[1].split(".", 1)[0]
    goto(f"{BASE}/", 6)
    sess = json.dumps({
        "access_token": tok["access_token"],
        "refresh_token": tok["refresh_token"],
        "expires_at": int(time.time()) + int(tok.get("expires_in", 3600)),
        "expires_in": int(tok.get("expires_in", 3600)),
        "token_type": "bearer", "user": tok.get("user", {})})
    js(f"localStorage.setItem('sb-{ref}-auth-token', {json.dumps(sess)});1")

    failures = 0
    try:
        for slug, want_ids in sorted(expected.items()):
            goto(f"{BASE}/dashboard/module/{slug}", 12)
            got_raw = js(
                "JSON.stringify([...document.querySelectorAll("
                "'a[href*=\"youtube.com\"], a[href*=\"youtu.be\"]')]"
                ".map(a => a.href))")
            got_ids = {m.group(1) for u in json.loads(got_raw or "[]")
                       if (m := vid_rx.search(u))}
            missing = want_ids - got_ids
            status = "OK  " if not missing else "FAIL"
            if missing:
                failures += 1
            print(f"{status} {slug:46} rendered {len(got_ids & want_ids)}"
                  f"/{len(want_ids)}"
                  + (f"  MISSING {sorted(missing)}" if missing else ""))
    finally:
        ws.close()
        proc.terminate()
        for path in (f"/rest/v1/user_roles?user_id=eq.{uid}",
                     f"/rest/v1/profiles?id=eq.{uid}"):
            curl_json(["-X", "DELETE", f"{sb}{path}", *auth])
        curl_json(["-X", "DELETE", f"{sb}/auth/v1/admin/users/{uid}", *auth])
        chk = curl_json([f"{sb}/rest/v1/profiles?id=eq.{uid}&select=id", *auth])
        print("temp user deleted" if chk == [] else f"CLEANUP CHECK: {chk}")

    print(f"\n{'ALL RENDERED ON LIVE PAGES' if not failures else str(failures) + ' modules FAILED'}")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
