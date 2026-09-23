#!/usr/bin/env python3
"""Second diagram set: the SONOFF track (M11-M17) plus F01, F03, F08.

The first generator (gen_diagrams.py) covered the industrial-control and
electrical-fundamentals lessons. An audit showed the entire SONOFF track --
30 lessons -- had no diagrams at all, which is exactly where a smart-home
installer needs them most: retrofit wiring, dimmer load types, mesh
troubleshooting, network segmentation.

Same rules as the first set, all learned the hard way:
  * original artwork from primitives, no third-party images
  * valid XML, validated before write (a duplicate attribute once made every
    file render blank as a standalone .svg)
  * explicit colours, no theme dependency
  * Arabic text WITHOUT direction="rtl" -- it inverts text-anchor="end" and
    pushes titles off the canvas
  * English and Arabic footer notes on separate lines, never one baseline

Run: python3 scripts/gen_diagrams2.py  ->  public/diagrams/
"""
from __future__ import annotations

import os
import xml.etree.ElementTree as ET

OUT = os.path.join("public", "diagrams")

BG = "#ffffff"
INK = "#0f172a"
MUT = "#5b6472"
ACC = "#c2410c"
OK = "#15803d"
BAD = "#b91c1c"
BLU = "#1d4ed8"
GRY = "#c9d2de"

DIAGRAMS: dict[str, tuple[str, str | None, str, str]] = {}


def esc(s: str) -> str:
    return (s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"))


def line(x1, y1, x2, y2, c=INK, w=1.7, dash=None, op=1.0):
    d = f' stroke-dasharray="{dash}"' if dash else ""
    return (f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{c}" '
            f'stroke-width="{w}" stroke-linecap="round" opacity="{op}"{d}/>')


def path(d, c=INK, w=1.7, dash=None, fill="none", op=1.0):
    da = f' stroke-dasharray="{dash}"' if dash else ""
    return (f'<path d="{d}" fill="{fill}" stroke="{c}" stroke-width="{w}" '
            f'stroke-linejoin="round" stroke-linecap="round" opacity="{op}"{da}/>')


def rect(x, y, w_, h_, c=INK, w=1.7, r=5, fill="none", dash=None):
    da = f' stroke-dasharray="{dash}"' if dash else ""
    return (f'<rect x="{x}" y="{y}" width="{w_}" height="{h_}" rx="{r}" '
            f'fill="{fill}" stroke="{c}" stroke-width="{w}"{da}/>')


def txt(x, y, s, size=12.5, c=INK, weight="500", anchor="start", style=""):
    st = ' font-style="italic"' if style == "i" else ""
    return (f'<text x="{x}" y="{y}" font-family="Segoe UI, system-ui, sans-serif" '
            f'font-size="{size}" fill="{c}" font-weight="{weight}" '
            f'text-anchor="{anchor}"{st}>{esc(s)}</text>')


def ar(x, y, s, size=12.5, c=MUT, weight="500", anchor="end"):
    """Arabic label. No direction="rtl" -- it inverts text-anchor and clips."""
    return (f'<text x="{x}" y="{y}" font-family="Noto Sans Arabic, Segoe UI, '
            f'Tahoma, sans-serif" font-size="{size}" fill="{c}" '
            f'font-weight="{weight}" text-anchor="{anchor}">{esc(s)}</text>')


def dot(x, y, c=INK, r=3.0):
    return f'<circle cx="{x}" cy="{y}" r="{r}" fill="{c}"/>'


def circ(x, y, r, c=INK, w=1.7, fill="none"):
    return (f'<circle cx="{x}" cy="{y}" r="{r}" fill="{fill}" stroke="{c}" '
            f'stroke-width="{w}"/>')


def arrow_h(x1, x2, y, c=INK, w=1.6):
    d = 1 if x2 > x1 else -1
    return (line(x1, y, x2, y, c, w)
            + path(f"M{x2} {y} L{x2 - 7 * d} {y - 4} L{x2 - 7 * d} {y + 4} Z",
                   c, w, fill=c))


def arrow_v(y1, y2, x, c=INK, w=1.6):
    d = 1 if y2 > y1 else -1
    return (line(x, y1, x, y2, c, w)
            + path(f"M{x} {y2} L{x - 4} {y2 - 7 * d} L{x + 4} {y2 - 7 * d} Z",
                   c, w, fill=c))


def box(x, y, w_, h_, label, sub=None, c=INK, fill="#f8fafc", size=12.5):
    s = rect(x, y, w_, h_, c, 1.6, 6, fill)
    s += txt(x + w_ / 2, y + (h_ / 2 + 4 if not sub else h_ / 2 - 2),
             label, size, INK, "600", "middle")
    if sub:
        s += txt(x + w_ / 2, y + h_ / 2 + 14, sub, 10.5, MUT, "500", "middle")
    return s


def title_block(w, en, arabic):
    return (txt(16, 24, en, 14.5, INK, "700")
            + ar(w - 16, 24, arabic, 13.5, MUT, "600")
            + line(16, 34, w - 16, 34, "#d7dee8", 1.2))


def note(w, h, en, arabic=None):
    s = txt(16, h - 26, en, 11.5, MUT, "500", style="i")
    if arabic:
        s += ar(w - 16, h - 10, arabic, 11, MUT)
    return s


def build(name, w, h, aria, body, lesson=None, cap_en="", cap_ar=""):
    svg = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" '
           f'width="{w}" height="{h}" role="img" aria-label="{esc(aria)}">'
           f'<rect width="{w}" height="{h}" fill="{BG}"/>{body}</svg>')
    ET.fromstring(svg)
    DIAGRAMS[name] = (svg, lesson, cap_en, cap_ar)


