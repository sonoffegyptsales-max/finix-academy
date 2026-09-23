#!/usr/bin/env python3
"""Add the English gloss beside agreed Arabic technical terms.

The course review asked that field terms carry the English word on first use --
"الشبكية (Mesh)", "التعتيم (Dimming)" -- because Egyptian technicians say the
English word in practice.

Rules that keep this safe to run unattended:

  * FIRST occurrence only, per lesson field. Glossing every mention turns prose
    into noise.
  * Skip a field that already glosses the term anywhere (the author may have
    written it differently, e.g. "شبكة mesh").
  * Never touch text inside a markdown table row, a code span, or a bold run --
    injecting parentheses there breaks the column count or the markup.
  * Never gloss inside an existing parenthesis.

Dry run by default; pass --apply to write.
"""
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import tempfile

# Arabic term -> English gloss. Longest terms first so "التحكم المحلي" is
# matched before "التحكم" would be by a shorter rule.
TERMS: list[tuple[str, str]] = [
    ("التحكم المحلي", "Local Control"),
    ("الشبكية", "Mesh"),
    ("الشبكيه", "Mesh"),
    ("التعتيم", "Dimming"),
    ("الأتمتة", "Automation"),
    ("الاتمتة", "Automation"),
    ("الأتمته", "Automation"),
    ("المشاهد", "Scenes"),
    ("المشهد", "Scene"),
    ("السحابة", "Cloud"),
    ("السحابه", "Cloud"),
    ("البوابة", "Gateway"),
    ("المستشعر", "Sensor"),
    ("الحساس", "Sensor"),
    ("القاطع", "Breaker"),
    ("الملامس", "Contactor"),
    ("المرحل", "Relay"),
    ("التأريض", "Earthing"),
    ("الحمل", "Load"),
    ("الجهد", "Voltage"),
    ("التيار", "Current"),
    ("الطور", "Phase"),
]


def env() -> dict:
    out = {}
    for line in open(".env", encoding="utf-8"):
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            k, v = line.split("=", 1)
            out[k.strip()] = v.strip()
    return out


E = env()
URL = E.get("SUPABASE_URL") or E.get("VITE_SUPABASE_URL")
KEY = E.get("SUPABASE_SERVICE_ROLE_KEY")
AUTH = ["-H", f"Authorization: Bearer {KEY}", "-H", f"apikey: {KEY}"]


def fetch_lessons() -> list[dict]:
    p = subprocess.run(
        ["curl", "-s",
         f"{URL}/rest/v1/lessons?select=id,title,content_ar&limit=500", *AUTH],
        capture_output=True, text=True)
    return json.loads(p.stdout)


def patch_lesson(lesson_id: str, content_ar: str) -> bool:
    fd, path = tempfile.mkstemp(suffix=".json")
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        json.dump({"content_ar": content_ar}, f, ensure_ascii=False)
    p = subprocess.run(
        ["curl", "-s", "-o", os.devnull, "-w", "%{http_code}",
         "-X", "PATCH", f"{URL}/rest/v1/lessons?id=eq.{lesson_id}",
         *AUTH, "-H", "Content-Type: application/json",
         "-H", "Prefer: return=minimal",
         "--data-binary", f"@{path}"],
        capture_output=True, text=True)
    os.unlink(path)
    return p.stdout.strip() in ("200", "204")


def protected_spans(text: str) -> list[tuple[int, int]]:
    """Ranges that must not be edited: table rows, code spans, parentheses."""
    spans: list[tuple[int, int]] = []
    for m in re.finditer(r"^\s*\|.*$", text, re.M):      # table rows
        spans.append((m.start(), m.end()))
    for m in re.finditer(r"`[^`]*`", text):              # inline code
        spans.append((m.start(), m.end()))
    for m in re.finditer(r"\([^)]*\)", text):            # existing parens
        spans.append((m.start(), m.end()))
    return spans


def in_protected(pos: int, spans: list[tuple[int, int]]) -> bool:
    return any(a <= pos < b for a, b in spans)


def gloss_field(text: str) -> tuple[str, list[str]]:
    """Insert the English gloss at the first safe occurrence of each term."""
    added: list[str] = []
    for ar, en in TERMS:
        # Already glossed anywhere in this field -> leave the author's wording.
        if re.search(re.escape(en), text, re.I):
            continue

        spans = protected_spans(text)
        for m in re.finditer(re.escape(ar), text):
            if in_protected(m.start(), spans):
                continue
            # Don't gloss when the very next characters already open a paren.
            tail = text[m.end():m.end() + 2]
            if tail.strip().startswith("("):
                break
            text = f"{text[:m.end()]} ({en}){text[m.end():]}"
            added.append(f"{ar}->{en}")
            break
    return text, added


def main() -> int:
    apply = "--apply" in sys.argv
    lessons = fetch_lessons()
    print(f"lessons: {len(lessons)}\n")

    changed = 0
    total_terms = 0
    failures = 0

    for L in lessons:
        original = L.get("content_ar") or ""
        if not original.strip():
            continue
        updated, added = gloss_field(original)
        if not added:
            continue
        changed += 1
        total_terms += len(added)
        title = (L.get("title") or "")[:44]
        print(f"  {title:<46} +{len(added):>2}  {', '.join(added[:4])}"
              f"{' …' if len(added) > 4 else ''}")
        if apply:
            if not patch_lesson(L["id"], updated):
                print(f"      WRITE FAILED for {L['id']}")
                failures += 1

    print(f"\n{'APPLIED' if apply else 'DRY RUN'}: "
          f"{total_terms} glosses across {changed} lessons")
    if failures:
        print(f"WRITE FAILURES: {failures}")
        return 1
    if not apply:
        print("re-run with --apply to write")
    return 0


if __name__ == "__main__":
    sys.exit(main())
