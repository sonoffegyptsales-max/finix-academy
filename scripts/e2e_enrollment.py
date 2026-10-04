#!/usr/bin/env python3
"""End-to-end test of paid enrollment on the LIVE site, through the real UI.

  1. anonymous buyer fills /enroll and submits an InstaPay reference
  2. a throwaway admin opens Admin Panel -> Payment requests -> Approve
     and reads the access code + password the page shows
  3. the admin opens "Login details" on the Trainees tab and sees the code
  4. a fresh browser signs in with that ACCESS CODE and sees unlocked modules
  5. a fresh browser signs in with EMAIL + PASSWORD
Everything created is deleted at the end.

Usage: python scripts/e2e_enrollment.py [--base URL]
"""
from __future__ import annotations

import base64
import json
import os
import secrets
import subprocess
import sys
import time

CHROME = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
PORT = 9334
BASE = sys.argv[sys.argv.index("--base") + 1] if "--base" in sys.argv else "https://finix-academy.vercel.app"
SHOTS = os.path.join(os.environ.get("TMPDIR", "."), "e2e_enroll")
os.makedirs(SHOTS, exist_ok=True)


def env():
    out = {}
    for line in open(".env", encoding="utf-8"):
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            k, v = line.split("=", 1)
            out[k.strip()] = v.strip()
    return out


E = env()
SB = E["VITE_SUPABASE_URL"].rstrip("/")
SRK = E["SUPABASE_SERVICE_ROLE_KEY"]
ANON = E["VITE_SUPABASE_PUBLISHABLE_KEY"]
REF = SB.split("//", 1)[1].split(".", 1)[0]
SESS_KEY = f"sb-{REF}-auth-token"


def rest(method, path, body=None, key=SRK, extra=()):
    cmd = ["curl", "-s", "-X", method, f"{SB}{path}", "-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}", *extra]
    if body is not None:
        pf = os.path.join(SHOTS, "_b.json")
        with open(pf, "w", encoding="utf-8") as f:
            json.dump(body, f)
        cmd += ["-H", "Content-Type: application/json", "--data-binary", f"@{pf}"]
    r = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8").stdout
    try:
        return json.loads(r) if r else None
    except Exception:
        return r


results: list[tuple[str, bool, str]] = []


def check(name, ok, detail=""):
    results.append((name, bool(ok), detail))
    print(("PASS " if ok else "FAIL ") + name + (f"  [{detail}]" if detail else ""))


