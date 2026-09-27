#!/usr/bin/env python3
"""Rewrite the 27 video-caption Arabic texts into the approved Egyptian register.

The captions were authored before the register was approved (docs/ARABIC_REGISTER.md)
and all read MSA. Same contract as apply_register_fixes.py, adapted to
lesson_media.caption_ar: verbatim match on the current caption or the entry is
refused; every row backed up.

  python3 scripts/fix_video_captions.py            # dry run
  python3 scripts/fix_video_captions.py --apply
"""
from __future__ import annotations

import datetime
import json
import os
import subprocess
import sys
import tempfile

# media_id -> new caption_ar (old captions read from the live table and matched
# against videos_live.json to guarantee we are editing what we reviewed)
NEW: dict[str, str] = {
    "f07fae6b-87f7-46a0-b830-7da926f6dd2b":
        "مقارنة شاملة بين Matter و Zigbee و Wi-Fi و Thread و Z-Wave. ركّز إزاي كل بروتوكول بيتربط بحالة استخدام — ده جوهر جدول القرار في الدرس ده.",
    "e1a5b525-80d9-435b-99a0-6c09931d86f7":
        "شرح Matter و Thread و Zigbee و Z-Wave. أفضل واحد بيوضّح ليه Matter محتاج موجّه حدودي (Border Router) — ودي أكتر نقطة بتلخبط الناس.",
    "143c2b92-2655-4c52-8e49-21009cd91c7b":
        "فيديو صاحبه له رأي واضح. استخدمه كتمرين نقدي: أنهي ادعاء من دول ينطبق على فيلا بجدران سميكة؟",
    "6192ff34-41c9-4d23-a532-e60c5c2e5668":
        "تركيب مفتاح ذكي مع وجود السلك المحايد ومن غيره. ابدأ بالفيديو ده — هو اللي بيطابق مخطط قرار المحايد في الدرس ده.",
    "7688d89b-bdcb-4856-bbe2-ac20452e1e8c":
        "الحل لما يكون في خط حي بس في علبة المفتاح من غير سلك محايد.",
    "5b4439e3-a0bd-460b-ab52-833e0c42a0aa":
        "إضافة سلك محايد — الخيار المكلف. مفيد عشان المتدرب يشوف بيسعّر إيه فعليًا.",
    "5de56551-f8e6-4091-abc6-5179b757a2db":
        "دمج Zigbee مع Home Assistant — أوضح شرح متكامل لمسار Zigbee المباشر.",
    "c0485bb1-b868-4faf-91cb-efc96cc48d1e":
        "إعداد دونجل SONOFF Zigbee 3.0 — خاص بالموديل اللي انت بتبيعه فعليًا.",
    "b2ccec9b-554e-4ed4-b1be-92bab1982df1":
        "إضافة أجهزة Zigbee عن طريق الدونجل — بيغطي دورة الاقتران بعد ما المنسّق يشتغل.",
    "bf65ff10-d7b1-4d6b-ad4f-7d19ce0787b2":
        "الديمر أبو حافة أمامية مقابل الخلفية — الفيديو الأساسي. بيشرح فرق الموجة اللي جدول أنواع الأحمال في الدرس مبني عليه.",
    "67c9a51e-fbe3-4fa9-afa4-f52439b22eb9":
        "دليل عملي لتعتيم إضاءة LED من غير مشاكل: الحد الأدنى للحمل وتوافق الدرايفر (Driver).",
    "49c48e8e-8f21-4091-a754-73b578df72e3":
        "مشاكل تعتيم إضاءة LED — متنظّم حسب العَرَض، وبيكمّل عمود الأعطال في المخطط.",
    "dfdd9c1f-0501-4ad8-8795-df3a6acfd876":
        "دليل برمجة دونجل SONOFF — ماشي على نفس ترتيب الخطوات الموجود في مخطط الدرس.",
    "bf2d7020-dd00-4773-b83d-8d7e5cc55dc1":
        "ترقية فيرموير الدونجل — زاوية تانية على الدخول لوضع الإقلاع، ودي الخطوة اللي ناس كتير بتتعثر فيها. تنبيه: الفيديوهين مش بيأكدوا إن إعادة اقتران كل الأجهزة إلزامية بعد تغيير نوع الفيرموير — هي إلزامية.",
    "3a4d2947-c19a-498f-8704-3cafd68759e0":
        "ليه شبكة Zigbee المتشابكة بتفشل — مبني على الانتقال من العَرَض للسبب، زي مخطط التشخيص في الدرس.",
    "9b9caedb-fb70-4d84-873d-1743e4b7c356":
        "تحسين شبكة Zigbee بتكلفة قليلة — عملي: إضافة موجّهات لمعالجة التغطية.",
    "7a6d5229-2af4-4a7b-9074-b5740c536da6":
        "مكان المنسّق (Coordinator) — السبب اللي المتدربين غالبًا مش واخدين بالهم منه.",
    "69493101-9bde-4965-b2f1-f495378a7dd4":
        "شبكات VLAN والفايروول للمنزل الذكي — الأساس النظري لمخطط التقسيم في الدرس.",
    "333eb807-3c9c-45b5-80f6-c655f900b8c2":
        "قواعد الفايروول لشبكة إنترنت الأشياء عمليًا — بيوضّح قاعدة الاتجاه الواحد وليه mDNS بيعقّدها. القوائم خاصة بـ UniFi، لكن المبدأ عام.",
    "7b71a9b2-9573-4d9c-ba6f-3ed85c15a160":
        "دواير التثبيت — بيطابق مخطط الدرس. ركّز ليه زرار الإيقاف موجود قبل نقطة التثبيت.",
    "81f0e2d4-a1a6-4b18-824d-f0372b8f474f":
        "توصيل محرك ثلاثي الأطوار بزرارين تشغيل وإيقاف — التنفيذ الفعلي لنفس الدايرة، بيربط المخطط باللوحة.",
    "192d81fc-3230-49af-8ebd-29525395e7fb":
        "توصيل دايرة تحكم نجمة-دلتا في لوحة حقيقية.",
    "27a7d087-ef87-4f55-9421-9c4080c25e09":
        "شرح بادئ نجمة-دلتا — أفضل واحد بيوضّح ليه تيار البدء بيقل. بعد ما تتفرج اسأل نفسك: أنهي أجزاء Alpha Control يقدر يحل محلها؟ التايمر والإشارات بس، مش الكونتاكتورات ولا ريلاي الحماية.",
    "0e7129fc-d443-441d-8ad0-96ec57e8dcc6":
        "مبدأ عمل نجمة-دلتا بالرسوم المتحركة — مفيد للي صعبان عليه يتصور لحظة الانتقال.",
    "99e45601-de4e-46c7-a35a-2a376b9c26c2":
        "تايمرات التأخير عند التشغيل وعند الإيقاف — بيطابق مخطط التوقيت في الدرس.",
    "c1d30e4e-58f0-4731-95ed-4f1843f694a4":
        "تأخير الإيقاف لوحده — الأصعب في التصور بين الاتنين.",
    "f2601b3c-509e-4afa-b8f7-d5b40cb3f5da":
        "توصيل تايمر التأخير عمليًا — بيكمّل الجانب النظري.",
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

    rows = json.loads(subprocess.run(
        ["curl", "-s",
         f"{url}/rest/v1/lesson_media?kind=eq.video&select=id,caption_ar&limit=200",
         *auth], capture_output=True, text=True, encoding="utf-8").stdout)
    cur = {r["id"]: r for r in rows}

    # cross-check against the reviewed snapshot so we never edit blind
    reviewed = {r["media_id"]: r for r in
                json.load(open("scripts/videos_live.json", encoding="utf-8"))}

    problems, staged = [], {}
    for mid, new in NEW.items():
        if mid not in cur:
            problems.append(f"{mid[:8]}: media id not found in live table")
            continue
        if mid not in reviewed:
            problems.append(f"{mid[:8]}: not in the reviewed snapshot")
            continue
        if (cur[mid].get("caption_ar") or "") != (reviewed[mid].get("caption_ar") or ""):
            problems.append(f"{mid[:8]}: live caption drifted since review")
            continue
        staged[mid] = new

    missing = set(cur) - set(NEW)
    if missing:
        problems.append(f"{len(missing)} live videos have no rewrite entry")

    print(f"{len(staged)}/{len(NEW)} captions staged")
    if problems:
        print("\nPROBLEMS:")
        for p in problems:
            print(f"  {p}")

    if not apply:
        print("\nDRY RUN — re-run with --apply to write")
        return 1 if problems else 0
    if problems:
        print("\nrefusing to write while problems remain")
        return 1

    os.makedirs("backups", exist_ok=True)
    stamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    bak = os.path.join("backups", f"video_captions_{stamp}.json")
    with open(bak, "w", encoding="utf-8") as f:
        json.dump([{"id": i, "caption_ar": cur[i].get("caption_ar")}
                   for i in staged], f, ensure_ascii=False, indent=1)
    print(f"backed up -> {bak}")

    ok = 0
    for mid, new in staged.items():
        fd, pf = tempfile.mkstemp(suffix=".json")
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump({"caption_ar": new}, f, ensure_ascii=False)
        try:
            res = subprocess.run(
                ["curl", "-s", "-w", "\n%{http_code}", "-X", "PATCH",
                 f"{url}/rest/v1/lesson_media?id=eq.{mid}", *auth,
                 "-H", "Content-Type: application/json",
                 "-H", "Prefer: return=minimal", "--data-binary", f"@{pf}"],
                capture_output=True, text=True, encoding="utf-8")
            if res.stdout.rpartition("\n")[2] in ("200", "204"):
                ok += 1
            else:
                print(f"  FAILED {mid[:8]}")
        finally:
            os.unlink(pf)

    print(f"updated {ok}/{len(staged)} captions")
    return 0 if ok == len(staged) else 1


if __name__ == "__main__":
    raise SystemExit(main())
