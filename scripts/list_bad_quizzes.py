#!/usr/bin/env python3
"""List every quiz question that does not have exactly 4 options, with its options."""
import json
import os
import subprocess
import tempfile

REF = "bdkwsveouzufgwajefrc"

SQL = """
SELECT m.code, qz.tier, qq.position, qq.id, qq.question,
       (SELECT json_agg(json_build_object('t', qo.option_text, 'ta', qo.option_text_ar,
                                          'ok', qo.is_correct, 'p', qo.position)
                        ORDER BY qo.position)
        FROM public.quiz_options qo WHERE qo.question_id = qq.id) AS opts
FROM public.quiz_questions qq
JOIN public.quizzes qz ON qz.id = qq.quiz_id
JOIN public.modules m ON m.id = qz.module_id
WHERE (SELECT count(*) FROM public.quiz_options o2 WHERE o2.question_id = qq.id) <> 4
ORDER BY m.code, qz.tier, qq.position;
"""


def token():
    tok = os.environ.get("SUPABASE_ACCESS_TOKEN")
    if tok:
        return tok
    with open(".env", encoding="utf-8") as f:
        for line in f:
            if line.startswith("SUPABASE_ACCESS_TOKEN="):
                return line.split("=", 1)[1].strip()
    raise SystemExit("no token")


fd, path = tempfile.mkstemp(suffix=".json")
with os.fdopen(fd, "w", encoding="utf-8") as f:
    json.dump({"query": SQL}, f)

r = subprocess.run(
    ["curl", "-s", "-X", "POST",
     f"https://api.supabase.com/v1/projects/{REF}/database/query",
     "-H", f"Authorization: Bearer {token()}",
     "-H", "Content-Type: application/json",
     "--data-binary", f"@{path}"],
    capture_output=True, text=True, encoding="utf-8")
os.unlink(path)

rows = json.loads(r.stdout)
if isinstance(rows, dict):
    raise SystemExit(rows.get("message", str(rows)))

for row in rows:
    print(f"=== {row['code']}/{row['tier']} pos{row['position']} id={row['id']}")
    print("Q:", row["question"])
    for o in row["opts"]:
        mark = " *" if o["ok"] else "  "
        print(f"  {mark} p{o['p']} EN: {o['t']}")
        print(f"       AR: {o['ta']}")
    print()
print(f"total: {len(rows)}")
