#!/usr/bin/env python3
"""Rewrite the six Arabic titles that still carry the rejected MSA register.

Found when the first rewritten lesson went live: the body read in the approved
Egyptian register while the heading directly above it still said
"ما هو ريليه الاستشعار ولماذا يحتاج نطاق تباطؤ". title_ar is a different field
from the body, so every content pass had silently skipped it -- and a heading
is the most-read text on the page.

Each title is hand-written, not substituted. Titles are short, high-visibility
and read aloud in class; a find-and-replace produces grammatical debris like
"ما هو ريليه الحساس ولماذا يحتاج الهيستيريسيس", which fixes the words and keeps
the translated shape.

Register spec: docs/ARABIC_REGISTER.md

  python3 scripts/rewrite_titles.py            # dry run
  python3 scripts/rewrite_titles.py --apply
"""
from __future__ import annotations

import datetime
import json
import os
import subprocess
import sys
import tempfile

# (table, match-on English title, new Arabic title, why)
TITLES: list[tuple[str, str, str, str]] = [
    ("modules", "Timers & Timing Functions",
     "التايمرات ووظايف التوقيت",
     "التايمر is the spoken term; وظايف is the Egyptian form of وظائف"),
    ("modules", "Sensing Relays: Photocell, Level & Pump Alternation",
     "ريليهات الحساس: الخلية الضوئية والمستوى وتبادل المضخات",
     "الحساس per the approved paragraph"),
    ("lessons", "Circuit Breakers: MCB, MCCB & ACB",
     "البريكرات: MCB وMCCB وACB",
     "البريكر is what technicians say; قواطع الدوائر is textbook Arabic"),
    ("lessons", "Interlocking, Reversing and Circuit Separation",
     "التعشيق وعكس الاتجاه وفصل الدواير",
     "colloquial plural of دايرة"),
    ("lessons", "What a Sensing Relay Is and Why It Needs Hysteresis",
     "ريليه الحساس بيشتغل إزاي وليه محتاج هيستيريسيس",
     "drops the 'ما هو … ولماذا' translation shape for a spoken question"),
    ("lessons", "From Sensing Relay to Smart Sensor: The Retrofit Opportunity",
     "من ريليه الحساس للحساس الذكي: فرصة التحديث",
     "الحساس + إلى -> لـ"),
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

    cache = {
        "modules": g("/rest/v1/modules?select=id,title,title_ar&limit=100"),
        "lessons": g("/rest/v1/lessons?select=id,title,title_ar&limit=500"),
    }

    planned, unresolved = [], []
    for table, en, new_ar, why in TITLES:
        hits = [r for r in cache[table] if (r["title"] or "").strip() == en]
        if len(hits) != 1:
            unresolved.append((table, en, f"{len(hits)} rows matched"))
            continue
        row = hits[0]
        if (row.get("title_ar") or "") == new_ar:
            print(f"  already done: {en[:50]}")
            continue
        planned.append((table, row, new_ar, why))
        print(f"  {table[:7]:<8} {en[:46]}")
        print(f"      - {row.get('title_ar')}")
        print(f"      + {new_ar}")
        print(f"      ({why})")

    if unresolved:
        print("\nUNRESOLVED — nothing written for these:")
        for t, en, why in unresolved:
            print(f"  [{t}] {en}: {why}")

    print(f"\n{len(planned)} titles to rewrite")

    if not apply:
        print("\nDRY RUN — re-run with --apply to write")
        return 1 if unresolved else 0

    os.makedirs("backups", exist_ok=True)
    stamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    bak = os.path.join("backups", f"titles_prerewrite_{stamp}.json")
    with open(bak, "w", encoding="utf-8") as f:
        json.dump([{"table": t, "id": r["id"], "title": r["title"],
                    "title_ar": r.get("title_ar")} for t, r, _, _ in planned],
                  f, ensure_ascii=False, indent=1)
    print(f"backed up -> {bak}")

    ok = 0
    for table, row, new_ar, _ in planned:
        fd, pf = tempfile.mkstemp(suffix=".json")
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump({"title_ar": new_ar}, f, ensure_ascii=False)
        try:
            res = subprocess.run(
                ["curl", "-s", "-w", "\n%{http_code}", "-X", "PATCH",
                 f"{url}/rest/v1/{table}?id=eq.{row['id']}", *auth,
                 "-H", "Content-Type: application/json",
                 "-H", "Prefer: return=minimal", "--data-binary", f"@{pf}"],
                capture_output=True, text=True, encoding="utf-8")
            if res.stdout.rpartition("\n")[2] in ("200", "204"):
                ok += 1
            else:
                print(f"  FAILED {row['title'][:40]}")
        finally:
            os.unlink(pf)

    print(f"updated {ok}/{len(planned)} titles")
    return 0 if ok == len(planned) and not unresolved else 1


if __name__ == "__main__":
    raise SystemExit(main())
