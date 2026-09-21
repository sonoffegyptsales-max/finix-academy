#!/usr/bin/env python3
"""Print a compact audit of the live curriculum: tracks, modules, lessons, quizzes."""
import json
import os
import subprocess
import tempfile
from collections import defaultdict

PROJECT = "bdkwsveouzufgwajefrc"
URL = f"https://api.supabase.com/v1/projects/{PROJECT}/database/query"
TOKEN = os.environ.get("SUPABASE_ACCESS_TOKEN", "sbp_fc3e21a08248c757be4a270ba9b986dc9d16b526")


def q(sql):
    fd, path = tempfile.mkstemp(suffix=".json")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump({"query": sql}, f)
        res = subprocess.run(
            ["curl", "-s", "-X", "POST", URL,
             "-H", f"Authorization: Bearer {TOKEN}",
             "-H", "Content-Type: application/json",
             "--data-binary", f"@{path}"],
            capture_output=True, text=True, timeout=300)
        return json.loads(res.stdout)
    finally:
        os.unlink(path)


tracks = q("SELECT id, name, position FROM public.tracks ORDER BY position;")
print("=== TRACKS ===")
for t in tracks:
    print(f"  {t['position']}. {t['id']:34s} {t['name']}")

mods = q("""SELECT m.code, m.track_id, m.position, m.title,
  (SELECT count(*) FROM public.lessons l WHERE l.module_id=m.id) AS lessons,
  (SELECT coalesce(sum(length(coalesce(l.content,''))),0) FROM public.lessons l WHERE l.module_id=m.id) AS chars,
  (SELECT count(*) FROM public.quizzes qz WHERE qz.module_id=m.id) AS quizzes
FROM public.modules m
ORDER BY (SELECT position FROM public.tracks t WHERE t.id=m.track_id), m.position;""")

print(f"\n=== MODULES ({len(mods)}) ===")
cur = None
for m in mods:
    if m["track_id"] != cur:
        cur = m["track_id"]
        print(f"\n  [{cur}]")
    avg = m["chars"] // m["lessons"] if m["lessons"] else 0
    flag = "  <-- THIN" if 0 < avg < 900 else ("  <-- EMPTY" if avg == 0 else "")
    print(f"    {m['code']} p{m['position']:<2} {m['title'][:52]:52s} "
          f"{m['lessons']}L {avg:>5}avg {m['quizzes']}Q{flag}")

qs = q("""SELECT m.code, qz.tier, (SELECT count(*) FROM public.quiz_questions qq WHERE qq.quiz_id=qz.id) AS n
FROM public.quizzes qz JOIN public.modules m ON m.id=qz.module_id
ORDER BY m.code, qz.tier;""")
d = defaultdict(dict)
for r in qs:
    d[r["code"]][r["tier"]] = r["n"]

total = sum(sum(v.values()) for v in d.values())
under = {c: v for c, v in d.items() if any(v.get(t, 0) < 5 for t in ("bronze", "silver", "gold"))}
missing = {c: v for c, v in d.items() if len(v) < 3}

print(f"\n=== QUIZZES ===")
print(f"  total questions: {total}")
print(f"  modules missing a tier: {len(missing)}  {sorted(missing)}")
print(f"  modules under 5 q/tier: {len(under)}")

lessons_total = sum(m["lessons"] for m in mods)
chars_total = sum(m["chars"] for m in mods)
print(f"\n=== TOTALS ===")
print(f"  tracks {len(tracks)} | modules {len(mods)} | lessons {lessons_total} "
      f"| avg {chars_total // lessons_total if lessons_total else 0} chars | questions {total}")
