#!/usr/bin/env python3
"""Set equations and worked examples apart from prose.

Review note 2: "تمييز المعادلات والمسائل والامثله" -- distinguish formulas,
problems and worked examples. They were authored inline as bold paragraphs:

    **V(Line) = √3 × V(Phase) = 1.732 × 220 = 380 V**

which reads as just another sentence and is easy to skim past. This wraps them
in fenced blocks that LessonContent renders as labelled callouts:

    ```formula
    V(Line) = √3 × V(Phase) = 1.732 × 220 = 380 V
    ```

Worked examples (a stated requirement followed by a calculation) become
```example blocks instead, so a trainee can tell a rule from a solved problem.

Deliberately conservative -- it only converts a line that is:
  * a standalone paragraph (blank line either side)
  * short enough to be an expression, not a sentence about one
  * carrying an '=' with an operator, or a recognised formula shape
  * not already inside a fence, table, list or heading

Anything it is unsure about is left for a human. Under-converting is safe;
mangling a sentence into a code block is not.

  python3 scripts/mark_equations.py            # dry run
  python3 scripts/mark_equations.py --apply
"""
from __future__ import annotations

import datetime
import json
import os
import re
import subprocess
import sys
import tempfile

FIELDS = ("content", "content_ar")

# An expression line: an '=' plus a real operator somewhere on the line.
# The operator may appear BEFORE the equals ("11.36 × 1.25 = 14.2 A") or after
# it ("I = P ÷ V"); an earlier version only looked to the right of '=' and so
# rejected every result-on-the-right calculation step.
EXPR = re.compile(r"^(?=.*=)(?=.*[×x*/÷√]|.*\d\s*[+\-]\s*\d).+$")
FORMULA_SHAPE = re.compile(r"√\s*3|1\.732|cos\s*\(?\s*[θΦφ]|\bP\s*=|\bI\s*=\s*P\b")

# A line that introduces a solved problem.
EXAMPLE_LEAD = re.compile(
    r"(worked example|مثال محلول|مثال عملي|مثال تطبيقي|المطلوب|required for)",
    re.I)

STRIP_BOLD = re.compile(r"^\*\*(.+?)\*\*$")
SKIP_PREFIX = ("|", ">", "#", "-", "*", "+", "```")


