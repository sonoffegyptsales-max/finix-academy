#!/usr/bin/env python3
"""Inspect the tables and constraints that trainee creation depends on."""
import json
import os
import subprocess
import tempfile

REF = "bdkwsveouzufgwajefrc"

SQL = """
SELECT 'constraint' AS kind, conrelid::regclass::text AS tbl, conname AS name,
       pg_get_constraintdef(oid) AS def
FROM pg_constraint
WHERE conrelid::regclass::text IN ('public.profiles','public.user_roles')
UNION ALL
SELECT 'column', table_name, column_name,
       data_type || CASE WHEN is_nullable='NO' THEN ' NOT NULL' ELSE '' END
       || COALESCE(' default ' || column_default, '')
FROM information_schema.columns
WHERE table_schema='public' AND table_name IN ('profiles','user_roles')
UNION ALL
SELECT 'trigger', event_object_table, trigger_name, action_statement
FROM information_schema.triggers
WHERE event_object_schema='public' AND event_object_table IN ('profiles','user_roles')
ORDER BY 1,2,3;
"""


def token():
    for line in open(".env", encoding="utf-8"):
        if line.startswith("SUPABASE_ACCESS_TOKEN="):
            return line.split("=", 1)[1].strip()
    raise SystemExit("no token")


fd, p = tempfile.mkstemp(suffix=".json")
os.close(fd)
json.dump({"query": SQL}, open(p, "w", encoding="utf-8"))
r = subprocess.run(
    ["curl", "-s", "-X", "POST",
     f"https://api.supabase.com/v1/projects/{REF}/database/query",
     "-H", f"Authorization: Bearer {token()}",
     "-H", "Content-Type: application/json", "--data-binary", f"@{p}"],
    capture_output=True, text=True, encoding="utf-8")
os.unlink(p)

rows = json.loads(r.stdout)
if isinstance(rows, dict):
    raise SystemExit(rows.get("message", str(rows)))

cur = None
for row in rows:
    if row["kind"] != cur:
        cur = row["kind"]
        print(f"\n===== {cur.upper()}S")
    print(f"  [{row['tbl']}] {row['name']}")
    print(f"      {row['def'][:150]}")
