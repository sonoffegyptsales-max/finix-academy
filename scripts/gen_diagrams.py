#!/usr/bin/env python3
"""Generate original SVG diagrams for Finix Academy lessons.

All artwork is authored here from primitives -- no third-party images, no
copyright exposure.

Design rules learned the hard way:

* ONE style attribute on the root element. An earlier generation emitted two,
  which browsers tolerate for SVG inlined into HTML but which is fatal XML for
  a standalone .svg file -- exactly how these are served from the media bucket.
  Every file produced here is parsed with ElementTree before it is written.
* No CSS classes and no currentColor. Colours are explicit inline attributes so
  the diagram looks identical standalone, in light mode and in dark mode.
* White canvas with dark ink, the convention for schematics, rather than
  inheriting the app theme.
* Arabic is placed in its own text node, never concatenated into an English
  string, so the shaping engine sees a clean run.

Run:  python3 scripts/gen_diagrams.py
Out:  public/diagrams/*.svg  plus  scripts/diagram_targets.json
"""
from __future__ import annotations

import json
import os
import xml.etree.ElementTree as ET

BG = "#ffffff"
INK = "#12151b"   # primary lines and text
MUT = "#5b6472"   # secondary text
ACC = "#c2410c"   # signal / emphasis (Finix accent)
OK = "#15803d"    # safe / permitted
BAD = "#b91c1c"   # fault / blocked
FILL = "#f1f4f8"  # block fill

FONT = "system-ui,-apple-system,Segoe UI,Noto Sans Arabic,sans-serif"

DIAGRAMS: dict[str, tuple] = {}


# ---------------------------------------------------------------- primitives
def esc(s: str) -> str:
    return (s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"))


def line(x1, y1, x2, y2, c=INK, w=1.7, dash=None, op=1.0):
    d = f' stroke-dasharray="{dash}"' if dash else ""
    return (f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{c}" '
            f'stroke-width="{w}" opacity="{op}" stroke-linecap="round"{d}/>')


def path(d, c=INK, w=1.7, dash=None, fill="none", op=1.0):
    da = f' stroke-dasharray="{dash}"' if dash else ""
    return (f'<path d="{d}" fill="{fill}" stroke="{c}" stroke-width="{w}" '
            f'opacity="{op}" stroke-linejoin="round" stroke-linecap="round"{da}/>')


def rect(x, y, w_, h_, c=INK, w=1.7, r=5, fill="none", dash=None):
    da = f' stroke-dasharray="{dash}"' if dash else ""
    return (f'<rect x="{x}" y="{y}" width="{w_}" height="{h_}" rx="{r}" '
            f'fill="{fill}" stroke="{c}" stroke-width="{w}"{da}/>')


def txt(x, y, s, size=12.5, c=INK, weight="500", anchor="start", style=""):
    it = ' font-style="italic"' if style == "i" else ""
    return (f'<text x="{x}" y="{y}" font-family="{FONT}" font-size="{size}" '
            f'font-weight="{weight}" fill="{c}" text-anchor="{anchor}"{it}>'
            f'{esc(s)}</text>')


def ar(x, y, s, size=12.5, c=MUT, weight="500", anchor="end"):
    """Arabic label in its own text node.

    Deliberately does NOT set direction="rtl". With direction rtl, text-anchor
    "end" anchors at the LEFT of the run, so a right-aligned title grows
    rightward and runs off the canvas -- which clipped every title here until
    it was caught in render review. The bidi algorithm shapes and orders the
    Arabic correctly on its own; the anchor then means what it looks like.
    """
    return (f'<text x="{x}" y="{y}" font-family="{FONT}" font-size="{size}" '
            f'font-weight="{weight}" fill="{c}" text-anchor="{anchor}" '
            f'xml:lang="ar">{esc(s)}</text>')


def dot(x, y, c=INK, r=3.0):
    return f'<circle cx="{x}" cy="{y}" r="{r}" fill="{c}"/>'


def circ(x, y, r, c=INK, w=1.7, fill="none"):
    return (f'<circle cx="{x}" cy="{y}" r="{r}" fill="{fill}" stroke="{c}" '
            f'stroke-width="{w}"/>')


def arrow_h(x1, x2, y, c=INK, w=1.6):
    """Horizontal arrow, head at x2."""
    d = 1 if x2 > x1 else -1
    return (line(x1, y, x2 - 5 * d, y, c, w)
            + path(f"M{x2} {y} L{x2 - 7 * d} {y - 4} L{x2 - 7 * d} {y + 4} Z",
                   c, w, fill=c))


def arrow_v(y1, y2, x, c=INK, w=1.6):
    d = 1 if y2 > y1 else -1
    return (line(x, y1, x, y2 - 5 * d, c, w)
            + path(f"M{x} {y2} L{x - 4} {y2 - 7 * d} L{x + 4} {y2 - 7 * d} Z",
                   c, w, fill=c))


def no_contact(x, y, label=None, c=INK):
    """Normally-open contact, 34 px wide, centred on (x, y)."""
    s = (line(x - 17, y, x - 7, y, c) + line(x + 7, y, x + 17, y, c)
         + line(x - 7, y, x + 6, y - 11, c) + dot(x - 7, y, c) + dot(x + 7, y, c))
    if label:
        s += txt(x, y - 19, label, 11.5, c, "600", "middle")
    return s


def nc_contact(x, y, label=None, c=INK):
    """Normally-closed contact: bar across the blade."""
    s = (line(x - 17, y, x - 7, y, c) + line(x + 7, y, x + 17, y, c)
         + line(x - 7, y, x + 6, y - 11, c) + line(x + 1, y - 13, x + 8, y - 3, c)
         + dot(x - 7, y, c) + dot(x + 7, y, c))
    if label:
        s += txt(x, y - 21, label, 11.5, c, "600", "middle")
    return s


def coil(x, y, label, c=INK, w=54, h=30):
    return (rect(x - w / 2, y - h / 2, w, h, c, 1.8, 5, FILL)
            + txt(x, y + 4.5, label, 13, c, "700", "middle"))


def grid_v(x, y1, y2, c="#c9d2de", dash="3 4"):
    return line(x, y1, x, y2, c, 1.0, dash)


def title_block(w, en, arabic):
    """Title bar. English left, Arabic right -- never in one string."""
    return (txt(16, 24, en, 14.5, INK, "700")
            + ar(w - 16, 24, arabic, 13.5, MUT, "600")
            + line(16, 34, w - 16, 34, "#d7dee8", 1.2))


def note(w, h, en, arabic=None):
    """Footer note. English on the left, Arabic on a SEPARATE line below it.

    Both were once on the same baseline at opposite anchors, which collided
    whenever the English ran long -- as it usually does.
    """
    s = txt(16, h - 26, en, 11.5, MUT, "500", style="i")
    if arabic:
        s += ar(w - 16, h - 10, arabic, 11, MUT)
    return s


def build(name, w, h, aria, body, lesson=None, cap_en="", cap_ar=""):
    svg = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" '
           f'width="{w}" height="{h}" role="img" aria-label="{esc(aria)}">'
           f'<rect width="{w}" height="{h}" fill="{BG}"/>{body}</svg>')
    ET.fromstring(svg)  # hard fail on malformed XML
    DIAGRAMS[name] = (svg, lesson, cap_en, cap_ar)


