#!/usr/bin/env python3
"""Find and fix damage done by the earlier English-gloss pass.

Two defects found while reading F03 L3 for a register rewrite:

  1. MID-WORD INJECTION
     "الحساس (Sensor)ات"  -- the script matched الحساس inside الحساسات and
     spliced the gloss into the middle of the word. The plural suffix is left
     stranded after the bracket.

  2. WRONG SENSE
     "البوابة (Gateway) الرئيسية" -- البوابة here is a physical main GATE on a
     villa perimeter, not a network gateway. The term audit matched the word
     without reading the phrase.

Both come from glossing on a bare word match. This script finds every
occurrence of the whole class and repairs it:

  * mid-word: gloss followed immediately by Arabic letters  -> move the gloss
    after the complete word, or drop it if the word is now plural
  * wrong sense: a curated list of phrases where the gloss must be removed

  python3 scripts/fix_gloss_damage.py            # dry run
  python3 scripts/fix_gloss_damage.py --apply
"""
from __future__ import annotations

import datetime
import json
import os
import re
import subprocess
import sys
import tempfile

FIELDS = ("content", "content_ar")

# A gloss immediately followed by Arabic letters = spliced into a word.
MIDWORD = re.compile(r"\((?P<en>[A-Za-z][A-Za-z /-]{1,24})\)(?P<tail>[\u0621-\u064A]+)")

# Phrases where the glossed word does not carry the technical sense.
WRONG_SENSE = [
    (r"البوابة \(Gateway\) الرئيسية", "البوابة الرئيسية",
     "physical main gate of a property, not a network gateway"),
    (r"بوابة \(Gateway\) الجراج", "بوابة الجراج",
     "garage gate"),
    (r"البوابة \(Gateway\) الرئيسة", "البوابة الرئيسة",
     "physical main gate"),
]


def env() -> dict[str, str]:
    out = {}
    with open(".env", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                out[k.strip()] = v.strip()
    return out


def repair(text: str) -> tuple[str, list[str]]:
    if not text:
        return text, []
    notes: list[str] = []

    for pat, rep, why in WRONG_SENSE:
        new, n = re.subn(pat, rep, text)
        if n:
            notes.append(f"wrong-sense x{n}: {why}")
            text = new

    def fix_mid(m: re.Match) -> str:
        en, tail = m.group("en"), m.group("tail")
        # The gloss was injected before the word ended. Drop the gloss: the
        # word it was meant to annotate is a different (usually plural) form,
        # and re-attaching it after the suffix would read as a mistranslation.
        notes.append(f"mid-word: ({en}){tail[:6]}… -> gloss removed")
        return tail

    text = MIDWORD.sub(fix_mid, text)
    return text, notes


def main() -> int:
    apply = "--apply" in sys.argv
    e = env()
    url = (e.get("VITE_SUPABASE_URL") or e["SUPABASE_URL"]).rstrip("/")
    key = e["SUPABASE_SERVICE_ROLE_KEY"]
    auth = ["-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}"]

    rows = json.loads(subprocess.run(
        ["curl", "-s",
         f"{url}/rest/v1/lessons?select=id,title,content,content_ar&limit=500", *auth],
        capture_output=True, text=True, encoding="utf-8").stdout)

    edits, total = [], 0
    for r in rows:
        patch, all_notes = {}, []
        for f in FIELDS:
            new, notes = repair(r.get(f) or "")
            if notes:
                patch[f] = new
                all_notes += [f"[{f}] {n}" for n in notes]
        if patch:
            edits.append((r, patch))
            total += len(all_notes)
            print(f"  {r['title'][:52]}")
            for n in all_notes[:4]:
                print(f"      {n}")
            if len(all_notes) > 4:
                print(f"      … and {len(all_notes) - 4} more")

    print(f"\n{total} defects in {len(edits)} lessons")

    if not apply:
        print("\nDRY RUN — re-run with --apply to write")
        return 0

    os.makedirs("backups", exist_ok=True)
    stamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    bak = os.path.join("backups", f"lessons_preglossfix_{stamp}.json")
    with open(bak, "w", encoding="utf-8") as f:
        json.dump([{k: r.get(k) for k in ("id", "title", *FIELDS)}
                   for r, _ in edits], f, ensure_ascii=False, indent=1)
    print(f"backed up -> {bak}")

    ok = 0
    for r, patch in edits:
        fd, pf = tempfile.mkstemp(suffix=".json")
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump(patch, f, ensure_ascii=False)
        try:
            res = subprocess.run(
                ["curl", "-s", "-w", "\n%{http_code}", "-X", "PATCH",
                 f"{url}/rest/v1/lessons?id=eq.{r['id']}", *auth,
                 "-H", "Content-Type: application/json",
                 "-H", "Prefer: return=minimal", "--data-binary", f"@{pf}"],
                capture_output=True, text=True, encoding="utf-8")
            if res.stdout.rpartition("\n")[2] in ("200", "204"):
                ok += 1
            else:
                print(f"  FAILED {r['title'][:40]}")
        finally:
            os.unlink(pf)

    print(f"updated {ok}/{len(edits)} lessons")
    return 0 if ok == len(edits) else 1


if __name__ == "__main__":
    raise SystemExit(main())
