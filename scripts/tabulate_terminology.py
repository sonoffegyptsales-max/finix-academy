#!/usr/bin/env python3
"""Convert the bilingual terminology lessons into real tables.

Review note 3, pointing at F08: "الدرس بالكامل عباره عن جداول" -- this whole
lesson is really a table. It was authored as running prose:

    **Main living spaces:** Living Room / Reception (غرفة المعيشة / الريسبشن),
    Dining Room (غرفة الطعام / السفرة), Kitchen (المطبخ), ...

A trainee looking up one word has to read a paragraph. As a table it becomes a
reference they can scan, which is the entire purpose of a terminology lesson.

Output per group:

    **Main living spaces / غرف المعيشة الرئيسية**

    | English | العربية |
    |---|---|
    | Living Room / Reception | غرفة المعيشة / الريسبشن |

Only touches the three F08 terminology lessons, whose shape is
"**Group:** Term (ترجمة), Term (ترجمة), ...". Each row is parsed from that
pattern; a group that does not parse cleanly is reported and left untouched
rather than half-converted.

  python3 scripts/tabulate_terminology.py            # dry run
  python3 scripts/tabulate_terminology.py --apply
"""
from __future__ import annotations

import datetime
import json
import os
import re
import subprocess
import sys
import tempfile

TARGET_CODES = {"F08"}

# **Group heading:** rest-of-line
GROUP = re.compile(r"^\*\*(?P<name>[^*]+?):?\*\*\s*(?P<body>.+)$")

# "English term (عربي)" -- the English lesson's shape
ENTRY = re.compile(
    r"(?P<en>[^,()،]+?)\s*\((?P<ar>[^()]*[\u0621-\u064A][^()]*)\)"
)

# "مصطلح عربي (English)" -- the Arabic lesson writes the pair the other way
# round. Parsing only the English shape silently left every Arabic terminology
# lesson as prose while reporting the English one as done.
ENTRY_AR = re.compile(
    r"(?P<ar>[^,()،]*[\u0621-\u064A][^,()،]*?)\s*\((?P<en>[^()]*[A-Za-z][^()]*)\)"
)

AR_HEADINGS = {
    "Main living spaces": "غرف المعيشة الرئيسية",
    "Bedrooms": "غرف النوم",
    "Utility & work spaces": "غرف الخدمات والعمل",
    "Outdoor & leisure spaces": "المساحات الخارجية والترفيهية",
}


def env() -> dict[str, str]:
    out = {}
    with open(".env", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                out[k.strip()] = v.strip()
    return out


def tabulate(text: str, lang: str) -> tuple[str, int, list[str]]:
    """Return (new_text, tables_made, skipped_group_names)."""
    if not text or "|---|" in text:
        return text, 0, []

    lines = text.split("\n")
    out: list[str] = []
    made = 0
    skipped: list[str] = []

    for line in lines:
        m = GROUP.match(line.strip())
        if not m:
            out.append(line)
            continue

        name = m.group("name").strip()
        body = m.group("body").strip()

        # Pick the pattern that matches how THIS language writes the pair.
        if lang == "ar":
            pairs = [(mm.group("en"), mm.group("ar"))
                     for mm in ENTRY_AR.finditer(body)]
        else:
            pairs = [(mm.group("en"), mm.group("ar"))
                     for mm in ENTRY.finditer(body)]
        entries = pairs

        # Require a real list, and require that the entries account for most
        # of the line -- otherwise this is prose that merely has a parenthesis.
        covered = sum(len(a) + len(b) + 2 for a, b in entries)
        if len(entries) < 3 or covered < len(body) * 0.55:
            if len(entries) >= 1:
                skipped.append(f"{name} ({len(entries)} entries, {covered}/{len(body)} chars)")
            out.append(line)
            continue

        hdr_ar = AR_HEADINGS.get(name, "")
        title = f"**{name}" + (f" / {hdr_ar}" if hdr_ar and lang == "en" else "") + "**"
        out.append(title)
        out.append("")
        out.append("| English | العربية |")
        out.append("|---|---|")
        for en, ar in entries:
            en_c = en.strip(" ,.;—-").strip()
            ar_c = ar.strip(" ,.;—-").strip()
            if not en_c or not ar_c:
                continue
            out.append(f"| {en_c} | {ar_c} |")
        out.append("")
        made += 1

    return "\n".join(out), made, skipped


def main() -> int:
    apply = "--apply" in sys.argv
    e = env()
    url = (e.get("VITE_SUPABASE_URL") or e["SUPABASE_URL"]).rstrip("/")
    key = e["SUPABASE_SERVICE_ROLE_KEY"]
    auth = ["-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}"]

    def g(q):
        return json.loads(subprocess.run(["curl", "-s", url + q, *auth],
                                         capture_output=True, text=True,
                                         encoding="utf-8").stdout)

    mods = {m["id"]: m["code"] for m in g("/rest/v1/modules?select=id,code&limit=100")}
    rows = g("/rest/v1/lessons?select=id,module_id,title,content,content_ar&limit=500")
    targets = [r for r in rows if mods.get(r["module_id"]) in TARGET_CODES]
    print(f"{len(targets)} lessons in {'/'.join(sorted(TARGET_CODES))}\n")

    edits, total = [], 0
    for r in targets:
        patch = {}
        for f, lang in (("content", "en"), ("content_ar", "ar")):
            new, n, skipped = tabulate(r.get(f) or "", lang)
            if n:
                patch[f] = new
                total += n
            if skipped:
                print(f"  SKIPPED in {r['title'][:38]} [{f}]:")
                for s in skipped:
                    print(f"      {s}")
        if patch:
            edits.append((r, patch))
            made = sum(patch[f].count("|---|") for f in patch)
            print(f"  {r['title'][:52]:<54} {made} tables")

    print(f"\n{total} tables across {len(edits)} lessons")

    if not apply:
        print("\nDRY RUN — re-run with --apply to write")
        return 0

    os.makedirs("backups", exist_ok=True)
    stamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    bak = os.path.join("backups", f"lessons_pretables_{stamp}.json")
    with open(bak, "w", encoding="utf-8") as f:
        json.dump([{k: r.get(k) for k in ("id", "title", "content", "content_ar")}
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
