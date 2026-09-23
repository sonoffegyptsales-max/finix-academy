#!/usr/bin/env python3
"""Show the exact raw form of numbered lines, to build the right regex."""
import json
import re
import subprocess

e = {}
for line in open(".env", encoding="utf-8"):
    line = line.strip()
    if line and not line.startswith("#") and "=" in line:
        k, v = line.split("=", 1)
        e[k.strip()] = v.strip()

url = (e.get("VITE_SUPABASE_URL") or e["SUPABASE_URL"]).rstrip("/")
key = e["SUPABASE_SERVICE_ROLE_KEY"]
A = ["-H", f"Authorization: Bearer {key}", "-H", f"apikey: {key}"]

rows = json.loads(subprocess.run(
    ["curl", "-s", f"{url}/rest/v1/lessons?select=id,title,content,content_ar&limit=500", *A],
    capture_output=True, text=True, encoding="utf-8").stdout)

# Any line whose first non-space run contains a digit within the first ~6 chars
probe = re.compile(r"^[ \t]{0,3}\S{0,6}?[0-9\u0660-\u0669]")
seen = {}
for r in rows:
    for f in ("content", "content_ar"):
        for ln in (r.get(f) or "").split("\n"):
            s = ln.strip()
            if not s or s.startswith("|") or s.startswith("```"):
                continue
            if probe.match(ln):
                # signature = first 8 chars with digits masked
                sig = re.sub(r"[0-9\u0660-\u0669]", "#", s[:8])
                seen.setdefault(sig, []).append((r["title"][:34], s[:70]))

print(f"{len(seen)} distinct line-start signatures containing a digit\n")
for sig, items in sorted(seen.items(), key=lambda x: -len(x[1]))[:22]:
    print(f"  {len(items):>4}x  {sig!r}")
    print(f"          e.g. {items[0][1][:66]}")
