#!/usr/bin/env python3
"""Targeted sentence-level register fixes, batch 3.

The corrected detector showed 42 lessons carrying 59 signals -- about 1.4 per
lesson. So these are surgical sentence replacements, not page rewrites: the
surrounding paragraphs are already in register and re-authoring them risks the
content loss that the length guard was added to catch.

Each entry replaces ONE exact sentence. The script refuses to write if the old
text is not found verbatim, so a drifted source can never be silently skipped
or partially applied.

Register spec: docs/ARABIC_REGISTER.md

  python3 scripts/fix_msa_sentences.py            # dry run
  python3 scripts/fix_msa_sentences.py --apply
"""
from __future__ import annotations

import datetime
import json
import os
import subprocess
import sys
import tempfile

# (lesson_id, label, old_exact, new)
FIXES: list[tuple[str, str, str, str]] = [

    ("1ff7c4b1-a422-4a87-b79f-d669eda9b4a5", "F02 L1 · DC vs AC",
     "ثانيًا تقنيًا، تعمل قواطع التيار المتردد عبر استغلال مرور التيار بالصفر بشكل طبيعي (مرتين كل دورة) لإطفاء القوس الكهربائي بأمان عند فصل الدايرة — بينما التيار المستمر لا يمر بالصفر أبدًا، فتحتاج قواطعه آليات أكثر تعقيدًا وتكلفة لإطفاء القوس.",
     "وتقنيًا، بريكرات التيار المتردد بتستغل إن التيار بيعدّي بالصفر بشكل طبيعي (مرتين كل دورة) عشان تطفي القوس الكهربائي بأمان وهي بتفصل الدايرة. أما التيار المستمر فمبيعدّيش بالصفر أبدًا، وعشان كده بريكراته محتاجة آليات أعقد وأغلى عشان تطفي القوس."),

    ("c7c13ea1-ef51-48a7-8989-0ff57cf793ec", "F02 L4 · Star vs Delta",
     "في توصيلة **النجمة (Star)**، تُربط نهايات الملفات الثلاثة معًا في نقطة مشتركة وتُغذى من بدايات الملفات الثلاثة — هذا يعطي جهدًا أقل لكل ملف، فيسحب تيار بدء تشغيل أقل، مناسب للأحمال الكبيرة التي تحتاج بدء تشغيل بتيار منخفض.",
     "في توصيلة **النجمة (Star)** بتربط نهايات الملفات الثلاثة مع بعض في نقطة مشتركة، وبتغذّي من بدايات الملفات الثلاثة. كده كل ملف بياخد جهد أقل، فبيسحب تيار بدء أقل — وده المناسب للأحمال الكبيرة اللي محتاجة تبدأ بتيار منخفض."),

    ("fe86f1b6-464f-4bee-a943-d118e6d9c559", "F04 L2 · Circuit Breakers",
     "**أساس اختيار تيار الكابل:** تُحدد سعة الكابل بناءً على تيار القاطع المقنن (لا تيار الحمل)، ويجب أن تكون أعلى من تيار القاطع بنسبة 20٪ على الأقل — لأن وظيفة القاطع حماية الكابل لا العكس.",
     "**أساس اختيار تيار الكابل:** سعة الكابل بتتحدّد على أساس تيار البريكر المقنّن، مش تيار الحمل. ولازم تكون أعلى من تيار البريكر بـ20٪ على الأقل — لأن وظيفة البريكر إنه يحمي الكابل، مش العكس."),

    ("9e0e9d8c-5dd2-448c-87a4-4ddb62688184", "F04 L3 · Relays (operation)",
     "**طريقة العمل:** تطبيق جهد على الملف يولّد مجالًا مغناطيسيًا يجذب الذراع المتحركة؛ حركة الذراع تؤدي إما لإغلاق الدايرة الكهربائية أو فتحها؛ عند انقطاع التيار (Current) عن الملف، يزول المجال المغناطيسي ويعيد نابض الذراع ونقاط التلامس إلى وضعها الأصلي.",
     "**بيشتغل إزاي:** لما تحطّ جهد على الملف بيتولّد مجال مغناطيسي بيشدّ الذراع المتحركة، وحركة الذراع دي إما بتقفل الدايرة أو بتفتحها. ولما التيار (Current) ينقطع عن الملف، المجال المغناطيسي بيزول والنابض بيرجّع الذراع ونقاط التلامس لوضعها الأصلي."),

    ("9e0e9d8c-5dd2-448c-87a4-4ddb62688184", "F04 L3 · Relays (benefits)",
     "**فوائد الريليه:** يعزل دائرة التحكم (الجهاز الذكي أو الكنترولر) عن دائرة الحمل (Load)، فيحمي طرف التحكم الأقل قدرة؛ يسمح بالتحكم في تيارات عالية عبر إشارات تحكم صغيرة منخفضة القدرة/الجهد (Voltage)؛ ويُستخدم داخل مفاتيح المنزل الذكي والأجهزة ودوائر الإضاءة، ما يقلل الحاجة للتدخل اليدوي.",
     "**الريليه بيفيدك في إيه:** بيعزل دايرة التحكم (الجهاز الذكي أو الكنترولر) عن دايرة الحمل (Load)، فبيحمي طرف التحكم اللي قدرته أقل. وبيخليك تتحكم في تيارات عالية بإشارات تحكم صغيرة واطية القدرة والجهد (Voltage). وبتلاقيه جوّه مفاتيح المنزل الذكي والأجهزة ودواير الإضاءة، فبيقلّل الحاجة للتدخل اليدوي."),

    ("9aef9385-949a-4a72-933d-4d473eb77e6b", "F04 L4 · Contactors (operation)",
     "**طريقة العمل:** عند مرور تيار كهربائي إلى ملف الكونتاكتور بناءً على إشارة تحكم، فإنه يغيّر وضع نقاط التلامس — النقاط المفتوحة عادة تُغلق، والنقاط المغلقة عادة تُفتح.",
     "**بيشتغل إزاي:** أول ما تيار كهربائي يعدّي لملف الكونتاكتور بإشارة تحكم، بيغيّر وضع نقاط التلامس — المفتوحة عادة بتقفل، والمقفولة عادة بتفتح."),

    ("9aef9385-949a-4a72-933d-4d473eb77e6b", "F04 L4 · Overload",
     "**حماية الحمل الزائد (الأوفرلود)** — جهاز حماية كهربائي، يُعرف أيضًا بالقاطع (Breaker) الحراري، وظيفته الأساسية حماية المحركات والأجهزة الكهربائية من التلف الناتج عن التيار الزائد عن الحد المسموح، عبر فصل التيار تلقائيًا؛ يمكن إعادة ضبطه يدويًا بعد زوال سبب الحمل الزائد.",
     "**حماية الحمل الزائد (الأوفرلود)** — جهاز حماية كهربائي، وبيتسمّى كمان البريكر (Breaker) الحراري. وظيفته إنه يحمي المحركات والأجهزة الكهربائية من التلف اللي بيسبّبه التيار الزايد عن الحد المسموح، وبيفصل التيار أوتوماتيك. وتقدر تعيد ضبطه يدوي بعد ما يزول سبب الحمل الزائد."),

    ("0e01899c-90fc-4b0f-a6c2-1d9213f6fce0", "F05 L2 · IPv6",
     "أما **IPv6** فهي الصيغة الأحدث المصممة لحل أكبر قيد في IPv4 — العالم بدأ ينفد من عناوين IPv4 — وتستخدم مساحة عناوين أكبر بكثير تُكتب بمجموعات ست عشرية، مثل fe80::200:f8ff:fe21:67cf.",
     "و**IPv6** دي الصيغة الأحدث، واتعملت عشان تحلّ أكبر مشكلة في IPv4 — إن عناوين IPv4 بدأت تخلص من العالم. وبتستخدم مساحة عناوين أكبر بكتير، وبتتكتب بمجموعات ست عشرية، زي fe80::200:f8ff:fe21:67cf."),

    ("0e01899c-90fc-4b0f-a6c2-1d9213f6fce0", "F05 L2 · DHCP vs static",
     "**DHCP (تلقائي)** — يخصص الراوتر أو الخدمة العنوان ديناميكيًا لأي جهاز ينضم للشبكة، وهذا ما يحدث افتراضيًا في أغلب المنازل؛ أو **ثابت (يدوي)** — يُدخَل العنوان يدويًا في إعدادات شبكة الجهاز ولا يتغير أبدًا، ويستخدمه الفنيون عمدًا للأجهزة التي يجب أن تظل متاحة دائمًا بنفس العنوان، مثل بوابة أو خادم.",
     "**DHCP (تلقائي)** — الراوتر أو الخدمة بيدّي العنوان ديناميكيًا لأي جهاز بينضم للشبكة، وده اللي بيحصل افتراضيًا في أغلب البيوت. أو **ثابت (يدوي)** — بتدخّل العنوان بإيدك في إعدادات شبكة الجهاز ومبيتغيّرش أبدًا، والفنيين بيستخدموه بقصد للأجهزة اللي لازم تفضل متاحة على نفس العنوان دايمًا، زي بوابة أو سيرفر."),

    ("afd9c824-5060-41fd-8417-b1ae537535ee", "F06 L2 · Thread (leftover)",
     "والأساس ده هو الفرق الجوهري: جهاز Thread من حيث المبدأ تقدر توصله مباشرة زي أي جهاز على الإنترنت، من غير ما تحتاج جسر مخصوص يترجم بياناته.",
     "والأساس ده هو الفرق الجوهري: جهاز Thread من حيث المبدأ تقدر توصّله على طول زي أي جهاز على الإنترنت، من غير ما تحتاج جسر مخصوص يترجم بياناته."),
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
    rows = json.loads(subprocess.run(
        ["curl", "-s",
         f"{url}/rest/v1/lessons?id=in.({','.join(chr(34) + i + chr(34) for i in ids)})"
         f"&select=id,title,content_ar", *auth],
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
        print(f"     - {old[:96]}")
        print(f"     + {new[:96]}")

    if problems:
        print("\nPROBLEMS — nothing written for these:")
        for p in problems:
            print(f"  {p}")

    # Length guard: sentence swaps must not change overall coverage.
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
    bak = os.path.join("backups", f"msa_sentences_{stamp}.json")
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
