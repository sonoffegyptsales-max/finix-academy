#!/usr/bin/env python3
"""Targeted sentence-level register fixes, batch 4 (F06/F07).

Same surgical approach as fix_msa_sentences.py: replace one exact sentence at a
time, refuse to write unless the source matches verbatim, and guard against
overall shrinkage.

Register spec: docs/ARABIC_REGISTER.md

  python3 scripts/fix_msa_sentences2.py            # dry run
  python3 scripts/fix_msa_sentences2.py --apply
"""
from __future__ import annotations

import datetime
import json
import os
import subprocess
import sys
import tempfile

FIXES: list[tuple[str, str, str, str]] = [

    ("afd9c824-5060-41fd-8417-b1ae537535ee", "F06 L2 · Thread principle",
     "جهاز Thread من حيث المبدأ تقدر توصّله على طول زي أي جهاز على الإنترنت، من غير ما تحتاج جسر مخصوص يترجم بياناته.",
     "جهاز Thread من حيث المبدأ تقدر توصّله على طول زي أي جهاز تاني على الإنترنت، من غير جسر مخصوص يترجم بياناته."),

    ("31b21586-c843-40fa-a0d8-56fe8915c2bf", "F06 L4 · Real automation",
     "الأتمتة الحقيقية تعني أن النظام يتخذ قرارًا نيابة عن العميل، بناءً على شرط ما، دون أن يلمس أحد تطبيقًا على الإطلاق.",
     "الأتمتة الحقيقية معناها إن النظام بياخد القرار بدل العميل، على أساس شرط معيّن، من غير ما حد يفتح تطبيق أصلًا."),

    ("31b21586-c843-40fa-a0d8-56fe8915c2bf", "F06 L4 · Scene vs automation",
     '**المشاهد (Scenes) مقابل الأتمتة — فرق كثيرًا ما يخلط بينه المتدربون:** **المشهد (Scene)** هو لقطة محفوظة لعدة حالات أجهزة تُفعَّل يدويًا أو كإجراء داخل أتمتة (مثل "ليلة السينما" التي تُعتّم الإضاءة إلى 20٪ وتُغلق الستائر وتُشغّل التلفاز، كل ذلك بلمسة واحدة أو أمر صوتي).',
     '**المشاهد (Scenes) مقابل الأتمتة — ده فرق المتدربين بيخلطوا فيه كتير:** **المشهد (Scene)** لقطة محفوظة لحالات كذا جهاز، بتشغّلها بإيدك أو كإجراء جوّه أتمتة. زي "ليلة السينما" اللي بتعتّم الإضاءة لـ20٪ وتقفل الستائر وتشغّل التلفزيون، كل ده بلمسة واحدة أو أمر صوتي.'),

    ("d7de7275-954d-44a6-8f00-afa60e365d1d", "F07 L1 · Why it matters",
     "**لماذا يهم هذا الفني عمليًا:** صناديق أقل للتركيب يعني تركيبًا أسرع ولوحة أنظف؛ أجهزة منفصلة أقل تتواصل مع الشبكة يعني نقاط فشل محتملة أقل وإصدارات برنامج ثابت أقل يجب متابعتها؛",
     "**ده مهم للفني ليه:** صناديق أقل يعني تركيب أسرع ولوحة أنضف. وأجهزة منفصلة أقل على الشبكة يعني نقط فشل أقل وإصدارات فيرموير أقل تتابعها."),

    ("b500f1b4-e14d-4d16-a109-95a6b4171d31", "F07 L2 · Platform support",
     "**ماذا تعني قائمة البروتوكولات هذه من حيث توافق المنصات:**",
     "**قائمة البروتوكولات دي معناها إيه لتوافق المنصات:**"),

    ("82bf3204-7e2f-4b1a-9632-39bc71456409", "F07 L3 · Hardware interlock",
     "الكلمة المفتاحية هنا هي القفل التبادلي *العتادي* — هذه الحماية مُطبّقة على مستوى الدايرة، لا فقط بمنطق برمجي/برنامج ثابت، لذا تستمر بالعمل بشكل صحيح حتى أثناء عطل في البرنامج الثابت أو انقطاع الشبكة، وهذا بالضبط الضمان الذي تحتاجه الدوائر الحرجة للسلامة.",
     "الكلمة المفتاحية هنا هي القفل التبادلي *العتادي*. الحماية دي متطبّقة على مستوى الدايرة نفسها، مش بمنطق برمجي أو فيرموير بس. يعني بتفضل شغالة صح حتى لو الفيرموير وقع أو الشبكة انقطعت — وده بالظبط الضمان اللي دواير السلامة الحرجة محتاجاه."),
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

    ids = sorted({f[0] for f in FIXES})
    quoted = ",".join(f'"{i}"' for i in ids)
    rows = json.loads(subprocess.run(
        ["curl", "-s",
         f"{url}/rest/v1/lessons?id=in.({quoted})&select=id,title,content_ar", *auth],
        capture_output=True, text=True, encoding="utf-8").stdout)
    cur = {r["id"]: r for r in rows}

    staged: dict[str, str] = {}
    problems: list[str] = []
    applied = 0

    for lid, label, old, new in FIXES:
        row = cur.get(lid)
        if not row:
            problems.append(f"{label}: lesson not found")
            continue
        text = staged.get(lid, row.get("content_ar") or "")
        if old not in text:
            problems.append(f"{label}: source sentence not found verbatim")
            continue
        staged[lid] = text.replace(old, new, 1)
        applied += 1
        print(f"  {label}")
        print(f"     - {old[:92]}")
        print(f"     + {new[:92]}")

    if problems:
        print("\nPROBLEMS — nothing written for these:")
        for p in problems:
            print(f"  {p}")

    for lid, new_text in staged.items():
        old_len = len(cur[lid].get("content_ar") or "")
        if len(new_text) < old_len * 0.85:
            problems.append(
                f"{cur[lid]['title'][:40]}: shrank {old_len} -> {len(new_text)}")

    print(f"\n{applied} sentence fixes across {len(staged)} lessons")

    if not apply:
        print("\nDRY RUN — re-run with --apply to write")
        return 1 if problems else 0
    if problems:
        print("\nrefusing to write while problems remain")
        return 1

    os.makedirs("backups", exist_ok=True)
    stamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    bak = os.path.join("backups", f"msa_sentences2_{stamp}.json")
    with open(bak, "w", encoding="utf-8") as f:
        json.dump([{"id": i, "title": cur[i]["title"],
                    "content_ar": cur[i].get("content_ar")} for i in staged],
                  f, ensure_ascii=False, indent=1)
    print(f"backed up -> {bak}")

    ok = 0
    for lid, new_text in staged.items():
        fd, pf = tempfile.mkstemp(suffix=".json")
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump({"content_ar": new_text}, f, ensure_ascii=False)
        try:
            res = subprocess.run(
                ["curl", "-s", "-w", "\n%{http_code}", "-X", "PATCH",
                 f"{url}/rest/v1/lessons?id=eq.{lid}", *auth,
                 "-H", "Content-Type: application/json",
                 "-H", "Prefer: return=minimal", "--data-binary", f"@{pf}"],
                capture_output=True, text=True, encoding="utf-8")
            if res.stdout.rpartition("\n")[2] in ("200", "204"):
                ok += 1
            else:
                print(f"  FAILED {cur[lid]['title'][:40]}")
        finally:
            os.unlink(pf)

    print(f"updated {ok}/{len(staged)} lessons")
    return 0 if ok == len(staged) else 1


if __name__ == "__main__":
    raise SystemExit(main())