def env() -> dict[str, str]:
    out = {}
    with open(".env", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                out[k.strip()] = v.strip()
    return out


def looks_like_expression(s: str) -> bool:
    t = s.strip()
    # A numbered calculation step ("1. Find the current: I = P ÷ V = 11.36 A")
    # is still an expression for our purposes -- strip the list marker and any
    # leading prose label before judging it.
    t = re.sub(r"^[0-9\u0660-\u0669]{1,2}[.)]\s*", "", t)
    m = STRIP_BOLD.match(t)
    if m:
        t = m.group(1).strip()
    if "=" not in t:
        return False
    # Length is judged on the MATHS, not the whole line: a step may carry a
    # long label and a trailing conclusion clause and still be a calculation.
    if len(t) > 220:
        return False
    # Drop a leading prose label ("Apply a 1.25 safety margin: ...") so the
    # symbol/letter ratio judges the maths, not the sentence introducing it.
    # Split on the LAST colon before the first '=', because a step may read
    # "Apply a 1.25 safety margin: 11.36 × 1.25 = 14.2 A" where the label
    # itself contains digits.
    head, sep, tail = t.partition("=")
    if ":" in head:
        expr_part = head.rsplit(":", 1)[1] + sep + tail
    else:
        expr_part = t
    expr_part = expr_part.strip()
    words = expr_part.split()
    if len(words) > 22:
        return False
    if not (EXPR.match(expr_part) or FORMULA_SHAPE.search(expr_part)):
        return False
    letters = sum(ch.isalpha() for ch in expr_part)
    symbols = sum(ch in "=×x*/÷+-√()." for ch in expr_part)
    if symbols < 3 or letters >= 70:
        return False
    # Reject prose that merely contains an equation, e.g.
    # "(√3 = 1.732, derived from the geometry of the 120° phase angles...)".
    # Judge ONLY the maths side: a numbered step legitimately carries a prose
    # label ("تطبيق هامش أمان 1.25 للقاطع: 11.36 × 1.25 = ..."), and counting
    # those words rejected every worked example in the corpus.
    maths = expr_part.partition(":")[2] if ":" in expr_part.partition("=")[0] else expr_part
    # A step often ends with a conclusion clause after an arrow
    # ("... = 14.2 A ← round up to the nearest available breaker: 16 A").
    # That trailing prose belongs to the step but must not be counted when
    # deciding whether the line is maths.
    maths = re.split(r"[←→⇒]|\s-->\s", maths)[0]
    prose_words = [w for w in re.findall(r"[A-Za-z\u0621-\u064A]{4,}", maths)
                   if w.lower() not in {"line", "phase", "load", "cos", "sin", "watt"}]
    return len(prose_words) < 4


def convert(text: str) -> tuple[str, int, int]:
    if not text or "```" in text:
        return text, 0, 0

    lines = text.split("\n")
    out: list[str] = []
    i = 0
    n_formula = n_example = 0

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        if not stripped or stripped.startswith(("|", ">", "#", "```")):
            out.append(line)
            i += 1
            continue

        is_numbered = bool(re.match(r"^[0-9\u0660-\u0669]{1,2}[.)]\s", stripped))

        # A RUN of numbered calculation steps is a worked example: keep the
        # numbering and lift the whole run into one block, rather than turning
        # each step into a separate formula card.
        if is_numbered and looks_like_expression(stripped):
            block = [stripped]
            j = i + 1
            while j < len(lines):
                nxt = lines[j].strip()
                if not nxt:
                    # allow a single blank line inside the run
                    if (j + 1 < len(lines)
                            and re.match(r"^[0-9\u0660-\u0669]{1,2}[.)]\s", lines[j + 1].strip())
                            and looks_like_expression(lines[j + 1].strip())):
                        j += 1
                        continue
                    break
                if not re.match(r"^[0-9\u0660-\u0669]{1,2}[.)]\s", nxt):
                    break
                if not looks_like_expression(nxt):
                    break
                block.append(nxt)
                j += 1

            if len(block) >= 2:
                # Keep the step's prose label with the maths, but render the
                # label on its own line above the expression so the monospace
                # LTR block holds only the calculation. An Arabic label inside
                # an LTR block reads backwards.
                out.append("```example")
                for step in block:
                    marker = re.match(r"^([0-9\u0660-\u0669]{1,2}[.)])\s*(.*)$", step)
                    num, rest = (marker.group(1), marker.group(2)) if marker else ("", step)
                    h, s, tl = rest.partition("=")
                    if ":" in h:
                        lbl, _, maths = rest.partition(":")
                        out.append(f"{num} {lbl.strip()}".strip())
                        out.append(f"   {maths.strip().strip('*')}")
                    else:
                        out.append(f"{num} {rest.strip().strip('*')}".strip())
                out.append("```")
                n_example += 1
                i = j
                continue
            # a lone numbered step stays prose
            out.append(line)
            i += 1
            continue

        if stripped.startswith(("-", "*", "+")):
            out.append(line)
            i += 1
            continue

        # Standalone expression => formula block
        prev_blank = not out or not out[-1].strip()
        nxt = lines[i + 1].strip() if i + 1 < len(lines) else ""
        if prev_blank and looks_like_expression(stripped) and not nxt.strip().startswith("|"):
            body = STRIP_BOLD.match(stripped)
            expr = (body.group(1) if body else stripped).strip()

            # A leading prose label ("Three-phase power formula: **P = ...**")
            # must stay OUTSIDE the block: the block renders as monospace LTR,
            # which mangles an Arabic label, and markdown bold does not render
            # inside a fence so "**P = ...**" would print its own asterisks.
            label = ""
            head, sep, tail = expr.partition("=")
            if ":" in head:
                label, _, rest = expr.partition(":")
                expr = rest.strip()
                label = label.strip()
            expr = expr.strip("*").strip()

            # Collect a run of consecutive expression lines into one block.
            block = [expr]
            j = i + 1
            while j < len(lines) and lines[j].strip() and looks_like_expression(lines[j].strip()):
                b2 = STRIP_BOLD.match(lines[j].strip())
                nxt_expr = (b2.group(1) if b2 else lines[j].strip()).strip()
                h2, s2, t2 = nxt_expr.partition("=")
                if ":" in h2:
                    nxt_expr = nxt_expr.partition(":")[2].strip()
                block.append(nxt_expr.strip("*").strip())
                j += 1

            kind = "example" if any(EXAMPLE_LEAD.search(x) for x in
                                    (out[-2] if len(out) >= 2 else "",
                                     out[-3] if len(out) >= 3 else "")) else "formula"
            if label:
                out.append(f"**{label}:**")
            out.append(f"```{kind}")
            out.extend(block)
            out.append("```")
            if kind == "formula":
                n_formula += 1
            else:
                n_example += 1
            i = j
            continue

        out.append(line)
        i += 1

    return "\n".join(out), n_formula, n_example


def main() -> int:
    apply = "--apply" in sys.argv
    e = env()
    url = (e.get("VITE_SUPABASE_URL") or e["SUPABASE_URL"]).rstrip("/")
    key = e["SUPABASE_SERVICE_ROLE_KEY"]
    auth = ["-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}"]

    rows = json.loads(subprocess.run(
        ["curl", "-s",
         f"{url}/rest/v1/lessons?select=id,title,content,content_ar&limit=500", *auth],
        capture_output=True, text=True, encoding="utf-8").stdout)

    edits, tot_f, tot_e = [], 0, 0
    for r in rows:
        patch = {}
        for f in FIELDS:
            new, nf, ne = convert(r.get(f) or "")
            if nf or ne:
                patch[f] = new
                tot_f += nf
                tot_e += ne
        if patch:
            edits.append((r, patch))

    for r, patch in edits[:8]:
        print(f"  {r['title'][:56]}")
        for f in patch:
            for ln in patch[f].split("\n"):
                if ln.startswith("```") and len(ln) > 3:
                    continue
            src = set((r.get(f) or "").split("\n"))
            for ln in patch[f].split("\n"):
                if ln and ln not in src and not ln.startswith("```"):
                    print(f"    {f}: {ln[:70]}")
                    break
    if len(edits) > 8:
        print(f"  … and {len(edits) - 8} more lessons")

    print(f"\n{tot_f} formula blocks, {tot_e} worked-example blocks "
          f"in {len(edits)} lessons")

    if not apply:
        print("\nDRY RUN — re-run with --apply to write")
        return 0

    os.makedirs("backups", exist_ok=True)
    stamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    bak = os.path.join("backups", f"lessons_preequations_{stamp}.json")
    with open(bak, "w", encoding="utf-8") as f:
        json.dump([{k: r.get(k) for k in ("id", "title", *FIELDS)}
                   for r, _ in edits], f, ensure_ascii=False, indent=1)
    print(f"\nbacked up {len(edits)} rows -> {bak}")

    ok = 0
    for r, patch in edits:
        fd, pf = tempfile.mkstemp(suffix=".json")
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump(patch, f, ensure_ascii=False)
        try:
            res = subprocess.run(
                ["curl", "-s", "-w", "\n%{http_code}", "-X", "PATCH",
                 f"{url}/rest/v1/lessons?id=eq.{r['id']}", *auth,
                 "-H", "Content-Type: application/json",
                 "-H", "Prefer: return=minimal", "--data-binary", f"@{pf}"],
                capture_output=True, text=True, encoding="utf-8")
            if res.stdout.rpartition("\n")[2] in ("200", "204"):
                ok += 1
            else:
                print(f"  FAILED {r['title'][:40]}")
        finally:
            os.unlink(pf)

    print(f"updated {ok}/{len(edits)} lessons")
    return 0 if ok == len(edits) else 1


if __name__ == "__main__":
    raise SystemExit(main())
