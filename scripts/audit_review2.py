#!/usr/bin/env python3
"""Enumerate every instance of the six problem classes in review round 2.

The reviewer stated the governing rule explicitly:

    "بشكل العام الملحوظه هى مثال وليست حصر ولذلك يفترض تطبيقها على كل ما هو شبيه بها"
    (the note is an EXAMPLE, not an exhaustive list -- apply it to everything
     similar)

So a screenshot of one broken lesson is a sample of a class. This script finds
the whole class for each of the six notes, so the work is targeted at a
measured population instead of the handful that happened to be screenshotted.

Classes:
  1 DIAGRAM_CORRECTNESS  figures whose labelling may be wrong/incomplete
  2 EQUATIONS            formulas and worked examples not visually set apart
  3 TABLE_LESSONS        lessons that are really reference lists, not prose
  4 ENGLISH_GLOSS        Arabic technical terms with no English equivalent
  5 TRANSLATIONESE       Arabic that mirrors English clause-for-clause
  6 MISSING_FIGURES      lessons describing circuits/components with no figure

Run: python3 scripts/audit_review2.py [--class N] [--json out.json]
"""
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
from collections import Counter

# Terms the reviewer wants carrying an English equivalent (Latin or
# Arabic-letter transliteration) on first use.
GLOSS_TERMS = {
    "الاستشعار": "Sensor", "المستشعر": "Sensor", "الحساس": "Sensor",
    "التباطؤ": "Hysteresis", "العتبة": "Threshold",
    "الكونتاكتور": "Contactor", "المرحل": "Relay", "الريليه": "Relay",
    "القاطع": "Breaker", "المؤقت": "Timer", "المؤقّت": "Timer",
    "الحمل": "Load", "الجهد": "Voltage", "التيار": "Current",
    "القدرة": "Power", "المقاومة": "Resistance", "التردد": "Frequency",
    "الطور": "Phase", "الأطوار": "Phases", "المحايد": "Neutral",
    "التأريض": "Earthing", "البوابة": "Gateway", "الشبكية": "Mesh",
    "التعتيم": "Dimming", "المشهد": "Scene", "الأتمتة": "Automation",
    "اللوحة": "Panel", "الملف": "Coil", "التلامس": "Contact",
    "التعشيق": "Interlock", "التثبيت": "Latching",
}

# Formula-ish signals: an equals sign with operators, or a known symbol set.
EQ_PATTERNS = [
    re.compile(r"[A-Za-z\u0621-\u064A()]\s*=\s*[^=\n]{3,}[×x*/÷+\-]"),
    re.compile(r"√\s*3|1\.732|cos\s*\(?\s*[θΦφ]"),
    re.compile(r"\bP\s*=|\bI\s*=|\bV\s*=|\bR\s*=|\bkW\b|\bkVA\b"),
]
WORKED = re.compile(
    r"worked example|Worked example|مثال محلول|مثال عملي|مثال تطبيقي|"
    r"المطلوب:|احسب|Calculate|required for", re.I)

# Prose that describes a circuit/component but may lack a figure.
CIRCUIT_WORDS = re.compile(
    r"\b(circuit|wiring|terminal|contactor|relay|breaker|coil|winding|"
    r"schematic|diagram|connect|starter|panel)\b", re.I)
CIRCUIT_AR = re.compile(
    r"(دائرة|توصيل|طرف|كونتاكتور|مرحل|قاطع|ملف|ملفات|لوحة|مخطط|بادئ)")