# ============================================================== M11 L1
def d_portfolio_map():
    W, H = 700, 360
    b = title_block(W, "SONOFF portfolio: choosing by job, not by name",
                    "اختيار المنتج حسب المهمة")
    cols = [
        (40, "In-line relay", "behind an existing switch", OK),
        (205, "Wall switch", "replaces the faceplate", BLU),
        (370, "Socket / plug", "no wiring at all", ACC),
        (535, "Gateway / hub", "carries the mesh", MUT),
    ]
    for x, name, sub, c in cols:
        b += box(x, 62, 125, 58, name, sub, c)
    q = [
        (150, "Is the wiring accessible?", "Neutral present?"),
        (196, "Is the faceplate replaceable?", "Client accepts new look?"),
        (242, "Is it a plug-in appliance?", "Portable load?"),
    ]
    for y, en, ar_hint in q:
        b += txt(40, y, en, 12, INK, "600")
        b += txt(300, y, ar_hint, 11.5, MUT, "500")
    b += rect(28, 132, W - 56, 128, GRY, 1.3, 8, "none", "4 4")
    b += txt(40, 288, "Decide in this order — wiring first, appearance second, convenience last.",
             12, ACC, "600")
    b += ar(W - 16, 310, "القرار بالترتيب: التوصيل أولًا ثم الشكل ثم الراحة", 11.5, MUT)
    b += note(W, H, "A socket cannot solve a lighting job; a relay cannot solve a rented flat.",
              "المقبس لا يحل مشكلة إنارة، والمرحل لا يصلح لشقة مؤجرة")
    build("m11-portfolio-decision", W, H,
          "Choosing a SONOFF device class by installation constraint", b,
          "0cac31d9-271a-4afe-b583-4c85bfa227d9",
          "Device selection runs on constraints, not preference: wiring access decides first, appearance second, convenience last.",
          "اختيار الجهاز يعتمد على القيود لا التفضيل: إتاحة التوصيل أولًا، ثم الشكل، ثم الراحة.")


# ============================================================== M11 L2
def d_protocol_pick():
    W, H = 700, 372
    b = title_block(W, "Wi-Fi, Zigbee or Matter: what decides",
                    "ما الذي يحدد اختيار البروتوكول")
    rows = [
        ("Device count in the home", "under ~15", "15 and above", "any"),
        ("Needs a hub", "no", "yes — gateway", "yes — border router"),
        ("Battery sensors", "poor", "excellent", "excellent"),
        ("Works if internet drops", "often not", "yes, locally", "yes, locally"),
        ("Cross-brand control", "app-bound", "brand mesh", "by design"),
    ]
    x0, y0, rh = 30, 62, 42
    cw = [250, 130, 140, 140]
    heads = ["Question", "Wi-Fi", "Zigbee 3.0", "Matter"]
    cx = x0
    for i, hd in enumerate(heads):
        b += rect(cx, y0, cw[i], 30, GRY, 1.2, 4, "#f1f5f9")
        b += txt(cx + 10, y0 + 20, hd, 12, INK, "700")
        cx += cw[i]
    for r, row in enumerate(rows):
        y = y0 + 30 + r * rh
        cx = x0
        for i, cell in enumerate(row):
            b += rect(cx, y, cw[i], rh, GRY, 1.0, 0)
            col = INK if i == 0 else MUT
            wt = "600" if i == 0 else "500"
            b += txt(cx + 10, y + rh / 2 + 4, cell, 11.5, col, wt)
            cx += cw[i]
    b += note(W, H,
              "Count the battery sensors first — that one answer usually settles the protocol.",
              "عدد حساسات البطارية يحسم الاختيار غالبًا")
    build("m11-protocol-decision", W, H,
          "Decision table comparing Wi-Fi, Zigbee and Matter", b,
          "0b64d103-84cc-45a7-8f4e-f621c06c13df",
          "Protocol choice by consequence: device count, hub need, battery life, offline behaviour and cross-brand control.",
          "اختيار البروتوكول بالنتائج: عدد الأجهزة، الحاجة لبوابة، عمر البطارية، السلوك دون إنترنت، والتحكم بين العلامات.")


