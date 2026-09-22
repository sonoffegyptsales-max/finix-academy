#!/usr/bin/env python3
"""Diagnose trainee creation with a CONTROL experiment.

A raw curl against a TanStack server function is not necessarily a faithful
copy of what the browser sends (the client serializes payloads and negotiates
content types). So before trusting any failure here, this calls a server
function that is known to work in the UI -- listTrainees -- the exact same way.

  * control fails too  -> the harness is wrong, not the app.
  * control passes, createTrainee fails -> the bug is real and in createTrainee.

Usage: python3 scripts/diagnose_trainee.py [base_url]
Default base is the local dev server so errors are not swallowed by the
production error page.
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import uuid

DEFAULT_BASE = "http://localhost:3124"


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


def short(s: str, n: int = 400) -> str:
    s = " ".join(s.split())
    return s[:n]


def main() -> int:
    base = (sys.argv[1] if len(sys.argv) > 1 else DEFAULT_BASE).rstrip("/")
    e = env()
    url = (e.get("VITE_SUPABASE_URL") or "").rstrip("/")
    svc = e.get("SUPABASE_SERVICE_ROLE_KEY")
    anon = e.get("VITE_SUPABASE_PUBLISHABLE_KEY")
    svc_h = [f"Authorization: Bearer {svc}", f"apikey: {svc}"]

    tag = uuid.uuid4().hex[:8]
    ae, ap = f"tmpadmin-{tag}@finixacademy.local", f"Tmp-{tag}-Pw!"
    aid = None
    print(f"base: {base}\n")

    try:
        code, body = req("POST", f"{url}/auth/v1/admin/users", svc_h,
                         {"email": ae, "password": ap, "email_confirm": True})
        if code not in (200, 201):
            print("temp admin create failed:", code, short(body)); return 1
        aid = json.loads(body)["id"]
        req("POST", f"{url}/rest/v1/profiles",
            svc_h + ["Prefer: resolution=merge-duplicates"],
            {"id": aid, "email": ae, "full_name": "Temp Admin"})
        req("POST", f"{url}/rest/v1/user_roles",
            svc_h + ["Prefer: resolution=merge-duplicates"],
            {"user_id": aid, "role": "admin"})

        code, body = req("POST", f"{url}/auth/v1/token?grant_type=password",
                         [f"apikey: {anon}"], {"email": ae, "password": ap})
        if code != 200:
            print("temp admin sign-in failed:", code, short(body)); return 1
        jwt = json.loads(body)["access_token"]
        print("temp admin ready and signed in\n")

        h = [f"Authorization: Bearer {jwt}", "x-tsr-serverFn: true",
             "accept: application/json", f"Origin: {base}"]

        # ---- CONTROL: a server fn that works in the UI
        code, body = req("GET", f"{base}/_serverFn/listTrainees", h)
        control_ok = code == 200
        print(f"CONTROL  listTrainees   -> HTTP {code}")
        print(f"         {short(body, 300)}\n")

        # ---- SUBJECT
        code, body = req("POST", f"{base}/_serverFn/createTrainee", h,
                         {"data": {"email": f"t-{tag}@finixacademy.local",
                                   "password": f"Tr-{tag}-Pw!", "fullName": "T"}})
        subject_ok = code == 200
        print(f"SUBJECT  createTrainee  -> HTTP {code}")
        print(f"         {short(body, 800)}\n")

        print("-" * 60)
        if not control_ok and not subject_ok:
            print("BOTH failed -> the harness does not faithfully imitate the")
            print("browser. Cannot conclude the app is broken from this.")
        elif control_ok and not subject_ok:
            print("Control passed, subject failed -> REAL BUG in createTrainee.")
        elif control_ok and subject_ok:
            print("Both succeeded -> creation works on this base URL.")
        else:
            print("Control failed but subject passed -> odd; inspect manually.")

        # clean up a trainee if one was made
        code, b = req("GET", f"{url}/auth/v1/admin/users?page=1&per_page=200", svc_h)
        if code == 200:
            for u in json.loads(b).get("users", []):
                if u.get("email", "").startswith(f"t-{tag}@"):
                    req("DELETE", f"{url}/auth/v1/admin/users/{u['id']}", svc_h)
                    print("cleaned up created trainee")
        return 0
    finally:
        if aid:
            req("DELETE", f"{url}/auth/v1/admin/users/{aid}", svc_h)
            print("cleaned up temp admin")


if __name__ == "__main__":
    sys.exit(main())
