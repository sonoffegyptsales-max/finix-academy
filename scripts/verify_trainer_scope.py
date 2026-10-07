"""Prove trainer scoping at the API level (no UI): a trainer assigned 2 lessons
can read/edit exactly those, and nothing else. Throwaway users, cleaned up."""
import json, secrets, subprocess, sys

E = {}
for l in open(".env", encoding="utf-8"):
    l = l.strip()
    if l and not l.startswith("#") and "=" in l:
        k, v = l.split("=", 1); E[k.strip()] = v.strip()
URL = E["VITE_SUPABASE_URL"].rstrip("/"); SRK = E["SUPABASE_SERVICE_ROLE_KEY"]; ANON = E["VITE_SUPABASE_PUBLISHABLE_KEY"]
SA = ["-H", f"Authorization: Bearer {SRK}", "-H", f"apikey: {SRK}"]


def curl(args, data=None, method=None, prefer=None):
    cmd = ["curl", "-s"] + (["-X", method] if method else []) + args
    if prefer: cmd += ["-H", f"Prefer: {prefer}"]
    if data is not None: cmd += ["-H", "Content-Type: application/json", "-d", json.dumps(data)]
    r = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8").stdout
    try: return json.loads(r) if r else None
    except Exception: return r


problems, created = [], []
def check(name, ok, detail=""):
    print(("PASS " if ok else "FAIL ") + name + (f"  [{detail}]" if detail else ""))
    if not ok: problems.append(name)


