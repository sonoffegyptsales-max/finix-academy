#!/usr/bin/env python3
"""Screenshot the app in Arabic (RTL) using Chrome DevTools Protocol.

Language is stored in localStorage, so a plain headless screenshot always
renders English. This launches Chrome with remote debugging, seeds
localStorage with lang=ar, reloads, and captures the result -- plus the actual
<html dir> attribute, which is the thing being fixed.

Usage: python3 scripts/shoot_rtl.py <url> <out.png>
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
    url = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:3126/"
    out = sys.argv[2] if len(sys.argv) > 2 else "rtl.png"

    port = free_port()
    profile = os.path.join(os.environ.get("TMPDIR") or os.environ["LOCALAPPDATA"],
                           f"cdp-prof-{port}")
    proc = subprocess.Popen([
        CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars",
        f"--remote-debugging-port={port}", f"--user-data-dir={profile}",
        "--remote-allow-origins=*",
        "--no-first-run", "--window-size=1200,1000", "about:blank",
    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    try:
        ws = None
        for _ in range(60):
            try:
                tabs = http_json(f"http://127.0.0.1:{port}/json")
                for t in tabs:
                    if t.get("type") == "page":
                        ws = t["webSocketDebuggerUrl"]
                        break
                if ws:
                    break
            except Exception:
                pass
            time.sleep(0.5)
        if not ws:
            print("could not reach CDP"); return 1

        try:
            from websocket import create_connection  # type: ignore
        except ImportError:
            print("needs websocket-client: uv pip install websocket-client")
            return 2

        conn = create_connection(ws, timeout=60)
        ident = [0]

        def cmd(method, **params):
            ident[0] += 1
            conn.send(json.dumps({"id": ident[0], "method": method, "params": params}))
            while True:
                msg = json.loads(conn.recv())
                if msg.get("id") == ident[0]:
                    return msg.get("result", {})

        cmd("Page.enable")
        cmd("Runtime.enable")

        # first load to get an origin we may write localStorage against
        cmd("Page.navigate", url=url)
        time.sleep(6)
        cmd("Runtime.evaluate",
            expression="localStorage.setItem('lang','ar')", awaitPromise=True)
        cmd("Page.navigate", url=url)
        time.sleep(8)

        info = cmd("Runtime.evaluate", expression=(
            "JSON.stringify({dir:document.documentElement.getAttribute('dir'),"
            "lang:document.documentElement.getAttribute('lang'),"
            "stored:localStorage.getItem('lang'),"
            "sample:(document.body.innerText||'').slice(0,120)})"
        ), returnByValue=True)
        print("page state:", info.get("result", {}).get("value"))

        shot = cmd("Page.captureScreenshot", format="png", captureBeyondViewport=True)
        data = shot.get("data")
        if not data:
            print("no screenshot data"); return 1
        with open(out, "wb") as f:
            f.write(base64.b64decode(data))
        print("wrote", out)
        return 0
    finally:
        proc.terminate()


if __name__ == "__main__":
    sys.exit(main())
