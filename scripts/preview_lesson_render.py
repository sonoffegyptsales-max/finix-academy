#!/usr/bin/env python3
"""Render a real lesson body through the app's own markdown pipeline.

Lesson pages sit behind auth plus the device lock, so a headless screenshot of
/dashboard/module/... would only capture the sign-in screen. Instead this pulls
a genuine lesson body from the database and renders it with the SAME markdown
parser and GFM table support the app uses, styled to match, so the output shows
what a trainee will actually see.

Writes an HTML file; screenshot it with Chrome headless.
"""
from __future__ import annotations

import html
import json
import subprocess
import sys


def env() -> dict:
    out = {}
    for line in open(".env", encoding="utf-8"):
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            k, v = line.split("=", 1)
            out[k.strip()] = v.strip()
    return out


def fetch_lesson(pattern: str = "*%7C*"):
    e = env()
    url = e.get("SUPABASE_URL")
    key = e.get("SUPABASE_SERVICE_ROLE_KEY")
    q = (f"{url}/rest/v1/lessons?select=title,title_ar,content,content_ar"
         f"&content_ar=like.{pattern}&limit=1")
    p = subprocess.run(["curl", "-s", q,
                        "-H", f"Authorization: Bearer {key}",
                        "-H", f"apikey: {key}"], capture_output=True, text=True)
    rows = json.loads(p.stdout)
    return rows[0] if rows else None


TEMPLATE = """<!doctype html>
<html dir="rtl" lang="ar">
<head>
<meta charset="utf-8">
<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
<style>
  body {{
    margin: 0; padding: 26px;
    background: #fff; color: #0f172a;
    font-family: "Noto Sans Arabic", "Segoe UI", Tahoma, system-ui, sans-serif;
    line-height: 1.85; font-size: 14px;
  }}
  .wrap {{ max-width: 860px; }}
  h1.lesson {{ font-size: 16px; margin: 0 0 4px; }}
  .body p {{ margin: 12px 0; color: #475569; }}
  .body strong {{ font-weight: 600; color: #0f172a; }}
  .body ul {{ margin: 12px 0; padding-inline-start: 0; list-style: disc inside; }}
  .body ol {{ margin: 12px 0; padding-inline-start: 0; list-style: decimal inside; }}
  .body li {{ margin: 6px 0; color: #475569; }}
  .body li::marker {{ color: #2563eb; font-weight: 600; }}
  .body table {{
    width: 100%; border-collapse: collapse; margin: 16px 0;
    border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;
  }}
  .body thead {{ background: #f1f5f9; }}
  .body th {{ padding: 8px 12px; text-align: start; font-weight: 600; color: #0f172a; }}
  .body td {{ padding: 8px 12px; text-align: start; color: #475569;
             border-top: 1px solid #e2e8f0; }}
  .body code {{ direction: ltr; background: #f1f5f9; padding: 2px 6px;
                border-radius: 4px; font-family: monospace; font-size: .85em; }}
  .tag {{ display:inline-block; background:#eff6ff; color:#1d4ed8;
          font-size: 11px; padding: 2px 8px; border-radius: 99px; }}
</style>
</head>
<body>
<div class="wrap">
  <span class="tag">{tag}</span>
  <h1 class="lesson">{title}</h1>
  <div class="body" id="out"></div>
</div>
<script>
  const src = {src};
  document.getElementById('out').innerHTML = marked.parse(src, {{ gfm: true }});
</script>
</body>
</html>
"""


def main() -> int:
    out_path = sys.argv[1] if len(sys.argv) > 1 else "lesson_preview.html"
    lesson = fetch_lesson()
    if not lesson:
        print("no lesson with a markdown table found")
        return 1

    body = lesson.get("content_ar") or lesson.get("content") or ""
    title = lesson.get("title_ar") or lesson.get("title") or ""
    print(f"lesson: {title}")
    print(f"body chars: {len(body)}")

    doc = TEMPLATE.format(
        tag="AFTER — markdown rendered",
        title=html.escape(title),
        src=json.dumps(body),
    )
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(doc)
    print(f"wrote {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
