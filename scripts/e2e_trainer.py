#!/usr/bin/env python3
"""Live UI test of trainer accounts on production.

Admin creates a trainer in Admin Panel -> Trainers, picks 2 lessons of F07,
saves. Trainer signs in with the issued password, sees "My Lessons" with only
F07 and only those 2 lessons, no create/delete/publish/quiz controls, edits a
lesson title (restored after). Throwaway accounts, cleaned up.
"""
import json, os, secrets, subprocess, sys, time

CHROME = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
BASE = "https://finix-academy.vercel.app"
OUT = os.path.join(os.environ.get("TMPDIR", "."), "e2e_trainer")
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
        pf = os.path.join(OUT, "_b.json"); json.dump(body, open(pf, "w", encoding="utf-8")); cmd += ["-H", "Content-Type: application/json", "--data-binary", f"@{pf}"]
    r = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8").stdout
    try: return json.loads(r) if r else None
    except Exception: return r


res = []
def check(n, ok, d=""):
    res.append(bool(ok)); print(("PASS " if ok else "FAIL ") + n + (f"  [{d}]" if d else ""))


import websocket
class B:
    def __init__(s, port):
        s.p = subprocess.Popen([CHROME, f"--remote-debugging-port={port}", "--remote-allow-origins=*", "--headless=new", "--disable-gpu",
                                "--window-size=1280,1500", f"--user-data-dir={OUT}/p{port}_{secrets.token_hex(2)}", "about:blank"],
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL); time.sleep(4)
        tabs = json.loads(subprocess.run(["curl", "-s", f"http://127.0.0.1:{port}/json"], capture_output=True, text=True).stdout)
        s.ws = websocket.create_connection([t for t in tabs if t["type"] == "page"][0]["webSocketDebuggerUrl"], suppress_origin=True, timeout=90)
        s.n = 0; s.cmd("Page.enable"); s.cmd("Runtime.enable")
    def cmd(s, m, **p):
        s.n += 1; s.ws.send(json.dumps({"id": s.n, "method": m, "params": p}))
        while True:
            x = json.loads(s.ws.recv())
            if x.get("id") == s.n: return x.get("result", {})
    def js(s, e): return s.cmd("Runtime.evaluate", expression=e, returnByValue=True, awaitPromise=True).get("result", {}).get("value")
    def go(s, path, w=9): s.cmd("Page.navigate", url=BASE + path); time.sleep(w)
    def wait(s, e, t=30):
        end = time.time() + t
        while time.time() < end:
            v = s.js(e)
            if v: return v
            time.sleep(1)
    def shot(s, name):
        import base64; d = s.cmd("Page.captureScreenshot", format="png"); open(os.path.join(OUT, name), "wb").write(base64.b64decode(d["data"]))
    def setv(s, sel, v, idx=0):
        return s.js(f"""(() => {{ const el=document.querySelectorAll({json.dumps(sel)})[{idx}]; if(!el) return false;
          const proto = el.tagName==='TEXTAREA'?HTMLTextAreaElement.prototype:HTMLInputElement.prototype;
          Object.getOwnPropertyDescriptor(proto,'value').set.call(el,{json.dumps(v)});
          el.dispatchEvent(new Event('input',{{bubbles:true}})); return true; }})()""")
    def close(s):
        try: s.ws.close()
        except Exception: pass
        s.p.terminate()