# ================================================================== I01 L2
def d_latch():
    W, H = 620, 318
    L, N, y = 40, W - 40, 150
    b = title_block(W, "Latch circuit with stop priority", "دائرة التثبيت وأولوية الإيقاف")
    b += txt(L, 64, "L", 13, MUT, "700", "middle") + txt(N, 64, "N", 13, MUT, "700", "middle")
    b += line(L, 72, L, H - 60) + line(N, 72, N, H - 60)
    b += line(L, y, 108, y)
    b += nc_contact(125, y, "STOP (NC)")
    b += line(142, y, 208, y)
    b += nc_contact(225, y, "O/L (NC)")
    b += line(242, y, 318, y)
    b += no_contact(335, y, "START (NO)")
    b += line(352, y, 455, y)
    b += coil(482, y, "KM")
    b += line(509, y, N, y)
    # latch branch around START only
    jx, bx, by = 318, 335, y + 62
    b += line(jx, y, jx, by) + line(jx, by, bx - 17, by)
    b += no_contact(bx, by)
    b += txt(bx + 24, by + 4.5, "KM aux (NO)", 11.5, ACC, "600")
    b += line(bx + 17, by, 455, by) + line(455, by, 455, y) + dot(455, y)
    b += dot(jx, y)
    b += note(W, H,
              "Stop and overload sit upstream of the latch junction, so either one drops the coil.",
              "الإيقاف والحمل الزائد قبل نقطة التثبيت")
    build("i01-latch-stop-priority", W, H, "Contactor latch circuit with stop priority", b,
          "bc8df72a-46d0-4748-a85d-1a757439dc59",
          "Latch circuit: the auxiliary contact bypasses only START, while STOP and overload stay upstream so either can always break the hold.",
          "دائرة التثبيت: التلامس المساعد يتجاوز زر البدء فقط، بينما يبقى الإيقاف والحمل الزائد قبله ليستطيع أي منهما قطع التثبيت دائمًا.")


# ================================================================== I01 L3
def d_interlock():
    W, H = 620, 338
    L, N = 40, W - 40
    yf, yr = 140, 232
    b = title_block(W, "Reversing starter with mutual interlock", "التعشيق المتبادل في دائرة العكس")
    b += line(L, 60, L, H - 56) + line(N, 60, N, H - 56)
    b += txt(L, 52, "L", 13, MUT, "700", "middle") + txt(N, 52, "N", 13, MUT, "700", "middle")
    for y, me, other, col in ((yf, "KM1", "KM2", INK), (yr, "KM2", "KM1", INK)):
        b += line(L, y, 118, y)
        b += no_contact(135, y, f"{me} start")
        b += line(152, y, 258, y)
        b += nc_contact(275, y, f"{other} NC")
        b += line(292, y, 430, y)
        b += coil(458, y, me, col)
        b += line(485, y, N, y)
    b += rect(258, 108, 34, 168, BAD, 1.3, 6, "none", "4 4")
    b += txt(275, 300, "interlock pair", 11, BAD, "600", "middle")
    b += txt(352, 190, "each coil opens the other's NC contact",
             11.5, BAD, "600", "start")
    b += line(292, 186, 344, 186, BAD, 1.3)
    b += note(W, H,
              "Electrical interlock only. A mechanical interlock is still required on the contactors.",
              "التعشيق الكهربائي لا يغني عن الميكانيكي")
    build("i01-reversing-interlock", W, H, "Reversing starter mutual interlock", b,
          "7f4eb767-3afe-45a2-92a2-bc505962b8e2",
          "Mutual interlock: each direction's coil is fed through the other contactor's NC contact, so both can never energise together.",
          "التعشيق المتبادل: تُغذّى ملف كل اتجاه عبر التلامس المغلق للكونتاكتور الآخر، فلا يمكن تنشيطهما معًا أبدًا.")


# ================================================================== I02 L1
def d_inrush():
    W, H = 620, 318
    x0, x1 = 70, W - 60
    yb, yt = 240, 70
    b = title_block(W, "Motor starting current", "تيار بدء المحرك")
    b += arrow_v(yb, yt - 6, x0, MUT, 1.3) + arrow_h(x0, x1, yb, MUT, 1.3)
    b += txt(x0 - 8, yt + 4, "I", 12.5, MUT, "600", "end")
    b += txt(x1, yb + 20, "time", 11.5, MUT, "500", "end")
    b += ar(x1, yb + 36, "الزمن", 11, MUT)
    for mult, lab in ((1, "I rated"), (6, "6 x I rated")):
        yy = yb - mult * 26
        b += line(x0, yy, x1 - 10, yy, "#c9d2de", 1.1, "3 4")
        b += txt(x0 - 8, yy + 4, lab, 11, MUT, "500", "end")
    ypk, yss = yb - 6 * 26, yb - 26
    b += path(f"M{x0} {yb} L{x0 + 6} {ypk} L{x0 + 34} {ypk} "
              f"C{x0 + 90} {ypk} {x0 + 120} {yss} {x0 + 210} {yss} L{x1 - 12} {yss}",
              ACC, 2.4)
    b += txt(x0 + 44, ypk - 10, "direct-on-line inrush", 11.5, ACC, "700")
    b += path(f"M{x0} {yb} L{x0 + 6} {yb - 3 * 26} L{x0 + 40} {yb - 3 * 26} "
              f"C{x0 + 110} {yb - 3 * 26} {x0 + 150} {yss} {x0 + 250} {yss} L{x1 - 12} {yss}",
              OK, 2.2, "6 4")
    b += txt(x0 + 150, yb - 3 * 26 - 10, "star-delta / soft start", 11.5, OK, "700")
    b += note(W, H,
              "Inrush is brief but it sets cable, breaker and supply sizing -- not the running current.",
              "تيار البدء قصير لكنه يحدد مقاسات الكابل والقاطع")
    build("i02-starting-current", W, H, "Motor starting current versus time", b,
          "90e3717d-ec4e-45aa-800c-4a1670493ba3",
          "Starting current: direct-on-line draws roughly six times rated current until the motor approaches speed; reduced-voltage starting trades torque for a lower peak.",
          "تيار البدء: البدء المباشر يسحب نحو ستة أمثال التيار المقنن حتى يقارب المحرك سرعته، بينما البدء بجهد مخفّض يقايض العزم بذروة أقل.")