# ============================================================== M11 L3
def d_ewelink_paths():
    W, H = 700, 330
    b = title_block(W, "eWeLink: cloud path vs local path",
                    "المسار السحابي مقابل المسار المحلي")
    b += box(30, 70, 120, 52, "Phone app", None, INK)
    b += box(290, 62, 130, 40, "eWeLink cloud", None, BLU, "#eff6ff")
    b += box(290, 140, 130, 40, "LAN / gateway", None, OK, "#f0fdf4")
    b += box(550, 100, 120, 52, "Device", None, INK)
    b += arrow_h(152, 288, 88, BLU)
    b += arrow_h(422, 548, 100, BLU)
    b += txt(215, 80, "internet", 11, BLU, "600", "middle")
    b += arrow_h(152, 288, 160, OK)
    b += arrow_h(422, 548, 146, OK)
    b += txt(215, 152, "local only", 11, OK, "600", "middle")
    b += txt(30, 218, "Cloud path dies with the internet. Local path survives it.",
             12.5, ACC, "600")
    b += ar(W - 16, 240, "المسار السحابي (Cloud) يتوقف بانقطاع الإنترنت، والمحلي يستمر", 11.5, MUT)
    b += txt(30, 264, "Always demo the local path to the client before handover.",
             11.5, MUT, "500", style="i")
    b += note(W, H, "Scenes stored on the gateway keep running; cloud-only scenes stop.",
              "المشاهد على البوابة تستمر، والسحابية تتوقف")
    build("m11-ewelink-paths", W, H,
          "eWeLink cloud versus local control paths", b,
          "fec3280c-d47c-4b69-90a6-e05c61648e73",
          "Two control paths: the cloud route fails with the internet, the local route keeps working — which is what the client actually feels.",
          "مساران للتحكم: السحابي يتعطل بانقطاع الإنترنت، والمحلي يستمر — وهو ما يشعر به العميل فعليًا.")


# ============================================================== M12 L1
def d_neutral_check():
    W, H = 680, 348
    b = title_block(W, "The neutral question, before you quote",
                    "سؤال السلك المحايد قبل التسعير")
    b += box(40, 66, 170, 92, "Switch box has", "LIVE + NEUTRAL", OK, "#f0fdf4")
    b += box(250, 66, 170, 92, "Switch box has", "LIVE only", BAD, "#fef2f2")
    b += txt(125, 186, "Standard smart switch", 12, OK, "600", "middle")
    b += txt(125, 204, "fits directly", 11, MUT, "500", "middle")
    b += txt(335, 186, "No-neutral model, OR", 12, BAD, "600", "middle")
    b += txt(335, 204, "in-line relay at the fitting", 11, MUT, "500", "middle")
    b += arrow_v(158, 176, 125, OK)
    b += arrow_v(158, 176, 335, BAD)
    b += rect(450, 66, 200, 138, ACC, 1.5, 8, "#fff7ed")
    b += txt(550, 92, "Test, never assume", 12.5, ACC, "700", "middle")
    for i, s in enumerate(["Probe live-to-neutral", "Probe live-to-earth",
                           "A reading on both means", "a true neutral is present"]):
        b += txt(468, 116 + i * 20, s, 11, MUT, "500")
    b += txt(40, 244, "A blue wire is not proof. Older installations loop switched-live in blue.",
             12, INK, "600")
    b += ar(W - 16, 268, "اللون الأزرق ليس دليلًا — قِس قبل الحكم", 11.5, MUT)
    b += note(W, H, "Getting this wrong on site turns a one-hour job into a rewire.",
              "الخطأ هنا يحوّل عملًا من ساعة إلى إعادة تمديد")
    build("m12-neutral-check", W, H,
          "Deciding smart switch type by presence of a neutral conductor", b,
          "c09e7b10-810a-49bf-ac15-b4db2e083500",
          "The neutral decides the product. Measure at the box before quoting — wire colour is not evidence in older installations.",
          "السلك المحايد يحدد المنتج. قِس في العلبة قبل التسعير — لون السلك ليس دليلًا في التمديدات القديمة.")


