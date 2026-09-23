#!/usr/bin/env python3
"""Convert hand-typed pseudo-numbering into real Markdown ordered lists.

The course review said numbered points do not start at the beginning of the
line. The cause was NOT CSS: many lessons were authored with the number folded
into bold text at the start of a paragraph --

    **1- مهندس/فني الشبكات** — هو "العمود الفقري" للمنزل...

Markdown parses that as a paragraph whose first characters happen to be a
digit, so no <ol> is produced, no marker is generated, and list styling has
nothing to act on. In an RTL paragraph the trailing "-" also lands on the wrong
side of the digit, which is why the Arabic looked worse than the English.

Rewritten to real Markdown:

    1. **مهندس/فني الشبكات** — هو "العمود الفقري" للمنزل...

The renderer then emits a true <ol><li>, the browser draws the marker at the
line start, and it mirrors correctly under dir="rtl" with no custom CSS.

Handles Western (1-9) and Arabic-Indic (٠-٩) digits, and the separators
- – . ، ) that appear in the corpus. Arabic-Indic numerals are normalised to
Western digits because Markdown only recognises those as list markers; the
browser renders them per the page's locale anyway.

Safety:
  * dry run by default, --apply to write
  * backs up every affected row first
  * only rewrites a line when the SAME field has 2+ such lines (a lone
    "2024-" or "3.5 mm" is never a list)
  * skips fenced code blocks and markdown table rows
  * leaves lines that are already valid Markdown lists alone

Usage:
  python3 scripts/fix_pseudo_numbering.py            # dry run
  python3 scripts/fix_pseudo_numbering.py --apply
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

AR_DIGITS = "٠١٢٣٤٥٦٧٨٩"
TRANS = {ord(c): str(i) for i, c in enumerate(AR_DIGITS)}

# **1- text**  |  **١. text**  |  1- text  |  ١- text  |  **٢.** text
#
# The number is often INSIDE the bold run: "**١- مهندس/فني الشبكات** — ...".
# That is the hardest variant to spot and the most common in this corpus, so
# the separator may be followed by a space OR directly by more bold text.
PSEUDO = re.compile(
    r"^(?P<indent>[ \t]{0,3})"
    r"(?P<bold>\*\*)?"
    r"(?P<num>[0-9\u0660-\u0669]{1,2})"
    r"(?P<sep>[-\u2013.\u060d)])"
    r"(?P<space>[ ]+|(?=\*\*)|(?=[^\s\d]))"
    r"(?P<rest>.*)$"
)
ALREADY_OK = re.compile(r"^[ \t]{0,3}[0-9]{1,2}\.[ ]")


def env() -> dict[str, str]:
    out = {}
    with open(".env", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                out[k.strip()] = v.strip()
    return out


def convert(text: str) -> tuple[str, int]:
    """Return (new_text, changes). Only acts when 2+ candidates exist."""
    if not text:
        return text, 0

    lines = text.split("\n")
    in_fence = False
    candidates = []

    for i, ln in enumerate(lines):
        if ln.lstrip().startswith("```"):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        if ln.lstrip().startswith("|"):      # markdown table row
            continue
        if ALREADY_OK.match(ln):             # already a real list
            continue
        m = PSEUDO.match(ln)
        if not m:
            continue
        # A number followed by "-" and another WESTERN digit is a range or a
        # date ("2024-2025", "3-5 metres"), not a list. Use an explicit range
        # check: Python's str.isdigit() is True for Arabic-Indic numerals too,
        # so it silently rejected every "**٢- ..." line -- the exact form the
        # reviewer screenshotted.
        rest = m.group("rest")
        if rest[:1] in "0123456789":
            continue
        candidates.append((i, m))

    if len(candidates) < 2:
        return text, 0

    changed = 0
    for i, m in candidates:
        num = m.group("num").translate(TRANS)
        rest = m.group("rest")
        bold = m.group("bold") or ""
        # Re-attach the bold opener that belonged to the text, not the number.
        lines[i] = f"{m.group('indent')}{num}. {bold}{rest}"
        changed += 1

    return "\n".join(lines), changed


def main() -> int:
    apply = "--apply" in sys.argv
    e = env()
    url = (e.get("VITE_SUPABASE_URL") or e["SUPABASE_URL"]).rstrip("/")
    key = e["SUPABASE_SERVICE_ROLE_KEY"]
    auth = ["-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}"]

    raw = subprocess.run(
        ["curl", "-s", f"{url}/rest/v1/lessons?select=id,title,content,content_ar&limit=500",
         *auth], capture_output=True, text=True, encoding="utf-8").stdout
    rows = json.loads(raw)
    print(f"scanning {len(rows)} lessons\n")

    edits, total = [], 0
    for r in rows:
        patch = {}
        for f in FIELDS:
            new, n = convert(r.get(f) or "")
            if n:
                patch[f] = new
                total += n
        if patch:
            edits.append((r, patch))

    for r, patch in edits[:6]:
        print(f"  {r['title'][:54]}")
        for f in patch:
            src = (r.get(f) or "").split("\n")
            dst = patch[f].split("\n")
            shown = 0
            for a, b in zip(src, dst):
                if a != b and shown < 2:
                    print(f"    {f}:")
                    print(f"      - {a[:74]}")
                    print(f"      + {b[:74]}")
                    shown += 1
    if len(edits) > 6:
        print(f"  … and {len(edits) - 6} more lessons")

    print(f"\n{total} pseudo-numbered lines in {len(edits)} lessons")

    if not apply:
        print("\nDRY RUN — re-run with --apply to write")
        return 0

    os.makedirs("backups", exist_ok=True)
    stamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    bak = os.path.join("backups", f"lessons_prenumbering_{stamp}.json")
    with open(bak, "w", encoding="utf-8") as f:
        json.dump([{k: r.get(k) for k in ("id", "title", *FIELDS)}
                   for r, _ in edits], f, ensure_ascii=False, indent=1)
    print(f"\nbacked up {len(edits)} rows -> {bak}")

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
            code = res.stdout.rpartition("\n")[2]
            if code in ("200", "204"):
                ok += 1
            else:
                print(f"  FAILED {r['title'][:40]}: {code}")
        finally:
            os.unlink(pf)

    print(f"updated {ok}/{len(edits)} lessons")
    return 0 if ok == len(edits) else 1


if __name__ == "__main__":
    raise SystemExit(main())
