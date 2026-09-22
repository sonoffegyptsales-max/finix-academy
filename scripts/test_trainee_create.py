#!/usr/bin/env python3
"""Reproduce the trainee-creation flow end to end with the service-role key.

Mirrors exactly what src/lib/trainees.functions.ts createTrainee does:
  1. auth.admin.createUser (email pre-confirmed)
  2. upsert into profiles  (onConflict id)
  3. upsert into user_roles (onConflict user_id,role)

Then cleans the test user up. Any step that fails prints the real API error,
which is what the UI is swallowing.

Usage: python3 scripts/test_trainee_create.py [--keep]
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import uuid


def env() -> dict[str, str]:
    out = {}
    for line in open(".env", encoding="utf-8"):
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            k, v = line.split("=", 1)
            out[k.strip()] = v.strip()
    return out


def call(method, url, key, payload=None, extra_headers=None):
    args = ["curl", "-s", "-w", "\n%{http_code}", "-X", method, url,
            "-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}",
            "-H", "Content-Type: application/json"]
    for h in (extra_headers or []):
        args += ["-H", h]
    pf = None
    if payload is not None:
        fd, pf = tempfile.mkstemp(suffix=".json")
        os.close(fd)
        json.dump(payload, open(pf, "w", encoding="utf-8"), ensure_ascii=False)
        args += ["--data-binary", f"@{pf}"]
    try:
        r = subprocess.run(args, capture_output=True, text=True, encoding="utf-8")
    finally:
        if pf:
            os.unlink(pf)
    body, _, code = r.stdout.rpartition("\n")
    return int(code or 0), body


def main() -> int:
    e = env()
    url = (e.get("VITE_SUPABASE_URL") or e.get("SUPABASE_URL", "")).rstrip("/")
    key = e.get("SUPABASE_SERVICE_ROLE_KEY")
    if not url or not key:
        print("missing url/service key in .env")
        return 1

    tag = uuid.uuid4().hex[:8]
    email = f"selftest-{tag}@finixacademy.local"
    print(f"target: {url}")
    print(f"test email: {email}\n")

    # --- step 1: create auth user
    code, body = call("POST", f"{url}/auth/v1/admin/users", key, {
        "email": email, "password": f"Test-{tag}-Pw!", "email_confirm": True,
        "user_metadata": {"full_name": "Self Test"},
    })
    print(f"1. createUser            -> {code}")
    if code not in (200, 201):
        print("   FAILED:", body[:400])
        return 1
    uid = json.loads(body).get("id")
    print(f"   user id: {uid}")

    failed = False

    # --- step 2: upsert profile
    code, body = call("POST", f"{url}/rest/v1/profiles", key,
                      {"id": uid, "email": email, "full_name": "Self Test"},
                      ["Prefer: resolution=merge-duplicates,return=minimal"])
    print(f"2. upsert profiles       -> {code}")
    if code not in (200, 201, 204):
        print("   FAILED:", body[:400])
        failed = True

    # --- step 3: upsert role
    code, body = call("POST", f"{url}/rest/v1/user_roles", key,
                      {"user_id": uid, "role": "trainee"},
                      ["Prefer: resolution=merge-duplicates,return=minimal"])
    print(f"3. upsert user_roles     -> {code}")
    if code not in (200, 201, 204):
        print("   FAILED:", body[:400])
        failed = True

    # --- step 4: can the new trainee actually sign in?
    anon = e.get("VITE_SUPABASE_PUBLISHABLE_KEY") or e.get("VITE_SUPABASE_ANON_KEY")
    if anon:
        code, body = call("POST", f"{url}/auth/v1/token?grant_type=password", anon,
                          {"email": email, "password": f"Test-{tag}-Pw!"})
        print(f"4. trainee sign-in       -> {code}")
        if code != 200:
            print("   FAILED:", body[:400])
            failed = True

    # --- cleanup
    if "--keep" not in sys.argv:
        code, _ = call("DELETE", f"{url}/auth/v1/admin/users/{uid}", key)
        print(f"5. cleanup deleteUser    -> {code}")

    print("\nRESULT:", "FAILURES ABOVE" if failed else "full flow succeeded")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
