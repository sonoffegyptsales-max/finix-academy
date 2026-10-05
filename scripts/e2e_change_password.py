#!/usr/bin/env python3
"""Live test of Admin Panel -> My account -> Change password, with a
throwaway admin and random passwords. Deleted afterwards."""
import json, os, secrets, subprocess, sys, time

CHROME = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
BASE = "https://finix-academy.vercel.app"
OUT = os.path.join(os.environ.get("TMPDIR", "."), "e2e_pw")
os.makedirs(OUT, exist_ok=True)
E = {}
for l in open(".env", encoding="utf-8"):
    l = l.strip()
    if l and not l.startswith("#") and "=" in l:
        k, v = l.split("=", 1); E[k.strip()] = v.strip()
SB = E["VITE_SUPABASE_URL"].rstrip("/"); SRK = E["SUPABASE_SERVICE_ROLE_KEY"]; ANON = E["VITE_SUPABASE_PUBLISHABLE_KEY"]
SESS_KEY = "sb-" + SB.split("//", 1)[1].split(".", 1)[0] + "-auth-token"


def rest(method, path, body=None, key=SRK):
    cmd = ["curl", "-s", "-X", method, SB + path, "-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}"]
    if body is not None:
        pf = os.path.join(OUT, "_b.json"); json.dump(body, open(pf, "w")); cmd += ["-H", "Content-Type: application/json", "--data-binary", f"@{pf}"]
    r = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8").stdout
    try: return json.loads(r) if r else None
    except Exception: return r


res = []
def check(n, ok, d=""):
    res.append(ok); print(("PASS " if ok else "FAIL ") + n + (f"  [{d}]" if d else ""))


email = f"pw-admin-{secrets.token_hex(3)}@finix-test.local"
old = secrets.token_urlsafe(14); new = "Probe-" + secrets.token_urlsafe(12)
uid = rest("POST", "/auth/v1/admin/users", {"email": email, "password": old, "email_confirm": True})["id"]
rest("POST", "/rest/v1/profiles", {"id": uid, "email": email, "full_name": "PW Admin"})
rest("POST", "/rest/v1/user_roles", {"user_id": uid, "role": "admin"})
tok = rest("POST", "/auth/v1/token?grant_type=password", {"email": email, "password": old}, key=ANON)

subprocess.run(["cmd.exe", "/c", "taskkill", "/F", "/IM", "chrome.exe"], capture_output=True); time.sleep(1)
proc = subprocess.Popen([CHROME, "--remote-debugging-port=9351", "--remote-allow-origins=*", "--headless=new", "--disable-gpu",
                         "--window-size=1280,1100", f"--user-data-dir={OUT}/prof_{secrets.token_hex(2)}", "about:blank"],
                        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
time.sleep(4)
import websocket
tabs = json.loads(subprocess.run(["curl", "-s", "http://127.0.0.1:9351/json"], capture_output=True, text=True).stdout)
ws = websocket.create_connection([t for t in tabs if t["type"] == "page"][0]["webSocketDebuggerUrl"], suppress_origin=True, timeout=60)
n = [0]
def cmd(m, **p):
    n[0] += 1; ws.send(json.dumps({"id": n[0], "method": m, "params": p}))
    while True:
        x = json.loads(ws.recv())
        if x.get("id") == n[0]: return x.get("result", {})
def js(e): return cmd("Runtime.evaluate", expression=e, returnByValue=True, awaitPromise=True).get("result", {}).get("value")
def setv(i, v):
    js(f"""(() => {{ const el=document.querySelectorAll('input[type=password]')[{i}];
      Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,'value').set.call(el,{json.dumps(v)});
      el.dispatchEvent(new Event('input',{{bubbles:true}})); }})()""")
def msg(): return js("(() => { const p=[...document.querySelectorAll('form p')].pop(); return p ? p.innerText : '' })()")
def submit_and_wait():
    js("document.querySelector('form button[type=submit]').click()"); time.sleep(6); return msg()

try:
    cmd("Page.enable"); cmd("Runtime.enable")
    cmd("Page.navigate", url=BASE + "/"); time.sleep(4)
    sess = json.dumps({"access_token": tok["access_token"], "refresh_token": tok["refresh_token"],
                       "expires_at": int(time.time()) + int(tok["expires_in"]), "expires_in": tok["expires_in"],
                       "token_type": "bearer", "user": tok["user"]})
    js(f"localStorage.setItem({json.dumps(SESS_KEY)}, {json.dumps(sess)}); localStorage.setItem('lang','en'); 1")
    cmd("Page.navigate", url=BASE + "/dashboard/admin-panel"); time.sleep(10)
    check("My account tab exists", js("!![...document.querySelectorAll('button')].find(b=>b.innerText.trim()==='My account')"))
    js("[...document.querySelectorAll('button')].find(b=>b.innerText.trim()==='My account').click()"); time.sleep(2)
    check("form shows 3 password fields", js("document.querySelectorAll('input[type=password]').length") == 3)

    setv(0, "wrong-" + old); setv(1, new); setv(2, new)
    m = submit_and_wait(); check("wrong current password refused", "wrong" in m.lower(), m)
    setv(0, old); setv(1, "Short@2025"[:8]); setv(2, "Short@2025"[:8])
    m = submit_and_wait(); check("8-character password refused", "10 characters" in m, m)
    setv(0, old); setv(1, new); setv(2, new + "x")
    m = submit_and_wait(); check("mismatch refused", "match" in m, m)
    setv(0, old); setv(1, new); setv(2, new)
    m = submit_and_wait(); check("valid change accepted", "changed" in m.lower(), m)

    chk_new = rest("POST", "/auth/v1/token?grant_type=password", {"email": email, "password": new}, key=ANON)
    chk_old = rest("POST", "/auth/v1/token?grant_type=password", {"email": email, "password": old}, key=ANON)
    check("new password signs in", bool(chk_new.get("access_token")))
    check("old password no longer works", not chk_old.get("access_token"))
finally:
    ws.close(); proc.terminate()
    rest("DELETE", f"/auth/v1/admin/users/{uid}")
    print("cleanup:", "clean" if rest("GET", f"/rest/v1/profiles?id=eq.{uid}&select=id") == [] else "LEFTOVER")
print(f"{sum(res)}/{len(res)} passed")
sys.exit(0 if all(res) else 1)
