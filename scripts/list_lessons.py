#!/usr/bin/env python3
"""Print every module and lesson (id, code, title) so diagram targets can be chosen."""
import json
import os
import subprocess
import tempfile

REF = "bdkwsveouzufgwajefrc"

SQL = """
SELECT m.code, m.slug, l.id AS lesson_id, l.position, l.title,
       length(l.content) AS en_chars
FROM public.lessons l
JOIN public.modules m ON m.id = l.module_id
ORDER BY m.code, l.position;
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

cur = None
for row in rows:
    if row["code"] != cur:
        cur = row["code"]
        print(f"\n--- {cur} ({row['slug']})")
    print(f"  L{row['position']} {row['lesson_id']}  {row['title'][:70]}")
print(f"\ntotal lessons: {len(rows)}")