# ============================================================== M12 L3
def d_automation_anatomy():
    W, H = 700, 300
    b = title_block(W, "Anatomy of a reliable automation",
                    "تشريح الأتمتة الموثوقة")
    parts = [
        (30, "TRIGGER", "what starts it", BLU),
        (200, "CONDITION", "when it may run", ACC),
        (370, "ACTION", "what it does", OK),
        (540, "FALLBACK", "if it fails", MUT),
    ]
    for x, name, sub, c in parts:
        b += box(x, 66, 130, 56, name, sub, c)
    for x in (160, 330, 500):
        b += arrow_h(x, x + 40, 94, MUT)
    ex = [
        ("Motion detected", "after sunset AND", "hall light 40%", "off after 3 min"),
        ("", "nobody home = skip", "", "manual switch wins"),
    ]
    for r, row in enumerate(ex):
        for i, cell in enumerate(row):
            if cell:
                b += txt(30 + i * 170 + 65, 152 + r * 20, cell, 11, MUT, "500", "middle")
    b += rect(22, 132, W - 44, 60, GRY, 1.2, 6, "none", "4 4")
    b += txt(30, 226, "An automation without a condition fires at noon. Without a fallback it traps the client.",
             12, ACC, "600")
    b += ar(W - 16, 250, "بدون شرط تعمل في غير وقتها، وبدون بديل تحبس العميل", 11.5, MUT)
    b += note(W, H, "The manual switch must always override the automation.",
              "المفتاح اليدوي يجب أن يتجاوز الأتمتة دائمًا")
    build("m12-automation-anatomy", W, H,
          "Four parts of a reliable automation rule", b,
          "01938302-b182-4992-a51c-a07cc1e6c9ef",
          "Trigger, condition, action, fallback. Skipping the condition makes it fire wrongly; skipping the fallback strands the client.",
          "المُشغّل والشرط والفعل والبديل. إهمال الشرط يجعلها تعمل خطأً، وإهمال البديل يترك العميل عالقًا.")


# ============================================================== M13 L1
def d_ha_integration():
    W, H = 700, 330
    b = title_block(W, "Three ways SONOFF reaches Home Assistant",
                    "ثلاث طرق للربط مع Home Assistant")
    paths = [
        (62, "Cloud API", "eWeLink account", "internet required", BLU, "slowest, survives nothing"),
        (140, "LAN mode", "device on local network", "no internet needed", OK, "fast, limited models"),
        (218, "Zigbee direct", "via coordinator dongle", "no eWeLink at all", ACC, "fastest, full control"),
    ]
    for y, name, how, cond, c, verdict in paths:
        b += rect(30, y - 20, 200, 52, c, 1.5, 6, "#f8fafc")
        b += txt(42, y, name, 12.5, INK, "700")
        b += txt(42, y + 16, how, 10.5, MUT, "500")
        b += arrow_h(236, 330, y + 4, c)
        b += txt(340, y, cond, 11.5, c, "600")
        b += txt(340, y + 16, verdict, 10.5, MUT, "500")
    b += txt(30, 272, "Flashing a dongle removes the vendor cloud from the path entirely.",
             12, ACC, "600")
    b += ar(W - 16, 294, "استخدام الدونجل يلغي الاعتماد على السحابة تمامًا", 11.5, MUT)
    build("m13-ha-paths", W, H,
          "Three integration routes from SONOFF devices to Home Assistant", b,
          "b76de319-41eb-40fa-8264-3ee645c9587c",
          "Cloud, LAN or direct Zigbee. Each trades setup effort against how much of the chain can fail.",
          "سحابي أو محلي أو زيجبي مباشر. كل خيار يوازن بين جهد الإعداد وعدد نقاط الفشل في السلسلة.")


