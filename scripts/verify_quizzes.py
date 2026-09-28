#!/usr/bin/env python3
"""Integrity check for the whole quiz bank (standing gate).

Verifies every question has exactly 4 options with exactly 1 correct,
both languages populated, Arabic differs from English, and no duplicate
question text within a module.

REWRITTEN on PostgREST + service-role key: the original used the Supabase
Management API (SUPABASE_ACCESS_TOKEN), which expired -- so the gate failed
with a TypeError on the error object and nobody noticed. A standing gate must
not depend on a token that can silently expire while the data path still works.
"""
import json
import subprocess
import sys
from collections import defaultdict


def env():
    out = {}
    with open(".env", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                out[k.strip()] = v.strip()
    return out


def get(url, key, path):
    """Fetch ALL rows with pagination. PostgREST caps responses at 1000 rows
    regardless of ?limit= -- the first version of this rewrite asked for
    limit=5000, silently got 1000 of 1320 options, and reported 80 questions
    as having zero options. Page until a short page arrives."""
    out, page, step = [], 0, 1000
    while True:
        r = subprocess.run(
            ["curl", "-s", f"{url}/rest/v1/{path}",
             "-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}",
             "-H", f"Range: {page * step}-{page * step + step - 1}"],
            capture_output=True, text=True, encoding="utf-8")
        data = json.loads(r.stdout)
        if not isinstance(data, list):
            raise SystemExit(f"API error on {path.split('?')[0]}: {data}")
        out.extend(data)
        if len(data) < step:
            return out
        page += 1


e = env()
URL = e["VITE_SUPABASE_URL"].rstrip("/")
KEY = e["SUPABASE_SERVICE_ROLE_KEY"]

modules = {m["id"]: m for m in get(URL, KEY, "modules?select=id,code,title&limit=100")}
quizzes = {q["id"]: q for q in get(URL, KEY, "quizzes?select=id,module_id,tier&limit=200")}
questions = get(URL, KEY, "quiz_questions?select=id,quiz_id,question,question_ar&limit=1000")
options = get(URL, KEY, "quiz_options?select=id,question_id,option_text,option_text_ar,is_correct&limit=5000")

opts_by_q = defaultdict(list)
for o in options:
    opts_by_q[o["question_id"]].append(o)

problems = []
seen = defaultdict(list)

for qq in questions:
    qz = quizzes.get(qq["quiz_id"])
    if not qz:
        problems.append(f"orphan question {qq['id'][:8]} (quiz missing)")
        continue
    m = modules.get(qz["module_id"], {})
    tag = f"{m.get('code', '?')}/{qz['tier']}"
    opts = opts_by_q.get(qq["id"], [])
    n_correct = sum(1 for o in opts if o["is_correct"])
    blank_en = sum(1 for o in opts if not (o["option_text"] or "").strip())
    blank_ar = sum(1 for o in opts if not (o["option_text_ar"] or "").strip())
    q_en = (qq["question"] or "").strip()
    q_ar = (qq["question_ar"] or "").strip()

    if len(opts) != 4:
        problems.append(f"{tag}: {len(opts)} options (expected 4) - {q_en[:60]}")
    if n_correct != 1:
        problems.append(f"{tag}: {n_correct} correct (expected 1) - {q_en[:60]}")
    if blank_en or blank_ar:
        problems.append(f"{tag}: blank option text en={blank_en} ar={blank_ar} - {q_en[:60]}")
    if not q_ar:
        problems.append(f"{tag}: missing Arabic question - {q_en[:60]}")
    if q_ar and q_ar == q_en:
        problems.append(f"{tag}: Arabic identical to English - {q_en[:60]}")
    seen[m.get("code", "?")].append(q_en.lower())

for code, qs in seen.items():
    dupes = {t for t in qs if qs.count(t) > 1}
    for d in dupes:
        problems.append(f"{code}: DUPLICATE question text - {d[:70]}")

print(f"questions checked: {len(questions)}  options: {len(options)}  quizzes: {len(quizzes)}")
if problems:
    print(f"\nPROBLEMS ({len(problems)}):")
    for p in problems:
        print("  " + p)
    sys.exit(1)
print("all clean: 4 options, exactly 1 correct, bilingual, no duplicates")
