#!/usr/bin/env python3
"""Targeted sentence-level register fixes, batch 5 (I-track + F07/F08 tails).

Same contract as the earlier batches: one exact sentence per entry, verbatim
match required, shrinkage guard on the whole field.

Register spec: docs/ARABIC_REGISTER.md

  python3 scripts/fix_msa_sentences3.py            # dry run
  python3 scripts/fix_msa_sentences3.py --apply
"""
from __future__ import annotations

import datetime
import json
import os
import subprocess
import sys
import tempfile

FIXES: list[tuple[str, str, str, str]] = [

    # ---- F08
    ("44629965-2892-4acd-b7e6-dced00e35f9c", "F08 L1 · why it matters",
     "**لماذا يهم هذا في مرحلة المعاينة تحديدًا:**",
     "**ليه ده مهم في المعاينة بالذات:**"),

    ("023e2483-0c45-43cf-899e-ac6ee0522bf8", "F08 L2 · practical rule",
     "**قاعدة عملية:** سجّل دائمًا المصطلح الإنجليزي والعربي معًا في استمارة المعاينة لكل جهاز يريد العميل أتمتته",
     "**قاعدة عملية:** سجّل دايمًا المصطلح الإنجليزي والعربي مع بعض في استمارة المعاينة لكل جهاز العميل عايز يأتمته"),

    # ---- I01
    ("bc8df72a-46d0-4748-a85d-1a757439dc59", "I01 L2 · auxiliary contact",
     "وبانسحابه يُغلق تلامسه المساعد — وذلك التلامس موازٍ للزر، فيوفر الآن مسارًا ثانيًا لتيار الملف.",
     "ولما بينسحب بيقفل تلامسه المساعد — والتلامس ده موازي للزرار، فبيوفّر دلوقتي مسار تاني لتيار الملف."),

    ("7f4eb767-3afe-45a2-92a2-bc505962b8e2", "I01 L3 · interlock principle",
     "**مبدأ التعشيق العام.** العكس هو الحالة الكلاسيكية، لكن النمط ذاته ينطبق حيثما كان حملان متبادلي الاستبعاد:",
     "**مبدأ التعشيق العام.** العكس هو الحالة الكلاسيكية، لكن نفس النمط بينطبق في أي حالة فيها حملين ميشتغلوش مع بعض:"),

    ("7f4eb767-3afe-45a2-92a2-bc505962b8e2", "I01 L3 · physical separation",
     "- **فصل مادي في اللوحة.** تُمرَّر أسلاك القوى والتحكم في مجارٍ منفصلة حيثما أمكن.",
     "- **فصل مادي في اللوحة.** مرّر أسلاك القوى والتحكم في مجاري منفصلة كل ما أمكن."),

    # ---- I02
    ("46ff4045-ab86-408f-b340-bb681e7aef49", "I02 L3 · two speeds",
     "واختيار أحدهما يعطي سرعتين، ولأن الملفين مستقلان يمكن أن تكون السرعتان بأي نسبة اختارها المصمم.",
     "واختيار واحد منهم بيديك سرعتين، ولأن الملفين مستقلين السرعتين ممكن تكون بينهم أي نسبة المصمّم يختارها."),

    ("46ff4045-ab86-408f-b340-bb681e7aef49", "I02 L3 · control requirements",
     "**متطلبات التحكم للمحركات ثنائية السرعة.** التبديل بين السرعات يتطلب كونتاكتورات يجب تعشيقها — مبدأ الاستبعاد المتبادل ذاته من برنامج الكونتاكتورات، إذ إن تغذية تكوينَي سرعة معًا ستقصّر الملف.",
     "**التحكم في المحركات ثنائية السرعة محتاج إيه.** التبديل بين السرعات محتاج كونتاكتورات لازم تتعشّق — نفس مبدأ الاستبعاد المتبادل من برنامج الكونتاكتورات، لأن تغذية تكوينين سرعة مع بعض هتقصّر الملف."),

    # ---- I03
    ("035cab60-53ef-45ff-8826-05592b158813", "I03 L1 · signal not break",
     "وذلك التلامس **إشارة** لا قطع.",
     "والتلامس ده **إشارة** مش قطع."),

    ("ca94a224-e06c-4493-8293-af953794217b", "I03 L2 · selectivity",
     "إن فصل عطل في محرك واحد قاطع التوزيع الرئيسي بدل حماية ذلك المحرك، أظلمت اللوحة بأكملها.",
     "لو عطل في محرك واحد فصل بريكر التوزيع الرئيسي بدل حماية المحرك ده، اللوحة كلها هتظلم."),

    # ---- I04
    ("b4361bcd-26f1-4b73-8f9d-48e33a0c1fe3", "I04 L1 · timer question",
     "هل هذا الحمل (Load) يعمل أم لا؟ أما التايمر (Timer) فيجيب عن سؤال أصعب:",
     "الحمل (Load) ده شغال ولا لأ؟ لكن التايمر (Timer) بيجاوب على سؤال أصعب:"),

    ("b4361bcd-26f1-4b73-8f9d-48e33a0c1fe3", "I04 L1 · where this goes",
     "**إلى أين يتجه هذا البرنامج.** تتناول الدروس التالية وظائف التوقيت القياسية واحدة تلو الأخرى، ثم كيف تقرأ مخططات التوقيت التي تصفها، وكيف تضبط جهازًا حقيقيًا، وأخيرًا أين تحل الجدولة الذكية الحديثة محل مؤقت الريليه فعلًا — والحالات المحددة التي يكون فيها استبدال جدول تطبيق بمؤقت عتادي خطأً هندسيًا.",
     "**البرنامج ده رايح فين.** الدروس الجاية بتاخد وظايف التوقيت القياسية واحدة واحدة، وبعدين تقرا مخططات التوقيت اللي بتوصفها إزاي، وتظبط جهاز حقيقي إزاي. وفي الآخر: الجدولة الذكية الحديثة بتحلّ محل تايمر الريليه فين فعلًا — وإمتى يكون استبدال التايمر العتادي بجدول في تطبيق غلطة هندسية."),

    # I04 L2 "on-delay edge" was dropped from this batch: the lesson id above
    # was GUESSED rather than looked up, and the verbatim check rejected it as
    # "lesson id not found". Re-add it once the id is read from the live table.
    # Do not restore a guessed id -- that is exactly what the check caught.
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
            problems.append(f"{label}: lesson id not found")
            continue
        text = staged.get(lid, row.get("content_ar") or "")
        if old not in text:
            problems.append(f"{label}: source sentence not found verbatim")
            continue
        staged[lid] = text.replace(old, new, 1)
        applied += 1
        print(f"  {label}")
        print(f"     - {old[:88]}")
        print(f"     + {new[:88]}")

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
    bak = os.path.join("backups", f"msa_sentences3_{stamp}.json")
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