# ================================================================== F02 L4
def d_star_delta_conn():
    W, H = 640, 348
    b = title_block(W, "Star and delta winding connections", "توصيل النجمة والدلتا")
    # star
    cx, cy, r = 165, 185, 62
    b += txt(cx, 74, "Star (Y)", 13.5, INK, "700", "middle")
    b += ar(cx + 52, 74, "نجمة", 12, MUT, "middle")
    pts = [(cx, cy - r), (cx - r * 0.87, cy + r * 0.5), (cx + r * 0.87, cy + r * 0.5)]
    for (px, py), lab in zip(pts, ("U1", "V1", "W1")):
        b += line(cx, cy, px, py, INK, 2.0) + dot(px, py)
        ax = "middle" if lab == "U1" else ("end" if px < cx else "start")
        oy = -12 if lab == "U1" else 18
        b += txt(px + (0 if lab == "U1" else (-8 if px < cx else 8)), py + oy,
                 lab, 12, INK, "700", ax)
    b += dot(cx, cy, ACC, 4.5)
    b += txt(cx - 14, cy + 22, "neutral point", 10.5, ACC, "600", "end")
    b += txt(cx, cy + 96, "phase voltage = line / 1.73", 11.5, MUT, "500", "middle")
    # delta
    dx, dy, s = 470, 178, 76
    b += txt(dx, 74, "Delta (D)", 13.5, INK, "700", "middle")
    b += ar(dx + 58, 74, "دلتا", 12, MUT, "middle")
    tp = [(dx, dy - s * 0.62), (dx - s * 0.87, dy + s * 0.5), (dx + s * 0.87, dy + s * 0.5)]
    for i in range(3):
        b += line(tp[i][0], tp[i][1], tp[(i + 1) % 3][0], tp[(i + 1) % 3][1], INK, 2.0)
    for (px, py), lab in zip(tp, ("U1/W2", "V1/U2", "W1/V2")):
        b += dot(px, py)
        oy = -12 if py < dy else 20
        ax = "middle" if py < dy else ("end" if px < dx else "start")
        b += txt(px, py + oy, lab, 11.5, INK, "700", ax)
    b += txt(dx, dy + 96, "phase voltage = line voltage", 11.5, MUT, "500", "middle")
    b += line(320, 96, 320, 268, "#d7dee8", 1.2, "4 5")
    b += note(W, H,
              "Same motor, same supply: star gives about a third of the delta torque and current.",
              "النجمة تعطي نحو ثلث عزم وتيار الدلتا")
    build("f02-star-delta-connections", W, H, "Star and delta winding connections", b,
          "c7c13ea1-ef51-48a7-8989-0ff57cf793ec",
          "Star and delta: in star each winding sees line voltage divided by 1.73, which is why star-delta starting reduces both current and torque to roughly a third.",
          "النجمة والدلتا: في النجمة يرى كل ملف جهد الخط مقسومًا على ١٫٧٣، ولهذا يخفض بدء النجمة دلتا التيار والعزم إلى نحو الثلث.")


# ================================================================== I04 L5
def d_stardelta_timing():
    W, H = 640, 338
    x0, x1 = 118, W - 46
    b = title_block(W, "Star-delta timing sequence", "تتابع توقيت النجمة دلتا")
    rows = [("Main KM1", "الرئيسي", 96), ("Star KM2", "النجمة", 158),
            ("Delta KM3", "الدلتا", 220)]
    t_star, t_open, t_delta = 190, 330, 360
    for lab, arl, y in rows:
        b += txt(16, y + 4, lab, 12, INK, "600")
        b += ar(112, y + 18, arl, 10.5, MUT)
        b += line(x0, y, x1, y, "#e2e8f0", 1.2)
    for gx in (x0, t_star, t_open, t_delta):
        b += grid_v(gx, 84, 262)
    yl = 18
    # KM1 on at t0, stays on
    y = rows[0][2]
    b += path(f"M{x0} {y} L{x0} {y - yl} L{x1 - 8} {y - yl}", ACC, 2.3)
    # KM2 star: on t0 -> t_open
    y = rows[1][2]
    b += path(f"M{x0} {y} L{x0} {y - yl} L{t_open} {y - yl} L{t_open} {y}", ACC, 2.3)
    b += line(t_open, y, x1 - 8, y, ACC, 2.3)
    # KM3 delta: on after dead time
    y = rows[2][2]
    b += line(x0, y, t_delta, y, ACC, 2.3)
    b += path(f"M{t_delta} {y} L{t_delta} {y - yl} L{x1 - 8} {y - yl}", ACC, 2.3)
    # dead time band
    b += rect(t_open, 84, t_delta - t_open, 178, BAD, 1.2, 3, "#fdecec", "3 3")
    b += txt((t_open + t_delta) / 2, 280, "dead time", 11, BAD, "700", "middle")
    b += txt(x0 + 6, 296, "start", 11, MUT, "500")
    b += txt(t_open - 52, 296, "changeover", 10.5, MUT, "500", "middle")
    b += note(W, H,
              "KM2 must open before KM3 closes. Overlap is a phase-to-phase short across the windings.",
              "تراكب النجمة والدلتا يعني قصرًا بين الأوجه")
    build("i04-star-delta-timing", W, H, "Star delta contactor timing sequence", b,
          "1b75b486-5c97-4821-8cd4-54c406d0f9f1",
          "Star-delta sequence: the star contactor must fully open and an intentional dead time elapse before the delta contactor closes.",
          "تتابع النجمة دلتا: يجب أن يفتح كونتاكتور النجمة تمامًا وأن يمر زمن ميت مقصود قبل إغلاق كونتاكتور الدلتا.")


# ================================================================== I04 L2
def d_on_off_delay():
    W, H = 640, 318
    x0, x1 = 128, W - 46
    b = title_block(W, "ON-delay and OFF-delay", "تأخير التشغيل وتأخير الفصل")
    ti, tf = 236, 392
    rows = [("Input", "الدخل", 92), ("ON-delay out", "تأخير التشغيل", 158),
            ("OFF-delay out", "تأخير الفصل", 224)]
    for lab, arl, y in rows:
        b += txt(16, y + 4, lab, 12, INK, "600")
        b += ar(122, y + 18, arl, 10.5, MUT)
        b += line(x0, y, x1, y, "#e2e8f0", 1.2)
    for gx in (ti, tf):
        b += grid_v(gx, 80, 250)
    yl = 18
    y = rows[0][2]
    b += path(f"M{x0} {y} L{ti} {y} L{ti} {y - yl} L{tf} {y - yl} L{tf} {y} L{x1 - 8} {y}",
              INK, 2.2)
    y = rows[1][2]
    b += path(f"M{x0} {y} L{ti + 62} {y} L{ti + 62} {y - yl} L{tf} {y - yl} L{tf} {y} L{x1 - 8} {y}",
              ACC, 2.2)
    b += arrow_h(ti, ti + 62, y + 22, ACC, 1.3)
    b += txt(ti + 31, y + 38, "set time", 10.5, ACC, "600", "middle")
    y = rows[2][2]
    b += path(f"M{x0} {y} L{ti} {y} L{ti} {y - yl} L{tf + 62} {y - yl} L{tf + 62} {y} L{x1 - 8} {y}",
              ACC, 2.2)
    b += arrow_h(tf, tf + 62, y + 22, ACC, 1.3)
    b += txt(tf + 31, y + 38, "set time", 10.5, ACC, "600", "middle")
    b += note(W, H,
              "ON-delay times the start of the output. OFF-delay times its release after the input goes.",
              "الأول يؤخر البدء والثاني يؤخر الفصل")
    build("i04-on-off-delay", W, H, "ON delay and OFF delay timing", b,
          "8cbf2109-b632-4188-a35e-9b4a76e43d4f",
          "ON-delay waits the set time before the output picks up; OFF-delay holds the output on for the set time after the input is removed.",
          "تأخير التشغيل ينتظر الزمن المضبوط قبل عمل الخرج، وتأخير الفصل يبقي الخرج عاملًا للزمن المضبوط بعد زوال الدخل.")


