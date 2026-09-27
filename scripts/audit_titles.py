#!/usr/bin/env python3
"""Audit Arabic LESSON AND MODULE TITLES for the old MSA register.

Found while verifying the first rewritten lesson: the body had been rewritten
into the approved Egyptian register, but the heading directly above it still
read "ما هو ريليه الاستشعار ولماذا يحتاج نطاق تباطؤ" -- the exact MSA wording
the client rejected, sitting on top of the corrected text.

Titles live in title_ar on lessons and modules, a different field from the body,
so every body-level pass silently skipped them. They are also the MOST visible
text: a trainee reads the heading before the paragraph.

  python3 scripts/audit_titles.py
"""
from __future__ import annotations

import json
import re
import subprocess

# Rejected-register terms that appear in headings, mapped to the approved form.
TERMS = {
    "ريليه الاستشعار": "ريليه الحساس",
    "الاستشعار": "الحساس",
    "نطاق تباطؤ": "الهيستيريسيس",
    "نطاق التباطؤ": "الهيستيريسيس",
    "التباطؤ": "الهيستيريسيس",
    "المؤقتات": "التايمرات",
    "المؤقّتات": "التايمرات",
    "المؤقت": "التايمر",
    "المؤقّت": "التايمر",
    "الدائرة": "الدايرة",
    "الدوائر": "الدواير",
}

# MSA heading patterns the client flagged as translation-shaped.
MSA_SHAPE = {
    "ما هو … ولماذا": re.compile(r"^ما\s+(?:هو|هي)\b.*\bولماذا\b"),
    "لماذا يحتاج": re.compile(r"\bلماذا\s+يحتاج\b"),
    "كيفية": re.compile(r"\bكيفية\b"),
    "بناءً على": re.compile(r"\bبناءً على\b"),
    "من حيث": re.compile(r"\bمن حيث\b"),
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

    def g(q):
        return json.loads(subprocess.run(["curl", "-s", url + q, *A],
                                         capture_output=True, text=True,
                                         encoding="utf-8").stdout)

    mods = g("/rest/v1/modules?select=id,code,title,title_ar&order=code&limit=100")
    modmap = {m["id"]: m["code"] for m in mods}
    lessons = g("/rest/v1/lessons?select=id,module_id,position,title,title_ar&limit=500")

    def scan(label, rows, keyfn):
        hits = []
        for r in rows:
            ar = r.get("title_ar") or ""
            if not ar.strip():
                continue
            terms = [t for t in TERMS if t in ar]
            # keep only the longest match when terms nest (الاستشعار in ريليه الاستشعار)
            terms = [t for t in terms
                     if not any(t != o and t in o and o in ar for o in terms)]
            shapes = [n for n, p in MSA_SHAPE.items() if p.search(ar)]
            if terms or shapes:
                hits.append((keyfn(r), ar, terms, shapes))
        print(f"\n{'=' * 72}\n{label} — {len(hits)} need attention\n{'=' * 72}")
        for tag, ar, terms, shapes in hits:
            print(f"  {tag}")
            print(f"     {ar}")
            if terms:
                print(f"     terms:  {', '.join(terms)} -> "
                      f"{', '.join(TERMS[t] for t in terms)}")
            if shapes:
                print(f"     shape:  {', '.join(shapes)}")
        return hits

    mh = scan("MODULE titles", mods, lambda r: f"{r['code']} · {r['title'][:44]}")
    lh = scan("LESSON titles", lessons,
              lambda r: f"{modmap.get(r['module_id'], '??')} L{r['position']} · {r['title'][:40]}")

    print(f"\n{'=' * 72}")
    print(f"  modules total {len(mods):>3}   needing change {len(mh):>3}")
    print(f"  lessons total {len(lessons):>3}   needing change {len(lh):>3}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
