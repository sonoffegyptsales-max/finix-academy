#!/usr/bin/env python3
"""Why is the lessons list empty on the module page?

Reproduces the exact query useCurriculum() runs, as an ANONYMOUS caller and as
an AUTHENTICATED one, with the narrowed column list and with select('*').
That isolates whether the cause is RLS, the column list, or the app code.
"""
from __future__ import annotations

import json
import os
import secrets
import subprocess

COLS = "id,module_id,position,title,title_ar,video_url,created_at,updated_at"


def env() -> dict[str, str]:
    out = {}
    with open(".env", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                out[k.strip()] = v.strip()
    return out


def get(url: str, headers: list[str]) -> tuple[int, str]:
    r = subprocess.run(["curl", "-s", "-w", "\n%{http_code}", url, *headers],
                       capture_output=True, text=True, encoding="utf-8")
    body, _, code = r.stdout.rpartition("\n")
    return int(code or 0), body


def post(url: str, headers: list[str], payload: dict) -> dict:
    pf = os.path.join(os.environ.get("TMPDIR", "."), f"_p{secrets.token_hex(3)}.json")
    with open(pf, "w", encoding="utf-8") as f:
        json.dump(payload, f)
    try:
        r = subprocess.run(["curl", "-s", "-X", "POST", url, *headers,
                            "-H", "Content-Type: application/json",
                            "--data-binary", f"@{pf}"],
                           capture_output=True, text=True, encoding="utf-8")
        try:
            return json.loads(r.stdout)
        except Exception:
            return {"_raw": r.stdout[:300]}
    finally:
        os.unlink(pf)


def main() -> int:
    e = env()
    sb = (e.get("VITE_SUPABASE_URL") or e["SUPABASE_URL"]).rstrip("/")
    svc = e["SUPABASE_SERVICE_ROLE_KEY"]
    anon = e.get("VITE_SUPABASE_PUBLISHABLE_KEY") or e.get("VITE_SUPABASE_ANON_KEY")

    print("=" * 62)
    print("1. SERVICE ROLE (bypasses RLS) — is the data there at all?")
    for label, q in [("narrowed cols", f"select={COLS}"), ("select *", "select=*")]:
        code, body = get(f"{sb}/rest/v1/lessons?{q}&limit=500",
                         ["-H", f"Authorization: Bearer {svc}", "-H", f"apikey: {svc}"])
        try:
            n = len(json.loads(body))
        except Exception:
            n = f"ERR {body[:120]}"
        print(f"   {label:<16} HTTP {code}  rows={n}")

    print()
    print("2. ANONYMOUS (apikey only) — what a logged-out visitor sees")
    for tbl in ["tracks", "modules", "lessons"]:
        code, body = get(f"{sb}/rest/v1/{tbl}?select=id&limit=500",
                         ["-H", f"apikey: {anon}"])
        try:
            n = len(json.loads(body))
        except Exception:
            n = f"ERR {body[:120]}"
        print(f"   {tbl:<10} HTTP {code}  rows={n}")

    print()
    print("3. AUTHENTICATED — the real app path")
    print("   NOTE: roles live in user_roles, NOT profiles.role. A probe user")
    print("   with only a profiles row is unprivileged and proves nothing.")
    email = f"rls-{secrets.token_hex(4)}@finix-shot.local"
    pwd = secrets.token_urlsafe(18)
    mk = post(f"{sb}/auth/v1/admin/users",
              ["-H", f"Authorization: Bearer {svc}", "-H", f"apikey: {svc}"],
              {"email": email, "password": pwd, "email_confirm": True})
    uid = mk.get("id")
    if not uid:
        print("   could not create probe user:", str(mk)[:200])
        return 1
    post(f"{sb}/rest/v1/profiles",
         ["-H", f"Authorization: Bearer {svc}", "-H", f"apikey: {svc}",
          "-H", "Prefer: resolution=merge-duplicates,return=minimal"],
         {"id": uid, "email": email, "full_name": "RLS Probe"})
    tok = post(f"{sb}/auth/v1/token?grant_type=password", ["-H", f"apikey: {anon}"],
               {"email": email, "password": pwd})
    at = tok.get("access_token")
    dev = secrets.token_hex(8)
    try:
        if not at:
            print("   sign-in failed:", str(tok)[:200])
            return 1
        hdr = ["-H", f"Authorization: Bearer {at}", "-H", f"apikey: {anon}"]

        def lessons(label, extra=None):
            code, body = get(f"{sb}/rest/v1/lessons?select=id&limit=500",
                             hdr + (extra or []))
            try:
                n = len(json.loads(body))
            except Exception:
                n = f"ERR {body[:120]}"
            print(f"   {label:<38} HTTP {code}  rows={n}")

        lessons("a) no role, no device")

        # trainee role only
        post(f"{sb}/rest/v1/user_roles",
             ["-H", f"Authorization: Bearer {svc}", "-H", f"apikey: {svc}",
              "-H", "Prefer: resolution=merge-duplicates,return=minimal"],
             {"user_id": uid, "role": "trainee"})
        lessons("b) trainee role, no device")
        lessons("c) trainee role, UNBOUND device hdr", ["-H", f"x-device-id: {dev}"])

        # bind the device, as the app does on first sign-in
        post(f"{sb}/rest/v1/trainee_devices",
             ["-H", f"Authorization: Bearer {svc}", "-H", f"apikey: {svc}",
              "-H", "Prefer: resolution=merge-duplicates,return=minimal"],
             {"user_id": uid, "device_id": dev, "device_label": "RLS Probe"})
        lessons("d) trainee role, BOUND device hdr", ["-H", f"x-device-id: {dev}"])
        lessons("e) trainee role, bound but NO hdr")

        # staff exemption
        subprocess.run(["curl", "-s", "-X", "DELETE",
                        f"{sb}/rest/v1/user_roles?user_id=eq.{uid}",
                        "-H", f"Authorization: Bearer {svc}", "-H", f"apikey: {svc}"],
                       capture_output=True)
        post(f"{sb}/rest/v1/user_roles",
             ["-H", f"Authorization: Bearer {svc}", "-H", f"apikey: {svc}",
              "-H", "Prefer: resolution=merge-duplicates,return=minimal"],
             {"user_id": uid, "role": "admin"})
        lessons("f) ADMIN role, no device")
    finally:
        subprocess.run(["curl", "-s", "-X", "DELETE",
                        f"{sb}/rest/v1/trainee_devices?user_id=eq.{uid}",
                        "-H", f"Authorization: Bearer {svc}", "-H", f"apikey: {svc}"],
                       capture_output=True)
        subprocess.run(["curl", "-s", "-X", "DELETE",
                        f"{sb}/rest/v1/user_roles?user_id=eq.{uid}",
                        "-H", f"Authorization: Bearer {svc}", "-H", f"apikey: {svc}"],
                       capture_output=True)
        subprocess.run(["curl", "-s", "-X", "DELETE",
                        f"{sb}/rest/v1/profiles?id=eq.{uid}",
                        "-H", f"Authorization: Bearer {svc}", "-H", f"apikey: {svc}"],
                       capture_output=True)
        subprocess.run(["curl", "-s", "-X", "DELETE",
                        f"{sb}/auth/v1/admin/users/{uid}",
                        "-H", f"Authorization: Bearer {svc}", "-H", f"apikey: {svc}"],
                       capture_output=True)
        print("\n   probe user cleaned up")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