# ============================================================== M14 L1
def d_retrofit_socket():
    W, H = 700, 372
    b = title_block(W, "Retrofit wiring: what goes where",
                    "توصيل الاستبدال: ما يذهب أين")
    b += txt(40, 62, "EXISTING", 12, MUT, "700")
    b += txt(400, 62, "SMART SWITCH", 12, ACC, "700")
    ys = [104, 148, 192, 236]
    names = [("L", "live in", BAD), ("N", "neutral", BLU),
             ("L1", "switched live out", ACC), ("E", "earth", OK)]
    for y, (tag, what, c) in zip(ys, names):
        b += circ(70, y, 13, c, 1.8, "#ffffff")
        b += txt(70, y + 4.5, tag, 11.5, c, "700", "middle")
        b += txt(96, y + 4.5, what, 11.5, MUT, "500")
        b += circ(430, y, 13, c, 1.8, "#ffffff")
        b += txt(430, y + 4.5, tag, 11.5, c, "700", "middle")
        b += line(83, y, 417, y, c, 1.6)
    b += rect(470, 86, 190, 168, ACC, 1.5, 8, "#fff7ed")
    b += txt(565, 112, "Before you disconnect", 12, ACC, "700", "middle")
    for i, s in enumerate(["Photograph the terminals", "Label every conductor",
                           "Never trust wire colour", "Confirm dead, then work"]):
        b += txt(486, 138 + i * 22, f"{i + 1}. {s}", 11, MUT, "500")
    b += txt(40, 288, "The switched live is the one that goes dead when the old switch is off.",
             12, INK, "600")
    b += ar(W - 16, 312, "الخط المُفتاح هو الذي ينقطع عند إطفاء المفتاح القديم", 11.5, MUT)
    b += note(W, H, "Photograph first: the old wiring is the only record of itself.",
              "صوّر أولًا — التمديد القديم هو السجل الوحيد لنفسه")
    build("m14-retrofit-terminals", W, H,
          "Terminal-by-terminal retrofit of a conventional switch to a smart switch", b,
          "839bb3c5-2ccf-4172-9b50-b05e37fd14d9",
          "Terminal mapping for a retrofit, with the four checks that prevent a destroyed device or a callback.",
          "خريطة الأطراف عند الاستبدال، مع أربع خطوات تمنع تلف الجهاز أو عودة العميل.")


# ============================================================== M14 L2
def d_dimmer_loads():
    W, H = 700, 348
    b = title_block(W, "Dimmer load types and what goes wrong",
                    "أنواع الأحمال مع الديمر وما يحدث من أخطاء")
    rows = [
        ("Leading edge", "wire-wound transformer, incandescent",
         "hum, flicker on LED", BAD),
        ("Trailing edge", "LED driver, electronic transformer",
         "correct for most LED", OK),
        ("Wrong mode", "LED on leading edge",
         "buzz, early driver failure", BAD),
        ("Below minimum", "load under the dimmer's floor",
         "flicker, will not strike", ACC),
    ]
    y0, rh = 66, 52
    for i, (mode, load, effect, c) in enumerate(rows):
        y = y0 + i * rh
        b += rect(30, y, 640, rh - 6, GRY, 1.1, 5,
                  "#f8fafc" if i % 2 == 0 else "#ffffff")
        b += txt(44, y + 20, mode, 12, INK, "700")
        b += txt(44, y + 36, load, 10.5, MUT, "500")
        b += circ(360, y + 23, 5, c, 0, c)
        b += txt(376, y + 27, effect, 11.5, c, "600")
    b += txt(30, 300, "Set the mode to match the driver, then raise the minimum until it strikes cleanly every time.",
             11.5, ACC, "600")
    b += note(W, H, "A dimmer that works at 80% and flickers at 10% is set wrong, not faulty.",
              "الوميض عند الخفض يعني ضبطًا خاطئًا لا عطلًا")
    build("m14-dimmer-loads", W, H,
          "Dimmer modes matched to load types and their failure symptoms", b,
          "9075ae13-2ba4-40ad-9519-a4a9dd0f6daf",
          "Leading versus trailing edge, and the symptoms each mismatch produces — buzz, flicker and early driver failure.",
          "الحافة الأمامية مقابل الخلفية، وأعراض كل خطأ: طنين ووميض وتلف مبكر للمُشغّل.")


