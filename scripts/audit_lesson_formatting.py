#!/usr/bin/env python3
"""Audit lesson content for the problems raised in the course review.

The reviewer's screenshots all show the same underlying fault: lesson bodies
were authored in markdown but are rendered as PLAIN TEXT, so `**bold**`,
`| table |` and `- bullet` appear literally on screen.

Reports, per lesson:
  bold    count of ** markers
  table   count of markdown table pipe-rows
  bullet  count of leading "- " lines
  head    count of markdown headings
  narr    longest paragraph in characters (narrative-wall detector)
"""
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import tempfile

REF = "bdkwsveouzufgwajefrc"


def env() -> dict:
    out = {}
    for line in open(".env", encoding="utf-8"):
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            k, v = line.split("=", 1)
            out[k.strip()] = v.strip()
    return out


def query(sql: str):
    e = env()
    url = e.get("SUPABASE_URL") or e.get("VITE_SUPABASE_URL")
    key = e.get("SUPABASE_SERVICE_ROLE_KEY")
    fd, path = tempfile.mkstemp(suffix=".json")
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        json.dump({"query": sql}, f)
    p = subprocess.run([
        "curl", "-s", "-X", "POST",
        f"{url}/rest/v1/rpc/exec_sql",
        "-H", f"Authorization: Bearer {key}",
        "-H", f"apikey: {key}",
        "-H", "Content-Type: application/json",
        "--data-binary", f"@{path}",
    ], capture_output=True, text=True)
    os.unlink(path)
    return p.stdout


def fetch_lessons():
    """Read lessons through PostgREST with the service-role key."""
    e = env()
    url = e.get("SUPABASE_URL") or e.get("VITE_SUPABASE_URL")
    key = e.get("SUPABASE_SERVICE_ROLE_KEY")
    p = subprocess.run([
        "curl", "-s",
        f"{url}/rest/v1/lessons?select=id,title,title_ar,content,content_ar,module_id&limit=500",
        "-H", f"Authorization: Bearer {key}",
        "-H", f"apikey: {key}",
    ], capture_output=True, text=True)
    try:
        return json.loads(p.stdout)
    except Exception:
        print("could not read lessons:", p.stdout[:400])
        return []


BOLD = re.compile(r"\*\*")
TABLE = re.compile(r"^\s*\|.*\|\s*$", re.M)
SEP = re.compile(r"^\s*\|[\s:|-]+\|\s*$", re.M)
BULLET = re.compile(r"^\s*[-*]\s+\S", re.M)
HEAD = re.compile(r"^\s*#{1,6}\s+\S", re.M)


def stats(text: str) -> dict:
    if not text:
        return {}
    paras = [p.strip() for p in re.split(r"\n\s*\n", text) if p.strip()]
    longest = max((len(p) for p in paras), default=0)
    return {
        "bold": len(BOLD.findall(text)),
        "table": len(TABLE.findall(text)),
        "sep": len(SEP.findall(text)),
        "bullet": len(BULLET.findall(text)),
        "head": len(HEAD.findall(text)),
        "narr": longest,
        "chars": len(text),
    }


def main() -> int:
    lessons = fetch_lessons()
    if not lessons:
        return 1
    print(f"lessons read: {len(lessons)}\n")

    tot = {"bold": 0, "table": 0, "bullet": 0, "head": 0}
    affected_bold = affected_table = affected_bullet = 0
    long_narr = 0
    worst = []

    for L in lessons:
        for field in ("content", "content_ar"):
            s = stats(L.get(field) or "")
            if not s:
                continue
            for k in tot:
                tot[k] += s[k]
            if s["bold"]:
                affected_bold += 1
            if s["table"]:
                affected_table += 1
            if s["bullet"]:
                affected_bullet += 1
            if s["narr"] > 700:
                long_narr += 1
            worst.append((s["bold"] + s["table"] * 2, L.get("title"), field, s))

    print("TOTALS across all lesson bodies")
    print(f"  ** bold markers      : {tot['bold']}")
    print(f"  markdown table rows  : {tot['table']}")
    print(f"  markdown bullets     : {tot['bullet']}")
    print(f"  markdown headings    : {tot['head']}")
    print()
    print("FIELDS AFFECTED (a field = one language of one lesson)")
    print(f"  containing bold      : {affected_bold}")
    print(f"  containing tables    : {affected_table}")
    print(f"  containing bullets   : {affected_bullet}")
    print(f"  paragraphs > 700 ch  : {long_narr}")

    worst.sort(reverse=True)
    print("\nWORST OFFENDERS")
    for score, title, field, s in worst[:12]:
        if score == 0:
            break
        print(f"  [{field:10}] {str(title)[:46]:46} "
              f"bold={s['bold']:3} tables={s['table']:3} bullets={s['bullet']:3}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
