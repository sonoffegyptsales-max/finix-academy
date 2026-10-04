"""Focused probe: does access-code sign-in work on production?
Creates a trainee + code via service role, drives /auth in code mode,
prints the on-page error / network failures, then cleans up."""
import base64, json, os, secrets, subprocess, sys, time
sys.path.insert(0, os.path.dirname(__file__))

CHROME = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
PORT = 9335
BASE = "https://finix-academy.vercel.app"
OUT = os.path.join(os.environ.get("TMPDIR", "."), "e2e_enroll")
E = {}
for l in open(".env", encoding="utf-8"):
    l = l.strip()
    if l and not l.startswith("#") and "=" in l:
        k, v = l.split("=", 1); E[k.strip()] = v.strip()
SB = E["VITE_SUPABASE_URL"].rstrip("/"); SRK = E["SUPABASE_SERVICE_ROLE_KEY"]


def rest(method, path, body=None):
    cmd = ["curl", "-s", "-X", method, SB + path, "-H", f"Authorization: Bearer {SRK}", "-H", f"apikey: {SRK}"]
    if body is not None:
        cmd += ["-H", "Content-Type: application/json", "-d", json.dumps(body)]
    r = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8").stdout
    try: return json.loads(r) if r else None
    except Exception: return r


email = f"code-probe-{secrets.token_hex(3)}@finix-test.local"
u = rest("POST", "/auth/v1/admin/users", {"email": email, "password": secrets.token_urlsafe(16), "email_confirm": True})
uid = u["id"]
rest("POST", "/rest/v1/profiles", {"id": uid, "email": email, "full_name": "Code Probe"})
rest("POST", "/rest/v1/user_roles", {"user_id": uid, "role": "trainee"})
code = "PRB" + secrets.token_hex(1).upper() + "-" + secrets.token_hex(2).upper()
print("code insert:", rest("POST", "/rest/v1/access_codes", {"code": code, "user_id": uid}))

subprocess.run(["cmd.exe", "/c", "taskkill", "/F", "/IM", "chrome.exe"], capture_output=True); time.sleep(1)
proc = subprocess.Popen([CHROME, f"--remote-debugging-port={PORT}", "--remote-allow-origins=*", "--headless=new",
                         "--disable-gpu", "--window-size=1280,1000", f"--user-data-dir={OUT}/prof2", "about:blank"],
                        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
time.sleep(4)
import websocket
tabs = json.loads(subprocess.run(["curl", "-s", f"http://127.0.0.1:{PORT}/json"], capture_output=True, text=True).stdout)
ws = websocket.create_connection([t for t in tabs if t["type"] == "page"][0]["webSocketDebuggerUrl"], suppress_origin=True, timeout=60)
n = [0]; events = []


def cmd(m, **p):
    n[0] += 1; ws.send(json.dumps({"id": n[0], "method": m, "params": p}))
    while True:
        x = json.loads(ws.recv())
        if x.get("id") == n[0]: return x.get("result", {})
        if x.get("method") in ("Network.responseReceived",):
            r = x["params"]["response"]
            if "_serverFn" in r["url"] or "/auth/v1/" in r["url"] or r["status"] >= 400:
                events.append(f'{r["status"]} {r["url"][:110]}')
        if x.get("method") == "Runtime.consoleAPICalled":
            events.append("console: " + " ".join(str(a.get("value", a.get("description", "")))[:150] for a in x["params"]["args"]))


def js(e): return cmd("Runtime.evaluate", expression=e, returnByValue=True, awaitPromise=True).get("result", {}).get("value")


try:
    cmd("Page.enable"); cmd("Runtime.enable"); cmd("Network.enable")
    cmd("Page.navigate", url=BASE + "/auth"); time.sleep(8)
    print("code input present:", js("!!document.querySelector('input[autocomplete=\"one-time-code\"]')"))
    js(f"""(() => {{ const el=document.querySelector('input[autocomplete="one-time-code"]');
      Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,'value').set.call(el,{json.dumps(code)});
      el.dispatchEvent(new Event('input',{{bubbles:true}})); }})()""")
    time.sleep(0.5)
    print("input value now:", js("document.querySelector('input[autocomplete=\"one-time-code\"]').value"))
    js("document.querySelector('form button[type=submit]').click()")
    for _ in range(20):
        time.sleep(1)
        js("1")  # pump events
        if js("location.pathname") != "/auth": break
    print("path after submit:", js("location.pathname"))
    print("on-page error:", js("(document.querySelector('.text-destructive')||{}).innerText||null"))
    d = cmd("Page.captureScreenshot", format="png")
    open(os.path.join(OUT, "probe_code.png"), "wb").write(base64.b64decode(d["data"]))
    print("events:"); [print("  ", e) for e in events[-15:]]
finally:
    ws.close(); proc.terminate()
    rest("DELETE", f"/auth/v1/admin/users/{uid}")
    print("cleanup done")