# ============================================================== M14 L5
def d_dongle_flash():
    W, H = 700, 300
    b = title_block(W, "Flashing a Zigbee coordinator: the order that matters",
                    "ترتيب خطوات برمجة الدونجل")
    steps = [
        ("1", "Back up", "current firmware"),
        ("2", "Bootloader", "hold BOOT, then plug"),
        ("3", "Erase", "full chip"),
        ("4", "Write", "coordinator image"),
        ("5", "Verify", "read back"),
        ("6", "Re-pair", "devices rejoin"),
    ]
    x = 28
    for i, (n, name, sub) in enumerate(steps):
        b += circ(x + 26, 92, 19, ACC if i < 5 else OK, 1.8, "#fff7ed" if i < 5 else "#f0fdf4")
        b += txt(x + 26, 97, n, 13, ACC if i < 5 else OK, "700", "middle")
        b += txt(x + 26, 132, name, 11.5, INK, "700", "middle")
        b += txt(x + 26, 148, sub, 10, MUT, "500", "middle")
        if i < 5:
            b += arrow_h(x + 50, x + 84, 92, MUT)
        x += 110
    b += rect(22, 178, W - 44, 56, BAD, 1.4, 6, "#fef2f2")
    b += txt(38, 200, "Step 6 is not optional.", 12, BAD, "700")
    b += txt(38, 218, "A new coordinator has a new network key — every device must be re-paired, and the client must be told before you start.",
             11, MUT, "500")
    b += note(W, H, "Skipping the backup means a failed write leaves you with no route home.",
              "تجاهل النسخة الاحتياطية يعني فقدان طريق العودة")
    build("m14-dongle-flash", W, H,
          "Ordered procedure for flashing a Zigbee coordinator dongle", b,
          "4dcb9c97-e744-42f9-9b47-0cc43042b621",
          "Six ordered steps. The backup protects a failed write, and re-pairing is mandatory because the network key changes.",
          "ست خطوات مرتبة. النسخة الاحتياطية تحمي من فشل الكتابة، وإعادة الاقتران إلزامية لأن مفتاح الشبكة يتغير.")


# ============================================================== M15 L1
def d_mesh_diagnosis():
    W, H = 700, 372
    b = title_block(W, "Zigbee symptom to root cause",
                    "من العَرَض إلى السبب الجذري")
    sym = [
        ("One device drops,", "always the same one", "out of range, or", "no router nearby", ACC),
        ("Several drop", "at the same time", "a router died, or", "lost its power", BAD),
        ("Everything is slow", "after adding devices", "too few routers", "for the device count", BLU),
        ("Drops at one time", "of day only", "interference — check", "Wi-Fi channel overlap", OK),
    ]
    y = 66
    for s1, s2, c1, c2, c in sym:
        b += rect(30, y, 250, 58, GRY, 1.2, 6, "#f8fafc")
        b += txt(44, y + 24, s1, 11.5, INK, "600")
        b += txt(44, y + 42, s2, 11.5, INK, "600")
        b += arrow_h(288, 348, y + 29, c)
        b += txt(358, y + 24, c1, 11.5, c, "600")
        b += txt(358, y + 42, c2, 11.5, MUT, "500")
        y += 68
    b += txt(30, 348, "Mains-powered devices route. Battery devices never do — counting them as coverage is the usual mistake.",
             11.5, ACC, "600")
    build("m15-mesh-diagnosis", W, H,
          "Mapping Zigbee mesh symptoms to their root causes", b,
          "0a561f59-af42-4f59-b582-69ce224b2a75",
          "Each drop pattern points at a different cause. Battery devices never relay, so they add no coverage.",
          "كل نمط انقطاع يشير إلى سبب مختلف. أجهزة البطارية لا ترحّل، فلا تضيف تغطية.")


# ============================================================== M16 L1
def d_segmentation():
    W, H = 700, 348
    b = title_block(W, "Network segmentation for smart home devices",
                    "تقسيم الشبكة لأجهزة المنزل الذكي")
    nets = [
        (40, "MAIN", "phones, laptops, work", OK, "#f0fdf4"),
        (255, "IOT", "smart devices only", ACC, "#fff7ed"),
        (470, "GUEST", "visitors, isolated", BLU, "#eff6ff"),
    ]
    for x, name, sub, c, fill in nets:
        b += rect(x, 66, 190, 76, c, 1.7, 8, fill)
        b += txt(x + 95, 96, name, 13, c, "700", "middle")
        b += txt(x + 95, 116, sub, 10.5, MUT, "500", "middle")
    b += arrow_h(230, 250, 104, MUT)
    b += txt(240, 92, "one way", 9.5, MUT, "500", "middle")
    b += path("M450 104 L470 104", BAD, 2)
    b += line(455, 96, 465, 112, BAD, 2)
    b += line(465, 96, 455, 112, BAD, 2)
    b += txt(40, 186, "Main can reach IoT. IoT cannot reach Main. Guest reaches neither.",
             12.5, INK, "600")
    b += ar(W - 16, 210, "الرئيسية تصل للأجهزة، والأجهزة لا تصل للرئيسية", 11.5, MUT)
    b += rect(30, 228, W - 60, 72, GRY, 1.2, 6, "none", "4 4")
    b += txt(44, 252, "Why it matters:", 11.5, ACC, "700")
    b += txt(44, 272, "A compromised camera on a flat network reaches the client's laptop, bank session and files.",
             11, MUT, "500")
    b += txt(44, 290, "On a segmented network it reaches nothing.", 11, OK, "600")
    build("m16-segmentation", W, H,
          "Three-network segmentation with one-way access from main to IoT", b,
          "52a61e07-42d9-45d6-b8c3-638ca75f4faf",
          "One-way trust: main reaches IoT, IoT reaches nothing. A compromised device is contained instead of being a doorway.",
          "ثقة باتجاه واحد: الرئيسية تصل للأجهزة والعكس ممنوع. الجهاز المخترق يُحتوى بدل أن يكون بابًا.")