# ================================================================== I04 L3
def d_interval_oneshot():
    W, H = 640, 348
    x0, x1 = 138, W - 46
    b = title_block(W, "Interval, one-shot and repeat-cycle", "الفترة والنبضة والدورة المتكررة")
    ti, tf = 250, 400
    rows = [("Input", "الدخل", 92), ("Interval", "فترة", 152),
            ("One-shot", "نبضة واحدة", 212), ("Repeat cycle", "دورة متكررة", 272)]
    for lab, arl, y in rows:
        b += txt(16, y + 4, lab, 12, INK, "600")
        b += ar(132, y + 17, arl, 10.5, MUT)
        b += line(x0, y, x1, y, "#e2e8f0", 1.2)
    for gx in (ti, tf):
        b += grid_v(gx, 80, 296)
    yl = 16
    y = rows[0][2]
    b += path(f"M{x0} {y} L{ti} {y} L{ti} {y - yl} L{tf} {y - yl} L{tf} {y} L{x1 - 8} {y}", INK, 2.2)
    y = rows[1][2]
    b += path(f"M{x0} {y} L{ti} {y} L{ti} {y - yl} L{ti + 70} {y - yl} L{ti + 70} {y} L{x1 - 8} {y}", ACC, 2.2)
    b += txt(ti + 78, y - 6, "ends on its own", 10.5, MUT, "500")
    y = rows[2][2]
    b += path(f"M{x0} {y} L{ti} {y} L{ti} {y - yl} L{ti + 26} {y - yl} L{ti + 26} {y} L{x1 - 8} {y}", ACC, 2.2)
    b += txt(ti + 36, y - 6, "fixed pulse, input length ignored", 10.5, MUT, "500")
    y = rows[3][2]
    seg, d = x0, True
    pw = 42
    while seg < x1 - 20:
        nx = min(seg + pw, x1 - 8)
        if d:
            b += path(f"M{seg} {y} L{seg} {y - yl} L{nx} {y - yl}", ACC, 2.2)
        else:
            b += path(f"M{seg} {y - yl} L{seg} {y} L{nx} {y}", ACC, 2.2)
        seg, d = nx, not d
    b += note(W, H,
              "Interval follows the input's start; one-shot ignores its length; repeat cycle free-runs.",
              "لكل وظيفة سلوك مختلف تمامًا")
    build("i04-interval-oneshot-repeat", W, H, "Interval one-shot and repeat cycle timing", b,
          "275e2058-47b7-41b3-9e09-9ec9d1b13a04",
          "Interval, one-shot and repeat-cycle compared against the same input: only the one-shot is immune to how long the input stays present.",
          "مقارنة الفترة والنبضة الواحدة والدورة المتكررة على الدخل نفسه: النبضة الواحدة وحدها لا تتأثر بطول بقاء الدخل.")


# ================================================================== I05 L1
def d_hysteresis():
    W, H = 640, 318
    x0, x1 = 70, W - 54
    yb, yt = 236, 78
    b = title_block(W, "Hysteresis prevents chatter", "الفجوة الفارقة تمنع الاهتزاز")
    b += arrow_v(yb, yt - 6, x0, MUT, 1.3) + arrow_h(x0, x1, yb, MUT, 1.3)
    b += txt(x0 - 8, yt + 4, "level", 11.5, MUT, "600", "end")
    b += txt(x1, yb + 20, "time", 11.5, MUT, "500", "end")
    y_on, y_off = 132, 178
    b += line(x0, y_on, x1 - 10, y_on, BAD, 1.3, "5 4")
    b += txt(x1 - 6, y_on - 7, "cut-out", 11, BAD, "700", "end")
    b += line(x0, y_off, x1 - 10, y_off, OK, 1.3, "5 4")
    b += txt(x1 - 6, y_off + 16, "cut-in", 11, OK, "700", "end")
    b += path(f"M{x0 + 10} {200} C{x0 + 70} {200} {x0 + 90} {120} {x0 + 170} {124} "
              f"C{x0 + 250} {128} {x0 + 270} {206} {x0 + 350} {200} "
              f"C{x0 + 410} {196} {x0 + 430} {130} {x1 - 20} {134}", ACC, 2.3)
    b += path(f"M{x0} {y_on} L{x0} {y_off}", MUT, 0)
    b += line(150, y_on, 150, y_off, MUT, 1.2)
    b += arrow_v(y_on, y_off, 150, MUT, 1.2)
    b += txt(158, (y_on + y_off) / 2 + 4, "differential", 11, MUT, "600")
    b += ar(W - 20, (y_on + y_off) / 2 + 20, "الفجوة", 10.5, MUT)
    b += note(W, H,
              "A single threshold would switch repeatedly as the level hovers. The gap forces travel.",
              "العتبة الواحدة تجعل التلامس يهتز عند الحد")
    build("i05-hysteresis", W, H, "Hysteresis differential band", b,
          "e37122e7-e8d1-4e90-857d-6a690b497a32",
          "Hysteresis: separate cut-in and cut-out thresholds mean a level hovering at the setpoint cannot chatter the contact.",
          "الفجوة الفارقة: فصل عتبتي التشغيل والفصل يمنع اهتزاز التلامس حين يتأرجح المستوى عند نقطة الضبط.")


