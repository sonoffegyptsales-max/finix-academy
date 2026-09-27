#!/usr/bin/env python3
"""Measure how much of the register change is mechanical vs real rewriting.

Before running any bulk edit, separate the two populations:

  MECHANICAL  a term or verb form that maps 1:1 and can be swapped safely
              (المؤقت -> التايمر, يعمل -> بيشتغل)

  REWRITE     sentence structure that no substitution can fix -- MSA
              subordination, "أما ... فـ", "بناءً على", long comma-chained
              clauses. These need a human-quality rewrite per sentence.

The split decides the approach: swaps get a script, rewrites get authored.
Reporting a number for each is the honest way to size the job.

  python3 scripts/measure_register.py
"""
from __future__ import annotations

import json
import re
import subprocess
from collections import Counter

# 1:1 swaps -- safe for a script.
MECHANICAL = {
    # trade loanwords
    r"المؤقّت|المؤقت": "التايمر",
    r"ريليه الاستشعار": "ريليه الحساس",
    r"عنصر الاستشعار": "الحساس",
    r"نطاق التباطؤ|التباطؤ": "الهيستيريسيس",
    # colloquial vocabulary
    r"\bشيئًا\b|\bشيء\b": "حاجة",
    r"\bالماء\b": "الميّة",
    r"\bالدائرة\b": "الدايرة",
    r"\bبقية\b": "باقي",
    r"\bكيف\b": "إزاي",
    r"\bهل\b": "",
    r"\bكم\b": "قد إيه",
    # MSA verb forms -> Egyptian habitual
    r"\bيعمل\b": "بيشتغل",
    r"\bيفصل\b": "بيفصل",
    r"\bيوصّل\b|\bيوصل\b": "بيوصّل",
    r"\bيحوّل\b|\bيحول\b": "بيحوّل",
    r"\bيقيس\b": "بيقيس",
    r"\bينتج\b": "بيطلّع",
    r"\bيمنع\b": "بيمنع",
    r"\bيحتاج\b": "بيحتاج",
    r"\bيستخدم\b": "بيستخدم",
}

# Structures that need authoring, not substitution.
#
# NOTE ON THE LENGTH SIGNAL: an earlier version counted any sentence over ~190
# chars as translation-shaped. That fired on the client-APPROVED text, because
# a long sentence in Egyptian colloquial is still Egyptian -- length measures
# density, not register. It inflated the "needs rewriting" count and would have
# sent me back to lessons that were already correct.
#
# A long sentence is only a signal when it ALSO carries an MSA marker, so the
# length check is now paired with one.
MSA_MARKER = (r"(?:الذي|التي|اللذان|حيث|إذ|بينما|كما أن|والذي|وقد|"
              r"يتم|تتم|يُ[\u0621-\u064A]{2,}|تُ[\u0621-\u064A]{2,})")

REWRITE_SIGNALS = {
    "أما … فـ": re.compile(r"\bأما\b[^.!?]{0,60}\bفـ?[يت]"),
    "بناءً على": re.compile(r"\bبناءً على\b"),
    "إنه / إن opener": re.compile(r"(?:^|[.!?]\s+)\s*إنه?\b"),
    "بما أن": re.compile(r"\bبما أن\b"),
    "من حيث / وذلك": re.compile(r"\bمن حيث\b|\bوذلك\b"),
    "في حين أن": re.compile(r"\bفي حين أن\b"),
    "على الرغم من أن": re.compile(r"\bعلى الرغم من أن\b"),
    "يمكن أن يكون": re.compile(r"\bيمكن أن (?:يكون|تكون)\b"),
    # الذي/التي are NOT translation tells on their own -- Egyptian speech uses
    # them constantly. Including them pushed the count from 57 to 80 and would
    # have sent me back into lessons that are already in register. Only the
    # markers with no colloquial equivalent stay.
    "MSA connective": re.compile(
        r"(?<![\w\u0621-\u064A])(?:إذ|كما أن|لا سيما|حيثما|آنذاك)"
        r"(?![\w\u0621-\u064A])"),
    "long MSA sentence": re.compile(
        r"[^.!?\n]{150,}?" + MSA_MARKER + r"[^.!?\n]{0,150}[.!?]"),
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
    e = env()
    url = (e.get("VITE_SUPABASE_URL") or e["SUPABASE_URL"]).rstrip("/")
    key = e["SUPABASE_SERVICE_ROLE_KEY"]
    A = ["-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}"]

    def g(q):
        return json.loads(subprocess.run(["curl", "-s", url + q, *A],
                                         capture_output=True, text=True,
                                         encoding="utf-8").stdout)

    mods = {m["id"]: m["code"] for m in g("/rest/v1/modules?select=id,code&limit=100")}
    rows = g("/rest/v1/lessons?select=id,module_id,position,title,content_ar&limit=500")

    mech = Counter()
    rew = Counter()
    per_lesson = []
    total_chars = 0

    for r in rows:
        ar = r.get("content_ar") or ""
        if not ar.strip():
            continue
        total_chars += len(ar)
        m_hits = 0
        for pat in MECHANICAL:
            n = len(re.findall(pat, ar))
            if n:
                mech[pat] += n
                m_hits += n
        r_hits = 0
        for name, pat in REWRITE_SIGNALS.items():
            n = len(pat.findall(ar))
            if n:
                rew[name] += n
                r_hits += n
        per_lesson.append({
            "code": mods.get(r["module_id"], "??"),
            "tag": f"{mods.get(r['module_id'], '??')} L{r['position']} · {r['title'][:42]}",
            "mech": m_hits, "rewrite": r_hits, "chars": len(ar),
        })

    print("=" * 70)
    print("MECHANICAL — safe 1:1 swaps")
    print("=" * 70)
    for pat, n in mech.most_common(18):
        print(f"  {n:>5}x  {pat}")
    print(f"\n  TOTAL mechanical substitutions: {sum(mech.values())}")

    print("\n" + "=" * 70)
    print("NEEDS REWRITING — structure no substitution can fix")
    print("=" * 70)
    for name, n in rew.most_common():
        print(f"  {n:>5}x  {name}")
    print(f"\n  TOTAL rewrite signals: {sum(rew.values())}")

    heavy = sorted(per_lesson, key=lambda x: -x["rewrite"])
    print("\n" + "=" * 70)
    print("WORST LESSONS BY REWRITE LOAD")
    print("=" * 70)
    for it in heavy[:16]:
        print(f"  {it['tag']:<52} rewrite={it['rewrite']:<4} mech={it['mech']:<4} {it['chars']:>6,}c")

    need_rewrite = [x for x in per_lesson if x["rewrite"] >= 1]
    print("\n" + "=" * 70)
    print(f"  Arabic lessons total          {len(per_lesson):>6}")
    print(f"  Arabic characters total       {total_chars:>6,}")
    print(f"  lessons needing real rewrite  {len(need_rewrite):>6}")
    print(f"  chars in those lessons        {sum(x['chars'] for x in need_rewrite):>6,}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
