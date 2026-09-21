#!/usr/bin/env python3
"""Apply a SQL migration file to the live Supabase project.

Usage: python apply_migration.py <path-to-sql> [...]
Reads the token from SUPABASE_ACCESS_TOKEN or falls back to the project value.
"""
import json
import os
import subprocess
import sys
import tempfile

PROJECT = "bdkwsveouzufgwajefrc"
URL = f"https://api.supabase.com/v1/projects/{PROJECT}/database/query"


def _token() -> str:
    """Read the management token from the environment or the gitignored .env."""
    tok = os.environ.get("SUPABASE_ACCESS_TOKEN")
    if tok:
        return tok
    try:
        with open(".env", encoding="utf-8") as fh:
            for line in fh:
                if line.startswith("SUPABASE_ACCESS_TOKEN="):
                    return line.split("=", 1)[1].strip()
    except FileNotFoundError:
        pass
    raise SystemExit("SUPABASE_ACCESS_TOKEN not set and not found in .env")


TOKEN = _token()


def run_sql(sql: str) -> str:
    fd, path = tempfile.mkstemp(suffix=".json")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump({"query": sql}, f)
        res = subprocess.run(
            [
                "curl", "-s", "-X", "POST", URL,
                "-H", f"Authorization: Bearer {TOKEN}",
                "-H", "Content-Type: application/json",
                "--data-binary", f"@{path}",
            ],
            capture_output=True, text=True, timeout=300,
        )
        return res.stdout.strip()
    finally:
        os.unlink(path)


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: apply_migration.py <file.sql> [...]")
        return 2

    failed = False
    for path in sys.argv[1:]:
        with open(path, encoding="utf-8") as f:
            sql = f.read()
        out = run_sql(sql)
        name = os.path.basename(path)
        if '"error"' in out or "ERROR" in out.upper():
            print(f"FAIL  {name}\n      {out[:600]}")
            failed = True
        else:
            print(f"OK    {name}  ({len(sql):,} chars)  -> {out[:120]}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
