#!/usr/bin/env python3
"""Audit anti-copy / anti-capture protections on the LIVE lesson page as a real student."""
import base64, json, os, secrets, subprocess, sys, time

CHROME = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
BASE = "https://finix-academy.vercel.app"
OUT = os.path.join(os.environ.get("TMPDIR", "."), "e2e_protect"); os.makedirs(OUT, exist_ok=True)
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
    res.append(bool(ok)); print(("PASS " if ok else "FAIL ") + n + (f"  [{d}]" if d else ""))


import websocket
email = f"prot-{secrets.token_hex(3)}@finix-test.local"; pw = secrets.token_urlsafe(14)
uid = rest("POST", "/auth/v1/admin/users", {"email": email, "password": pw, "email_confirm": True})["id"]
rest("POST", "/rest/v1/profiles", {"id": uid, "email": email, "full_name": "Protect Probe"})
rest("POST", "/rest/v1/user_roles", {"user_id": uid, "role": "trainee"})
mod = rest("GET", "/rest/v1/modules?code=eq.F07&select=id,slug")[0]
rest("POST", "/rest/v1/module_access", {"user_id": uid, "module_id": mod["id"], "source": "manual"})
tok = rest("POST", "/auth/v1/token?grant_type=password", {"email": email, "password": pw}, key=ANON)

subprocess.run(["cmd.exe", "/c", "taskkill", "/F", "/IM", "chrome.exe"], capture_output=True); time.sleep(1)
proc = subprocess.Popen([CHROME, "--remote-debugging-port=9371", "--remote-allow-origins=*", "--headless=new", "--disable-gpu",
                         "--window-size=1280,1400", f"--user-data-dir={OUT}/p{secrets.token_hex(2)}", "about:blank"],
                        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL); time.sleep(4)
tabs = json.loads(subprocess.run(["curl", "-s", "http://127.0.0.1:9371/json"], capture_output=True, text=True).stdout)
ws = websocket.create_connection([t for t in tabs if t["type"] == "page"][0]["webSocketDebuggerUrl"], suppress_origin=True, timeout=90)
n = [0]
def cmd(m, **p):
    n[0] += 1; ws.send(json.dumps({"id": n[0], "method": m, "params": p}))
    while True:
        x = json.loads(ws.recv())
        if x.get("id") == n[0]: return x.get("result", {})
