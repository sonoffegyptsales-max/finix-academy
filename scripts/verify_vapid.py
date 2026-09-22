#!/usr/bin/env python3
"""Verify the VAPID keypair in .env is internally consistent.

A push subscription is created in the browser with the PUBLIC key and the
server signs with the PRIVATE key. If they are not a real P-256 pair, the
browser subscribes happily and every send later fails with a 403 from the push
service -- a failure that looks like a delivery problem, not a key problem.

Checks:
  * public key decodes to 65 bytes starting with 0x04 (uncompressed P-256 point)
  * private key decodes to 32 bytes
  * the public key is exactly what the private key derives to
"""
from __future__ import annotations

import base64
import sys


def b64url(s: str) -> bytes:
    pad = "=" * (-len(s) % 4)
    return base64.urlsafe_b64decode(s + pad)


def env() -> dict[str, str]:
    out: dict[str, str] = {}
    for line in open(".env", encoding="utf-8"):
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            k, v = line.split("=", 1)
            out[k.strip()] = v.strip()
    return out


def main() -> int:
    e = env()
    pub_s = e.get("VAPID_PUBLIC_KEY", "")
    vite_s = e.get("VITE_VAPID_PUBLIC_KEY", "")
    priv_s = e.get("VAPID_PRIVATE_KEY", "")

    ok = True

    if pub_s != vite_s:
        print("MISMATCH: VAPID_PUBLIC_KEY != VITE_VAPID_PUBLIC_KEY")
        print("  the browser would subscribe with a different key than the server signs with")
        ok = False
    else:
        print("OK  server and client public keys are identical")

    try:
        pub = b64url(pub_s)
        print(f"OK  public decodes to {len(pub)} bytes, first byte 0x{pub[0]:02x}")
        if len(pub) != 65 or pub[0] != 0x04:
            print("BAD public key: expected 65 bytes beginning 0x04 (uncompressed P-256)")
            ok = False
    except Exception as exc:
        print(f"BAD public key: cannot base64url-decode ({exc})")
        return 1

    try:
        priv = b64url(priv_s)
        print(f"OK  private decodes to {len(priv)} bytes")
        if len(priv) != 32:
            print("BAD private key: expected 32 bytes")
            ok = False
    except Exception as exc:
        print(f"BAD private key: cannot base64url-decode ({exc})")
        return 1

    # Derive the public point from the private scalar on P-256 and compare.
    p = 0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF
    a = p - 3
    gx = 0x6B17D1F2E12C4247F8BCE6E563A440F277037D812DEB33A0F4A13945D898C296
    gy = 0x4FE342E2FE1A7F9B8EE7EB4A7C0F9E162BCE33576B315ECECBB6406837BF51F5
    n = 0xFFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551

    def inv(x: int) -> int:
        return pow(x, p - 2, p)

    def add(P, Q):
        if P is None:
            return Q
        if Q is None:
            return P
        x1, y1 = P
        x2, y2 = Q
        if x1 == x2 and (y1 + y2) % p == 0:
            return None
        if P == Q:
            lam = (3 * x1 * x1 + a) * inv(2 * y1) % p
        else:
            lam = (y2 - y1) * inv(x2 - x1) % p
        x3 = (lam * lam - x1 - x2) % p
        return (x3, (lam * (x1 - x3) - y1) % p)

    def mul(k: int, P):
        R = None
        while k:
            if k & 1:
                R = add(R, P)
            P = add(P, P)
            k >>= 1
        return R

    d = int.from_bytes(priv, "big")
    if not (1 <= d < n):
        print("BAD private key: scalar out of range")
        return 1

    Q = mul(d, (gx, gy))
    derived = b"\x04" + Q[0].to_bytes(32, "big") + Q[1].to_bytes(32, "big")

    if derived == pub:
        print("OK  private key derives exactly to the public key — valid VAPID pair")
    else:
        print("MISMATCH: the private key does NOT correspond to the public key")
        print("  browsers will subscribe, but every send will fail with 403")
        ok = False

    print("\nRESULT:", "keypair is valid" if ok else "keypair is BROKEN")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
