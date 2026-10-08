#!/usr/bin/env python3
"""Move the Security Camera lesson from M15 to M14 together with its 4 quiz
questions, and write 4 replacement M15 questions so every M15 quiz keeps 5.

  python scripts/move_camera_lesson.py            # dry run
  python scripts/move_camera_lesson.py --apply
"""
import json, os, sys, urllib.request, time

APPLY = "--apply" in sys.argv
E = {}
for l in open(".env", encoding="utf-8"):
    l = l.strip()
    if l and not l.startswith("#") and "=" in l:
        k, v = l.split("=", 1); E[k.strip()] = v.strip()
U = E["VITE_SUPABASE_URL"].rstrip("/"); K = E["SUPABASE_SERVICE_ROLE_KEY"]


def call(method, path, body=None, prefer=None):
    h = {"apikey": K, "Authorization": "Bearer " + K, "Content-Type": "application/json"}
    if prefer: h["Prefer"] = prefer
    req = urllib.request.Request(U + path, method=method, headers=h, data=json.dumps(body).encode() if body is not None else None)
    with urllib.request.urlopen(req) as r:
        t = r.read().decode()
        return json.loads(t) if t else None


g = lambda p: call("GET", p)
m15 = g("/rest/v1/modules?code=eq.M15&select=id")[0]["id"]
m14 = g("/rest/v1/modules?code=eq.M14&select=id")[0]["id"]
lesson = [l for l in g(f"/rest/v1/lessons?module_id=eq.{m15}&select=id,title,position") if "Camera" in l["title"]]
assert len(lesson) == 1, lesson
lesson = lesson[0]
m14_lessons = g(f"/rest/v1/lessons?module_id=eq.{m14}&select=position&order=position.desc&limit=1")
new_pos = m14_lessons[0]["position"] + 1

CAMERA_WORDS = ("camera", "cctv", "footage")
quiz15 = {q["tier"]: q["id"] for q in g(f"/rest/v1/quizzes?module_id=eq.{m15}&select=id,tier")}
quiz14 = {q["tier"]: q["id"] for q in g(f"/rest/v1/quizzes?module_id=eq.{m14}&select=id,tier")}
move = []
for tier, qid in quiz15.items():
    for q in g(f"/rest/v1/quiz_questions?quiz_id=eq.{qid}&select=id,question,position"):
        if any(w in q["question"].lower() for w in CAMERA_WORDS):
            move.append((tier, q))
print(f"lesson '{lesson['title'][:50]}' -> M14 position {new_pos}")
for tier, q in move: print(f"  move {tier}: {q['question'][:90]}")
assert len(move) == 4, "expected exactly 4 camera questions"

