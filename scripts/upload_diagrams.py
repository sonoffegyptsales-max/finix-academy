#!/usr/bin/env python3
"""Upload generated diagrams to the private lesson-media bucket and attach
them to their lessons.

Idempotent: re-running replaces the stored object and updates the existing
lesson_media row instead of creating duplicates. Diagrams are given a high
position (900+) so they sit after any media a trainer uploads by hand.

Needs SUPABASE_SERVICE_ROLE_KEY (storage write + row insert bypassing RLS)
and VITE_SUPABASE_URL, both from the gitignored .env.
"""
from __future__ import annotations

import json
import mimetypes
import os
import subprocess
import sys
import tempfile

BUCKET = "lesson-media"
BASE_POSITION = 900


def env() -> dict[str, str]:
    out = {}
    if os.path.exists(".env"):
        with open(".env", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    k, v = line.split("=", 1)
                    out[k.strip()] = v.strip()
    out.update({k: v for k, v in os.environ.items() if k.startswith(("SUPABASE", "VITE_"))})
    return out


def curl(args: list[str]) -> tuple[int, str]:
    r = subprocess.run(["curl", "-s", "-w", "\n%{http_code}", *args],
                       capture_output=True, text=True, encoding="utf-8")
    body, _, code = r.stdout.rpartition("\n")
    return int(code or 0), body


def main() -> int:
    e = env()
    url = e.get("VITE_SUPABASE_URL") or e.get("SUPABASE_URL")
    key = e.get("SUPABASE_SERVICE_ROLE_KEY")
    if not url or not key:
        print("missing VITE_SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY", file=sys.stderr)
        return 1
    url = url.rstrip("/")

    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    # Optional argument selects a different target manifest, so a second
    # diagram set can reuse this uploader instead of being copy-pasted.
    manifest = sys.argv[1] if len(sys.argv) > 1 else "diagram_targets.json"
    with open(os.path.join(root, "scripts", manifest), encoding="utf-8") as f:
        targets = json.load(f)

    auth = ["-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}"]
    ok = skipped = 0

    for i, t in enumerate(targets):
        lesson = t["lesson_id"]
        if not lesson:
            skipped += 1
            continue

        local = os.path.join(root, "public", "diagrams", t["file"])
        path = f"{lesson}/diagram-{t['name']}.svg"
        ctype = mimetypes.guess_type(local)[0] or "image/svg+xml"

        # upsert the object
        code, body = curl([
            "-X", "POST", f"{url}/storage/v1/object/{BUCKET}/{path}",
            *auth, "-H", f"Content-Type: {ctype}", "-H", "x-upsert: true",
            "--data-binary", f"@{local}",
        ])
        if code not in (200, 201):
            print(f"  upload FAILED {t['name']}: {code} {body[:160]}")
            continue

        # does a row already exist for this exact path?
        code, body = curl([
            f"{url}/rest/v1/lesson_media?storage_path=eq.{path}&select=id", *auth,
        ])
        existing = json.loads(body) if body.strip().startswith("[") else []

        payload = {
            "lesson_id": lesson,
            "kind": "image",
            "storage_path": path,
            "caption": t["caption"],
            "caption_ar": t["caption_ar"],
            "position": BASE_POSITION + i,
        }

        # Payload goes through a file, never the command line: a caption
        # containing shell-significant characters silently mangles -d and the
        # API answers "Empty or invalid json".
        fd, pf = tempfile.mkstemp(suffix=".json")
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump(payload, f, ensure_ascii=False)
        try:
            if existing:
                code, body = curl([
                    "-X", "PATCH", f"{url}/rest/v1/lesson_media?id=eq.{existing[0]['id']}",
                    *auth, "-H", "Content-Type: application/json",
                    "-H", "Prefer: return=minimal", "--data-binary", f"@{pf}",
                ])
                verb = "updated"
            else:
                code, body = curl([
                    "-X", "POST", f"{url}/rest/v1/lesson_media",
                    *auth, "-H", "Content-Type: application/json",
                    "-H", "Prefer: return=minimal", "--data-binary", f"@{pf}",
                ])
                verb = "attached"
        finally:
            os.unlink(pf)

        if code in (200, 201, 204):
            ok += 1
            print(f"  {verb:<9} {t['name']}")
        else:
            print(f"  row FAILED {t['name']}: {code} {body[:160]}")

    print(f"\n{ok} diagrams attached, {skipped} skipped (no lesson id)")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