# ================================================================== I05 L3
def d_level_dryrun():
    W, H = 640, 348
    b = title_block(W, "Level control with dry-run protection", "التحكم في المستوى وحماية التشغيل الجاف")
    # roof tank
    rx, ry, rw, rh = 60, 78, 210, 120
    b += rect(rx, ry, rw, rh, INK, 1.8, 4)
    b += txt(rx, ry - 10, "Roof tank", 12, INK, "700")
    b += ar(rx + rw, ry - 10, "خزان علوي", 11, MUT)
    b += rect(rx + 3, ry + 56, rw - 6, rh - 59, "#dbeafe", 0, 3, "#dbeafe")
    b += line(rx + 3, ry + 56, rx + rw - 3, ry + 56, "#3b82f6", 1.6)
    for py, lab, c in ((ry + 26, "high - stop", BAD), (ry + 88, "low - start", OK)):
        b += line(rx + 26, ry + 6, rx + 26, py, MUT, 1.2)
        b += dot(rx + 26, py, c, 4)
        b += line(rx + 32, py, rx + 120, py, c, 1.2, "4 3")
        b += txt(rx + 126, py + 4, lab, 10.5, c, "600")
    # ground tank
    gx, gy, gw, gh = 360, 150, 210, 110
    b += rect(gx, gy, gw, gh, INK, 1.8, 4)
    b += txt(gx, gy - 10, "Ground tank", 12, INK, "700")
    b += ar(gx + gw, gy - 10, "خزان أرضي", 11, MUT)
    b += rect(gx + 3, gy + 40, gw - 6, gh - 43, "#dbeafe", 0, 3, "#dbeafe")
    b += line(gx + 3, gy + 40, gx + gw - 3, gy + 40, "#3b82f6", 1.6)
    pyd = gy + 74
    b += line(gx + 26, gy + 6, gx + 26, pyd, MUT, 1.2)
    b += dot(gx + 26, pyd, BAD, 4)
    b += line(gx + 32, pyd, gx + 120, pyd, BAD, 1.2, "4 3")
    b += txt(gx + 126, pyd + 4, "dry-run cut-out", 10.5, BAD, "600")
    # pump
    pxx, pyy = 316, 286
    b += circ(pxx, pyy, 19, INK, 1.8, FILL) + txt(pxx, pyy + 5, "P", 13, INK, "700", "middle")
    b += line(gx, gy + gh - 20, pxx + 19, pyy) + line(pxx - 19, pyy, 140, pyy)
    b += line(140, pyy, 140, ry + rh) + arrow_v(pyy, ry + rh + 4, 140, INK, 1.6)
    b += note(W, H,
              "Two probe sets, one decision: demand from the roof tank, permission from the ground tank.",
              "الطلب من الأعلى والإذن من الأسفل")
    build("i05-level-dryrun", W, H, "Level control with dry run protection", b,
          "fa32cc2b-a851-4c90-af03-05b13bd46109",
          "Level control: the roof tank probes create demand while the ground tank probe grants permission, so the pump can never run dry.",
          "التحكم في المستوى: مجسات الخزان العلوي تنشئ الطلب ومجس الخزان الأرضي يمنح الإذن، فلا تعمل المضخة جافة أبدًا.")


# ================================================================== I05 L4
def d_pump_alternation():
    W, H = 640, 308
    x0, x1 = 128, W - 46
    b = title_block(W, "Duty / standby alternation", "تبادل المضخات")
    c1, c2 = 250, 386
    rows = [("Demand", "الطلب", 96), ("Pump A", "مضخة أ", 166), ("Pump B", "مضخة ب", 228)]
    for lab, arl, y in rows:
        b += txt(16, y + 4, lab, 12, INK, "600")
        b += ar(122, y + 18, arl, 10.5, MUT)
        b += line(x0, y, x1, y, "#e2e8f0", 1.2)
    for gx in (c1, c2):
        b += grid_v(gx, 84, 252)
    yl = 17
    y = rows[0][2]
    b += path(f"M{x0} {y} L{x0} {y - yl} L{x1 - 8} {y - yl}", INK, 2.2)
    y = rows[1][2]
    b += path(f"M{x0} {y} L{x0} {y - yl} L{c1} {y - yl} L{c1} {y} L{c2} {y} "
              f"L{c2} {y - yl} L{x1 - 8} {y - yl}", ACC, 2.2)
    y = rows[2][2]
    b += path(f"M{x0} {y} L{c1} {y} L{c1} {y - yl} L{c2} {y - yl} L{c2} {y} L{x1 - 8} {y}",
              ACC, 2.2)
    for cx_, lab in ((c1, "cycle 1"), (c2, "cycle 2")):
        b += txt(cx_, 270, lab, 10.5, MUT, "500", "middle")
    b += note(W, H,
              "Alternating on each cycle wears both pumps evenly and proves the standby still runs.",
              "التبادل يوزع البلى ويثبت صلاحية الاحتياطي")
    build("i05-pump-alternation", W, H, "Duty standby pump alternation", b,
          "4957a9d5-37ec-4594-a197-a237ecbd6069",
          "Duty/standby alternation: swapping the lead pump every cycle shares wear and regularly proves the standby pump actually starts.",
          "تبادل المضخات: تبديل المضخة القائدة كل دورة يوزّع البلى ويثبت دوريًا أن المضخة الاحتياطية تعمل فعلًا.")


# ================================================================== I03 L1
def d_protection_layers():
    W, H = 640, 318
    b = title_block(W, "Overload versus short circuit", "الحمل الزائد مقابل القصر")
    items = [
        ("Short circuit", "قصر", "huge current, instant", "breaker clears it in milliseconds", BAD),
        ("Overload", "حمل زائد", "moderate current, sustained", "overload relay, thermal image", ACC),
        ("Thermistor", "ثرمستور", "winding temperature", "senses heat the current cannot show", OK),
    ]
    y = 74
    for en, arl, cause, cure, c in items:
        b += rect(24, y, 150, 50, c, 1.6, 6, FILL)
        b += txt(99, y + 22, en, 12.5, c, "700", "middle")
        b += ar(160, y + 40, arl, 11, MUT)
        b += arrow_h(184, 214, y + 25, MUT, 1.3)
        b += txt(222, y + 20, cause, 11.5, INK, "600")
        b += txt(222, y + 38, cure, 11, MUT, "500")
        y += 68
    b += note(W, H,
              "Each answers a different threat. Neither device substitutes for the other.",
              "لا يغني أحدهما عن الآخر")
    build("i03-protection-layers", W, H, "Overload versus short circuit protection", b,
          "035cab60-53ef-45ff-8826-05592b158813",
          "Short circuit and overload are different threats on different timescales, which is why a breaker and an overload relay are both required.",
          "القصر والحمل الزائد تهديدان مختلفان بمقياسين زمنيين مختلفين، ولذلك يلزم القاطع ومرحّل الحمل الزائد معًا.")


# ================================================================== I06 L2
def d_voltage_window():
    W, H = 640, 318
    x0, x1 = 78, W - 54
    yb, yt = 240, 76
    b = title_block(W, "Voltage monitoring window", "نافذة مراقبة الجهد")
    b += arrow_v(yb, yt - 6, x0, MUT, 1.3) + arrow_h(x0, x1, yb, MUT, 1.3)
    b += txt(x0 - 8, yt + 4, "V", 12.5, MUT, "700", "end")
    b += txt(x1, yb + 20, "time", 11.5, MUT, "500", "end")
    y_hi, y_lo = 112, 196
    b += rect(x0, y_hi, x1 - x0 - 10, y_lo - y_hi, OK, 0, 0, "#eefaf1")
    b += line(x0, y_hi, x1 - 10, y_hi, BAD, 1.4, "5 4")
    b += line(x0, y_lo, x1 - 10, y_lo, BAD, 1.4, "5 4")
    b += txt(x1 - 6, y_hi - 7, "over-voltage trip", 11, BAD, "700", "end")
    b += txt(x1 - 6, y_lo + 16, "under-voltage trip", 11, BAD, "700", "end")
    b += txt(x0 + 10, y_hi + 18, "healthy window", 11.5, OK, "700")
    b += ar(x1 - 16, y_hi + 18, "النطاق السليم", 10.5, OK)
    b += path(f"M{x0 + 6} 160 C{x0 + 70} 140 {x0 + 100} 176 {x0 + 160} 158 "
              f"C{x0 + 210} 144 {x0 + 240} 214 {x0 + 300} 210 "
              f"C{x0 + 350} 206 {x0 + 380} 150 {x1 - 16} 152", ACC, 2.3)
    b += dot(x0 + 300, 210, BAD, 4.5)
    b += txt(x0 + 300, 232, "trip + delay", 10.5, BAD, "600", "middle")
    b += note(W, H,
              "A delay stops a momentary dip tripping the plant; too long a delay defeats the relay.",
              "التأخير يمنع الفصل العابر ولا يُطال أكثر من اللازم")
    build("i06-voltage-window", W, H, "Voltage monitoring healthy window", b,
          "35f79863-160b-4a44-9ef6-63c8dde35d06",
          "A voltage monitoring relay trips outside a healthy window, with a deliberate delay so momentary dips do not stop the plant.",
          "يفصل مرحّل مراقبة الجهد خارج النطاق السليم، مع تأخير مقصود كي لا توقف الانخفاضات اللحظية المنشأة.")


