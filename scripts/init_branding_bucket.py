#!/usr/bin/env python3
"""Create the public 'branding' bucket and seed it with the current assets.

Deliberately avoids DDL: bucket creation and uploads are plain Storage REST
calls authorised by the service-role key, so this works without a Management
API token. No new table is needed either -- a small settings.json inside the
bucket carries the version stamp used for cache-busting.

Usage: python3 scripts/init_branding_bucket.py
"""
from __future__ import annotations

import json
import mimetypes
import os
import pathlib
import subprocess
import sys
import tempfile
import time

BUCKET = "branding"


def env() -> dict[str, str]:
    out: dict[str, str] = {}
    for line in open(".env", encoding="utf-8"):
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            k, v = line.split("=", 1)
            out[k.strip()] = v.strip()
    return out


def curl(args: list[str]) -> tuple[int, str]:
    p = subprocess.run(["curl", "-s", "-w", "\n%{http_code}", *args],
                       capture_output=True, text=True)
    body = p.stdout.rsplit("\n", 1)
    if len(body) == 2:
        return int(body[1] or 0), body[0]
    return 0, p.stdout


def main() -> int:
    e = env()
    url = e.get("SUPABASE_URL") or e.get("VITE_SUPABASE_URL")
    key = e.get("SUPABASE_SERVICE_ROLE_KEY")
    if not url or not key:
        print("missing SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY in .env")
        return 1

    auth = ["-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}"]

    # 1. Create the bucket (public: branding must render for signed-out
    #    visitors on the landing page and as a favicon).
    payload = {
        "id": BUCKET,
        "name": BUCKET,
        "public": True,
        "file_size_limit": 5 * 1024 * 1024,
        "allowed_mime_types": [
            "image/png", "image/jpeg", "image/webp", "image/svg+xml",
            "image/x-icon", "image/vnd.microsoft.icon", "application/json",
        ],
    }
    fd, path = tempfile.mkstemp(suffix=".json")
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        json.dump(payload, f)
    code, body = curl([*auth, "-H", "Content-Type: application/json",
                       "-X", "POST", f"{url}/storage/v1/bucket",
                       "--data-binary", f"@{path}"])
    os.unlink(path)
    if code in (200, 201):
        print(f"bucket '{BUCKET}' created")
    elif "already exists" in body.lower() or code == 409:
        print(f"bucket '{BUCKET}' already exists")
        # make sure it is public even if it pre-dated this script
        fd, path = tempfile.mkstemp(suffix=".json")
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump({"public": True,
                       "file_size_limit": payload["file_size_limit"],
                       "allowed_mime_types": payload["allowed_mime_types"]}, f)
        curl([*auth, "-H", "Content-Type: application/json", "-X", "PUT",
              f"{url}/storage/v1/bucket/{BUCKET}", "--data-binary", f"@{path}"])
        os.unlink(path)
    else:
        print(f"bucket create failed [{code}]: {body[:300]}")
        return 1

    # 2. Seed the current assets so the bucket is the single source of truth
    #    from the very first load.
    assets = [
        ("public/logo.png", "logo.png"),
        ("public/logo-light.png", "logo-light.png"),
        ("public/favicon.ico", "favicon.ico"),
        ("public/icons/icon-192.png", "icon-192.png"),
        ("public/icons/icon-512.png", "icon-512.png"),
        ("public/icons/icon-maskable-512.png", "icon-maskable-512.png"),
        ("public/icons/apple-touch-icon.png", "apple-touch-icon.png"),
    ]
    for local, remote in assets:
        p = pathlib.Path(local)
        if not p.exists():
            print(f"  skip {local} (missing)")
            continue
        ctype = mimetypes.guess_type(local)[0] or "application/octet-stream"
        if local.endswith(".ico"):
            ctype = "image/x-icon"
        code, body = curl([*auth, "-H", f"Content-Type: {ctype}",
                           "-H", "x-upsert: true", "-X", "POST",
                           f"{url}/storage/v1/object/{BUCKET}/{remote}",
                           "--data-binary", f"@{local}"])
        print(f"  {'OK ' if code in (200, 201) else f'[{code}]'} {remote}")

    # 3. Version stamp for cache-busting.
    fd, path = tempfile.mkstemp(suffix=".json")
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        json.dump({"version": int(time.time()), "updatedAt": time.strftime("%Y-%m-%dT%H:%M:%SZ")}, f)
    code, _ = curl([*auth, "-H", "Content-Type: application/json",
                    "-H", "x-upsert: true", "-X", "POST",
                    f"{url}/storage/v1/object/{BUCKET}/settings.json",
                    "--data-binary", f"@{path}"])
    os.unlink(path)
    print(f"  {'OK ' if code in (200, 201) else f'[{code}]'} settings.json")

    print(f"\npublic base: {url}/storage/v1/object/public/{BUCKET}/")
    return 0


if __name__ == "__main__":
    sys.exit(main())
