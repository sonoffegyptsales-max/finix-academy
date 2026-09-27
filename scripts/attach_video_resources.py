#!/usr/bin/env python3
"""Attach the verified video resources to their lessons.

The links were verified and written to docs/VIDEO_RESOURCES.md, but a markdown
file in the repo is invisible to trainees -- the resources have to live in the
app. This puts them in lesson_media so they render inside the lesson.

Why lesson_media and not a new table: the Supabase management token is expired,
so no DDL is possible. lesson_media already allows kind IN ('image','video',
'audio'), so an external video is a 'video' row whose storage_path is the URL
instead of a bucket key. useSignedMedia() detects the http(s) prefix and passes
it through unsigned; LessonResources renders those as links.

These stay LINKS, never embeds: re-hosting or embedding third-party video is a
copyright problem, and a link keeps the no-download policy intact.

Lessons are resolved by module code + a title keyword, and anything that fails
to resolve is reported rather than guessed at.

Idempotent: re-running updates the existing row for a URL instead of
duplicating it.

  python3 scripts/attach_video_resources.py           # dry run
  python3 scripts/attach_video_resources.py --apply
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile

BASE_POSITION = 950  # after diagrams (900+), so resources sit at the end

# (module_code, lesson title keyword, [(url, caption_en, caption_ar), ...])
RESOURCES: list[tuple[str, str, list[tuple[str, str, str]]]] = [
    ("M11", "Communication Protocols", [
        ("https://www.youtube.com/watch?v=RX7nGsvw1M0",
         "Matter vs Zigbee vs Wi-Fi vs Thread vs Z-Wave — the widest comparison. Watch for how each protocol maps to a use case, which is exactly the decision table in this lesson.",
         "مقارنة شاملة بين Matter و Zigbee و Wi-Fi و Thread و Z-Wave. ركّز على ربط كل بروتوكول بحالة استخدام، وهو جوهر جدول القرار في هذا الدرس."),
        ("https://www.youtube.com/watch?v=MGgyEQIsosE",
         "Matter, Thread, Zigbee & Z-Wave explained — strongest on why Matter needs a border router, the point trainees most often get wrong.",
         "شرح Matter و Thread و Zigbee و Z-Wave. الأفضل في توضيح سبب حاجة Matter إلى موجّه حدودي (Border Router)، وهي النقطة الأكثر التباسًا."),
        ("https://www.youtube.com/watch?v=XIjsPqn8Vxg",
         "Why Matter finally makes sense (and Wi-Fi doesn't) — opinionated. Use it as a critique exercise: which claims hold for a villa with thick walls?",
         "فيديو ذو رأي واضح. استخدمه كتمرين نقدي: أي من هذه الادعاءات ينطبق على فيلا بجدران سميكة؟"),
    ]),
    ("M12", "Installation Best Practices", [
        ("https://www.youtube.com/watch?v=fAcr1fL2uTM",
         "Neutral vs no-neutral smart switch install — assign this first. It matches the neutral decision diagram in this lesson directly.",
         "تركيب مفتاح ذكي مع وجود السلك المحايد وبدونه. ابدأ بهذا الفيديو؛ فهو يطابق مخطط قرار المحايد في هذا الدرس."),
        ("https://www.youtube.com/watch?v=YGD_kCwMP1Y",
         "The no-neutral path — what to do when the switch box has live only.",
         "الحل عند وجود خط حي فقط في علبة المفتاح دون سلك محايد."),
        ("https://www.youtube.com/watch?v=LaqPDBbMgLM",
         "Adding a neutral wire — the expensive option. Useful for showing trainees what they are actually quoting for.",
         "إضافة سلك محايد — الخيار المكلف. مفيد ليرى المتدرب ما الذي يسعّره فعليًا."),
    ]),
    ("M13", "Home Assistant", [
        ("https://www.youtube.com/watch?v=gN-_TO_HnTQ",
         "Zigbee integration into Home Assistant — the cleanest end-to-end walkthrough of the direct-Zigbee path.",
         "دمج Zigbee مع Home Assistant — أوضح شرح متكامل لمسار Zigbee المباشر."),
        ("https://www.youtube.com/watch?v=SlgC7xhhzzE",
         "SONOFF Zigbee 3.0 USB Dongle Plus setup — model-specific, matches hardware you actually sell.",
         "إعداد دونجل SONOFF Zigbee 3.0 — خاص بالموديل الذي تبيعه فعليًا."),
        ("https://www.youtube.com/watch?v=YrAzjQ3of0o",
         "Adding Zigbee devices with a dongle — covers the pairing loop after the coordinator is running.",
         "إضافة أجهزة Zigbee عبر الدونجل — يغطي دورة الاقتران بعد تشغيل المنسّق."),
    ]),
    ("M14", "Dimmer", [
        ("https://www.youtube.com/watch?v=EDmXiG5AvSQ",
         "Leading vs trailing edge dimmers — the core one. It explains the waveform difference behind this lesson's load-type table.",
         "الديمر ذو الحافة الأمامية مقابل الخلفية — الفيديو الأساسي. يشرح فرق الموجة الذي يقوم عليه جدول أنواع الأحمال في الدرس."),
        ("https://www.youtube.com/watch?v=tRGfppBahgY",
         "Guide to flawless LED dimming — practical on minimum load and driver compatibility.",
         "دليل عملي لخفض إضاءة LED دون مشاكل: الحد الأدنى للحمل وتوافق المُشغّل (Driver)."),
        ("https://www.youtube.com/watch?v=zuaQ8WIMUbQ",
         "Dimming LED lamps: tips and problems — symptom-led, pairs with the fault column of the diagram.",
         "مشاكل خفض إضاءة LED — منظّم حسب العَرَض، ويكمل عمود الأعطال في المخطط."),
    ]),
    ("M14", "Flashing", [
        ("https://www.youtube.com/watch?v=t-f4f6mhAQw",
         "SONOFF dongle flasher guide — follows the same step order as this lesson's flashing diagram.",
         "دليل برمجة دونجل SONOFF — يتبع ترتيب الخطوات نفسه الموجود في مخطط الدرس."),
        ("https://www.youtube.com/watch?v=KBAGWBWBATg",
         "Dongle Plus firmware upgrade — a second angle on bootloader entry, the step that trips people. Note: neither video stresses that re-pairing every device is mandatory afterwards. This lesson does.",
         "ترقية البرنامج الثابت للدونجل — زاوية ثانية على الدخول لوضع الإقلاع، وهي الخطوة التي يتعثر فيها الكثيرون. تنبيه: الفيديوهان لا يؤكدان أن إعادة اقتران كل الأجهزة إلزامية بعدها، وهذا الدرس يؤكدها."),
    ]),
    ("M15", "Zigbee Mesh", [
        ("https://www.youtube.com/watch?v=MDD7RRjr7uo",
         "Why your Zigbee mesh keeps failing — symptom-to-cause structure, the same as this lesson's diagnosis diagram.",
         "لماذا تفشل شبكة Zigbee المتشابكة — مبني على الانتقال من العَرَض إلى السبب، مثل مخطط التشخيص في الدرس."),
        ("https://www.youtube.com/watch?v=uPo7Mi0WLb4",
         "Improving a Zigbee network cheaply — concrete: adding routers to fix coverage.",
         "تحسين شبكة Zigbee بتكلفة منخفضة — عملي: إضافة موجّهات لمعالجة التغطية."),
        ("https://www.youtube.com/watch?v=yY-aD1hvwr4",
         "Coordinator placement — the cause trainees overlook most often.",
         "موضع المنسّق (Coordinator) — السبب الذي يغفله المتدربون غالبًا."),
    ]),
    ("M16", "Segmentation", [
        ("https://www.youtube.com/watch?v=eqr-vTC7EVk",
         "VLANs and firewalls for smart homes — conceptual grounding for this lesson's segmentation diagram.",
         "شبكات VLAN وجدران الحماية للمنزل الذكي — الأساس النظري لمخطط التقسيم في الدرس."),
        ("https://www.youtube.com/watch?v=xMHQy4u8JZA",
         "IoT VLAN firewall rules in practice — shows the one-way rule concretely, and why mDNS complicates it. UniFi-specific menus; the principle is vendor-neutral.",
         "قواعد جدار الحماية لشبكة إنترنت الأشياء عمليًا — يوضح قاعدة الاتجاه الواحد وسبب تعقيد mDNS لها. القوائم خاصة بـ UniFi، لكن المبدأ عام."),
    ]),
    ("I01", "Latch Circuit", [
        ("https://www.youtube.com/watch?v=3f3OnyM0S2E",
         "Latching circuits — matches the latch diagram. Watch for why stop sits upstream of the latch junction.",
         "دوائر التثبيت — يطابق مخطط الدرس. ركّز على سبب وجود زر الإيقاف قبل نقطة التثبيت."),
        ("https://www.youtube.com/watch?v=9x9QdL9N7vc",
         "Wiring a 3-phase motor with start/stop — the physical wiring of the same circuit, connecting schematic to panel.",
         "توصيل محرك ثلاثي الأطوار بزري تشغيل وإيقاف — التنفيذ الفعلي لنفس الدائرة، يربط المخطط باللوحة."),
    ]),
    ("I02", "Star-Delta Starting", [
        ("https://www.youtube.com/watch?v=J0rs0vSLpRk",
         "Star-delta starters explained — best on why star-delta reduces starting current. After watching, ask which parts Alpha Control may replace: the timer and signalling, never the contactors or overload relay.",
         "شرح بادئ نجمة-دلتا — الأفضل في توضيح سبب خفض تيار البدء. بعد المشاهدة اسأل: أي أجزاء يمكن أن يحل محلها Alpha Control؟ المؤقّت والإشارات فقط، وليس الكونتاكتورات أو ريلاي الحمل الزائد."),
        ("https://www.youtube.com/watch?v=vVs_1oEVMgQ",
         "Star-delta control wiring in a real panel.",
         "توصيل دائرة تحكم نجمة-دلتا في لوحة حقيقية."),
        ("https://www.youtube.com/watch?v=h89TTwlNnpY",
         "Star-delta working principle, animated — good for trainees who struggle to picture the transition moment.",
         "مبدأ عمل نجمة-دلتا بالرسوم المتحركة — مفيد لمن يصعب عليه تصور لحظة الانتقال."),
    ]),
    ("I04", "ON-Delay and OFF-Delay", [
        ("https://www.youtube.com/watch?v=r9HeJMCjwjk",
         "On-delay and off-delay timers — matches this lesson's timing diagram directly.",
         "مؤقّتات التأخير عند التشغيل وعند الإيقاف — يطابق مخطط التوقيت في الدرس."),
        ("https://www.youtube.com/watch?v=yTU7EjTV778",
         "Off-delay alone — the harder of the two to picture.",
         "تأخير الإيقاف وحده — الأصعب في التصور بين الاثنين."),
        ("https://www.youtube.com/watch?v=VQSRWBWwT80",
         "On/off delay timer connection — wiring-level, complements the theory.",
         "توصيل مؤقّت التأخير عمليًا — يكمل الجانب النظري."),
    ]),
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

    def get(q):
        r = subprocess.run(["curl", "-s", url + q, *auth],
                           capture_output=True, text=True, encoding="utf-8")
        return json.loads(r.stdout)

    modules = {m["code"]: m["id"] for m in get("/rest/v1/modules?select=id,code&limit=100")}
    lessons = get("/rest/v1/lessons?select=id,module_id,title,position&limit=500")
    existing = {m["storage_path"]: m["id"]
                for m in get("/rest/v1/lesson_media?select=id,storage_path&limit=800")}

    planned, unresolved = [], []
    for code, keyword, vids in RESOURCES:
        mid = modules.get(code)
        if not mid:
            unresolved.append((code, keyword, "module code not found"))
            continue
        hits = [l for l in lessons
                if l["module_id"] == mid and keyword.lower() in (l["title"] or "").lower()]
        if len(hits) != 1:
            unresolved.append((code, keyword, f"{len(hits)} lessons matched"))
            continue
        lesson = hits[0]
        print(f"  {code} · {lesson['title'][:52]}  ({len(vids)} videos)")
        for i, (vurl, cap, cap_ar) in enumerate(vids):
            planned.append({
                "lesson_id": lesson["id"], "kind": "video", "storage_path": vurl,
                "caption": cap, "caption_ar": cap_ar,
                "position": BASE_POSITION + i,
            })

    if unresolved:
        print("\nUNRESOLVED (nothing written for these):")
        for c, k, why in unresolved:
            print(f"  {c} '{k}': {why}")

    new = [p for p in planned if p["storage_path"] not in existing]
    upd = [p for p in planned if p["storage_path"] in existing]
    print(f"\n{len(planned)} video resources across "
          f"{len({p['lesson_id'] for p in planned})} lessons "
          f"({len(new)} new, {len(upd)} existing)")

    if not apply:
        print("\nDRY RUN — re-run with --apply to write")
        return 1 if unresolved else 0

    ok = 0
    for p in planned:
        fd, pf = tempfile.mkstemp(suffix=".json")
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump(p, f, ensure_ascii=False)
        try:
            eid = existing.get(p["storage_path"])
            if eid:
                args = ["-X", "PATCH", f"{url}/rest/v1/lesson_media?id=eq.{eid}"]
            else:
                args = ["-X", "POST", f"{url}/rest/v1/lesson_media"]
            r = subprocess.run(
                ["curl", "-s", "-w", "\n%{http_code}", *args, *auth,
                 "-H", "Content-Type: application/json",
                 "-H", "Prefer: return=minimal", "--data-binary", f"@{pf}"],
                capture_output=True, text=True, encoding="utf-8")
            code = r.stdout.rpartition("\n")[2]
            if code in ("200", "201", "204"):
                ok += 1
            else:
                print(f"  FAILED {p['storage_path']}: {code} {r.stdout[:120]}")
        finally:
            os.unlink(pf)

    print(f"attached {ok}/{len(planned)} video resources")
    return 0 if ok == len(planned) and not unresolved else 1


if __name__ == "__main__":
    raise SystemExit(main())