# ================================================================== I05 L5
def d_retrofit():
    W, H = 660, 366
    b = title_block(W, "Retrofit architecture: what changes, what must not",
                    "بنية التحديث: ما يتغير وما يجب ألا يتغير")
    # left: untouched power layer
    b += rect(28, 66, 260, 216, INK, 1.7, 7)
    b += txt(40, 88, "Power and safety layer", 12.5, INK, "700")
    b += ar(276, 104, "طبقة القدرة والأمان", 10.5, MUT)
    for i, (en, arl) in enumerate((("Breaker / fuse", "قاطع"), ("Contactor", "كونتاكتور"),
                                   ("Overload relay", "حمل زائد"), ("Motor", "محرك"))):
        yy = 124 + i * 36
        b += rect(44, yy, 172, 26, MUT, 1.3, 4, FILL)
        b += txt(52, yy + 17, en, 11.5, INK, "600")
        b += ar(276, yy + 17, arl, 10.5, MUT)
    b += txt(40, 302, "UNTOUCHED -- stays hardwired", 11, OK, "700")
    # right: smart logic layer
    b += rect(372, 66, 262, 216, ACC, 1.7, 7, "#fff7f3")
    b += txt(384, 88, "Logic and signalling layer", 12.5, ACC, "700")
    b += ar(622, 104, "طبقة المنطق والإشارة", 10.5, MUT)
    for i, (old, new) in enumerate((("Push buttons", "app / scene"),
                                    ("Mechanical timer", "schedule"),
                                    ("Sensor switch", "sensor input"),
                                    ("Inter-panel wiring", "network"))):
        yy = 124 + i * 36
        b += txt(384, yy + 17, old, 11, MUT, "500")
        b += arrow_h(482, 512, yy + 13, ACC, 1.2)
        b += txt(520, yy + 17, new, 11.5, ACC, "600")
    b += txt(384, 302, "REPLACED by Alpha Control", 11, ACC, "700")
    b += arrow_h(300, 360, 166, ACC, 1.6)
    b += txt(330, 156, "signals", 10.5, ACC, "600", "middle")
    b += note(W, H,
              "The smart layer is additive and removable. Pull it out and the classical circuit still runs.",
              "الطبقة الذكية إضافية وقابلة للإزالة")
    build("i05-retrofit-architecture", W, H, "Smart retrofit architecture layers", b,
          "1dc66d6d-f7dc-4376-8846-d298fc492dd3",
          "Retrofit doctrine: protection and switching stay hardwired exactly as designed, while only the low-power logic and signalling layer moves to Alpha Control.",
          "مبدأ التحديث: تبقى الحماية والتبديل موصولة سلكيًا كما صُممت تمامًا، وتنتقل طبقة المنطق والإشارة منخفضة القدرة وحدها إلى Alpha Control.")


# ================================================================== F06 L1
def d_zigbee_mesh():
    W, H = 640, 364
    b = title_block(W, "How a Zigbee mesh routes and heals", "كيف توجّه شبكة زيجبي وتلتئم")
    gx, gy = 106, 196
    b += rect(gx - 34, gy - 22, 68, 44, ACC, 1.9, 6, "#fff7f3")
    b += txt(gx, gy + 5, "GW", 13, ACC, "700", "middle")
    b += txt(gx, gy + 38, "coordinator", 10.5, MUT, "500", "middle")
    routers = [(268, 118, "R1"), (268, 264, "R2"), (424, 190, "R3")]
    for rx, ry, lab in routers:
        b += circ(rx, ry, 20, INK, 1.7, FILL)
        b += txt(rx, ry + 5, lab, 12, INK, "700", "middle")
    b += txt(268, 88, "mains-powered routers relay", 10.5, MUT, "500", "middle")
    ends = [(544, 122, "E1"), (544, 258, "E2")]
    for ex, ey, lab in ends:
        b += circ(ex, ey, 16, MUT, 1.5, "#ffffff")
        b += txt(ex, ey + 4.5, lab, 11, MUT, "700", "middle")
    b += txt(544, 296, "battery end devices", 10.5, MUT, "500", "middle")
    b += ar(544, 312, "أجهزة طرفية لا ترحّل", 10, MUT, "500", "middle")
    links = [((gx + 34, gy - 8), (248, 128)), ((gx + 34, gy + 8), (248, 256)),
             ((288, 128), (408, 180)), ((288, 254), (408, 200)),
             ((444, 182), (528, 128)), ((444, 198), (528, 252))]
    for (ax_, ay_), (bx_, by_) in links:
        b += line(ax_, ay_, bx_, by_, INK, 1.5, op=0.75)
    b += line(288, 138, 288, 244, BAD, 2.0, "5 4")
    b += txt(296, 196, "failed link", 10.5, BAD, "600")
    b += path("M288 138 C340 150 340 232 288 244", OK, 2.0, "6 4")
    b += txt(352, 226, "traffic re-routes via R3", 10.5, OK, "600")
    b += note(W, H,
              "Only mains-powered devices relay. Adding battery sensors never strengthens a mesh.",
              "الأجهزة المغذاة وحدها ترحّل")
    build("f06-zigbee-mesh", W, H, "Zigbee mesh routing and self healing", b,
          "d492cb5e-c412-4b4f-b3f7-3a25bcce4e10",
          "Zigbee mesh: mains-powered routers carry traffic and provide alternate paths, while battery end devices only ever talk to their parent.",
          "شبكة زيجبي: الموجّهات المغذاة من الشبكة تحمل حركة البيانات وتوفر مسارات بديلة، أما أجهزة البطاريات الطرفية فتتحدث إلى أصلها فقط.")


