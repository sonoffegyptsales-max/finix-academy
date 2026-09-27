#!/usr/bin/env python3
"""Hand-written Egyptian-register rewrites of the six module summaries.

summary_ar is the third Arabic field (after content_ar and title_ar) and sits
directly under the module heading, so it is read before any lesson. The I05
summary still said "ريليهات تراقب حالة فيزيائية وتتصرف بناءً عليها" after both
the body and the title were corrected.

Summaries are one sentence each and read as a promise of what the module
covers, so each is written by hand. Technical scope is preserved exactly -- the
same topics in the same order; only the voice changes.

Register spec: docs/ARABIC_REGISTER.md

  python3 scripts/rewrite_summaries.py            # dry run
  python3 scripts/rewrite_summaries.py --apply
"""
from __future__ import annotations

import datetime
import json
import os
import subprocess
import sys
import tempfile

# code -> new summary_ar
NEW: dict[str, str] = {
    "F03": (
        "المعاينة الاحترافية بمراحلها الخمس، والأسئلة اللي لازم تسألها للعميل "
        "وللفني أثناء الزيارة، والاستمارات الست الموحّدة اللي بتغطي كل غرفة "
        "وكل نظام فرعي."
    ),
    "F04": (
        "الفرق بين الأدابتور ومزوّد الطاقة والشاحن، ومنحنيات شحن البطاريات، "
        "وأنواع البريكرات وإزاي تختار بينها، وتركيب الريليه وأنواعه، "
        "والكونتاكتور ومفاتيح الاختيار وحماية الحمل الزائد."
    ),
    "F05": (
        "نطاقات الشبكات (PAN/LAN/MAN/WAN)، وعناوين IP بتشتغل إزاي، والعنوان "
        "الخاص والعام وNAT بمثال الفندق، وفئات IPv4، ومقارنة عملية بين Wi-Fi "
        "وZigbee وThread وZ-Wave."
    ),
    "I01": (
        "اللبنة الأساسية في أي لوحة تحكم: الكونتاكتور بيشتغل إزاي، وتحدّد "
        "أطرافه إزاي، ودواير التثبيت والتعشيق اللي بتخليه مفيد، وليه بنفصل "
        "دايرة القوى عن دايرة التحكم."
    ),
    "I03": (
        "إيه اللي بيدمّر المحركات فعلًا، وكل جهاز حماية بيعالج تهديد مختلف "
        "إزاي: ريليهات الحمل الزائد الحرارية، وحماية القصر، وبريكرات حماية "
        "المحركات، والثرمستورات، وليه جهاز واحد مش بيغطي كل الأعطال."
    ),
    "I05": (
        "ريليهات بتقيس حالة على الطبيعة وبتتصرّف على أساسها: التبديل بضوء "
        "النهار، والتحكم في المستوى بالأقطاب وحماية التشغيل الجاف، وتبادل "
        "المضخات بين العاملة والاحتياطية — مع المكافئ الذكي لكل واحدة "
        "والأعطال اللي بتدمّر المضخات."
    ),
}

# Terms whose presence proves the technical scope survived the rewrite.
SCOPE_CHECKS: dict[str, list[str]] = {
    "F03": ["الخمس", "الست"],
    "F04": ["الأدابتور", "الريليه", "الكونتاكتور"],
    "F05": ["PAN/LAN/MAN/WAN", "IPv4", "NAT", "Wi-Fi", "Zigbee", "Thread", "Z-Wave"],
    "I01": ["الكونتاكتور", "التثبيت", "التعشيق"],
    "I03": ["الثرمستورات", "القصر"],
    "I05": ["الأقطاب", "التشغيل الجاف", "المضخات"],
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
    apply = "--apply" in sys.argv
    e = env()
    url = (e.get("VITE_SUPABASE_URL") or e["SUPABASE_URL"]).rstrip("/")
    key = e["SUPABASE_SERVICE_ROLE_KEY"]
    auth = ["-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}"]

    mods = json.loads(subprocess.run(
        ["curl", "-s",
         f"{url}/rest/v1/modules?select=id,code,title,summary_ar&limit=100", *auth],
        capture_output=True, text=True, encoding="utf-8").stdout)
    by_code = {m["code"]: m for m in mods}

    planned, problems = [], []
    for code, new in NEW.items():
        m = by_code.get(code)
        if not m:
            problems.append(f"{code}: module not found")
            continue
        missing = [c for c in SCOPE_CHECKS.get(code, []) if c not in new]
        if missing:
            problems.append(f"{code}: scope terms dropped -> {missing}")
            continue
        if (m.get("summary_ar") or "") == new:
            print(f"  already done: {code}")
            continue
        planned.append((m, new))
        print(f"\n  {code} · {m['title'][:48]}")
        print(f"     - {(m.get('summary_ar') or '')[:120]}")
        print(f"     + {new[:120]}")

    if problems:
        print("\nPROBLEMS — nothing written for these:")
        for p in problems:
            print(f"  {p}")

    print(f"\n{len(planned)} summaries to rewrite")

    if not apply:
        print("\nDRY RUN — re-run with --apply to write")
        return 1 if problems else 0

    os.makedirs("backups", exist_ok=True)
    stamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    bak = os.path.join("backups", f"summaries_prerewrite_{stamp}.json")
    with open(bak, "w", encoding="utf-8") as f:
        json.dump([{"id": m["id"], "code": m["code"],
                    "summary_ar": m.get("summary_ar")} for m, _ in planned],
                  f, ensure_ascii=False, indent=1)
    print(f"backed up -> {bak}")

    ok = 0
    for m, new in planned:
        fd, pf = tempfile.mkstemp(suffix=".json")
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump({"summary_ar": new}, f, ensure_ascii=False)
        try:
            res = subprocess.run(
                ["curl", "-s", "-w", "\n%{http_code}", "-X", "PATCH",
                 f"{url}/rest/v1/modules?id=eq.{m['id']}", *auth,
                 "-H", "Content-Type: application/json",
                 "-H", "Prefer: return=minimal", "--data-binary", f"@{pf}"],
                capture_output=True, text=True, encoding="utf-8")
            if res.stdout.rpartition("\n")[2] in ("200", "204"):
                ok += 1
            else:
                print(f"  FAILED {m['code']}")
        finally:
            os.unlink(pf)

    print(f"updated {ok}/{len(planned)} summaries")
    return 0 if ok == len(planned) and not problems else 1


if __name__ == "__main__":
    raise SystemExit(main())