# Direct-translation signal: Arabic sentence structure that tracks English
# word order, em-dash parentheticals copied verbatim, and calqued connectives.
TRANSLATIONESE = [
    re.compile(r"—\s*[^—\n]{10,}\s*—"),          # doubled em-dash asides
    re.compile(r"\bوهو ما\b|\bوهذا ما\b|\bالذي هو\b|\bبما أن\b"),
    re.compile(r"\bيمكن أن يكون\b|\bسوف يكون\b|\bمن المهم أن\b"),
    re.compile(r"\bفي حين أن\b|\bعلى الرغم من أن\b|\bبالإضافة إلى ذلك\b"),
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


def fetch():
    e = env()
    url = (e.get("VITE_SUPABASE_URL") or e["SUPABASE_URL"]).rstrip("/")
    key = e["SUPABASE_SERVICE_ROLE_KEY"]
    A = ["-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}"]

    def g(q):
        r = subprocess.run(["curl", "-s", url + q, *A],
                           capture_output=True, text=True, encoding="utf-8")
        return json.loads(r.stdout)

    mods = {m["id"]: m for m in g("/rest/v1/modules?select=id,code,title,slug&limit=100")}
    lessons = g("/rest/v1/lessons?select=id,module_id,position,title,title_ar,"
                "content,content_ar&limit=500")
    media = g("/rest/v1/lesson_media?select=lesson_id,kind,storage_path&limit=900")
    return mods, lessons, media


def has_gloss(text: str, term: str, eng: str) -> bool:
    """True if this term already carries an English or transliterated gloss."""
    i = text.find(term)
    if i < 0:
        return True  # not present at all
    window = text[i:i + len(term) + 42]
    if eng.lower() in window.lower():
        return True
    # any Latin run, or a parenthetical, counts as a gloss attempt
    return bool(re.search(r"\([^)]*[A-Za-z][^)]*\)", window))


def main() -> int:
    only = None
    if "--class" in sys.argv:
        only = int(sys.argv[sys.argv.index("--class") + 1])

    mods, lessons, media = fetch()
    fig_by_lesson = Counter()
    for m in media:
        if not m["storage_path"].startswith("http"):
            fig_by_lesson[m["lesson_id"]] += 1

    report: dict[str, list] = {k: [] for k in
                               ("equations", "table_lessons", "english_gloss",
                                "translationese", "missing_figures")}

    for L in lessons:
        mod = mods.get(L["module_id"], {})
        code = mod.get("code", "??")
        en, ar = L.get("content") or "", L.get("content_ar") or ""
        tag = f"{code} L{L['position']} · {L['title'][:46]}"

        # 2 EQUATIONS -------------------------------------------------------
        eq_hits = sum(len(p.findall(en)) + len(p.findall(ar)) for p in EQ_PATTERNS)
        worked = len(WORKED.findall(en)) + len(WORKED.findall(ar))
        # already set apart if inside a fenced block or a blockquote
        fenced = en.count("```") + ar.count("```")
        if (eq_hits >= 2 or worked >= 1) and fenced == 0:
            report["equations"].append(
                {"id": L["id"], "tag": tag, "formulas": eq_hits, "worked": worked})

        # 3 TABLE_LESSONS ---------------------------------------------------
        # reference-style: many " / " pairs or many parenthetical glosses,
        # but few or no real markdown table rows
        pairs = len(re.findall(r"[A-Za-z][^\n/|]{2,28}/\s*[A-Za-z(]", en))
        gloss_pairs = len(re.findall(r"\([^)]{2,30}\)", ar))
        rows = en.count("\n|") + ar.count("\n|")
        if (pairs >= 8 or gloss_pairs >= 12) and rows < 4:
            report["table_lessons"].append(
                {"id": L["id"], "tag": tag, "pairs": pairs,
                 "gloss_pairs": gloss_pairs, "table_rows": rows})

        # 4 ENGLISH_GLOSS ---------------------------------------------------
        missing = [t for t, eng in GLOSS_TERMS.items()
                   if t in ar and not has_gloss(ar, t, eng)]
        if missing:
            report["english_gloss"].append(
                {"id": L["id"], "tag": tag, "terms": missing[:8],
                 "count": len(missing)})

        # 5 TRANSLATIONESE --------------------------------------------------
        tr = sum(len(p.findall(ar)) for p in TRANSLATIONESE)
        if tr >= 3:
            report["translationese"].append(
                {"id": L["id"], "tag": tag, "signals": tr,
                 "ar_len": len(ar)})

        # 6 MISSING_FIGURES -------------------------------------------------
        circuit = len(CIRCUIT_WORDS.findall(en)) + len(CIRCUIT_AR.findall(ar))
        if circuit >= 6 and fig_by_lesson[L["id"]] == 0:
            report["missing_figures"].append(
                {"id": L["id"], "tag": tag, "circuit_mentions": circuit})

    titles = {
        "equations": "2. Equations / worked examples NOT visually set apart",
        "table_lessons": "3. Reference lessons that should be TABLES",
        "english_gloss": "4. Arabic terms missing an English equivalent",
        "translationese": "5. Arabic reading as direct translation",
        "missing_figures": "6. Circuit/component lessons with NO figure",
    }
    order = ["equations", "table_lessons", "english_gloss",
             "translationese", "missing_figures"]

    for i, key in enumerate(order, start=2):
        if only and only != i:
            continue
        items = report[key]
        print(f"\n{'=' * 68}\n{titles[key]}  —  {len(items)} lessons\n{'=' * 68}")
        for it in items[:24]:
            extra = {k: v for k, v in it.items() if k not in ("id", "tag")}
            print(f"  {it['tag']:<58} {extra}")
        if len(items) > 24:
            print(f"  … and {len(items) - 24} more")

    print(f"\n{'=' * 68}\nTOTALS")
    for key in order:
        print(f"  {titles[key][:52]:<54} {len(report[key]):>3}")
    print(f"  {'lessons total':<54} {len(lessons):>3}")

    if "--json" in sys.argv:
        out = sys.argv[sys.argv.index("--json") + 1]
        with open(out, "w", encoding="utf-8") as f:
            json.dump(report, f, ensure_ascii=False, indent=1)
        print(f"\nwrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