# ============================================================== M17 L3
def d_troubleshoot_tree():
    W, H = 700, 372
    b = title_block(W, "Symptom to root cause: work outward",
                    "من العَرَض إلى السبب: اعمل من الداخل للخارج")
    layers = [
        (78, "1. The load", "Does it work on a plain switch?", OK),
        (134, "2. The device", "LED on? responds locally?", BLU),
        (190, "3. The link", "paired? in range? router nearby?", ACC),
        (246, "4. The logic", "scene, condition, schedule", BAD),
    ]
    for y, name, q, c in layers:
        b += rect(30, y - 22, 330, 44, c, 1.5, 6, "#f8fafc")
        b += txt(44, y - 4, name, 12, INK, "700")
        b += txt(44, y + 13, q, 10.5, MUT, "500")
        b += arrow_h(368, 410, y, c)
        b += txt(420, y + 4, "prove it, then move on", 11, MUT, "500")
    b += arrow_v(100, 124, 195, MUT)
    b += arrow_v(156, 180, 195, MUT)
    b += arrow_v(212, 236, 195, MUT)
    b += txt(30, 300, "Most call-outs end at layer 1 or 2. Starting at the app wastes the visit.",
             12, ACC, "600")
    b += ar(W - 16, 324, "معظم الأعطال تنتهي عند الطبقة الأولى أو الثانية", 11.5, MUT)
    b += note(W, H, "Prove each layer before blaming the next one.",
              "أثبت كل طبقة قبل اتهام التالية")
    build("m17-troubleshoot-layers", W, H,
          "Four-layer troubleshooting order from load to logic", b,
          "c0468a0d-d67f-4263-bcde-9a766d73a1eb",
          "Work outward from the load. Each layer must be proven before the next is blamed — most faults end at the first two.",
          "اعمل من الحمل للخارج. أثبت كل طبقة قبل اتهام التالية — معظم الأعطال تنتهي عند الأوليين.")


# ============================================================== F03 L1
def d_survey_phases():
    W, H = 700, 318
    b = title_block(W, "Site survey: five phases, in order",
                    "المسح الميداني: خمس مراحل مرتبة")
    ph = [
        ("Walk", "see the property"),
        ("Ask", "what bothers them"),
        ("Measure", "wiring, signal, loads"),
        ("Record", "photos and forms"),
        ("Propose", "scope and price"),
    ]
    x = 34
    for i, (name, sub) in enumerate(ph):
        c = ACC if i < 4 else OK
        b += rect(x, 72, 118, 60, c, 1.6, 7, "#fff7ed" if i < 4 else "#f0fdf4")
        b += txt(x + 59, 98, f"{i + 1}. {name}", 12.5, INK, "700", "middle")
        b += txt(x + 59, 117, sub, 10, MUT, "500", "middle")
        if i < 4:
            b += arrow_h(x + 122, x + 128, 102, MUT)
        x += 132
    b += txt(34, 176, "Proposing before measuring is how a job loses money.",
             12.5, BAD, "700")
    b += ar(W - 16, 200, "التسعير قبل القياس هو سبب خسارة العمل", 11.5, MUT)
    b += txt(34, 228, "The client's answer in phase 2 decides which measurements matter in phase 3.",
             11.5, MUT, "500")
    b += note(W, H, "A survey that skips photos always costs a second visit.",
              "المسح بلا صور يكلف زيارة ثانية")
    build("f03-survey-phases", W, H,
          "Five ordered phases of a site survey", b,
          "2514ad34-417e-40ab-b80f-8fa25a675b0a",
          "Five phases in order. Quoting before measuring is the single most expensive sequencing error in the trade.",
          "خمس مراحل مرتبة. التسعير قبل القياس هو أغلى خطأ ترتيب في هذه المهنة.")


