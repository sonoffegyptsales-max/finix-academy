#!/usr/bin/env python3
"""Measure what actually makes a lesson page slow.

The course review says lectures load slowly. Guessing is pointless -- this
times each thing the module page does, in the order it does it, so the real
cost shows up rather than the suspected one.

Measures:
  1. the HTML document
  2. the JS chunks the page needs
  3. the curriculum query (all modules + lessons)
  4. the lesson_media query
  5. minting a signed URL per media row
  6. downloading a diagram through that signed URL
"""
from __future__ import annotations

import json
import subprocess
import sys
import time

SITE = "https://finix-academy.vercel.app"


def env() -> dict:
    out = {}
    for line in open(".env", encoding="utf-8"):
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            k, v = line.split("=", 1)
            out[k.strip()] = v.strip()
    return out


E = env()
URL = E.get("SUPABASE_URL")
KEY = E.get("SUPABASE_SERVICE_ROLE_KEY")
ANON = E.get("VITE_SUPABASE_PUBLISHABLE_KEY") or E.get("SUPABASE_PUBLISHABLE_KEY")


def timed(label: str, args: list[str], show_bytes: bool = True) -> tuple[float, str]:
    t0 = time.time()
    p = subprocess.run(args, capture_output=True, text=True)
    dt = (time.time() - t0) * 1000
    size = len(p.stdout)
    note = f"{size:>9,} B" if show_bytes else ""
    print(f"  {label:<44} {dt:8.0f} ms  {note}")
    return dt, p.stdout


def main() -> int:
    print("=" * 74)
    print("LESSON PAGE LOAD PROFILE")
    print("=" * 74)

    print("\n1. Static assets")
    timed("HTML document", ["curl", "-s", f"{SITE}/dashboard"])

    html = subprocess.run(["curl", "-s", f"{SITE}/"],
                          capture_output=True, text=True).stdout
    import re
    chunks = sorted(set(re.findall(r"/assets/[A-Za-z0-9_.$-]+\.js", html)))
    total_js = 0.0
    for c in chunks[:6]:
        dt, body = timed(f"chunk {c.split('/')[-1][:34]}", ["curl", "-s", f"{SITE}{c}"])
        total_js += dt
    # the lazily-loaded lesson chunk
    idx = [c for c in chunks if "index-" in c]
    if idx:
        body = subprocess.run(["curl", "-s", f"{SITE}{idx[0]}"],
                              capture_output=True, text=True).stdout
        lazy = re.findall(r"module\._slug-[A-Za-z0-9_-]+\.js", body)
        if lazy:
            timed(f"lazy {lazy[0][:38]}", ["curl", "-s", f"{SITE}/assets/{lazy[0]}"])

    print("\n2. Data queries (service role, same shape the app uses)")
    auth = ["-H", f"Authorization: Bearer {KEY}", "-H", f"apikey: {KEY}"]

    timed("modules + lessons (curriculum)",
          ["curl", "-s",
           f"{URL}/rest/v1/modules?select=*,lessons(*)&limit=100", *auth])

    _, media_raw = timed("lesson_media rows",
                         ["curl", "-s",
                          f"{URL}/rest/v1/lesson_media?select=*&limit=200", *auth])

    try:
        media = json.loads(media_raw)
    except Exception:
        media = []
    print(f"       -> {len(media)} media rows in the table")

    print("\n3. Signed URLs (the suspected bottleneck)")
    if media:
        paths = [m["storage_path"] for m in media[:5]]

        # one-by-one, which is what a naive implementation does
        t0 = time.time()
        for p in paths:
            body = json.dumps({"expiresIn": 1800})
            subprocess.run(
                ["curl", "-s", "-X", "POST",
                 f"{URL}/storage/v1/object/sign/lesson-media/{p}",
                 *auth, "-H", "Content-Type: application/json", "-d", body],
                capture_output=True, text=True)
        seq = (time.time() - t0) * 1000
        print(f"  {'5 signed URLs, one request each':<44} {seq:8.0f} ms"
              f"   ({seq/5:.0f} ms each)")

        # batched, which the storage API supports
        t0 = time.time()
        body = json.dumps({"expiresIn": 1800, "paths": paths})
        r = subprocess.run(
            ["curl", "-s", "-X", "POST",
             f"{URL}/storage/v1/object/sign/lesson-media",
             *auth, "-H", "Content-Type: application/json", "-d", body],
            capture_output=True, text=True)
        batch = (time.time() - t0) * 1000
        ok = r.stdout.strip().startswith("[")
        print(f"  {'5 signed URLs, ONE batched request':<44} {batch:8.0f} ms"
              f"   {'(supported)' if ok else '(NOT supported)'}")
        if ok and seq > 0:
            print(f"       -> batching is {seq/batch:.1f}x faster")

        # actually fetch one asset through its signed URL
        try:
            signed = json.loads(r.stdout)
            if signed and signed[0].get("signedURL"):
                timed("download 1 diagram via signed URL",
                      ["curl", "-s", f"{URL}/storage/v1{signed[0]['signedURL']}"])
        except Exception:
            pass
    else:
        print("  no media rows to test")

    print("\n" + "=" * 74)
    return 0


if __name__ == "__main__":
    sys.exit(main())