# ================================================================== F05 L3
def d_nat():
    W, H = 660, 318
    b = title_block(W, "Private addresses, public address, NAT", "العناوين الخاصة والعامة و NAT")
    b += rect(28, 70, 300, 186, INK, 1.6, 7, "#f7fafc")
    b += txt(42, 92, "Home network", 12.5, INK, "700")
    b += ar(316, 92, "الشبكة المنزلية", 11, MUT)
    devs = [("Phone", "192.168.1.20"), ("Gateway", "192.168.1.30"), ("Camera", "192.168.1.41")]
    for i, (n, ip) in enumerate(devs):
        yy = 114 + i * 46
        b += rect(46, yy, 130, 32, MUT, 1.3, 4, "#ffffff")
        b += txt(54, yy + 20, n, 11.5, INK, "600")
        b += txt(188, yy + 20, ip, 11, ACC, "600")
    rx = 392
    b += rect(rx - 44, 140, 88, 56, ACC, 1.9, 6, "#fff7f3")
    b += txt(rx, 164, "Router", 12, ACC, "700", "middle")
    b += txt(rx, 182, "NAT", 11.5, ACC, "700", "middle")
    b += arrow_h(330, rx - 46, 168, INK, 1.5)
    b += arrow_h(rx + 46, 560, 168, INK, 1.5)
    b += circ(596, 168, 30, MUT, 1.7, FILL)
    b += txt(596, 172, "www", 11, MUT, "700", "middle")
    b += txt(rx, 118, "one public address", 11, MUT, "500", "middle")
    b += txt(rx, 226, "translates many to one", 10.5, MUT, "500", "middle")
    b += ar(rx, 244, "يترجم الكثير إلى واحد", 10.5, MUT, "500", "middle")
    b += note(W, H,
              "Private addresses repeat in every building; only the public address is unique on the internet.",
              "العنوان العام وحده فريد على الإنترنت")
    build("f05-nat", W, H, "Private and public addressing with NAT", b,
          "3a9e97a4-e89a-462d-a813-ffd0e6f9e477",
          "NAT: every device holds a private address that repeats in millions of buildings, and the router translates them all onto one unique public address.",
          "NAT: يحمل كل جهاز عنوانًا خاصًا يتكرر في ملايين المباني، ويترجمها الراوتر جميعًا إلى عنوان عام واحد فريد.")


# ================================================================== F05 L4
def d_protocol_compare():
    W, H = 680, 348
    b = title_block(W, "Wireless protocol trade-offs", "مقايضات البروتوكولات اللاسلكية")
    cols = ["", "Wi-Fi", "Zigbee", "Thread", "Z-Wave"]
    rows = [
        ("Power use", "استهلاك", ["high", "very low", "very low", "low"]),
        ("Mesh", "شبكة شبكية", ["no", "yes", "yes", "yes"]),
        ("Band", "النطاق", ["2.4/5 GHz", "2.4 GHz", "2.4 GHz", "sub-GHz"]),
        ("Needs hub", "بوابة", ["no", "yes", "border router", "yes"]),
        ("Best for", "الأنسب لـ", ["cameras", "sensors", "new build", "congested"]),
    ]
    x0, cw, y0, rh = 150, 126, 58, 42
    for i, c in enumerate(cols[1:]):
        cx = x0 + i * cw + cw / 2
        b += rect(x0 + i * cw + 4, y0, cw - 8, 28, ACC, 1.4, 5, "#fff7f3")
        b += txt(cx, y0 + 19, c, 12, ACC, "700", "middle")
    for r, (en, arl, vals) in enumerate(rows):
        yy = y0 + 36 + r * rh
        b += txt(16, yy + 20, en, 11.5, INK, "600")
        b += ar(144, yy + 34, arl, 10, MUT)
        b += line(16, yy + 32, W - 16, yy + 32, "#e8edf3", 1.1)
        for i, v in enumerate(vals):
            cx = x0 + i * cw + cw / 2
            col = OK if v in ("yes", "very low", "low") else (BAD if v in ("no", "high") else MUT)
            b += txt(cx, yy + 20, v, 11.5, col, "600", "middle")
    b += note(W, H,
              "No protocol wins outright. Match the radio to the device's power source and duty.",
              "اختر البروتوكول حسب مصدر الطاقة والوظيفة")
    build("f05-protocol-comparison", W, H, "Wireless protocol comparison", b,
          "52bdd174-ab30-4e0f-8733-11d3e48ea07b",
          "Protocol trade-offs: battery sensors need the low-power mesh radios, while cameras need Wi-Fi bandwidth -- most real installations use several.",
          "مقايضات البروتوكولات: حساسات البطاريات تحتاج راديو الشبكة منخفض الاستهلاك، والكاميرات تحتاج عرض نطاق Wi-Fi، وأغلب التركيبات الحقيقية تستخدم عدة بروتوكولات.")


# ================================================================== F04 L2
def d_trip_curve():
    W, H = 640, 338
    x0, x1 = 96, W - 56
    yb, yt = 252, 74
    b = title_block(W, "Breaker trip curve", "منحنى فصل القاطع")
    b += arrow_v(yb, yt - 6, x0, MUT, 1.3) + arrow_h(x0, x1, yb, MUT, 1.3)
    b += txt(x0 - 10, yt + 6, "trip", 11.5, MUT, "600", "end")
    b += txt(x0 - 10, yt + 22, "time", 11.5, MUT, "600", "end")
    b += txt(x1, yb + 20, "current (x rated)", 11.5, MUT, "500", "end")
    for mult, lab in ((1, "1x"), (3, "3x"), (5, "5x"), (10, "10x")):
        gx = x0 + mult * 42
        if gx < x1 - 10:
            b += grid_v(gx, yt, yb)
            b += txt(gx, yb + 20, lab, 10.5, MUT, "500", "middle")
    b += path(f"M{x0 + 46} {yb - 6} C{x0 + 70} {160} {x0 + 96} {120} {x0 + 130} {116} "
              f"L{x0 + 130} {yt + 8}", MUT, 2.0, "5 4")
    b += txt(x0 + 136, 104, "thermal: slow, for overload", 11, MUT, "600")
    b += path(f"M{x0 + 212} {yb - 6} L{x0 + 212} {yt + 8}", ACC, 2.4)
    b += txt(x0 + 220, 200, "magnetic: instant,", 11, ACC, "700")
    b += txt(x0 + 220, 216, "for short circuit", 11, ACC, "700")
    b += rect(x0 + 46, yt + 6, 84, yb - yt - 12, MUT, 0, 0, "#f3f6fa")
    b += note(W, H,
              "Curve class sets where the magnetic threshold sits -- C for mixed loads, D for motors.",
              "فئة المنحنى تحدد عتبة الفصل المغناطيسي")
    build("f04-trip-curve", W, H, "Circuit breaker trip curve", b,
          "fe86f1b6-464f-4bee-a943-d118e6d9c559",
          "A breaker has two mechanisms: a slow thermal element for sustained overload and an instant magnetic element for short circuit.",
          "للقاطع آليتان: عنصر حراري بطيء للحمل الزائد المستمر وعنصر مغناطيسي لحظي للقصر.")


