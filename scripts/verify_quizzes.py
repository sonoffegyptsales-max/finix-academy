#!/usr/bin/env python3
"""Integrity check for the whole quiz bank.

Verifies every question has exactly 4 options with exactly 1 correct,
both languages populated, and no duplicate question text within a module.
"""
import json
import os
import subprocess
import sys
import tempfile
from collections import defaultdict

REF = "bdkwsveouzufgwajefrc"


def token():
    tok = os.environ.get("SUPABASE_ACCESS_TOKEN")
    if tok:
        return tok
    with open(".env", encoding="utf-8") as f:
        for line in f:
            if line.startswith("SUPABASE_ACCESS_TOKEN="):
                return line.split("=", 1)[1].strip()
    raise SystemExit("no token")


def q(sql):
    fd, path = tempfile.mkstemp(suffix=".json")
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        json.dump({"query": sql}, f)
    try:
        r = subprocess.run(
            ["curl", "-s", "-X", "POST",
             f"https://api.supabase.com/v1/projects/{REF}/database/query",
             "-H", f"Authorization: Bearer {token()}",
             "-H", "Content-Type: application/json",
             "--data-binary", f"@{path}"],
            capture_output=True, text=True, encoding="utf-8")
        return json.loads(r.stdout)
    finally:
        os.unlink(path)


rows = q("""
SELECT m.code, qz.tier, qq.id, qq.question, qq.question_ar,
       count(qo.id) AS n_opts,
       count(*) FILTER (WHERE qo.is_correct) AS n_correct,
       count(*) FILTER (WHERE qo.option_text IS NULL OR btrim(qo.option_text) = '') AS blank_en,
       count(*) FILTER (WHERE qo.option_text_ar IS NULL OR btrim(qo.option_text_ar) = '') AS blank_ar
FROM public.quiz_questions qq
JOIN public.quizzes qz ON qz.id = qq.quiz_id
JOIN public.modules m ON m.id = qz.module_id
LEFT JOIN public.quiz_options qo ON qo.question_id = qq.id
GROUP BY m.code, qz.tier, qq.id, qq.question, qq.question_ar
ORDER BY m.code, qz.tier;
""")

problems = []
seen = defaultdict(list)

for r in rows:
    tag = f"{r['code']}/{r['tier']}"
    if r["n_opts"] != 4:
        problems.append(f"{tag}: {r['n_opts']} options (expected 4) - {r['question'][:60]}")
    if r["n_correct"] != 1:
        problems.append(f"{tag}: {r['n_correct']} correct (expected 1) - {r['question'][:60]}")
    if r["blank_en"] or r["blank_ar"]:
        problems.append(f"{tag}: blank option text en={r['blank_en']} ar={r['blank_ar']} - {r['question'][:60]}")
    if not (r["question_ar"] or "").strip():
        problems.append(f"{tag}: missing Arabic question - {r['question'][:60]}")
    if (r["question_ar"] or "").strip() == (r["question"] or "").strip():
        problems.append(f"{tag}: Arabic identical to English - {r['question'][:60]}")
    seen[r["code"]].append((r["question"] or "").strip().lower())

for code, qs in seen.items():
    dupes = {t for t in qs if qs.count(t) > 1}
    for d in dupes:
        problems.append(f"{code}: DUPLICATE question text - {d[:70]}")

print(f"questions checked: {len(rows)}")
if problems:
    print(f"\nPROBLEMS ({len(problems)}):")
    for p in problems:
        print("  " + p)
    sys.exit(1)
print("all clean: 4 options, exactly 1 correct, bilingual, no duplicates")
