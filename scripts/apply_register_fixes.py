#!/usr/bin/env python3
"""Apply hand-authored register fixes from scripts/register_fixes.json.

Generalisation of fix_msa_sentences*.py: the FIXES list moves to a JSON file
(entries {id, old, new}) so batches can grow without new scripts. Contract is
unchanged and non-negotiable:

  - `old` must match the live content_ar VERBATIM or the entry is refused
    (catches drifted rows and guessed ids -- a guessed id already tried to
    slip through once and only this check stopped it);
  - the whole field must not shrink more than 15% (content-loss guard);
  - every touched row is backed up before writing.

  python3 scripts/apply_register_fixes.py                # dry run
  python3 scripts/apply_register_fixes.py --apply
  python3 scripts/apply_register_fixes.py --file other.json --apply
"""
from __future__ import annotations

import datetime
import json
import os
import subprocess
import sys
import tempfile


def env() -> dict[str, str]:
    out = {}
    with open(".env", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                out[k.strip()] = v.strip()
    return out


def main() -> int:
    apply = "--apply" in sys.argv
    path = "scripts/register_fixes.json"
    if "--file" in sys.argv:
        path = sys.argv[sys.argv.index("--file") + 1]

    fixes = json.load(open(path, encoding="utf-8"))
    e = env()
    url = (e.get("VITE_SUPABASE_URL") or e["SUPABASE_URL"]).rstrip("/")
    key = e["SUPABASE_SERVICE_ROLE_KEY"]
    auth = ["-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}"]

    ids = sorted({f["id"] for f in fixes})
    cur: dict[str, dict] = {}
    for i in range(0, len(ids), 25):
        quoted = ",".join(f'"{x}"' for x in ids[i:i + 25])
        rows = json.loads(subprocess.run(
            ["curl", "-s",
             f"{url}/rest/v1/lessons?id=in.({quoted})&select=id,title,content_ar",
             *auth], capture_output=True, text=True, encoding="utf-8").stdout)
        cur.update({r["id"]: r for r in rows})

    staged: dict[str, str] = {}
    problems: list[str] = []
    applied = 0

    for n, fx in enumerate(fixes, 1):
        lid, old, new = fx["id"], fx["old"], fx["new"]
        label = f"#{n} {cur.get(lid, {}).get('title', lid)[:44]}"
        row = cur.get(lid)
        if not row:
            problems.append(f"{label}: lesson id not found")
            continue
        text = staged.get(lid, row.get("content_ar") or "")
        if old not in text:
            problems.append(f"{label}: source not found verbatim")
            continue
        staged[lid] = text.replace(old, new, 1)
        applied += 1

    for lid, new_text in staged.items():
        old_len = len(cur[lid].get("content_ar") or "")
        if len(new_text) < old_len * 0.85:
            problems.append(
                f"{cur[lid]['title'][:40]}: shrank {old_len} -> {len(new_text)}")

    print(f"{applied}/{len(fixes)} fixes staged across {len(staged)} lessons")
    if problems:
        print("\nPROBLEMS — nothing written for these:")
        for p in problems:
            print(f"  {p}")

    if not apply:
        print("\nDRY RUN — re-run with --apply to write")
        return 1 if problems else 0
    if problems:
        print("\nrefusing to write while problems remain")
        return 1

    os.makedirs("backups", exist_ok=True)
    stamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    bak = os.path.join("backups", f"register_fixes_{stamp}.json")
    with open(bak, "w", encoding="utf-8") as f:
        json.dump([{"id": i, "title": cur[i]["title"],
                    "content_ar": cur[i].get("content_ar")} for i in staged],
                  f, ensure_ascii=False, indent=1)
    print(f"backed up -> {bak}")

    ok = 0
    for lid, new_text in staged.items():
        fd, pf = tempfile.mkstemp(suffix=".json")
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump({"content_ar": new_text}, f, ensure_ascii=False)
        try:
            res = subprocess.run(
                ["curl", "-s", "-w", "\n%{http_code}", "-X", "PATCH",
                 f"{url}/rest/v1/lessons?id=eq.{lid}", *auth,
                 "-H", "Content-Type: application/json",
                 "-H", "Prefer: return=minimal", "--data-binary", f"@{pf}"],
                capture_output=True, text=True, encoding="utf-8")
            if res.stdout.rpartition("\n")[2] in ("200", "204"):
                ok += 1
            else:
                print(f"  FAILED {cur[lid]['title'][:40]}")
        finally:
            os.unlink(pf)

    print(f"updated {ok}/{len(staged)} lessons")
    return 0 if ok == len(staged) else 1


if __name__ == "__main__":
    raise SystemExit(main())
