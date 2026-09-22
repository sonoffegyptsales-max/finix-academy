#!/usr/bin/env python3
"""Attempt a REAL push subscription against the deployed site, headlessly.

Push delivery has never been verified end to end on this project (0 rows in
push_subscriptions). This drives Chrome over CDP:

  1. grant the Notification permission for the origin
  2. load the site and wait for the service worker
  3. read VITE_VAPID_PUBLIC_KEY out of the live bundle
  4. call pushManager.subscribe() for real, against the browser's push service

A successful subscribe proves the key is well-formed AND accepted by the push
service -- which no amount of reading the bundle can establish. The resulting
subscription is printed (endpoint host only) and immediately unsubscribed, so
nothing is left registered.

Usage: python3 scripts/test_push_subscribe.py [url]
"""
from __future__ import annotations

import base64
import json
import os
import socket
import subprocess
import sys
import time
import urllib.request

CHROME = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
DEFAULT_URL = "https://finix-academy.vercel.app/"


def free_port() -> int:
    s = socket.socket()
    s.bind(("127.0.0.1", 0))
    p = s.getsockname()[1]
    s.close()
    return p


def http_json(url: str, timeout: float = 20.0):
    with urllib.request.urlopen(url, timeout=timeout) as r:
        return json.loads(r.read().decode())


def main() -> int:
    url = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_URL
    origin = "/".join(url.split("/")[:3])

    port = free_port()
    profile = os.path.join(
        os.environ.get("LOCALAPPDATA", "."), "Temp", f"push-prof-{port}")
    proc = subprocess.Popen([
        CHROME, "--headless=new", "--disable-gpu",
        f"--remote-debugging-port={port}", f"--user-data-dir={profile}",
        "--remote-allow-origins=*", "--no-first-run",
        "--window-size=1200,900", "about:blank",
    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    try:
        ws = None
        for _ in range(60):
            try:
                for t in http_json(f"http://127.0.0.1:{port}/json"):
                    if t.get("type") == "page":
                        ws = t["webSocketDebuggerUrl"]
                        break
                if ws:
                    break
            except Exception:
                pass
            time.sleep(0.5)
        if not ws:
            print("could not reach CDP")
            return 1

        from websocket import create_connection  # type: ignore

        conn = create_connection(ws, timeout=90)
        ident = [0]

        def cmd(method, **params):
            ident[0] += 1
            conn.send(json.dumps(
                {"id": ident[0], "method": method, "params": params}))
            while True:
                msg = json.loads(conn.recv())
                if msg.get("id") == ident[0]:
                    if "error" in msg:
                        return {"__error": msg["error"]}
                    return msg.get("result", {})

        cmd("Page.enable")
        cmd("Runtime.enable")

        # Grant notifications up front so requestPermission() cannot block.
        cmd("Browser.grantPermissions", origin=origin,
            permissions=["notifications"])

        cmd("Page.navigate", url=url)
        time.sleep(12)

        state = cmd("Runtime.evaluate", returnByValue=True, expression="""
            JSON.stringify({
              permission: Notification.permission,
              hasSW: 'serviceWorker' in navigator,
              hasPush: 'PushManager' in window,
            })
        """)
        print("browser state:", state.get("result", {}).get("value"))

        # Pull the key the deployed bundle actually shipped with.
        key_res = cmd("Runtime.evaluate", returnByValue=True, awaitPromise=True,
                      expression="""
            (async () => {
              const html = await (await fetch('/')).text();
              const chunks = [...html.matchAll(/\\/assets\\/[A-Za-z0-9_.-]+\\.js/g)]
                                .map(m => m[0]);
              for (const c of [...new Set(chunks)]) {
                const t = await (await fetch(c)).text();
                const m = t.match(/VITE_VAPID_PUBLIC_KEY:`([^`]*)`/);
                if (m) return m[1];
              }
              return '';
            })()
        """)
        key = key_res.get("result", {}).get("value") or ""
        print(f"VAPID key from live bundle: {len(key)} chars")
        if not key:
            print("FAIL: bundle still ships an empty VAPID key")
            return 1

        # The real thing: subscribe against the browser's push service.
        sub_res = cmd("Runtime.evaluate", returnByValue=True, awaitPromise=True,
                      expression=f"""
            (async () => {{
              try {{
                const b64 = "{key}";
                const pad = "=".repeat((4 - (b64.length % 4)) % 4);
                const s = (b64 + pad).replace(/-/g, "+").replace(/_/g, "/");
                const raw = atob(s);
                const arr = new Uint8Array(raw.length);
                for (let i = 0; i < raw.length; i++) arr[i] = raw.charCodeAt(i);

                const reg = await navigator.serviceWorker.register('/sw.js');
                await navigator.serviceWorker.ready;

                const sub = await reg.pushManager.subscribe({{
                  userVisibleOnly: true,
                  applicationServerKey: arr,
                }});
                const j = sub.toJSON();
                const endpoint = sub.endpoint;
                await sub.unsubscribe();
                return JSON.stringify({{
                  ok: true,
                  keyBytes: arr.length,
                  endpointHost: new URL(endpoint).host,
                  hasP256dh: !!(j.keys && j.keys.p256dh),
                  hasAuth: !!(j.keys && j.keys.auth),
                }});
              }} catch (e) {{
                return JSON.stringify({{ ok: false, error: String(e) }});
              }}
            }})()
        """)
        raw = sub_res.get("result", {}).get("value")
        if not raw:
            print("no result from subscribe attempt:", sub_res)
            return 1
        out = json.loads(raw)
        print("\nsubscribe result:")
        for k, v in out.items():
            print(f"  {k}: {v}")

        if out.get("ok"):
            print("\nPASS: the browser accepted the VAPID key and the push "
                  "service issued a subscription.")
            return 0
        print("\nFAIL: subscription rejected.")
        return 1
    finally:
        proc.terminate()


if __name__ == "__main__":
    sys.exit(main())