try:
    email = f"trainer-probe-{secrets.token_hex(3)}@finix-test.local"; pw = secrets.token_urlsafe(16)
    uid = curl(["-X", "POST", f"{URL}/auth/v1/admin/users"] + SA, {"email": email, "password": pw, "email_confirm": True})["id"]
    created.append(uid)
    curl([f"{URL}/rest/v1/user_roles"] + SA, {"user_id": uid, "role": "trainer"}, "POST")
    tok = curl(["-X", "POST", f"{URL}/auth/v1/token?grant_type=password", "-H", f"apikey: {ANON}"], {"email": email, "password": pw})["access_token"]
    TA = ["-H", f"Authorization: Bearer {tok}", "-H", f"apikey: {ANON}"]

    mod = curl([f"{URL}/rest/v1/modules?code=eq.F07&select=id"] + SA)[0]
    other = curl([f"{URL}/rest/v1/modules?code=eq.I01&select=id"] + SA)[0]
    f07 = curl([f"{URL}/rest/v1/lessons?module_id=eq.{mod['id']}&select=id,title,position&order=position"] + SA)
    mine, notmine = f07[:2], f07[2]
    i01_lesson = curl([f"{URL}/rest/v1/lessons?module_id=eq.{other['id']}&select=id,title&limit=1"] + SA)[0]

    # --- before any assignment: sees nothing
    n = len(curl([f"{URL}/rest/v1/lessons?select=id"] + TA))
    check("unassigned trainer reads 0 lessons", n == 0, str(n))

    for l in mine:
        curl([f"{URL}/rest/v1/trainer_assignments"] + SA, {"trainer_id": uid, "lesson_id": l["id"]}, "POST")

    vis = {l["id"] for l in curl([f"{URL}/rest/v1/lessons?select=id"] + TA)}
    check("trainer reads exactly the 2 assigned lessons", vis == {l["id"] for l in mine}, f"{len(vis)} visible")
    check("other lesson in same module hidden", notmine["id"] not in vis)
    mods = curl([f"{URL}/rest/v1/modules?select=id"] + TA)
    check("module card of assigned module visible", any(m["id"] == mod["id"] for m in mods))

    # --- edit own lesson text
    orig = mine[0]["title"]
    r = curl([f"{URL}/rest/v1/lessons?id=eq.{mine[0]['id']}"] + TA, {"title": orig + " (trainer edit)"}, "PATCH", "return=representation")
    check("trainer edits assigned lesson", isinstance(r, list) and len(r) == 1, json.dumps(r)[:80])
    curl([f"{URL}/rest/v1/lessons?id=eq.{mine[0]['id']}"] + SA, {"title": orig}, "PATCH")

    # --- cannot move own lesson
    r = curl([f"{URL}/rest/v1/lessons?id=eq.{mine[0]['id']}"] + TA, {"position": 99}, "PATCH", "return=representation")
    check("trainer cannot reorder/move a lesson", isinstance(r, dict) and "cannot move" in json.dumps(r).lower(), json.dumps(r)[:80])

    # --- cannot edit non-assigned lessons (RLS: 0 rows updated)
    for label, lid in (("same-module unassigned", notmine["id"]), ("other-module", i01_lesson["id"])):
        r = curl([f"{URL}/rest/v1/lessons?id=eq.{lid}"] + TA, {"title": "HACKED"}, "PATCH", "return=representation")
        check(f"trainer cannot edit {label} lesson", r == [] or (isinstance(r, dict) and "code" in r), json.dumps(r)[:60])
    still = curl([f"{URL}/rest/v1/lessons?id=in.({notmine['id']},{i01_lesson['id']})&select=title"] + SA)
    check("untouched lessons unchanged", all(x["title"] != "HACKED" for x in still))

    # --- structure: cannot create/delete lessons, modules, tracks; cannot publish
    r = curl([f"{URL}/rest/v1/lessons"] + TA, {"module_id": mod["id"], "title": "x", "title_ar": "x", "position": 50}, "POST", "return=representation")
    check("trainer cannot create lessons", isinstance(r, dict) and r.get("code") == "42501", json.dumps(r)[:60])
    r = curl([f"{URL}/rest/v1/lessons?id=eq.{mine[1]['id']}"] + TA, method="DELETE", prefer="return=representation")
    check("trainer cannot delete even an assigned lesson", r == [], json.dumps(r)[:60])
    r = curl([f"{URL}/rest/v1/modules?id=eq.{mod['id']}"] + TA, {"published": False}, "PATCH", "return=representation")
    check("trainer cannot unpublish modules", r == [], json.dumps(r)[:60])
    r = curl([f"{URL}/rest/v1/tracks?id=eq.finix-technician"] + TA, {"name": "HACKED"}, "PATCH", "return=representation")
    check("trainer cannot edit tracks", r == [] or isinstance(r, dict), json.dumps(r)[:60])

    # --- quizzes: can read keys of their module, cannot change them
    q = curl([f"{URL}/rest/v1/quizzes?module_id=eq.{mod['id']}&tier=eq.bronze&select=id"] + SA)[0]
    opt = curl([f"{URL}/rest/v1/quiz_options?select=id,is_correct,quiz_questions!inner(quiz_id)&quiz_questions.quiz_id=eq.{q['id']}&limit=1"] + SA)[0]
    r = curl([f"{URL}/rest/v1/quiz_options?id=eq.{opt['id']}&select=id,is_correct"] + TA)
    check("trainer can read answer key of own module", isinstance(r, list) and len(r) == 1)
    r = curl([f"{URL}/rest/v1/quiz_options?id=eq.{opt['id']}"] + TA, {"is_correct": not opt["is_correct"]}, "PATCH", "return=representation")
    check("trainer cannot change answer key", r == [], json.dumps(r)[:60])
    other_opts = curl([f"{URL}/rest/v1/quiz_options?select=id,quiz_questions!inner(quizzes!inner(module_id))&quiz_questions.quizzes.module_id=eq.{other['id']}&limit=1"] + TA)
    check("trainer cannot read other modules' answer keys", other_opts == [], json.dumps(other_opts)[:60])

    # --- media: may upload to own lesson folder, not others
    def put(path):
        return subprocess.run(["curl", "-s", "-o", "/dev/null", "-w", "%{http_code}", "-X", "POST",
                               f"{URL}/storage/v1/object/lesson-media/{path}", *TA, "-H", "Content-Type: image/png",
                               "--data-binary", "probe"], capture_output=True, text=True).stdout
    own = f"{mine[0]['id']}/probe-{secrets.token_hex(3)}.png"
    alien = f"{i01_lesson['id']}/probe-{secrets.token_hex(3)}.png"
    c1, c2 = put(own), put(alien)
    check("trainer uploads media to assigned lesson", c1 == "200", c1)
    check("trainer cannot upload to other lessons", c2 in ("400", "403"), c2)
    curl([f"{URL}/storage/v1/object/lesson-media"] + SA, {"prefixes": [own, alien]}, "DELETE")

    # --- unassign -> access gone
    curl([f"{URL}/rest/v1/trainer_assignments?trainer_id=eq.{uid}"] + SA, method="DELETE")
    n = len(curl([f"{URL}/rest/v1/lessons?select=id"] + TA))
    check("removing assignments removes access", n == 0, str(n))
finally:
    for u in created:
        curl([f"{URL}/auth/v1/admin/users/{u}"] + SA, method="DELETE")
    print("probe users deleted")

print("\nRESULT:", "PASS" if not problems else f"FAIL ({len(problems)})")
sys.exit(1 if problems else 0)