# ------------------------------------------------------------------ browser
subprocess.run(["cmd.exe", "/c", "taskkill", "/F", "/IM", "chrome.exe"], capture_output=True)
time.sleep(1)
prof = os.path.join(SHOTS, "prof")
proc = subprocess.Popen(
    [CHROME, f"--remote-debugging-port={PORT}", "--remote-allow-origins=*", "--headless=new", "--disable-gpu",
     "--window-size=1280,1600", f"--user-data-dir={prof}", "about:blank"],
    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
time.sleep(4)
import websocket  # noqa: E402

tabs = json.loads(subprocess.run(["curl", "-s", f"http://127.0.0.1:{PORT}/json"], capture_output=True, text=True).stdout)
ws = websocket.create_connection([t for t in tabs if t["type"] == "page"][0]["webSocketDebuggerUrl"], suppress_origin=True, timeout=90)
n = [0]


def cmd(method, **params):
    n[0] += 1
    ws.send(json.dumps({"id": n[0], "method": method, "params": params}))
    while True:
        m = json.loads(ws.recv())
        if m.get("id") == n[0]:
            return m.get("result", {})


def js(expr):
    r = cmd("Runtime.evaluate", expression=expr, returnByValue=True, awaitPromise=True)
    return r.get("result", {}).get("value")


def goto(path, wait=8):
    cmd("Page.navigate", url=BASE + path)
    time.sleep(wait)


def wait_for(expr, timeout=25):
    end = time.time() + timeout
    while time.time() < end:
        v = js(expr)
        if v:
            return v
        time.sleep(1)
    return None


def shot(name):
    d = cmd("Page.captureScreenshot", format="png")
    p = os.path.join(SHOTS, name)
    with open(p, "wb") as f:
        f.write(base64.b64decode(d["data"]))
    return p


def fresh_browser():
    cmd("Network.enable")
    cmd("Network.clearBrowserCookies")
    goto("/", 4)
    js("localStorage.clear(); sessionStorage.clear(); indexedDB.databases && indexedDB.databases().then(d=>d.forEach(x=>indexedDB.deleteDatabase(x.name))); 1")


# React-controlled inputs need the native setter + input event.
SET = """((sel, val) => { const el = document.querySelector(sel); if(!el) return false;
  const proto = el.tagName==='TEXTAREA'?HTMLTextAreaElement.prototype:(el.tagName==='SELECT'?HTMLSelectElement.prototype:HTMLInputElement.prototype);
  Object.getOwnPropertyDescriptor(proto,'value').set.call(el,val);
  el.dispatchEvent(new Event(el.tagName==='SELECT'?'change':'input',{bubbles:true})); return true; })"""
CLICK_TEXT = """((txt, scope) => { const els=[...document.querySelectorAll(scope||'button,a')];
  const el=els.find(e=>e.innerText.trim().includes(txt)); if(!el) return false; el.click(); return true; })"""

tag = secrets.token_hex(3)
buyer_email = f"e2e-buyer-{tag}@finix-test.local"
reference = f"E2E{secrets.token_hex(5).upper()}"
admin_uid = buyer_uid = None
cmd("Page.enable")
cmd("Runtime.enable")

try:
    # ============================================================ 1. buyer
    fresh_browser()
    js("localStorage.setItem('lang','en');1")
    goto("/enroll", 9)
    n_pkgs = js("document.querySelectorAll('button[aria-pressed]').length")
    check("enroll page lists packages", n_pkgs == 5, f"{n_pkgs} packages")
    check("header shows Enroll link", js("!![...document.querySelectorAll('a')].find(a=>a.getAttribute('href')==='/enroll')"))
    # choose the full programme + labs package (scope all)
    js(f"{CLICK_TEXT}('Full programme + labs', 'button[aria-pressed]')")
    time.sleep(1)
    form = {
        "form label:nth-of-type(1) input": "E2E Buyer " + tag,
        "input[inputmode=tel]": "01000000000",
        "input[type=email]": buyer_email,
    }
    for sel, val in form.items():
        js(f"{SET}({json.dumps(sel)}, {json.dumps(val)})")
    # reference = 4th text input in the form
    js(f"""(() => {{ const ins=[...document.querySelectorAll('form input:not([type=file])')];
        const el=ins[3]; Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,'value').set.call(el,{json.dumps(reference)});
        el.dispatchEvent(new Event('input',{{bubbles:true}})); return true; }})()""")
    shot("1_enroll_filled.png")
    js("document.querySelector('form button[type=submit]').click()")
    ok = wait_for("document.body.innerText.includes('Request received')", 30)
    check("buyer submission accepted", ok, js("(document.querySelector('form .text-destructive')||{}).innerText||''") or "")
    shot("2_enroll_done.png")

    req = rest("GET", f"/rest/v1/access_requests?instapay_reference=eq.{reference}&select=id,status,amount_egp,email")
    check("request stored with server-side price", isinstance(req, list) and len(req) == 1 and req[0]["amount_egp"] == 11900,
          json.dumps(req)[:120])

    # duplicate reference must be refused
    goto("/enroll", 8)
    js(f"{CLICK_TEXT}('Full programme + labs', 'button[aria-pressed]')")
    for sel, val in form.items():
        js(f"{SET}({json.dumps(sel)}, {json.dumps(val)})")
    js(f"""(() => {{ const el=[...document.querySelectorAll('form input:not([type=file])')][3];
        Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,'value').set.call(el,{json.dumps(reference)});
        el.dispatchEvent(new Event('input',{{bubbles:true}})); }})()""")
    js("document.querySelector('form button[type=submit]').click()")
    dup = wait_for("(document.querySelector('form .text-destructive')||{}).innerText", 20)
    check("duplicate InstaPay reference refused", dup and "already" in dup, dup or "")

    # ============================================================ 2. admin approves
    admin_email = f"e2e-admin-{tag}@finix-test.local"
    admin_pw = secrets.token_urlsafe(16)
    a = rest("POST", "/auth/v1/admin/users", {"email": admin_email, "password": admin_pw, "email_confirm": True})
    admin_uid = a["id"]
    rest("POST", "/rest/v1/profiles", {"id": admin_uid, "email": admin_email, "full_name": "E2E Admin"},
         extra=("-H", "Prefer: resolution=merge-duplicates"))
    rest("POST", "/rest/v1/user_roles", {"user_id": admin_uid, "role": "admin"})
    tok = rest("POST", "/auth/v1/token?grant_type=password", {"email": admin_email, "password": admin_pw}, key=ANON)

    fresh_browser()
    sess = json.dumps({"access_token": tok["access_token"], "refresh_token": tok["refresh_token"],
                       "expires_at": int(time.time()) + int(tok["expires_in"]), "expires_in": tok["expires_in"],
                       "token_type": "bearer", "user": tok["user"]})
    js(f"localStorage.setItem({json.dumps(SESS_KEY)}, {json.dumps(sess)}); localStorage.setItem('lang','en'); 1")
    goto("/dashboard/admin-panel", 10)
    js("window.confirm = () => true; 1")
    tabs_txt = js("[...document.querySelectorAll('button')].map(b=>b.innerText.trim()).filter(Boolean).join('|')")
    check("admin tabs present", all(x in (tabs_txt or "") for x in ("Payment requests", "Module access", "Pricing & InstaPay")), "")
    js(f"{CLICK_TEXT}('Payment requests')")
    found = wait_for(f"document.body.innerText.includes({json.dumps(reference)})", 20)
    check("request visible to admin", found)
    shot("3_admin_requests.png")
    # approve the card containing our reference
    js(f"""(() => {{ const card=[...document.querySelectorAll('div.rounded-xl')].find(d=>d.innerText.includes({json.dumps(reference)}) && d.querySelector('button'));
        const b=[...card.querySelectorAll('button')].find(x=>x.innerText.includes('Approve')); b.click(); return true; }})()""")
    got = wait_for("(() => { const g=document.querySelector('.bg-green-50'); return g && g.innerText.includes('Access code') ? g.innerText : null })()", 40)
    shot("4_admin_approved.png")
    check("approval shows credentials", bool(got), (got or "")[:160].replace("\n", " | "))
    code = js("(() => { const g=document.querySelector('.bg-green-50'); const s=[...g.querySelectorAll('span.font-mono')]; return s[0]&&s[0].innerText.trim(); })()")
    password = js("(() => { const g=document.querySelector('.bg-green-50'); const s=[...g.querySelectorAll('span.font-mono')]; return s[2]&&s[2].innerText.trim(); })()")
    check("access code format", bool(code) and len(code) == 9 and code[4] == "-", code or "")
    check("password issued", bool(password) and len(password) == 14, "(hidden)")
    check("WhatsApp hand-off link", js("!!document.querySelector('.bg-green-50 a[href^=\"https://wa.me/201000000000\"]')"))

    prof_row = rest("GET", f"/rest/v1/profiles?email=eq.{buyer_email}&select=id")
    buyer_uid = prof_row[0]["id"] if prof_row else None
    acc = rest("GET", f"/rest/v1/module_access?user_id=eq.{buyer_uid}&revoked_at=is.null&select=module_id,source")
    check("all 22 modules unlocked by payment", isinstance(acc, list) and len(acc) == 22 and all(x["source"] == "payment" for x in acc),
          f"{len(acc) if isinstance(acc, list) else acc}")

    # ============================================================ 3. Login details panel
    js(f"{CLICK_TEXT}('Trainees')")
    wait_for(f"document.body.innerText.includes({json.dumps(buyer_email)})", 20)
    js(f"""(() => {{ const row=[...document.querySelectorAll('div.p-4')].find(d=>d.innerText.includes({json.dumps(buyer_email)}));
        [...row.querySelectorAll('button')].find(b=>b.innerText.includes('Login details')).click(); return true; }})()""")
    panel = wait_for(f"(() => {{ const p=document.querySelector('.bg-primary\\\\/5'); return p && p.innerText.includes({json.dumps(code)}) ? p.innerText : null }})()", 20)
    shot("5_login_details.png")
    check("Login details shows the access code", bool(panel), (panel or "")[:200].replace("\n", " | "))
    check("password is NOT revealable (hashed)", panel and "hidden" in panel)

    # ============================================================ 4. sign in with the code
    fresh_browser()
    js("localStorage.setItem('lang','en');1")
    goto("/auth", 8)
    js(f"{SET}('input[autocomplete=\"one-time-code\"]', {json.dumps(code)})")
    js("document.querySelector('form button[type=submit]').click()")
    wait_for("location.pathname.startsWith('/dashboard')", 30)
    goto("/dashboard/my-courses", 10)
    txt = js("document.body.innerText") or ""
    shot("6_trainee_courses.png")
    check("code sign-in reaches My Courses", "My Courses" in txt, js("location.pathname"))
    check("no Locked badges after payment", "Locked" not in txt)
    goto("/dashboard/module/finix-alpha-control-platform", 10)
    body_len = js("document.body.innerText.length")
    check("paid trainee can read a lesson", (body_len or 0) > 3000 and "This module is locked" not in (js("document.body.innerText") or ""), f"body {body_len}")

    # ============================================================ 5. lock one module, verify UI
    f07 = rest("GET", "/rest/v1/modules?slug=eq.finix-alpha-control-platform&select=id")[0]["id"]
    rest("PATCH", f"/rest/v1/module_access?user_id=eq.{buyer_uid}&module_id=eq.{f07}", {"revoked_at": "2026-01-01T00:00:00Z"})
    goto("/dashboard/module/finix-alpha-control-platform", 10)
    locked_txt = js("document.body.innerText") or ""
    shot("7_locked_module.png")
    check("revoked module shows locked notice", "This module is locked" in locked_txt)
    goto("/dashboard/quiz/finix-alpha-control-platform/bronze", 9)
    check("revoked module's quiz is locked", "This module is locked" in (js("document.body.innerText") or ""))

    # ============================================================ 6. password sign-in
    fresh_browser()
    js("localStorage.setItem('lang','en');1")
    goto("/auth", 8)
    js(f"{CLICK_TEXT}('Email & password')")
    time.sleep(1)
    js(f"{SET}('input[type=email]', {json.dumps(buyer_email)})")
    js(f"{SET}('input[type=password]', {json.dumps(password)})")
    js("document.querySelector('form button[type=submit]').click()")
    pw_ok = wait_for("location.pathname.startsWith('/dashboard')", 30)
    check("email + issued password signs in", bool(pw_ok), js("location.pathname"))
finally:
    try:
        ws.close()
    except Exception:
        pass
    proc.terminate()
    # cleanup
    rest("DELETE", f"/rest/v1/access_requests?instapay_reference=eq.{reference}")
    for uid in (buyer_uid, admin_uid):
        if uid:
            rest("DELETE", f"/auth/v1/admin/users/{uid}")
    left = rest("GET", f"/rest/v1/profiles?email=in.({buyer_email},e2e-admin-{tag}@finix-test.local)&select=id")
    print("\ncleanup:", "clean" if left == [] else left)

fails = [r for r in results if not r[1]]
print(f"\n{len(results) - len(fails)}/{len(results)} passed  · screenshots: {SHOTS}")
sys.exit(1 if fails else 0)
