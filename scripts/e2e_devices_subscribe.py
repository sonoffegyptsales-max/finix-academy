#!/usr/bin/env python3
"""Live test: 2-device limit + in-app subscribe for a signed-in student.

  A. device limit (real sign-ins through /auth with an access code, three
     separate browser profiles = three devices): 1st ok, 2nd ok, 3rd refused;
     admin frees one slot -> 3rd now ok; the DB trigger refuses a raw 3rd insert.
  B. a student owning only Track 1 opens /dashboard/subscribe, sees the other
     two tracks, pays for one; admin approves; the SAME account (same code)
     now opens that track; the code did not change.
Everything created is deleted.
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
BASE = "https://finix-academy.vercel.app"
OUT = os.path.join(os.environ.get("TMPDIR", "."), "e2e_devices")
os.makedirs(OUT, exist_ok=True)

E = {}
for l in open(".env", encoding="utf-8"):
    l = l.strip()
    if l and not l.startswith("#") and "=" in l:
        k, v = l.split("=", 1)
        E[k.strip()] = v.strip()
SB = E["VITE_SUPABASE_URL"].rstrip("/")
SRK = E["SUPABASE_SERVICE_ROLE_KEY"]
ANON = E["VITE_SUPABASE_PUBLISHABLE_KEY"]
SESS_KEY = "sb-" + SB.split("//", 1)[1].split(".", 1)[0] + "-auth-token"


def rest(method, path, body=None, key=SRK, extra=()):
    cmd = ["curl", "-s", "-X", method, SB + path, "-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}", *extra]
    if body is not None:
        pf = os.path.join(OUT, "_b.json")
        with open(pf, "w", encoding="utf-8") as f:
            json.dump(body, f)
        cmd += ["-H", "Content-Type: application/json", "--data-binary", f"@{pf}"]
    r = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8").stdout
    try:
        return json.loads(r) if r else None
    except Exception:
        return r


results = []


def check(name, ok, detail=""):
    results.append((name, bool(ok)))
    print(("PASS " if ok else "FAIL ") + name + (f"  [{detail}]" if detail else ""))


import websocket  # noqa: E402


class Browser:
    """One headless Chrome with its own profile = one distinct device."""

    def __init__(self, name, port):
        self.proc = subprocess.Popen(
            [CHROME, f"--remote-debugging-port={port}", "--remote-allow-origins=*", "--headless=new", "--disable-gpu",
             "--window-size=1280,1400", f"--user-data-dir={OUT}/prof_{name}_{secrets.token_hex(2)}", "about:blank"],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        time.sleep(4)
        tabs = json.loads(subprocess.run(["curl", "-s", f"http://127.0.0.1:{port}/json"], capture_output=True, text=True).stdout)
        self.ws = websocket.create_connection([t for t in tabs if t["type"] == "page"][0]["webSocketDebuggerUrl"],
                                              suppress_origin=True, timeout=90)
        self.n = 0
        self.cmd("Page.enable")
        self.cmd("Runtime.enable")

    def cmd(self, m, **p):
        self.n += 1
        self.ws.send(json.dumps({"id": self.n, "method": m, "params": p}))
        while True:
            x = json.loads(self.ws.recv())
            if x.get("id") == self.n:
                return x.get("result", {})

    def js(self, e):
        return self.cmd("Runtime.evaluate", expression=e, returnByValue=True, awaitPromise=True).get("result", {}).get("value")

    def goto(self, path, wait=8):
        self.cmd("Page.navigate", url=BASE + path)
        time.sleep(wait)

    def wait(self, e, timeout=30):
        end = time.time() + timeout
        while time.time() < end:
            v = self.js(e)
            if v:
                return v
            time.sleep(1)
        return None

    def set(self, sel, val):
        return self.js(f"""(() => {{ const el=document.querySelector({json.dumps(sel)}); if(!el) return false;
          const proto = el.tagName==='TEXTAREA'?HTMLTextAreaElement.prototype:HTMLInputElement.prototype;
          Object.getOwnPropertyDescriptor(proto,'value').set.call(el,{json.dumps(val)});
          el.dispatchEvent(new Event('input',{{bubbles:true}})); return true; }})()""")

    def shot(self, name):
        d = self.cmd("Page.captureScreenshot", format="png")
        with open(os.path.join(OUT, name), "wb") as f:
            f.write(base64.b64decode(d["data"]))

    def code_login(self, code):
        self.goto("/", 4)
        self.js("localStorage.setItem('lang','en');1")
        self.goto("/auth", 8)
        self.set('input[autocomplete="one-time-code"]', code)
        self.js("document.querySelector('form button[type=submit]').click()")
        for _ in range(25):
            time.sleep(1)
            p = self.js("location.pathname")
            err = self.js("(document.querySelector('.text-destructive')||{}).innerText||''")
            if p != "/auth" or err:
                return p, err
        return self.js("location.pathname"), self.js("(document.querySelector('.text-destructive')||{}).innerText||''")

    def close(self):
        try:
            self.ws.close()
        except Exception:
            pass
        self.proc.terminate()


def make_user(role, full):
    email = f"dev-{role}-{secrets.token_hex(3)}@finix-test.local"
    pw = secrets.token_urlsafe(16)
    u = rest("POST", "/auth/v1/admin/users", {"email": email, "password": pw, "email_confirm": True})
    uid = u["id"]
    rest("POST", "/rest/v1/profiles", {"id": uid, "email": email, "full_name": full}, extra=("-H", "Prefer: resolution=merge-duplicates"))
    rest("POST", "/rest/v1/user_roles", {"user_id": uid, "role": role})
    return uid, email, pw


subprocess.run(["cmd.exe", "/c", "taskkill", "/F", "/IM", "chrome.exe"], capture_output=True)
time.sleep(1)
created = []
ref = f"UPG{secrets.token_hex(5).upper()}"
browsers = []
try:
    # ---------------------------------------------------------------- setup
    sid, semail, _ = make_user("trainee", "Device Student")
    created.append(sid)
    code = "DV" + secrets.token_hex(1).upper() + "-" + secrets.token_hex(2).upper()
    rest("POST", "/rest/v1/access_codes", {"code": code, "user_id": sid})
    tracks = rest("GET", "/rest/v1/tracks?select=id,name&order=position")
    mods = rest("GET", "/rest/v1/modules?select=id,track_id,slug&published=eq.true")
    t1 = tracks[0]["id"]
    t2 = tracks[1]["id"]
    rest("POST", "/rest/v1/module_access", [{"user_id": sid, "module_id": m["id"], "source": "manual"} for m in mods if m["track_id"] == t1])

    # ---------------------------------------------------------------- A. devices
    b1 = Browser("phone", 9341); browsers.append(b1)
    p, e = b1.code_login(code)
    check("device 1 signs in", p.startswith("/dashboard"), p + (" " + e if e else ""))
    b2 = Browser("laptop", 9342); browsers.append(b2)
    p, e = b2.code_login(code)
    check("device 2 signs in", p.startswith("/dashboard"), p + (" " + e if e else ""))
    b3 = Browser("third", 9343); browsers.append(b3)
    p, e = b3.code_login(code)
    b3.shot("A_third_device_refused.png")
    check("device 3 stays on sign-in page (no silent redirect)", p == "/auth", p)
    if p != "/auth":  # signed in, then the dashboard gate must stop it
        b3.wait("!!document.querySelector('[data-testid=device-blocked]')", 20)
        e = b3.js("(document.querySelector('[data-testid=device-blocked]')||{}).innerText||''") or e
    b3.shot("A_third_device_refused.png")
    check("device 3 refused with explanation", ("2 devices" in (e or "")), (e or "")[:120].replace("\n", " | "))
    b3.goto("/dashboard/my-courses", 9)
    check("device 3 cannot reach courses", b3.js("!!document.querySelector('[data-testid=device-blocked]')") or b3.js("location.pathname") == "/auth")
    n_active = len(rest("GET", f"/rest/v1/trainee_devices?user_id=eq.{sid}&revoked_at=is.null&select=id"))
    check("exactly 2 devices registered", n_active == 2, str(n_active))

    raw = rest("POST", "/rest/v1/trainee_devices", {"user_id": sid, "device_id": "raw-third-" + secrets.token_hex(4)})
    check("database trigger refuses a raw 3rd device", isinstance(raw, dict) and "device_limit_reached" in json.dumps(raw), json.dumps(raw)[:90])

    # device 1 still works on a reload (a returning device is not "new")
    b1.goto("/dashboard/my-courses", 9)
    check("device 1 still works after the refusal", "My Courses" in (b1.js("document.body.innerText") or ""))

    # admin frees ONE slot via the real admin UI
    aid, aemail, apw = make_user("admin", "Device Admin")
    created.append(aid)
    tok = rest("POST", "/auth/v1/token?grant_type=password", {"email": aemail, "password": apw}, key=ANON)
    b4 = Browser("admin", 9344); browsers.append(b4)
    b4.goto("/", 4)
    sess = json.dumps({"access_token": tok["access_token"], "refresh_token": tok["refresh_token"],
                       "expires_at": int(time.time()) + int(tok["expires_in"]), "expires_in": tok["expires_in"],
                       "token_type": "bearer", "user": tok["user"]})
    b4.js(f"localStorage.setItem({json.dumps(SESS_KEY)}, {json.dumps(sess)}); localStorage.setItem('lang','en'); 1")
    b4.goto("/dashboard/admin-panel", 10)
    b4.js("window.confirm = () => true; 1")
    b4.js("[...document.querySelectorAll('button')].find(b=>b.innerText.trim()==='Devices').click()")
    grp = b4.wait(f"(() => {{ const d=[...document.querySelectorAll('div.p-4')].find(x=>x.innerText.includes({json.dumps(semail)})); return d ? d.innerText : null }})()", 25)
    b4.shot("A_admin_devices.png")
    check("admin sees the student with 2/2 devices", grp and "2/2" in grp, (grp or "")[:120].replace("\n", " | "))
    b4.js(f"""(() => {{ const d=[...document.querySelectorAll('div.p-4')].find(x=>x.innerText.includes({json.dumps(semail)}));
        [...d.querySelectorAll('button')].find(b=>b.innerText.includes('Free this slot')).click(); }})()""")
    after = b4.wait(f"(() => {{ const d=[...document.querySelectorAll('div.p-4')].find(x=>x.innerText.includes({json.dumps(semail)})); return d && d.innerText.includes('1/2') ? d.innerText : null }})()", 25)
    check("freeing one slot leaves 1/2", bool(after))
    b3.js("localStorage.clear(); 1")
    p, e = b3.code_login(code)
    # Admin freed the most recent slot (device 2), so device 2 must now be refused.
    b2.goto("/dashboard/my-courses", 10)
    check("freed device (2) is now refused", b2.js("!!document.querySelector('[data-testid=device-blocked]')"))
    check("device 3 signs in after a slot is freed", p.startswith("/dashboard"), p + (" " + e if e else ""))

    # ---------------------------------------------------------------- B. subscribe inside
    S = b3  # device 3 is now a registered device
    S.js("localStorage.setItem('lang','en');1")
    S.goto(f"/dashboard/subscribe?track={t2}", 10)
    txt = S.js("document.body.innerText") or ""
    S.shot("B_subscribe_page.png")
    check("Subscribe page loads for the student", "Subscribe to more courses" in txt)
    check("sidebar has Subscribe entry", S.js("!![...document.querySelectorAll('a')].find(a=>a.getAttribute('href')==='/dashboard/subscribe')"))
    t1name = tracks[0]["name"]
    check("owned track shown as enrolled", "Enrolled — all modules open" in txt)
    preselected = S.js("!!document.querySelector('button[aria-pressed=true]')")
    check("track from the link is preselected", preselected)
    S.set("input[name=reference]", ref)
    S.set("input[name=phone]", "01000000001")
    S.js("document.querySelector('form button[type=submit]').click()")
    ok = S.wait("document.body.innerText.includes('Request received')", 30)
    check("student request submitted", bool(ok), S.js("(document.querySelector('form .text-destructive')||{}).innerText||''") or "")
    req = rest("GET", f"/rest/v1/access_requests?instapay_reference=eq.{ref}&select=id,user_id,email,track_id,amount_egp,full_name")
    check("request tied to this account + chosen track", req and req[0]["user_id"] == sid and req[0]["track_id"] == t2 and req[0]["email"] == semail,
          json.dumps(req)[:140])
    S.goto("/dashboard/subscribe", 9)
    check("request shows 'Under review' to the student", "Under review" in (S.js("document.body.innerText") or ""))

    # approve through the admin UI
    b4.goto("/dashboard/admin-panel", 10)
    b4.js("window.confirm = () => true; 1")
    b4.js("[...document.querySelectorAll('button')].find(b=>b.innerText.includes('Payment requests')).click()")
    b4.wait(f"document.body.innerText.includes({json.dumps(ref)})", 25)
    b4.js(f"""(() => {{ const c=[...document.querySelectorAll('div.rounded-xl')].find(d=>d.innerText.includes({json.dumps(ref)}) && d.querySelector('button'));
        [...c.querySelectorAll('button')].find(x=>x.innerText.includes('Approve')).click(); }})()""")
    box = b4.wait("(() => { const g=document.querySelector('[data-testid=issued-credentials]'); return g ? g.innerText : null })()", 40)
    b4.shot("B_admin_approved_upgrade.png")
    shown_code = b4.js("(document.querySelector('[data-k=code]')||{}).innerText")
    check("approval keeps the student's existing code", shown_code == code, f"{shown_code} vs {code}")
    check("existing account, no new password", box and "Existing account" in box and not b4.js("!!document.querySelector('[data-k=password]')"))
    acc_t2 = rest("GET", f"/rest/v1/module_access?user_id=eq.{sid}&revoked_at=is.null&select=module_id")
    t2_ids = {m["id"] for m in mods if m["track_id"] == t2}
    t3_ids = {m["id"] for m in mods if m["track_id"] == tracks[2]["id"]}
    have = {a["module_id"] for a in acc_t2}
    check("bought track unlocked on same account", t2_ids <= have, f"{len(t2_ids & have)}/{len(t2_ids)}")
    check("unbought track still locked", not (t3_ids & have))

    # the student's existing session on device 2 (laptop) now opens Track 2
    t2_slug = next(m["slug"] for m in mods if m["track_id"] == t2)
    S.goto(f"/dashboard/module/{t2_slug}", 10)
    body = S.js("document.body.innerText") or ""
    S.shot("B_track2_open.png")
    check("student opens the newly bought track (no re-login)", "This module is locked" not in body and len(body) > 2500, f"body {len(body)}")
    S.goto("/dashboard/subscribe", 9)
    check("subscribe page now shows only the remaining track", "Enrolled — all modules open" in (S.js("document.body.innerText") or "")
          and (S.js("document.body.innerText") or "").count("Enrolled — all modules open") == 2)
finally:
    for b in browsers:
        b.close()
    rest("DELETE", f"/rest/v1/access_requests?instapay_reference=eq.{ref}")
    for uid in created:
        rest("DELETE", f"/auth/v1/admin/users/{uid}")
    left = rest("GET", "/rest/v1/profiles?email=like.dev-*@finix-test.local&select=id")
    print("\ncleanup:", "clean" if left == [] else left)

fails = [r for r in results if not r[1]]
print(f"\n{len(results) - len(fails)}/{len(results)} passed · screenshots: {OUT}")
sys.exit(1 if fails else 0)