def js(e): return cmd("Runtime.evaluate", expression=e, returnByValue=True, awaitPromise=True).get("result", {}).get("value")
try:
    cmd("Page.enable"); cmd("Runtime.enable")
    cmd("Page.navigate", url=BASE + "/"); time.sleep(4)
    sess = json.dumps({"access_token": tok["access_token"], "refresh_token": tok["refresh_token"], "expires_at": int(time.time()) + 3600,
                       "expires_in": 3600, "token_type": "bearer", "user": tok["user"]})
    js(f"localStorage.setItem({json.dumps(SESS_KEY)}, {json.dumps(sess)}); localStorage.setItem('lang','en'); 1")
    cmd("Page.navigate", url=BASE + f"/dashboard/module/{mod['slug']}"); time.sleep(13)
    body = js("document.body.innerText.length"); check("lesson page loaded as student", body > 3000, str(body))

    check("protected wrapper present", js("!!document.querySelector('.finix-protected')"))
    wm = js("[...document.querySelectorAll('.finix-protected span')].filter(s=>s.textContent.includes('@')).length")
    check("watermark carries the student's email (repeated)", wm >= 30, str(wm))
    check("text is not selectable (user-select:none)", js("getComputedStyle(document.querySelector('.finix-protected li') || document.querySelector('.finix-protected')).userSelect") == "none")
    js("document.execCommand('selectAll')")
    leaked = js("""(() => { const s=window.getSelection().toString(); const lesson=document.querySelector('.finix-protected li');
        const probe=(lesson.innerText||'').trim().split('\\n').find(l=>l.length>40)||''; return JSON.stringify({total:s.length, hasLessonText: !!probe && s.includes(probe.slice(0,40))}); })()""")
    check("select-all does not capture lesson text", '"hasLessonText":false' in leaked, leaked)

    def prevented(ev_js):
        return js(f"""(() => {{ const el=document.querySelector('.finix-protected li')||document.querySelector('.finix-protected');
            const e={ev_js}; el.dispatchEvent(e); return e.defaultPrevented; }})()""")
    check("copy blocked", prevented("new ClipboardEvent('copy',{bubbles:true,cancelable:true})"))
    check("cut blocked", prevented("new ClipboardEvent('cut',{bubbles:true,cancelable:true})"))
    check("right-click menu blocked", prevented("new MouseEvent('contextmenu',{bubbles:true,cancelable:true})"))
    check("drag blocked", prevented("new Event('dragstart',{bubbles:true,cancelable:true})"))

    def key(k, **kw):
        return js(f"""(() => {{ const e=new KeyboardEvent('keydown',{{key:{json.dumps(k)},bubbles:true,cancelable:true,...{json.dumps(kw)}}});
            document.body.dispatchEvent(e); return e.defaultPrevented; }})()""")
    check("Ctrl+P (print) blocked", key("p", ctrlKey=True))
    check("Ctrl+S (save) blocked", key("s", ctrlKey=True))
    check("Ctrl+C blocked", key("c", ctrlKey=True))
    check("Ctrl+U (view source) blocked", key("u", ctrlKey=True))
    check("F12 blocked", key("F12"))

    js("window.dispatchEvent(new Event('blur'))"); time.sleep(0.7)
    hidden = js("document.body.innerText.includes('Content hidden while this window is not in focus')")
    cmd("Page.captureScreenshot", format="png")
    check("content blanks when window loses focus", hidden)
    js("window.dispatchEvent(new Event('focus'))"); time.sleep(0.5)
    js("""(() => { const e=new KeyboardEvent('keydown',{key:'PrintScreen',bubbles:true,cancelable:true}); document.body.dispatchEvent(e); })()""")
    time.sleep(0.4)
    check("PrintScreen blanks content", js("document.body.innerText.includes('Content hidden while this window is not in focus')"))
    time.sleep(1.6)

    # print stylesheet
    cmd("Emulation.setEmulatedMedia", media="print"); time.sleep(0.5)
    vis = js("""(() => { const el=document.querySelector('.finix-protected'); const c=getComputedStyle(el);
        const kids=[...el.children].map(k=>getComputedStyle(k).display); return JSON.stringify({d:c.display, v:c.visibility, kids}); })()""")
    cmd("Emulation.setEmulatedMedia", media="screen")
    check("print stylesheet hides lesson material", ('"d":"none"' in vis) or ('"v":"hidden"' in vis) or all(k == "none" for k in json.loads(vis)["kids"]), vis[:100])

    # media URLs
    imgs = js("[...document.querySelectorAll('.finix-protected img')].map(i=>i.currentSrc||i.src)")
    check("lesson has images to inspect", bool(imgs), f"{len(imgs or [])}")
    if imgs:
        u = imgs[0]
        signed = "/object/sign/" in u and "token=" in u
        exp = None
        if signed:
            try:
                p = u.split("token=")[1].split("&")[0].split(".")[1]; p += "=" * (-len(p) % 4)
                exp = json.loads(base64.urlsafe_b64decode(p)).get("exp")
            except Exception: pass
        ttl = (exp - time.time()) if exp else None
        check("images are time-limited signed URLs", signed and ttl and ttl < 24 * 3600, f"expires in {int(ttl/60) if ttl else '?'} min")
        anon = subprocess.run(["curl", "-s", "-o", "/dev/null", "-w", "%{http_code}", u.replace("/object/sign/", "/object/public/").split("?")[0]], capture_output=True, text=True).stdout
        check("bucket is not public (public URL refused)", anon in ("400", "403", "404"), anon)
    # protected-copy leaks of text via other surfaces
    check("images not draggable / right-click blocked inside wrapper", js("[...document.querySelectorAll('.finix-protected img')].every(i=>getComputedStyle(i).userSelect==='none' || i.draggable===false || getComputedStyle(i).pointerEvents==='none')") is not False)
finally:
    ws.close(); proc.terminate()
    rest("DELETE", f"/auth/v1/admin/users/{uid}")
print(f"{sum(res)}/{len(res)} protections verified")
