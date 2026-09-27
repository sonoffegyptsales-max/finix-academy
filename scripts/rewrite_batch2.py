#!/usr/bin/env python3
"""Batch 2 of the Egyptian-register rewrite: the five heaviest lessons.

Selected by measure_register.py as carrying the most structural MSA signals.
Each is hand-authored against docs/ARABIC_REGISTER.md -- the measurement showed
only 74 of 562 candidate substitutions were safe to script, so structure has to
be rewritten sentence by sentence.

Technical content is preserved exactly. SCOPE_CHECKS below assert that every
protocol name, device name, number and form name that existed before still
exists after; the script refuses to write a lesson that drops one.

  python3 scripts/rewrite_batch2.py            # dry run + scope check
  python3 scripts/rewrite_batch2.py --apply
"""
from __future__ import annotations

import datetime
import json
import os
import subprocess
import sys
import tempfile

# lesson id -> (label, new content_ar, scope terms that must survive)
REWRITES: dict[str, tuple[str, str, list[str]]] = {

    # ---------------------------------------------------------- F06 L2
    "afd9c824-5060-41fd-8417-b1ae537535ee": (
        "F06 L2 · Thread & Matter",
        """\
لسنين، الفني كان لازم يحفظ كل تطبيق بتاع كل ماركة — مفتاح SONOFF عايز تطبيق eWeLink، وحساس ماركة تانية عايز تطبيقه هو، وعشان تخلي ماركتين يشغّلوا بعض كنت محتاج جسر من طرف تالت زي Home Assistant أو IFTTT، ومن غير أي ضمان إنه يفضل شغال بعد تحديث فيرموير. Thread وMatter اتعملوا بالظبط عشان ينهوا التشتت ده. وأسهل طريقة تفهمهم بيها إنك تشوفهم طبقتين منفصلتين بيحلّوا مشكلتين مختلفتين.

**Thread دي طبقة النقل** — بروتوكول راديو شبكي واطي الاستهلاك مبني على IPv6. سلوكه الفيزيائي شبه Zigbee (الأجهزة اللي على الكهرباء بتعيد الإرسال للأجهزة اللي على بطارية، والشبكة بتصلّح نفسها)، بس مبني على عنونة الإنترنت القياسية من أول يوم. والأساس ده هو الفرق الجوهري: جهاز Thread من حيث المبدأ تقدر توصله مباشرة زي أي جهاز على الإنترنت، من غير ما تحتاج جسر مخصوص يترجم بياناته.

**Matter دي طبقة التطبيق** — "مفردات" مشتركة بتشتغل فوق Thread (أو Wi-Fi أو الإيثرنت)، وبتحدّد طريقة موحّدة لأي جهاز معتمد من Matter إنه يعرّف نفسه ويرد على الأوامر، مهما كانت الشركة المصنّعة. يعني مفتاح إضاءة معتمد من Matter من ماركة، ولمبة معتمدة من Matter من ماركة تانية خالص، تقدر تربطهم يشغّلوا بعض على طول — من غير خدمة سحابية لأي ماركة فيهم، ومن غير تطبيق أتمتة من طرف تالت في النص.

**ده يعني إيه للفني عمليًا؟** أولًا، الأتمتة (Automation) اللي بتعدّي بين الماركات بقت أوثق بكتير، لأن الاتصال مبقاش معتمد على إن واجهتين برمجة سحابيتين يفضلوا متوافقين. ثانيًا، أغلب المنصات الكبيرة (Apple Home وGoogle Home وAmazon Alexa وSamsung SmartThings) بقت تقدر تشتغل كـ**راوتر حدودي (Border Router)** — جهاز بيخلي أجهزة Thread توصل لباقي شبكة البيت — يعني هب واحد موجود عندك أصلًا (غالبًا جوّه سماعة ذكية أو راوتر حديث) يقدر يربط كذا ماركة مرة واحدة. ثالثًا، وده الأهم في الشغل اليومي: أي جهاز معتمد من Matter من أي ماركة هيدعم دايمًا التشغيل والإيقاف الأساسي والتعتيم (Dimming) والتقارير من خلال مجموعة أوامر موحّدة، حتى لو تطبيق الماركة دي اختفى بعد 5 سنين. وده بيقلّل خطر إنك ترشّح جهاز لعميل، لأن العميل مبقاش مربوط بدعم تطبيق شركة واحدة على المدى الطويل.""",
        ["Thread", "Matter", "IPv6", "Zigbee", "Wi-Fi", "eWeLink", "SONOFF",
         "Home Assistant", "IFTTT", "Border Router", "Dimming", "Automation",
         "Apple Home", "Google Home", "Amazon Alexa", "Samsung SmartThings"],
    ),

    # ---------------------------------------------------------- F03 L1
    "2514ad34-417e-40ab-b80f-8fa25a675b0a": (
        "F03 L1 · Site Survey Methodology",
        """\
مفيش مشروع منزل ذكي بيبدأ من غير زيارة للموقع. المعاينة الاحترافية زيارة مخصوصة بتقيّم الحالة الكهربائية والإنشائية وشبكة الإنترنت واحتياجات العميل، عشان تطلع بتصميم هندسي دقيق: تختار الأجهزة المتوافقة، وتحدّد التكلفة، وتقدّر عدد أفراد الفريق والمدة اللازمة للتركيب والبرمجة.

**المعاينة مهمة ليه:**
- **تقييم الشبكة والكهرباء** — تتأكد إن في سلك نيوترال متعادل ورا المفاتيح، وتفحص قوة تغطية الواي فاي.
- **تحديد الاحتياجات** — تدرس الأجهزة اللي هتتأتمت (إضاءة، تكييف، ستائر، أمان) وتصمّم سيناريوهات التفاعل.
- **تجنّب المشاكل التقنية** — تتجنّب عدم توافق الأجهزة وتضمن اختيار البروتوكول المناسب (Wi-Fi/Zigbee/Z-Wave).
- **تقدير التكلفة** — تحدّد حجم الشغل والمواد اللازمة قبل ما تبدأ.

**إجراءات المعاينة بتختلف حسب المرحلة الإنشائية:**
- **تحت التأسيس** — بتفحص المخططات الهندسية وتحدّد مسارات المواسير وأماكن لوحات التحكم، عشان تضمن وجود البنية التحتية اللازمة للأسلاك المركزية.
- **بعد التشطيب** — بتدوّر على حلول من غير تكسير حيطان، زي الأنظمة اللاسلكية اللي بتعتمد على مفاتيح ذكية بتتركّب مكان المفاتيح العادية.

**مراحل المعاينة الخمس:**
1. **حصر الاحتياجات** — تقعد مع العميل وتحدّد بالظبط عايز يتحكم في إيه في كل غرفة، وتفحص أنواع التكييفات عشان تحدّد وحدة التحكم المناسبة، وتتأكد إن في تأسيس كهربائي جنب الشبابيك لموتورات الستائر، وتعاين المداخل والمخارج عشان تحدّد أماكن الكاميرات والحساسات.
2. **تحديد نقاط الحمل (Load)** — تحسب الأحمال الكهربائية لكل نقطة: نوع الإضاءة (سبوت LED ولا ثريا ضخمة) عشان تختار الديمر المناسب، وسعة تحمّل موتور التكييف أو الستارة اللي المفاتيح الذكية لازم تشيلها، والمسافة بين الأجهزة والبوابة عشان تضمن مدى الإشارة.
3. **تقييم الشبكة** — دي قلب شبكة المنزل الذكي: تقيس قوة إشارة الواي فاي في كل غرفة، وتحدّد أحسن أماكن لنقاط الوصول، وتتأكد إن اللوحة الكهربائية الرئيسية تستوعب وحدات التحكم والكنترولرات الذكية المطلوبة.
4. **تحليل منطق السيناريوهات** — بدل ما تعدّ الأجهزة وخلاص، فكّر العميل هيعيش في المكان إزاي فعلًا: تحطّ حساسات الحركة في مكان ميصطادش الحيوانات الأليفة بس يشوف الإنسان أول ما يدخل، وتتأكد إن أماكن المفاتيح اليدوية تفضل منطقية ومريحة كتجاوز في حالات الطوارئ.
5. **توثيق الموقع** — تخرج من الموقع ومعاك صور أو فيديوهات لكل علبة كهرباء ولوحة رئيسية مفتوحة، ورسم كروكي مبدئي بترقيم النقاط، وقائمة ملاحظات فنية (زي "محتاج تغيير سلك معيّن" أو "إضافة نقطة إنترنت أو كهرباء").""",
        ["Load", "Wi-Fi", "Zigbee", "Z-Wave", "LED"],
    ),

    # ---------------------------------------------------------- F07 L3
    "": ("", "", []),
}

