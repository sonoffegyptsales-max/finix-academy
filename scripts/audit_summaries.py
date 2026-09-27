#!/usr/bin/env python3
"""Audit module summary_ar for the rejected MSA register.

Third field in the chain. The body is content_ar, the heading is title_ar, and
the paragraph under a module heading is summary_ar -- three separate columns,
so a pass over one silently skips the others. The I05 module summary still read
"ريليهات تراقب حالة فيزيائية وتتصرف بناءً عليها" after both the body and the
title had been corrected.

  python3 scripts/audit_summaries.py
"""
from __future__ import annotations

import json
import re
import subprocess

TERMS = {
    "الاستشعار": "الحساس",
    "التباطؤ": "الهيستيريسيس",
    "المؤقتات": "التايمرات",
    "المؤقّتات": "التايمرات",
    "المؤقت": "التايمر",
    "المؤقّت": "التايمر",
    "الدوائر": "الدواير",
    "الدائرة": "الدايرة",
}

MSA_SHAPE = {
    "بناءً على": re.compile(r"\bبناءً على\b"),
    "أما … فـ": re.compile(r"\bأما\b[^.!?]{0,60}\bفـ?[يت]"),
    "من حيث / وذلك": re.compile(r"\bمن حيث\b|\bوذلك\b"),
    "كيفية": re.compile(r"\bكيفية\b"),
    "بما أن": re.compile(r"\bبما أن\b"),
    "في حين أن": re.compile(r"\bفي حين أن\b"),
    "MSA present verb": re.compile(
        r"(?<![\w\u0621-\u064A])(?:يعمل|تعمل|يقوم|تقوم|يتم|تتناول|يتناول|"
        r"تراقب|يراقب|تتصرف|يتصرف|تغطي|يغطي)(?![\w\u0621-\u064A])"),
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


def main() -> int:
    e = env()
    url = (e.get("VITE_SUPABASE_URL") or e["SUPABASE_URL"]).rstrip("/")
    key = e["SUPABASE_SERVICE_ROLE_KEY"]
    A = ["-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}"]

    mods = json.loads(subprocess.run(
        ["curl", "-s",
         f"{url}/rest/v1/modules?select=id,code,title,summary,summary_ar"
         f"&order=code&limit=100", *A],
        capture_output=True, text=True, encoding="utf-8").stdout)

    need = []
    for m in mods:
        s = m.get("summary_ar") or ""
        if not s.strip():
            continue
        terms = [t for t in TERMS if t in s]
        terms = [t for t in terms
                 if not any(t != o and t in o and o in s for o in terms)]
        shapes = [n for n, p in MSA_SHAPE.items() if p.search(s)]
        if terms or shapes:
            need.append((m, terms, shapes))

    print(f"{'=' * 72}\nMODULE summary_ar — {len(need)} of {len(mods)} need rewriting\n{'=' * 72}")
    for m, terms, shapes in need:
        print(f"\n  {m['code']} · {m['title'][:50]}")
        print(f"     {(m.get('summary_ar') or '')[:150]}")
        if terms:
            print(f"     terms:  {', '.join(terms)}")
        if shapes:
            print(f"     shape:  {', '.join(shapes)}")

    print(f"\n{'=' * 72}")
    print(f"  modules {len(mods):>3}   needing change {len(need):>3}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