# ================================================================== F07 L3
def d_alpha_modules():
    W, H = 660, 318
    b = title_block(W, "Alpha Control expansion modules", "وحدات التوسعة في Alpha Control")
    b += rect(28, 76, 168, 168, ACC, 1.9, 7, "#fff7f3")
    b += txt(112, 108, "ALPHA", 14, ACC, "700", "middle")
    b += txt(112, 128, "CONTROL", 14, ACC, "700", "middle")
    b += txt(112, 156, "base unit", 11, MUT, "500", "middle")
    b += ar(188, 176, "الوحدة الأساسية", 10.5, MUT)
    b += txt(112, 206, "logic + scheduling", 10.5, MUT, "500", "middle")
    b += txt(112, 224, "+ connectivity", 10.5, MUT, "500", "middle")
    mods = [
        ("Digital I/O", "دخل/خرج رقمي", "dry contacts, relays,", "buttons and status"),
        ("Analog I/O", "دخل/خرج تناظري", "4-20 mA and 0-10 V,", "sensors and drives"),
        ("Comms", "اتصالات", "RS-485 / Modbus to", "meters and inverters"),
    ]
    for i, (en, arl, l1, l2) in enumerate(mods):
        yy = 76 + i * 58
        b += rect(268, yy, 214, 48, INK, 1.5, 6, FILL)
        b += txt(280, yy + 20, en, 12, INK, "700")
        b += txt(280, yy + 37, l1, 10.5, MUT, "500")
        b += ar(636, yy + 20, arl, 11, MUT)
        b += txt(492, yy + 37, l2, 10.5, MUT, "500")
        b += line(196, 160, 268, yy + 24, ACC, 1.4)
        b += dot(268, yy + 24, ACC, 3)
    b += note(W, H,
              "Add only the module the job needs. The base unit is the same in every panel.",
              "أضف الوحدة التي يحتاجها العمل فقط")
    build("f07-alpha-modules", W, H, "Alpha Control expansion modules", b,
          "82bf3204-7e2f-4b1a-9632-39bc71456409",
          "Alpha Control expansion: one base unit plus the module the job actually needs -- digital I/O, analog I/O, or serial comms.",
          "توسعة Alpha Control: وحدة أساسية واحدة مع الوحدة التي يحتاجها العمل فعلًا — دخل/خرج رقمي أو تناظري أو اتصالات تسلسلية.")


# ================================================================== I07 L2
def d_faultfinding():
    W, H = 640, 348
    b = title_block(W, "Systematic fault-finding", "التشخيص المنهجي للأعطال")
    steps = [
        ("1", "Confirm the symptom", "شاهد العطل بنفسك", "reproduce it before touching anything"),
        ("2", "Is there supply?", "هل يوجد جهد؟", "measure at the incomer, not the label"),
        ("3", "Control or power?", "تحكم أم قدرة؟", "split the circuit in half"),
        ("4", "Which half fails?", "أي نصف يفشل؟", "halve again, do not guess"),
        ("5", "Prove the repair", "أثبت الإصلاح", "restore and re-test under load"),
    ]
    y = 68
    for n, en, arl, hint in steps:
        b += circ(44, y + 20, 15, ACC, 1.7, "#fff7f3")
        b += txt(44, y + 25, n, 12, ACC, "700", "middle")
        b += txt(74, y + 17, en, 12.5, INK, "700")
        b += txt(74, y + 34, hint, 11, MUT, "500")
        b += ar(624, y + 17, arl, 11, MUT)
        if n != "5":
            b += arrow_v(y + 38, y + 50, 44, MUT, 1.3)
        y += 50
    b += note(W, H,
              "Halving beats guessing: each measurement must eliminate half of what remains.",
              "كل قياس يستبعد نصف الاحتمالات")
    build("i07-fault-finding", W, H, "Systematic fault finding method", b,
          "aa69ca56-dd65-417e-ad60-cf559282f04f",
          "Systematic fault-finding: each measurement should eliminate half the remaining possibilities, rather than testing components in the order they come to hand.",
          "التشخيص المنهجي: ينبغي أن يستبعد كل قياس نصف الاحتمالات المتبقية بدل فحص المكونات بترتيب وصول اليد إليها.")


# ================================================================== I05 L2
def d_photocell():
    W, H = 640, 308
    x0, x1 = 90, W - 54
    yb, yt = 226, 76
    b = title_block(W, "Photocell switching with delay", "التشغيل الضوئي مع التأخير")
    b += arrow_v(yb, yt - 6, x0, MUT, 1.3) + arrow_h(x0, x1, yb, MUT, 1.3)
    b += txt(x0 - 10, yt + 4, "light", 11.5, MUT, "600", "end")
    b += txt(x1, yb + 20, "dusk to dawn", 11.5, MUT, "500", "end")
    y_th = 150
    b += line(x0, y_th, x1 - 10, y_th, BAD, 1.3, "5 4")
    b += txt(x1 - 6, y_th - 8, "threshold", 11, BAD, "700", "end")
    b += path(f"M{x0 + 6} 96 C{x0 + 80} 104 {x0 + 120} 188 {x0 + 200} 200 "
              f"C{x0 + 280} 210 {x0 + 330} 120 {x1 - 16} 100", ACC, 2.3)
    b += dot(x0 + 138, y_th, INK, 4) + dot(x0 + 352, y_th, INK, 4)
    for xx, lab in ((x0 + 138, "lamp on"), (x0 + 352, "lamp off")):
        b += line(xx, y_th, xx, 244, MUT, 1.1, "3 3")
        b += txt(xx, 260, lab, 10.5, INK, "600", "middle")
    b += path(f"M{x0 + 180} 118 C{x0 + 200} 128 {x0 + 220} 128 {x0 + 240} 118", MUT, 1.4)
    b += txt(x0 + 210, 112, "passing cloud -- delay ignores it", 10.5, MUT, "600", "middle")
    b += note(W, H,
              "Without a delay a headlight or a cloud switches the circuit. Delay is not optional outdoors.",
              "التأخير ضروري في الخارج وليس اختياريًا")
    build("i05-photocell", W, H, "Photocell dusk to dawn switching", b,
          "ff522b12-cc96-48c0-9af1-205ae02c143c",
          "Photocell switching: the threshold decides dusk and dawn, while the delay stops a cloud or a passing headlight from cycling the lamp.",
          "التشغيل الضوئي: العتبة تحدد الغسق والفجر، والتأخير يمنع سحابة أو ضوء سيارة عابرة من تشغيل المصباح وإطفائه.")


# ================================================================== emit
def main():
    for fn in (d_latch, d_interlock, d_inrush, d_star_delta_conn, d_stardelta_timing,
               d_on_off_delay, d_interval_oneshot, d_hysteresis, d_level_dryrun,
               d_pump_alternation, d_protection_layers, d_voltage_window, d_retrofit,
               d_zigbee_mesh, d_nat, d_protocol_compare, d_trip_curve,
               d_alpha_modules, d_faultfinding, d_photocell):
        fn()

    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    out = os.path.join(root, "public", "diagrams")
    os.makedirs(out, exist_ok=True)

    targets = []
    for name, (svg, lesson, cap_en, cap_ar) in sorted(DIAGRAMS.items()):
        with open(os.path.join(out, f"{name}.svg"), "w", encoding="utf-8") as f:
            f.write(svg)
        targets.append({"name": name, "file": f"{name}.svg", "lesson_id": lesson,
                        "caption": cap_en, "caption_ar": cap_ar, "bytes": len(svg)})

    with open(os.path.join(root, "scripts", "diagram_targets.json"), "w",
              encoding="utf-8") as f:
        json.dump(targets, f, ensure_ascii=False, indent=2)

    print(f"wrote {len(targets)} diagrams -> public/diagrams/")
    for t in targets:
        print(f"  {t['file']:<36} {t['bytes']:>6} B  lesson={t['lesson_id']}")


if __name__ == "__main__":
    main()