subprocess.run(["cmd.exe", "/c", "taskkill", "/F", "/IM", "chrome.exe"], capture_output=True); time.sleep(1)
created, bs = [], []
temail = f"e2e-trainer-{secrets.token_hex(3)}@finix-test.local"
f07 = rest("GET", "/rest/v1/modules?code=eq.F07&select=id,slug")[0]
lessons = rest("GET", f"/rest/v1/lessons?module_id=eq.{f07['id']}&select=id,title&order=position")
pick = lessons[:2]
orig_title = pick[0]["title"]
try:
    aemail = f"e2e-admin-{secrets.token_hex(3)}@finix-test.local"; apw = secrets.token_urlsafe(16)
    aid = rest("POST", "/auth/v1/admin/users", {"email": aemail, "password": apw, "email_confirm": True})["id"]; created.append(aid)
    rest("POST", "/rest/v1/profiles", {"id": aid, "email": aemail, "full_name": "E2E Admin"})
    rest("POST", "/rest/v1/user_roles", {"user_id": aid, "role": "admin"})
    tok = rest("POST", "/auth/v1/token?grant_type=password", {"email": aemail, "password": apw}, key=ANON)

    A = B(9361); bs.append(A)
    A.go("/", 4)
    A.js(f"localStorage.setItem({json.dumps(SESS_KEY)}, {json.dumps(json.dumps({'access_token': tok['access_token'], 'refresh_token': tok['refresh_token'], 'expires_at': int(time.time()) + 3600, 'expires_in': 3600, 'token_type': 'bearer', 'user': tok['user']}))}); localStorage.setItem('lang','en'); 1")
    A.go("/dashboard/admin-panel", 10)
    A.js("window.confirm=()=>true;1")
    check("Trainers tab exists", A.js("!![...document.querySelectorAll('button')].find(b=>b.innerText.trim()==='Trainers')"))
    A.js("[...document.querySelectorAll('button')].find(b=>b.innerText.trim()==='Trainers').click()"); time.sleep(3)
    A.setv("form input", "E2E Trainer", 0); A.setv("form input", temail, 1)
    A.js("[...document.querySelectorAll('form button[type=submit]')].find(b=>b.innerText.includes('Create trainer')).click()")
    pw = A.wait("(document.querySelector('[data-k=trainer-password]')||{}).innerText", 30)
    check("trainer created, password shown once", bool(pw) and len(pw) == 14)
    tid = (rest("GET", f"/rest/v1/profiles?email=eq.{temail}&select=id") or [{}])[0].get("id")
    if tid: created.append(tid)
    # pick 2 lessons of F07
    ready = A.wait("document.querySelectorAll('input[type=checkbox][aria-label]').length >= 20", 30)
    print("   picker rendered:", bool(ready), A.js("document.querySelectorAll('input[type=checkbox]').length"))
    print("   checkbox labels:", A.js("[...document.querySelectorAll('input[type=checkbox]')].slice(0,4).map(c=>c.getAttribute('aria-label')+'/'+c.outerHTML.slice(0,90)).join(' || ')"))
    diag = A.js("""(() => { const cb=document.querySelector('input[aria-label="F07"]'); if(!cb) return 'no F07 checkbox';
        const btn=cb.parentElement.querySelector('button'); if(!btn) return 'no expand button'; btn.click(); return 'clicked'; })()""")
    found = A.wait(f"!!document.querySelector('input[data-lesson=\"{pick[0]['id']}\"]')", 10)
    print("   expand:", diag, "| lesson checkbox present:", bool(found))
    for l in pick:
        A.js(f"document.querySelector('input[data-lesson=\"{l['id']}\"]').click()")
        time.sleep(0.5)
    print("   selected count text:", A.js("(document.querySelector('.sticky')||{}).innerText"))
    A.js("document.querySelector('[data-testid=save-lessons]').click()")
    saved = A.wait("document.body.innerText.includes('2 lessons assigned')", 25)
    A.shot("1_admin_trainer_lessons.png")
    check("admin saved 2 lessons for trainer", bool(saved))
    db = rest("GET", f"/rest/v1/trainer_assignments?trainer_id=eq.{tid}&select=lesson_id")
    check("assignments stored", {r["lesson_id"] for r in db} == {l["id"] for l in pick}, str(len(db)))

    # ---- trainer signs in with issued password
    T = B(9362); bs.append(T)
    T.go("/", 4); T.js("localStorage.setItem('lang','en');1")
    T.go("/auth", 8)
    T.js("[...document.querySelectorAll('button')].find(b=>b.innerText.includes('Email & password')).click()"); time.sleep(1)
    T.setv("input[type=email]", temail); T.setv("input[type=password]", pw)
    T.js("document.querySelector('form button[type=submit]').click()")
    p = T.wait("location.pathname.startsWith('/dashboard') && location.pathname", 30)
    check("trainer signs in", bool(p), str(p))
    T.go("/dashboard/authoring", 10)
    txt = T.js("document.body.innerText") or ""
    T.shot("2_trainer_my_lessons.png")
    check("trainer sees 'My Lessons'", "My Lessons" in txt)
    rows = T.js("[...document.querySelectorAll('a[href^=\"/dashboard/authoring/\"]')].length")
    check("only 1 module listed (F07)", rows == 1 and "F07" in txt, f"{rows} modules")
    check("no '+ New Module' / Publish controls", "+ New Module" not in txt and "Unpublish" not in txt and "Publish" not in txt.replace("Published", ""))
    T.go(f"/dashboard/authoring/{f07['id']}", 10)
    txt = T.js("document.body.innerText") or ""
    T.shot("3_trainer_module_editor.png")
    n_cards = T.js("document.querySelectorAll('textarea').length")
    check("editor shows exactly the 2 assigned lessons", n_cards == 4, f"{n_cards} textareas (2 per lesson)")
    check("no delete/add lesson, no quiz editor, no module details",
          "Delete lesson" not in txt and "Add Lesson" not in txt and "Quiz Questions" not in txt and "Module Details" not in txt)
    # edit a title (blur saves)
    T.js(f"""(() => {{ const el=[...document.querySelectorAll('input')].find(i=>i.value==={json.dumps(orig_title)});
        Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,'value').set.call(el,{json.dumps(orig_title + ' [e2e]')});
        el.dispatchEvent(new Event('input',{{bubbles:true}})); el.focus(); el.blur(); el.dispatchEvent(new FocusEvent('focusout',{{bubbles:true}})); }})()""")
    time.sleep(4)
    now = rest("GET", f"/rest/v1/lessons?id=eq.{pick[0]['id']}&select=title")[0]["title"]
    check("trainer edit saved to database", now == orig_title + " [e2e]", now)
    # direct URL to another module shows nothing editable
    i01 = rest("GET", "/rest/v1/modules?code=eq.I01&select=id")[0]
    T.go(f"/dashboard/authoring/{i01['id']}", 9)
    check("other module: no lessons for trainer", T.js("document.querySelectorAll('textarea').length") == 0)
    # trainer panel tabs
    T.go("/dashboard/admin-panel", 9)
    tabs = T.js("[...document.querySelectorAll('button')].map(b=>b.innerText.trim()).join('|')") or ""
    check("trainer panel hides admin-only tabs", "Trainers" not in tabs.split("|") and "Payment requests" not in tabs and "Module access" in tabs, tabs[:120])
finally:
    for b in bs: b.close()
    rest("PATCH", f"/rest/v1/lessons?id=eq.{pick[0]['id']}", {"title": orig_title})
    restored = rest("GET", f"/rest/v1/lessons?id=eq.{pick[0]['id']}&select=title")[0]["title"] == orig_title
    for u in created: rest("DELETE", f"/auth/v1/admin/users/{u}")
    print("cleanup:", "clean" if restored and rest("GET", "/rest/v1/profiles?email=like.e2e-*@finix-test.local&select=id") == [] else "CHECK")
print(f"{sum(res)}/{len(res)} passed · screenshots: {OUT}")
sys.exit(0 if all(res) else 1)
