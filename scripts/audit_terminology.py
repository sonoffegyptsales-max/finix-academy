#!/usr/bin/env python3
"""Check Arabic lesson text for technical terms missing their English gloss.

The course review asked that agreed terms carry the English word beside the
Arabic on first use -- e.g. "الشبكية (Mesh)", "التعتيم (Dimming)" -- because
field technicians in Egypt use the English words in practice.

For each term this reports how many Arabic lesson fields mention it WITHOUT
the English equivalent anywhere in the same field.
"""
from __future__ import annotations

import json
import re
import subprocess
import sys

# Arabic term -> the English word that should appear beside it.
TERMS = {
    "الشبكية": "Mesh",
    "الشبكيه": "Mesh",
    "التعتيم": "Dimming",
    "المشهد": "Scene",
    "المشاهد": "Scene",
    "الأتمتة": "Automation",
    "الاتمتة": "Automation",
    "الأتمته": "Automation",
    "السحابة": "Cloud",
    "السحابه": "Cloud",
    "التحكم المحلي": "Local control",
    "البوابة": "Gateway",
    "المستشعر": "Sensor",
    "الحساس": "Sensor",
    "القاطع": "Breaker",
    "الملامس": "Contactor",
    "المرحل": "Relay",
    "الحمل": "Load",
    "الجهد": "Voltage",
    "التيار": "Current",
    "التأريض": "Earthing",
    "الطور": "Phase",
}


def env() -> dict:
    out = {}
    for line in open(".env", encoding="utf-8"):
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            k, v = line.split("=", 1)
            out[k.strip()] = v.strip()
    return out


def fetch():
    e = env()
    url = e.get("SUPABASE_URL") or e.get("VITE_SUPABASE_URL")
    key = e.get("SUPABASE_SERVICE_ROLE_KEY")
    p = subprocess.run([
        "curl", "-s",
        f"{url}/rest/v1/lessons?select=id,title,content_ar&limit=500",
        "-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}",
    ], capture_output=True, text=True)
    return json.loads(p.stdout)


def main() -> int:
    lessons = fetch()
    print(f"Arabic lesson bodies scanned: {len(lessons)}\n")

    rows = []
    for ar_term, en in TERMS.items():
        missing = 0
        present = 0
        for L in lessons:
            txt = L.get("content_ar") or ""
            if ar_term not in txt:
                continue
            # English gloss counts if the word appears anywhere in the field
            if re.search(re.escape(en), txt, re.I):
                present += 1
            else:
                missing += 1
        if missing or present:
            rows.append((missing, present, ar_term, en))

    rows.sort(reverse=True)
    print(f"{'term':<18} {'English':<14} {'missing':>8} {'glossed':>8}")
    print("-" * 52)
    total_missing = 0
    for missing, present, ar_term, en in rows:
        total_missing += missing
        flag = "  <-- fix" if missing else ""
        print(f"{ar_term:<18} {en:<14} {missing:>8} {present:>8}{flag}")

    print(f"\nlesson-fields needing a gloss added: {total_missing}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
