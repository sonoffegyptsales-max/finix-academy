#!/usr/bin/env python3
"""Convert physical-direction Tailwind classes to logical ones in app code.

Physical classes (ml-, pr-, text-left, left-, border-r ...) do not mirror when
the document flips to dir="rtl", so Arabic ends up with left-aligned text and
gutters on the wrong side. The logical equivalents (ms-, pe-, text-start,
start-, border-e ...) mirror automatically.

Deliberately skips components/ui: those shadcn primitives use physical classes
for things like dropdown chevrons and OTP separators where flipping is either
irrelevant or actively wrong, and they are upstream code we do not own.

Run with --apply to write; default is a dry run.
"""
from __future__ import annotations

import pathlib
import re
import sys

# (pattern, replacement) -- ordered, longest/most specific first.
RULES: list[tuple[str, str]] = [
    (r"\btext-left\b", "text-start"),
    (r"\btext-right\b", "text-end"),
    (r"\bml-(\d+|px|auto|\[[^\]]+\])", r"ms-\1"),
    (r"\bmr-(\d+|px|auto|\[[^\]]+\])", r"me-\1"),
    (r"\bpl-(\d+|px|\[[^\]]+\])", r"ps-\1"),
    (r"\bpr-(\d+|px|\[[^\]]+\])", r"pe-\1"),
    # negative margins keep their sign: -ml-1 -> -ms-1
    (r"-ml-(\d+|px|\[[^\]]+\])", r"-ms-\1"),
    (r"-mr-(\d+|px|\[[^\]]+\])", r"-me-\1"),
    (r"\bborder-l\b(?!g)", "border-s"),
    (r"\bborder-r\b", "border-e"),
    # file: variants used on upload inputs
    (r"\bfile:mr-(\d+)", r"file:me-\1"),
    (r"\bfile:ml-(\d+)", r"file:ms-\1"),
]

# Positional utilities need care: only convert when clearly a layout offset.
POSITIONAL = [
    (r"(?<![\w-])left-(\d+|0|full|auto|\[[^\]]+\])", r"start-\1"),
    (r"(?<![\w-])right-(\d+|0|full|auto|\[[^\]]+\])", r"end-\1"),
    (r"-left-(\d+|\[[^\]]+\])", r"-start-\1"),
    (r"-right-(\d+|\[[^\]]+\])", r"-end-\1"),
]


def is_ui_primitive(p: pathlib.Path) -> bool:
    parts = p.parts
    return "ui" in parts and "components" in parts


def main() -> int:
    apply = "--apply" in sys.argv
    files = [f for f in sorted(pathlib.Path("src").rglob("*.tsx"))
             if not is_ui_primitive(f)]

    total = 0
    for f in files:
        original = f.read_text(encoding="utf-8")
        text = original
        changes: list[str] = []

        for pat, rep in RULES + POSITIONAL:
            new, n = re.subn(pat, rep, text)
            if n:
                changes.append(f"{pat} -> {rep} ({n})")
                text = new

        if text != original:
            total += len(changes)
            rel = str(f)
            print(f"\n{rel}")
            for c in changes:
                print(f"    {c}")
            if apply:
                f.write_text(text, encoding="utf-8")

    print(f"\n{'APPLIED' if apply else 'DRY RUN'} — {total} rule application(s)")
    if not apply:
        print("re-run with --apply to write changes")
    return 0


if __name__ == "__main__":
    sys.exit(main())