# ------------------------------------------------------------ replacements
NEW = {
 "bronze": [
  ("A weak Zigbee area appears in one hallway while the rest of the property works well. What is usually the best fix before considering a second gateway?",
   "فيه منطقة ضعيفة في الـ Zigbee عند ممر واحد، وباقي المكان شغال كويس. إيه الحل الأنسب عادةً قبل ما نفكر في بوابة تانية (Gateway)؟",
   [("Install a second gateway on the same Zigbee channel", "ركّب بوابة تانية على نفس قناة الـ Zigbee", False),
    ("Add a mains-powered router device, such as a smart socket, in the gap", "ضيف جهاز موجّه (Router) شغال على الكهرباء، زي بريزة ذكية، في الفجوة دي", True),
    ("Add more battery-powered sensors to strengthen the signal", "ضيف حساسات بالبطارية أكتر علشان الإشارة تقوى", False),
    ("Move the coordinator right next to the Wi-Fi router", "انقل المنسّق (Coordinator) جنب راوتر الواي فاي على طول", False)]),
  ("How should the built-in energy monitoring of a smart switch or socket be presented to a client?",
   "إزاي نقدّم قياس الطاقة المدمج في المفتاح أو البريزة الذكية للعميل؟",
   [("As an exact match for the utility meter", "إنه مطابق تمامًا لعدّاد الكهرباء", False),
    ("As a replacement for the utility meter in billing disputes", "إنه بديل لعدّاد الكهرباء لو حصل خلاف على الفاتورة", False),
    ("As good enough for trends and spotting changes, but not a billing-grade meter", "إنه كويس كفاية لمتابعة الاتجاه واكتشاف أي تغيّر، بس مش عدّاد بدرجة الفوترة", True),
    ("As too unreliable to show the client at all", "إنه مش موثوق خالص فمينفعش نعرضه على العميل", False)]),
 ],
 "silver": [
  ("A motion sensor on Gateway A must switch on a light that belongs to Gateway B. What is the correct design?",
   "حساس حركة على البوابة A لازم يشغّل لمبة تابعة للبوابة B. إيه التصميم الصح؟",
   [("Pair the light to both gateways at the same time", "نزاوج اللمبة مع البوابتين في نفس الوقت", False),
    ("Set both gateways to the same channel so they can talk to each other", "نضبط البوابتين على نفس القناة علشان يتكلموا مع بعض", False),
    ("Bind the two networks directly, because Zigbee gateways share their devices", "نربط الشبكتين مباشرة لأن بوابات الـ Zigbee بتتشارك أجهزتها", False),
    ("Run the automation in a layer above both, such as Home Assistant or the eWeLink cloud, accepting an extra dependency and some latency",
     "نشغّل الأتمتة في طبقة فوق الاتنين، زي Home Assistant أو سحابة eWeLink، ونقبل اعتمادية زيادة وتأخير بسيط", True)]),
 ],
 "gold": [
  ("A Zigbee network that worked well for a year slowly degrades. What is the most productive first step?",
   "شبكة Zigbee كانت شغالة كويس سنة وبدأت تتدهور شوية بشوية. إيه أنفع أول خطوة؟",
   [("Replace every battery in the property", "نغيّر كل البطاريات في المكان", False),
    ("Find what changed, such as a new Wi-Fi access point, a metal shelf or mirror, or an unplugged router device, and read the routing map",
     "نعرف إيه اللي اتغيّر، زي نقطة وصول واي فاي جديدة أو رف معدن أو مراية أو جهاز موجّه اتفصل، ونراجع خريطة التوجيه", True),
    ("Factory-reset and re-pair every device", "نعمل Reset لكل الأجهزة ونزاوجها من الأول", False),
    ("Install a second gateway straight away", "نركّب بوابة تانية على طول", False)]),
 ],
}
for tier, items in NEW.items():
    for en, ar, opts in items:
        assert sum(1 for o in opts if o[2]) == 1 and len(opts) == 4
        assert en.strip() and ar.strip() and all(o[0] and o[1] for o in opts)
print("replacements:", {t: len(v) for t, v in NEW.items()})

if not APPLY:
    print("\nDRY RUN OK - run with --apply"); sys.exit(0)

# ------------------------------------------------------------ backup + apply
bk = {"lesson": lesson, "m15": m15, "m14": m14, "moved_questions": [{"tier": t, **q} for t, q in move]}
os.makedirs("scripts/backups", exist_ok=True)
json.dump(bk, open(f"scripts/backups/camera_move_{int(time.time())}.json", "w"), indent=1)

call("PATCH", f"/rest/v1/lessons?id=eq.{lesson['id']}", {"module_id": m14, "position": new_pos})
for tier, q in move:
    call("PATCH", f"/rest/v1/quiz_questions?id=eq.{q['id']}", {"quiz_id": quiz14[tier], "position": 999})
for tier, items in NEW.items():
    for en, ar, opts in items:
        row = call("POST", "/rest/v1/quiz_questions", {"quiz_id": quiz15[tier], "question": en, "question_ar": ar, "position": 998}, "return=representation")[0]
        call("POST", "/rest/v1/quiz_options", [{"question_id": row["id"], "option_text": a, "option_text_ar": b, "is_correct": c, "position": i + 1}
                                                for i, (a, b, c) in enumerate(opts)])
# renumber contiguous
for qid in list(quiz15.values()) + list(quiz14.values()):
    qs = g(f"/rest/v1/quiz_questions?quiz_id=eq.{qid}&select=id,position&order=position,created_at")
    for i, q in enumerate(qs, 1):
        if q["position"] != i: call("PATCH", f"/rest/v1/quiz_questions?id=eq.{q['id']}", {"position": i})
for i, l in enumerate(g(f"/rest/v1/lessons?module_id=eq.{m15}&select=id,position&order=position"), 1):
    call("PATCH", f"/rest/v1/lessons?id=eq.{l['id']}", {"position": i})
print("APPLIED")
for code, mid, qs in (("M14", m14, quiz14), ("M15", m15, quiz15)):
    print(code, "lessons:", len(g(f"/rest/v1/lessons?module_id=eq.{mid}&select=id")),
          "questions by tier:", {t: len(g(f"/rest/v1/quiz_questions?quiz_id=eq.{q}&select=id")) for t, q in qs.items()})