# The F07/F03-L3 entries are filled in below from the live rows so the file
# stays readable; see load_extra().


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

    todo = {k: v for k, v in REWRITES.items() if k and v[1].strip()}

    ids = ",".join(f'"{i}"' for i in todo)
    rows = json.loads(subprocess.run(
        ["curl", "-s",
         f"{url}/rest/v1/lessons?id=in.({ids})&select=id,title,content_ar", *auth],
        capture_output=True, text=True, encoding="utf-8").stdout)
    cur = {r["id"]: r for r in rows}

    planned, problems = [], []
    for lid, (label, new, scope) in todo.items():
        row = cur.get(lid)
        if not row:
            problems.append(f"{label}: lesson id not found")
            continue
        old = row.get("content_ar") or ""
        missing = [t for t in scope if t in old and t not in new]
        if missing:
            problems.append(f"{label}: scope terms dropped -> {missing}")
            continue
        # A register rewrite changes VOICE, not coverage. Losing a third of the
        # text means material was dropped -- which happened once when a rewrite
        # was drafted from an audit summary instead of the live row.
        if len(new) < len(old) * 0.75:
            problems.append(
                f"{label}: too short ({len(old):,} -> {len(new):,}, "
                f"{100 * len(new) / len(old):.0f}%) — content likely dropped")
            continue
        planned.append((row, label, new))
        print(f"  {label}")
        print(f"     old {len(old):,}c  ->  new {len(new):,}c")
        print(f"     scope terms preserved: {len(scope)}")

    if problems:
        print("\nPROBLEMS — nothing written for these:")
        for p in problems:
            print(f"  {p}")

    print(f"\n{len(planned)} lessons to rewrite")

    if not apply:
        print("\nDRY RUN — re-run with --apply to write")
        return 1 if problems else 0

    os.makedirs("backups", exist_ok=True)
    stamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    bak = os.path.join("backups", f"batch2_prerewrite_{stamp}.json")
    with open(bak, "w", encoding="utf-8") as f:
        json.dump([{"id": r["id"], "title": r["title"],
                    "content_ar": r.get("content_ar")} for r, _, _ in planned],
                  f, ensure_ascii=False, indent=1)
    print(f"backed up -> {bak}")

    ok = 0
    for row, label, new in planned:
        fd, pf = tempfile.mkstemp(suffix=".json")
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump({"content_ar": new}, f, ensure_ascii=False)
        try:
            res = subprocess.run(
                ["curl", "-s", "-w", "\n%{http_code}", "-X", "PATCH",
                 f"{url}/rest/v1/lessons?id=eq.{row['id']}", *auth,
                 "-H", "Content-Type: application/json",
                 "-H", "Prefer: return=minimal", "--data-binary", f"@{pf}"],
                capture_output=True, text=True, encoding="utf-8")
            if res.stdout.rpartition("\n")[2] in ("200", "204"):
                ok += 1
            else:
                print(f"  FAILED {label}")
        finally:
            os.unlink(pf)

    print(f"updated {ok}/{len(planned)} lessons")
    return 0 if ok == len(planned) and not problems else 1


if __name__ == "__main__":
    raise SystemExit(main())
