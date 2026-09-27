#!/usr/bin/env python3
"""Print the exact SENTENCES that still carry MSA structure.

After correcting the detector, the real population is 42 lessons carrying 59
signals -- an average of 1.4 per lesson, not a wholesale rewrite. So the
efficient unit of work is the sentence, not the lesson.

This lists every offending sentence with its lesson and the signal that fired,
so each can be fixed precisely instead of re-authoring pages that are already
in register.

  python3 scripts/list_msa_sentences.py            # all
  python3 scripts/list_msa_sentences.py --code I04 # one module
"""
from __future__ import annotations

import json
import re
import subprocess
import sys

sys.path.insert(0, "scripts")
import measure_register as M  # noqa: E402

# Markdown tables and fenced blocks are not prose. A terminology table has no
# sentence punctuation, so the whole table arrives as one "sentence" and trips
# the length signal -- reporting the two F08 lessons that were deliberately
# CONVERTED into tables as needing a register rewrite.
TABLE_OR_FENCE = re.compile(r"^\s*(\||```)", re.M)


def strip_non_prose(text: str) -> str:
    out, in_fence = [], False
    for line in text.split("\n"):
        s = line.strip()
        if s.startswith("```"):
            in_fence = not in_fence
            continue
        if in_fence or s.startswith("|"):
            continue
        out.append(line)
    return "\n".join(out)


# Split on sentence punctuation OR a blank line. Stripping tables leaves the
# surrounding bold headings adjacent, and without the blank-line rule they glue
# into one enormous pseudo-sentence that trips the length signal -- which is
# why the F08 lessons kept reporting after the table fix.
SPLIT = re.compile(r"(?<=[.!?:])\s+|\n\s*\n")


def main() -> int:
    only = None
    if "--code" in sys.argv:
        only = sys.argv[sys.argv.index("--code") + 1].upper()
    e = M.env()
    url = (e.get("VITE_SUPABASE_URL") or e["SUPABASE_URL"]).rstrip("/")
    key = e["SUPABASE_SERVICE_ROLE_KEY"]
    A = ["-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}"]

    def g(q):
        return json.loads(subprocess.run(["curl", "-s", url + q, *A],
                                         capture_output=True, text=True,
                                         encoding="utf-8").stdout)

    mods = {m["id"]: m["code"] for m in g("/rest/v1/modules?select=id,code&limit=100")}
    rows = g("/rest/v1/lessons?select=id,module_id,position,title,content_ar&limit=500")

    total = 0
    for r in sorted(rows, key=lambda x: (mods.get(x["module_id"], ""), x["position"])):
        code = mods.get(r["module_id"], "??")
        if only and code != only:
            continue
        ar = strip_non_prose(r.get("content_ar") or "")
        if not ar.strip():
            continue

        found: list[tuple[str, str]] = []
        for sent in SPLIT.split(ar):
            s = sent.strip()
            if not s:
                continue
            for name, pat in M.REWRITE_SIGNALS.items():
                if pat.search(s):
                    found.append((name, s))
                    break

        if not found:
            continue
        total += len(found)
        print(f"\n{'=' * 74}")
        print(f"{code} L{r['position']} · {r['title'][:54]}")
        print(f"id: {r['id']}")
        print("=" * 74)
        for name, s in found:
            print(f"  [{name}]")
            print(f"    {s[:300]}")

    print(f"\n\n{total} sentences need a targeted fix")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
