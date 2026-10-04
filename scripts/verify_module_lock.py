"""Prove per-module locking at the API level for a fresh trainee.

Creates a throwaway trainee with a bound device and NO module_access rows,
reads every protected surface, grants one module, reads again, then cleans up.
"""
import json
import subprocess
import sys
import uuid


def env():
    out = {}
    for line in open(".env", encoding="utf-8"):
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            k, v = line.split("=", 1)
            out[k.strip()] = v.strip()
    return out


E = env()
URL = E["VITE_SUPABASE_URL"].rstrip("/")
SRK = E["SUPABASE_SERVICE_ROLE_KEY"]
ANON = E["VITE_SUPABASE_PUBLISHABLE_KEY"]
SA = ["-H", f"Authorization: Bearer {SRK}", "-H", f"apikey: {SRK}"]


def curl(args, data=None):
    cmd = ["curl", "-s"] + args
    if data is not None:
        cmd += ["-H", "Content-Type: application/json", "-d", json.dumps(data)]
    r = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8").stdout
    try:
        return json.loads(r)
    except Exception:
        return r


email = f"lock-probe-{uuid.uuid4().hex[:8]}@finix-test.local"
pw = uuid.uuid4().hex
device = "probe-" + uuid.uuid4().hex
u = curl(["-X", "POST", f"{URL}/auth/v1/admin/users"] + SA,
         {"email": email, "password": pw, "email_confirm": True})
uid = u["id"]
problems = []
try:
    curl(["-X", "POST", f"{URL}/rest/v1/user_roles"] + SA, {"user_id": uid, "role": "trainee"})
    curl(["-X", "POST", f"{URL}/rest/v1/trainee_devices"] + SA,
         {"user_id": uid, "device_id": device, "device_label": "probe"})
    tok = curl(["-X", "POST", f"{URL}/auth/v1/token?grant_type=password", "-H", f"apikey: {ANON}"],
               {"email": email, "password": pw})["access_token"]
    TA = ["-H", f"Authorization: Bearer {tok}", "-H", f"apikey: {ANON}", "-H", f"x-device-id: {device}"]

    mod = curl([f"{URL}/rest/v1/modules?code=eq.F07&select=id,code"] + SA)[0]
    other = curl([f"{URL}/rest/v1/modules?code=eq.I01&select=id"] + SA)[0]
    quiz = curl([f"{URL}/rest/v1/quizzes?module_id=eq.{mod['id']}&tier=eq.bronze&select=id"] + SA)[0]
    media = curl([f"{URL}/rest/v1/lesson_media?select=storage_path,lessons!inner(module_id)"
                  f"&lessons.module_id=eq.{mod['id']}&storage_path=not.like.http*&limit=1"] + SA)
    obj = media[0]["storage_path"] if media else None

    def surfaces(label):
        out = {}
        out["lessons(all)"] = len(curl([f"{URL}/rest/v1/lessons?select=id"] + TA))
        out["lessons(F07)"] = len(curl([f"{URL}/rest/v1/lessons?module_id=eq.{mod['id']}&select=id"] + TA))
        out["lessons(I01)"] = len(curl([f"{URL}/rest/v1/lessons?module_id=eq.{other['id']}&select=id"] + TA))
        out["lesson_media"] = len(curl([f"{URL}/rest/v1/lesson_media?select=id"] + TA))
        out["quiz_questions"] = len(curl([f"{URL}/rest/v1/quiz_questions?select=id"] + TA))
        out["quiz_options_public"] = len(curl([f"{URL}/rest/v1/quiz_options_public?select=id"] + TA))
        out["modules(cards)"] = len(curl([f"{URL}/rest/v1/modules?select=id"] + TA))
        if obj:
            code = subprocess.run(["curl", "-s", "-o", "/dev/null", "-w", "%{http_code}",
                                   f"{URL}/storage/v1/object/authenticated/lesson-media/{obj}"] + TA,
                                  capture_output=True, text=True).stdout
            out["storage object"] = code
        sub = curl(["-X", "POST", f"{URL}/rest/v1/rpc/submit_quiz_attempt"] + TA,
                   {"_quiz_id": quiz["id"], "_answers": []})
        out["grade F07 quiz"] = "REFUSED" if isinstance(sub, dict) and "locked" in json.dumps(sub).lower() else "ran"
        print(f"\n{label}")
        for k, v in out.items():
            print(f"  {k:22} {v}")
        return out

    before = surfaces("BEFORE any grant (fresh trainee)")
    for k in ("lessons(all)", "lesson_media", "quiz_questions", "quiz_options_public"):
        if before[k] != 0:
            problems.append(f"locked trainee can read {k}: {before[k]}")
    if before.get("storage object") == "200":
        problems.append("locked trainee can download a lesson file")
    if before["grade F07 quiz"] != "REFUSED":
        problems.append("grader accepted a locked quiz")
    if before["modules(cards)"] != 22:
        problems.append("module cards should stay visible (locked) so trainees can request access")

    curl(["-X", "POST", f"{URL}/rest/v1/module_access"] + SA,
         {"user_id": uid, "module_id": mod["id"], "source": "manual"})
    after = surfaces("AFTER granting F07 only")
    if after["lessons(F07)"] == 0:
        problems.append("granted module still locked")
    if after["lessons(I01)"] != 0:
        problems.append("grant leaked to another module")
    if after["lessons(all)"] != after["lessons(F07)"]:
        problems.append("trainee sees lessons outside the granted module")
    if obj and after.get("storage object") != "200":
        problems.append("granted trainee cannot download the module's file")
    if after["grade F07 quiz"] == "REFUSED":
        problems.append("grader refuses a granted module")

    # Self-grant attempt must fail.
    sg = curl(["-X", "POST", f"{URL}/rest/v1/module_access"] + TA,
              {"user_id": uid, "module_id": other["id"]})
    print("\n  self-grant attempt   ", json.dumps(sg)[:90])
    if isinstance(sg, list) or (isinstance(sg, dict) and "code" not in sg):
        problems.append("trainee could grant themselves a module")
finally:
    curl(["-X", "DELETE", f"{URL}/auth/v1/admin/users/{uid}"] + SA)
    print("\nprobe user deleted")

print("\nRESULT:", "PASS" if not problems else "FAIL")
for p in problems:
    print("  -", p)
sys.exit(1 if problems else 0)
