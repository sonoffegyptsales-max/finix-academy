#!/usr/bin/env python3
"""Re-verify every video link in docs/VIDEO_RESOURCES.md.

Third-party videos get deleted, made private, or have embedding disabled. A
dead link discovered by a trainee is worse than no link, so this runs before
each intake and reports anything that stopped resolving.

YouTube's oEmbed endpoint answers 200 only for a video that is public AND
embeddable, which is a stricter and more useful check than fetching the watch
page (that returns 200 even for removed videos, with an error rendered in the
body by JavaScript).

Exit code is 1 if any link is dead, so it can gate a content release.

Run: python3 scripts/check_video_links.py
"""
from __future__ import annotations

import os
import re
import subprocess
import sys
import urllib.parse
from concurrent.futures import ThreadPoolExecutor

DOC = os.path.join("docs", "VIDEO_RESOURCES.md")
OEMBED = "https://www.youtube.com/oembed?format=json&url="


def check(url: str) -> tuple[str, str]:
    api = OEMBED + urllib.parse.quote(url, safe="")
    try:
        r = subprocess.run(
            ["curl", "-s", "-o", os.devnull, "-w", "%{http_code}",
             "--max-time", "25", api],
            capture_output=True, text=True,
        )
        return url, r.stdout.strip()
    except Exception as exc:  # network stack failure, not a dead video
        return url, f"ERR {exc}"


def main() -> int:
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    doc = os.path.join(root, DOC)
    if not os.path.exists(doc):
        print(f"missing {DOC}", file=sys.stderr)
        return 2

    with open(doc, encoding="utf-8") as f:
        text = f.read()

    urls = sorted(set(re.findall(r"https://www\.youtube\.com/watch\?v=[\w-]+", text)))
    if not urls:
        print("no video links found", file=sys.stderr)
        return 2

    print(f"checking {len(urls)} links from {DOC}\n")
    with ThreadPoolExecutor(max_workers=8) as pool:
        results = list(pool.map(check, urls))

    dead = [(u, c) for u, c in results if c != "200"]
    for u, c in sorted(results, key=lambda x: x[1] != "200"):
        mark = "ok  " if c == "200" else "DEAD"
        print(f"  {mark} {c:<4} {u}")

    print()
    if dead:
        print(f"{len(dead)} of {len(urls)} links are no longer usable.")
        print("Replace them in docs/VIDEO_RESOURCES.md before the next intake.")
        return 1

    print(f"all {len(urls)} links live, public and embeddable")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