# ============================================================== F01 L3
def d_kpi_loop():
    W, H = 660, 366
    b = title_block(W, "Performance evaluation as a loop",
                    "تقييم الأداء كدورة مستمرة")
    cx, cy, r = 330, 172, 78
    # Sub-labels sit OUTSIDE the circles: an earlier version centred them on
    # the node and "against the KPI" spilled past the circle edge.
    pts = [(cx, cy - r, "Observe", "on real jobs", -44),
           (cx + r, cy, "Measure", "against the KPI", 0),
           (cx, cy + r, "Feed back", "same week", 46),
           (cx - r, cy, "Train", "on the gap", 0)]
    b += circ(cx, cy, r, GRY, 1.4, "none")
    for x, y, name, sub, dy in pts:
        b += circ(x, y, 30, ACC, 1.7, "#fff7ed")
        b += txt(x, y + 4, name, 11.5, INK, "700", "middle")
        if dy:
            b += txt(x, y + dy, sub, 10, MUT, "500", "middle")
        elif x > cx:
            b += txt(x + 38, y + 4, sub, 10, MUT, "500")
        else:
            b += txt(x - 38, y + 4, sub, 10, MUT, "500", "end")
    b += txt(40, 300, "A KPI measured once a year is a record, not a tool.",
             12, ACC, "600")
    b += ar(W - 16, 324, "المؤشر الذي يُقاس مرة سنويًا سجل لا أداة", 11.5, MUT)
    build("f01-kpi-loop", W, H,
          "Continuous performance evaluation loop", b,
          "5f1efe41-3ff6-4677-9efe-d0cec8d3ca22",
          "Evaluation only changes behaviour as a loop: observe, measure, feed back within the week, train on the gap.",
          "التقييم يغيّر السلوك كدورة: لاحظ، قِس، أعطِ التغذية الراجعة خلال الأسبوع، درّب على الفجوة.")


# ============================================================== F08 L3
def d_toolkit():
    W, H = 700, 348
    b = title_block(W, "The field toolkit, grouped by what it prevents",
                    "حقيبة الأدوات مرتبة حسب ما تمنعه")
    groups = [
        ("Prevents injury", OK, ["Voltage tester (البنسة الاختبار)",
                                 "Insulated screwdrivers",
                                 "Lock-off kit"]),
        ("Prevents damage", ACC, ["Side cutters (القصافة)",
                                  "Wire strippers",
                                  "Torque screwdriver"]),
        ("Prevents callbacks", BLU, ["Clamp meter (البنسة الأمبير)",
                                     "Network tester",
                                     "Label printer"]),
    ]
    x = 30
    for name, c, items in groups:
        b += rect(x, 62, 210, 178, c, 1.6, 8, "#f8fafc")
        b += txt(x + 105, 90, name, 12.5, c, "700", "middle")
        b += line(x + 16, 100, x + 194, 100, GRY, 1.1)
        for i, it in enumerate(items):
            b += txt(x + 105, 128 + i * 32, it, 10.5, MUT, "500", "middle")
        x += 223
    b += txt(30, 276, "Buy in that order. The cheapest tool that prevents one injury has already paid for itself.",
             11.5, ACC, "600")
    b += note(W, H, "A clamp meter turns a guess about load into a number.",
              "بنسة الأمبير تحوّل التخمين إلى رقم")
    build("f08-toolkit", W, H,
          "Field toolkit grouped by the failure each tool prevents", b,
          "5589552b-09fd-47f8-bb4d-7cc87fb98f51",
          "Tools grouped by what they prevent — injury, damage, callbacks — which is also the order to buy them in.",
          "الأدوات مرتبة حسب ما تمنعه: إصابة، تلف، عودة للموقع — وهو ترتيب الشراء أيضًا.")


def main() -> int:
    os.makedirs(OUT, exist_ok=True)
    for fn in [d_portfolio_map, d_protocol_pick, d_ewelink_paths,
               d_neutral_check, d_automation_anatomy, d_ha_integration,
               d_retrofit_socket, d_dimmer_loads, d_dongle_flash,
               d_mesh_diagnosis, d_segmentation, d_troubleshoot_tree,
               d_survey_phases, d_kpi_loop, d_toolkit]:
        fn()

    manifest = {}
    for name, (svg, lesson, cap_en, cap_ar) in DIAGRAMS.items():
        p = os.path.join(OUT, f"{name}.svg")
        with open(p, "w", encoding="utf-8") as f:
            f.write(svg)
        ET.parse(p)  # validate as a standalone file, how the bucket serves it
        manifest[name] = {"lesson_id": lesson, "caption_en": cap_en,
                          "caption_ar": cap_ar}
        print(f"  {name}.svg  ({len(svg):,} B)")

    import json
    with open(os.path.join("scripts", "diagrams2_manifest.json"), "w",
              encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=1)

    print(f"\n{len(DIAGRAMS)} diagrams written to {OUT}/ and validated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
