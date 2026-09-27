#!/usr/bin/env python3
"""Hand-authored Egyptian-register rewrite of I05 L1, as a sample for approval.

This is NOT a scripted transform. The measurement showed why:

  562 candidate substitutions -> only 74 were context-free enough to script
  135 structural signals across 58 lessons need the sentence read and rewritten

Running the safe script on this very lesson produced:

  "الكونتاكتور يفصل ويوصّل حملًا. والمؤقت يعمل بمرور الزمن. أما ريليه الحساس
   (Sensing Relay) فيعمل بناءً على حالة فيزيائية مقاسة..."

-- the terms swapped, but "أما ... فيعمل بناءً على" is still MSA and still
reads as a translation. Only authoring fixes that.

Register spec: docs/ARABIC_REGISTER.md
Technical content is UNCHANGED: every threshold, lux value, part name and
safety point is preserved. Only the voice changes.

  python3 scripts/rewrite_i05l1.py            # show a diff
  python3 scripts/rewrite_i05l1.py --apply
"""
from __future__ import annotations

import datetime
import json
import os
import subprocess
import sys
import tempfile

LESSON_ID = "e37122e7-e8d1-4e90-857d-6a690b497a32"

NEW_AR = """\
الكونتاكتور بيفصل ويوصّل الحمل. والتايمر (Timer) بيشتغل بالوقت. لكن **ريليه الحساس (Sensing Relay)** بيشتغل على حاجة بيقيسها فعليًا — النور قد إيه، الميّة واصلة لفين، في طور ناقص ولا لأ. يعني بيحوّل حاجة من الواقع لتلامس (Contact) باقي الدايرة تعرف تتعامل معاه.

**أي ريليه حساس جواه 3 أجزاء.** مهما كان بيقيس إيه، الجوّه واحد. ولو فهمت الـ3 دول تقدر تشخّص أي جهاز حتى لو أول مرة تشوفه:

1. **الحساس (Sensor)** — ده الجزء اللي بيشوف الدنيا برّه: مقاومة ضوئية، أو قطبين في خزان، أو نقطة بتقيس الجهد على الأطوار الداخلة. بيطلّع إشارة صغيرة بتتغيّر على طول.
2. **مرحلة المقارنة** — دايرة بتقارن الإشارة دي بعتبة إنت ضابطها بقرص. هنا سؤال زي "الضلمة توصل لكام عشان نعتبرها ضلمة؟" بيتحوّل لقرار: أيوه ولا لأ.
3. **تلامس الخرج** — تلامس تحويل عادي، بتستخدمه في دايرة التحكم زي أي تلامس تاني.

القرص اللي بتلفّه ده بيظبط **العتبة (Threshold)**، مش حساسية الحساس نفسه. والفرق ده مهم: لما الريليه يبان مش بيرد، الغالب إن الحساس سليم بس العتبة مضبوطة برّه المدى اللي الحالة بتوصله أصلًا. تعرف ده يوفّر عليك مطاردة عطل مش موجود.

**الهيستيريسيس (Hysteresis): أهم مفهوم في البرنامج ده.** الحالة الفيزيائية نادرًا ما بتعدّي العتبة بشكل نظيف. نور المغرب بيخفت بالتدريج وبيتذبذب مع مرور السحاب. والميّة في الخزان بتتموّج. لو الريليه بيبدّل عند عتبة واحدة بالظبط، هيحصل **رفرفة (Chattering)** — يفصل ويوصّل عشرات المرات في الثانية والإشارة بتلفّ حوالين نقطة الفصل. النتيجة: التلامسات بتتحرق، والحمل (Load) بيتحرق معاها.

الحل إنك تستخدم عتبتين مش واحدة: الريليه بيشتغل عند مستوى، وبيفصل عند مستوى تاني، وبينهم فجوة مقصودة. الفجوة دي اسمها الهيستيريسيس أو الفرق التفاضلي (Differential) أو النطاق الميت (Dead Band).

**مثال محلول.** خلّي بالك من مفتاح ضوء النهار: بيشغّل الإضاءة لما النور ينزل تحت 20 لكس، ومبيطفّيهاش غير لما يطلع فوق 50 لكس. عند المغرب النور بينزل تحت 20 فالمصابيح بتنوّر. دلوقتي النور بيلفّ حوالين 20 لكس مع مرور السحاب — بس الريليه مش هيفصل، لأن الفصل عايز 50 لكس، وده مش هيحصل غير بعد الفجر بوقت. يعني عملية واحدة نضيفة بدل ميّات.

**ليه ده مهم وإنت بتظبط جهاز في الموقع.** أغلب الريليهات بتديلك قرص للعتبة وقرص للفرق التفاضلي. لو ظبطت الفرق ضيّق أوي هتاخد رفرفة. ولو ظبطته واسع أوي الريليه هيبقى بليد — تحكم في مستوى خزان بفرق تفاضلي كبير هيسيب الميّة تنزل لمستوى خطر قبل ما يطلب المضخة. اختيار الفرق التفاضلي ده قرار هندسي حقيقي، مش قيمة افتراضية تسيبها زي ما هي.

**السلاح التاني ضد الرفرفة: تأخير الاستجابة.** الهيستيريسيس بيعالج إشارة بتزحف ببطء. لكنه مش بيعالج نبضة قصيرة — نور عربية بيمسح حساس ضوء النهار، أو موجة بتخبط في قطب المستوى. عشان كده أغلب ريليهات الحساس فيها تأخير استجابة قصير: الحالة لازم تفضل موجودة مدة معيّنة قبل ما الخرج يتحرّك. وده بالظبط سلوك تأخير التشغيل (ON-Delay) من البرنامج اللي فات، بس مبني جوّه جهاز الحساس نفسه.

يعني وإنت بتشغّل ريليه حساس لأول مرة، إنت بتظبط 3 حاجات: **العتبة**، و**الفرق التفاضلي**، و**تأخير الاستجابة**. والفني اللي بيظبط الأولى بس وبعدين يستغرب ليه الخرج بيرجّف — ده فني لسه مفهمش الجهاز.

**باقي البرنامج ده بيغطي إيه.** الدروس الجاية بتاخد 3 ريليهات حساس بتقابلك على طول في التركيبات الحقيقية — التبديل بضوء النهار، ومستوى السائل، وتبادل المضخات. وهنشوف في كل واحد: بيتوصّل إزاي، وبيفشل إزاي، وإيه اللي المكافئ الذكي يقدر يحلّ محله وإيه اللي ميقدرش."""


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

    cur = json.loads(subprocess.run(
        ["curl", "-s",
         f"{url}/rest/v1/lessons?id=eq.{LESSON_ID}&select=id,title,content_ar", *auth],
        capture_output=True, text=True, encoding="utf-8").stdout)
    if not cur:
        print("lesson not found", file=sys.stderr)
        return 1
    old = cur[0]["content_ar"] or ""

    print(f"lesson: {cur[0]['title']}")
    print(f"old: {len(old):,} chars   new: {len(NEW_AR):,} chars\n")

    # Technical values must survive the rewrite untouched.
    checks = ["20", "50", "٢٠", "٥٠", "Hysteresis", "Sensing Relay"]
    print("technical-value check:")
    for c in checks:
        print(f"  {c:<14} old={c in old}  new={c in NEW_AR}")

    if not apply:
        print("\nDRY RUN — re-run with --apply to write")
        return 0

    os.makedirs("backups", exist_ok=True)
    stamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    bak = os.path.join("backups", f"i05l1_prerewrite_{stamp}.json")
    with open(bak, "w", encoding="utf-8") as f:
        json.dump(cur[0], f, ensure_ascii=False, indent=1)
    print(f"\nbacked up -> {bak}")

    fd, pf = tempfile.mkstemp(suffix=".json")
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        json.dump({"content_ar": NEW_AR}, f, ensure_ascii=False)
    try:
        res = subprocess.run(
            ["curl", "-s", "-w", "\n%{http_code}", "-X", "PATCH",
             f"{url}/rest/v1/lessons?id=eq.{LESSON_ID}", *auth,
             "-H", "Content-Type: application/json",
             "-H", "Prefer: return=minimal", "--data-binary", f"@{pf}"],
            capture_output=True, text=True, encoding="utf-8")
        code = res.stdout.rpartition("\n")[2]
    finally:
        os.unlink(pf)

    print("updated" if code in ("200", "204") else f"FAILED {code}")
    return 0 if code in ("200", "204") else 1


if __name__ == "__main__":
    raise SystemExit(main())
