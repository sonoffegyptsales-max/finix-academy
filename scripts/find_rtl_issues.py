#!/usr/bin/env python3
"""Find physical-direction Tailwind classes that will NOT mirror under dir=rtl.

Only the app's own routes/components are reported by default; the shadcn
primitives under components/ui are listed separately because many of them are
icon/indicator positioning that is direction-neutral in practice.

Usage: python3 scripts/find_rtl_issues.py [--all]
"""
from __future__ import annotations

import pathlib
import re
import sys

PATTERNS = {
    "ml-": r"\bml-(?:\d+|\[|px\b|auto\b)",
    "mr-": r"\bmr-(?:\d+|\[|px\b|auto\b)",
    "pl-": r"\bpl-(?:\d+|\[|px\b)",
    "pr-": r"\bpr-(?:\d+|\[|px\b)",
    "text-left": r"\btext-left\b",
    "text-right": r"\btext-right\b",
    "left-": r"\bleft-(?:\d+|\[|0\b|full\b|auto\b)",
    "right-": r"\bright-(?:\d+|\[|0\b|full\b|auto\b)",
    "border-l": r"\bborder-l\b(?!g)",
    "border-r": r"\bborder-r\b",
    "rounded-l": r"\brounded-l(?:\b(?!g)|-)",
    "rounded-r": r"\brounded-r(?:\b|-)",
}

SUGGEST = {
    "ml-": "ms-", "mr-": "me-", "pl-": "ps-", "pr-": "pe-",
    "text-left": "text-start", "text-right": "text-end",
    "left-": "start-", "right-": "end-",
    "border-l": "border-s", "border-r": "border-e",
    "rounded-l": "rounded-s", "rounded-r": "rounded-e",
}


def is_ui_primitive(p: pathlib.Path) -> bool:
    parts = p.parts
    return "ui" in parts and "components" in parts


def main() -> int:
    show_all = "--all" in sys.argv
    files = sorted(pathlib.Path("src").rglob("*.tsx"))

    app_hits, ui_hits = [], []
    for f in files:
        text = f.read_text(encoding="utf-8", errors="ignore")
        lines = text.split("\n")
        for name, pat in PATTERNS.items():
            for m in re.finditer(pat, text):
                ln = text[:m.start()].count("\n") + 1
                row = (str(f), ln, name, SUGGEST[name], lines[ln - 1].strip()[:86])
                (ui_hits if is_ui_primitive(f) else app_hits).append(row)

    def dump(rows, title):
        print(f"\n===== {title}: {len(rows)} occurrence(s)")
        for path, ln, name, sug, src in sorted(rows):
            short = path.replace("src" + chr(92), "").replace("src/", "")
            print(f"  {short}:{ln}")
            print(f"      {name}  ->  {sug}   |  {src}")

    dump(app_hits, "APP CODE (fix these)")
    if show_all:
        dump(ui_hits, "shadcn primitives (usually safe)")
    else:
        print(f"\n(+ {len(ui_hits)} in components/ui — rerun with --all to list)")

    print(f"\ntotal app-code issues: {len(app_hits)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
