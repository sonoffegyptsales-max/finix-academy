"""Certificates are per track + level. Throwaway student owning ONLY Track 3
passes all its Bronze quizzes via the real grading RPC."""
import json, secrets, subprocess, sys

E = {}
for l in open(".env", encoding="utf-8"):
    l = l.strip()
    if l and not l.startswith("#") and "=" in l:
        k, v = l.split("=", 1); E[k.strip()] = v.strip()
URL = E["VITE_SUPABASE_URL"].rstrip("/"); SRK = E["SUPABASE_SERVICE_ROLE_KEY"]; ANON = E["VITE_SUPABASE_PUBLISHABLE_KEY"]
SA = ["-H", f"Authorization: Bearer {SRK}", "-H", f"apikey: {SRK}"]


def curl(args, data=None, method=None):
    cmd = ["curl", "-s"] + (["-X", method] if method else []) + args
    if data is not None: cmd += ["-H", "Content-Type: application/json", "-d", json.dumps(data)]
    r = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8").stdout
    try: return json.loads(r) if r else None
    except Exception: return r


bad = []
def check(n, ok, d=""):
    print(("PASS " if ok else "FAIL ") + n + (f"  [{d}]" if d else ""))
    if not ok: bad.append(n)

email = f"cert-{secrets.token_hex(3)}@finix-test.local"; pw = secrets.token_urlsafe(14); dev = "cert-" + secrets.token_hex(6)
uid = curl([f"{URL}/auth/v1/admin/users"] + SA, {"email": email, "password": pw, "email_confirm": True}, "POST")["id"]
try:
    curl([f"{URL}/rest/v1/user_roles"] + SA, {"user_id": uid, "role": "trainee"}, "POST")
    curl([f"{URL}/rest/v1/trainee_devices"] + SA, {"user_id": uid, "device_id": dev, "device_label": "probe"}, "POST")
    tok = curl([f"{URL}/auth/v1/token?grant_type=password", "-H", f"apikey: {ANON}"], {"email": email, "password": pw}, "POST")["access_token"]
    TA = ["-H", f"Authorization: Bearer {tok}", "-H", f"apikey: {ANON}", "-H", f"x-device-id: {dev}"]
    mods = curl([f"{URL}/rest/v1/modules?select=id,code,track_id&published=eq.true"] + SA)
    t3 = [m for m in mods if m["track_id"] == "finix-industrial-control"]
    curl([f"{URL}/rest/v1/module_access"] + SA, [{"user_id": uid, "module_id": m["id"], "source": "manual"} for m in t3], "POST")

    def take(m, tier, correct=True):
        q = curl([f"{URL}/rest/v1/quizzes?module_id=eq.{m['id']}&tier=eq.{tier}&select=id"] + SA)[0]
        qs = curl([f"{URL}/rest/v1/quiz_questions?quiz_id=eq.{q['id']}&select=id"] + SA)
        ans = []
        for x in qs:
            opts = curl([f"{URL}/rest/v1/quiz_options?question_id=eq.{x['id']}&select=id,is_correct"] + SA)
            pick = next(o for o in opts if o["is_correct"] == correct)
            ans.append({"question_id": x["id"], "selected_option_id": pick["id"]})
        return curl([f"{URL}/rest/v1/rpc/submit_quiz_attempt"] + TA, {"_quiz_id": q["id"], "_answers": ans}, "POST")

    def certs():
        return {(c["track_id"], c["tier"]) for c in curl([f"{URL}/rest/v1/certificates?user_id=eq.{uid}&select=track_id,tier"] + SA)}

    take(t3[0], "bronze", correct=False)
    check("failing a quiz earns nothing", certs() == set())
    for m in t3[:-1]:
        take(m, "bronze")
    check("6 of 7 modules passed -> no certificate yet", certs() == set(), str(certs()))
    r = take(t3[-1], "bronze")
    check("last module passed", isinstance(r, list) and r[0]["passed"], json.dumps(r)[:80])
    c = certs()
    check("Track 3 Bronze certificate issued (only that student's one track)", c == {("finix-industrial-control", "bronze")}, str(c))
    check("no Silver/Gold or other-track certificate leaked", all(t == "bronze" and k == "finix-industrial-control" for k, t in c))
    take(t3[0], "bronze")  # retake must not duplicate or error
    check("retake does not duplicate the certificate", len(certs()) == 1)
    num = curl([f"{URL}/rest/v1/certificates?user_id=eq.{uid}&select=certificate_number"] + SA)[0]["certificate_number"]
    check("certificate number names the track", num.startswith("FIN-T3-BRONZE-"), num)
finally:
    curl([f"{URL}/auth/v1/admin/users/{uid}"] + SA, method="DELETE")
print("RESULT:", "PASS" if not bad else f"FAIL {bad}")
sys.exit(1 if bad else 0)
