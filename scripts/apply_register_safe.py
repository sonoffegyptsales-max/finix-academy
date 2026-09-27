#!/usr/bin/env python3
"""Apply the SAFE half of the Egyptian-register change.

The register spec is docs/ARABIC_REGISTER.md, derived from a paragraph the
client approved verbatim.

This script does ONLY the substitutions that are safe without reading the
sentence. Anything whose correctness depends on context is deliberately left
for hand-authoring -- see the REJECTED list below for what was considered and
dropped, and why.

Measured: 562 candidate substitutions, but only the subset here is safe.

  python3 scripts/apply_register_safe.py            # dry run
  python3 scripts/apply_register_safe.py --apply
"""
from __future__ import annotations

import datetime
import json
import os
import re
import subprocess
import sys
import tempfile

# ---------------------------------------------------------------- SAFE
# Trade loanwords and fixed noun phrases. These carry the same meaning in any
# sentence position, so a blind swap cannot change what a sentence claims.
SAFE: list[tuple[str, str, str]] = [
    # (pattern, replacement, note)
    (r"ريليه الاستشعار", "ريليه الحساس (Sensing Relay)",
     "approved reference wording"),
    (r"(?<![\w\u0621-\u064A])المؤقّت(?![\w\u0621-\u064A])", "التايمر (Timer)",
     "technicians say التايمر"),
    (r"(?<![\w\u0621-\u064A])المؤقت(?![\w\u0621-\u064A])", "التايمر (Timer)",
     "unpointed spelling of the same word"),
    (r"(?<![\w\u0621-\u064A])عنصر الاستشعار(?![\w\u0621-\u064A])",
     "الحساس (Sensor)", "the part itself"),
    (r"(?<![\w\u0621-\u064A])نطاق التباطؤ(?![\w\u0621-\u064A])",
     "الهيستيريسيس (Hysteresis)", "loanword is the spoken term"),
    (r"(?<![\w\u0621-\u064A])الدائرة(?![\w\u0621-\u064A])", "الدايرة",
     "colloquial form, same word"),
    (r"(?<![\w\u0621-\u064A])بقية دائرة التحكم(?![\w\u0621-\u064A])",
     "باقي دايرة التحكم", "from the approved paragraph"),
    (r"(?<![\w\u0621-\u064A])الماء(?![\w\u0621-\u064A])", "الميّة",
     "colloquial form, same word"),
]

# ------------------------------------------------------------ REJECTED
# Considered and NOT applied. Each would need the sentence read first.
#
#   يعمل -> بيشتغل      "يعمل على" (works on) vs "يعمل" (operates) differ;
#                        and "يعمل" appears inside quoted English glosses.
#   يحوّل -> بيحوّل      correct in habitual statements, wrong in conditionals
#                        ("إذا حوّل") and in imperatives.
#   يستخدم -> بيستخدم   often passive/impersonal ("يُستخدم") where the
#                        colloquial habitual is simply wrong.
#   هل -> (delete)      deleting the interrogative leaves a broken question;
#                        the Egyptian form needs "... ولا لأ" appended, which
#                        is a rewrite, not a swap.
#   كم -> قد إيه        changes word ORDER ("كم الإضاءة" -> "النور قد إيه"),
#                        so it cannot be a find-and-replace.
#   شيء -> حاجة         fine in prose, wrong inside fixed technical phrases
#                        ("شيء من الجهد" style constructions).
#   الدائرة الكهربائية   left alone: the full formal phrase is correct as-is.
#
# The verb forms in particular are why 58 lessons still need authoring.

FIELD = "content_ar"

# Never touch inside these: code/formula blocks, table rows, English glosses.
FENCE = re.compile(r"```.*?```", re.S)
PAREN_EN = re.compile(r"\([^)]*[A-Za-z][^)]*\)")


def env() -> dict[str, str]:
    out = {}
    with open(".env", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                out[k.strip()] = v.strip()
    return out


def protect(text: str) -> tuple[str, dict[str, str]]:
    """Mask regions that must not be rewritten."""
    store: dict[str, str] = {}

    def stash(m: re.Match) -> str:
        key = f"\x00{len(store)}\x00"
        store[key] = m.group(0)
        return key

    text = FENCE.sub(stash, text)
    text = PAREN_EN.sub(stash, text)
    return text, store


def restore(text: str, store: dict[str, str]) -> str:
    for k, v in store.items():
        text = text.replace(k, v)
    return text


def convert(text: str) -> tuple[str, list[tuple[str, int]]]:
    if not text:
        return text, []
    masked, store = protect(text)
    hits: list[tuple[str, int]] = []
    for pat, rep, _note in SAFE:
        masked, n = re.subn(pat, rep, masked)
        if n:
            hits.append((pat, n))
    # Collapse a double gloss if the term already carried one nearby.
    masked = re.sub(r"\((Sensing Relay|Timer|Sensor|Hysteresis)\)\s*\(\1\)",
                    r"(\1)", masked)
    return restore(masked, store), hits


def main() -> int:
    apply = "--apply" in sys.argv
    e = env()
    url = (e.get("VITE_SUPABASE_URL") or e["SUPABASE_URL"]).rstrip("/")
    key = e["SUPABASE_SERVICE_ROLE_KEY"]
    auth = ["-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}"]

    rows = json.loads(subprocess.run(
        ["curl", "-s",
         f"{url}/rest/v1/lessons?select=id,title,{FIELD}&limit=500", *auth],
        capture_output=True, text=True, encoding="utf-8").stdout)

    edits, total = [], 0
    for r in rows:
        new, hits = convert(r.get(FIELD) or "")
        if hits:
            n = sum(c for _, c in hits)
            total += n
            edits.append((r, new, n))

    for r, new, n in edits[:10]:
        print(f"  {r['title'][:54]:<56} {n} swaps")
        old_lines = (r.get(FIELD) or "").split("\n")
        for i, ln in enumerate(new.split("\n")):
            if i < len(old_lines) and ln != old_lines[i]:
                print(f"      - {old_lines[i][:70]}")
                print(f"      + {ln[:70]}")
                break
    if len(edits) > 10:
        print(f"  … and {len(edits) - 10} more lessons")

    print(f"\n{total} safe substitutions in {len(edits)} lessons")
    print("Verb forms and question structures are NOT included — they need "
          "the sentence read. See the REJECTED block in this script.")

    if not apply:
        print("\nDRY RUN — re-run with --apply to write")
        return 0

    os.makedirs("backups", exist_ok=True)
    stamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    bak = os.path.join("backups", f"lessons_preregister_{stamp}.json")
    with open(bak, "w", encoding="utf-8") as f:
        json.dump([{"id": r["id"], "title": r["title"], FIELD: r.get(FIELD)}
                   for r, _, _ in edits], f, ensure_ascii=False, indent=1)
    print(f"\nbacked up {len(edits)} rows -> {bak}")

    ok = 0
    for r, new, _ in edits:
        fd, pf = tempfile.mkstemp(suffix=".json")
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump({FIELD: new}, f, ensure_ascii=False)
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
