#!/usr/bin/env python3
"""Reproduce trainee creation against the DEPLOYED site, end to end.

Creates a temporary admin, signs in as them to get a real JWT, calls the
deployed /_serverFn/createTrainee exactly as the browser does, then removes
both the temp admin and anything it created.

This is the only way to see the error the user sees: the failure is in the
server runtime (env vars, middleware), not in the database, which already
tests clean.

Usage: python3 scripts/test_trainee_prod.py [https://site]
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import uuid

SITE_DEFAULT = "https://finix-academy.vercel.app"


def env() -> dict[str, str]:
    out = {}
    for line in open(".env", encoding="utf-8"):
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            k, v = line.split("=", 1)
            out[k.strip()] = v.strip()
    return out


def req(method, url, headers=None, payload=None):
    args = ["curl", "-s", "-w", "\n%{http_code}", "-X", method, url]
    for h in (headers or []):
        args += ["-H", h]
    pf = None
    if payload is not None:
        fd, pf = tempfile.mkstemp(suffix=".json")
        os.close(fd)
        json.dump(payload, open(pf, "w", encoding="utf-8"), ensure_ascii=False)
        args += ["-H", "Content-Type: application/json", "--data-binary", f"@{pf}"]
    try:
        r = subprocess.run(args, capture_output=True, text=True, encoding="utf-8")
    finally:
        if pf:
            os.unlink(pf)
    body, _, code = r.stdout.rpartition("\n")
    return int(code or 0), body


def main() -> int:
    site = (sys.argv[1] if len(sys.argv) > 1 else SITE_DEFAULT).rstrip("/")
    e = env()
    url = (e.get("VITE_SUPABASE_URL") or "").rstrip("/")
    svc = e.get("SUPABASE_SERVICE_ROLE_KEY")
    anon = e.get("VITE_SUPABASE_PUBLISHABLE_KEY")
    if not (url and svc and anon):
        print("missing keys in .env")
        return 1

    svc_h = [f"Authorization: Bearer {svc}", f"apikey: {svc}"]
    tag = uuid.uuid4().hex[:8]
    admin_email = f"tmpadmin-{tag}@finixacademy.local"
    admin_pw = f"Tmp-{tag}-Pw!"
    admin_id = None
    made_trainee_email = f"tmptrainee-{tag}@finixacademy.local"

    try:
        # 1. temp admin
        code, body = req("POST", f"{url}/auth/v1/admin/users", svc_h, {
            "email": admin_email, "password": admin_pw, "email_confirm": True,
            "user_metadata": {"full_name": "Temp Admin"}})
        if code not in (200, 201):
            print("could not create temp admin:", code, body[:300]); return 1
        admin_id = json.loads(body)["id"]

        req("POST", f"{url}/rest/v1/profiles", svc_h + ["Prefer: resolution=merge-duplicates"],
            {"id": admin_id, "email": admin_email, "full_name": "Temp Admin"})
        code, body = req("POST", f"{url}/rest/v1/user_roles",
                         svc_h + ["Prefer: resolution=merge-duplicates"],
                         {"user_id": admin_id, "role": "admin"})
        print(f"temp admin ready ({code})")

        # 2. sign in for a real JWT
        code, body = req("POST", f"{url}/auth/v1/token?grant_type=password",
                         [f"apikey: {anon}"], {"email": admin_email, "password": admin_pw})
        if code != 200:
            print("temp admin sign-in failed:", code, body[:300]); return 1
        jwt = json.loads(body)["access_token"]
        print("signed in, JWT acquired\n")

        # 3. call the deployed server function the way the browser does
        print(f"POST {site}/_serverFn/createTrainee")
        code, body = req(
            "POST", f"{site}/_serverFn/createTrainee",
            [f"Authorization: Bearer {jwt}", "x-tsr-serverFn: true",
             "accept: application/json"],
            {"data": {"email": made_trainee_email, "password": f"Trainee-{tag}-Pw!",
                      "fullName": "Temp Trainee"}})
        print(f"  HTTP {code}")
        print(f"  body: {body[:900]}\n")

        if code == 200 and '"ok":true' in body.replace(" ", ""):
            print("RESULT: production trainee creation SUCCEEDED")
            rc = 0
        else:
            print("RESULT: production trainee creation FAILED  <-- this is the user's error")
            rc = 1

        # clean up any trainee that did get made
        code, b = req("GET", f"{url}/auth/v1/admin/users?page=1&per_page=200", svc_h)
        if code == 200:
            for u in json.loads(b).get("users", []):
                if u.get("email") == made_trainee_email:
                    req("DELETE", f"{url}/auth/v1/admin/users/{u['id']}", svc_h)
                    print("cleaned up created trainee")
        return rc

    finally:
        if admin_id:
            req("DELETE", f"{url}/auth/v1/admin/users/{admin_id}", svc_h)
            print("cleaned up temp admin")


if __name__ == "__main__":
    sys.exit(main())
