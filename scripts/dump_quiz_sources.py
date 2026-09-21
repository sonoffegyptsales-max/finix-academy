#!/usr/bin/env python3
"""Dump per-module lesson content + existing quiz questions to workdir files.

Gives quiz authors the actual source material so questions are drawn from
what is taught rather than invented.
"""
import json
import os
import subprocess
import tempfile

REF = "bdkwsveouzufgwajefrc"
OUT = os.path.join("scripts", "quizsrc")


def token():
    with open(".env", encoding="utf-8") as f:
        for line in f:
            if line.startswith("SUPABASE_ACCESS_TOKEN="):
                return line.split("=", 1)[1].strip()
    return os.environ.get("SUPABASE_ACCESS_TOKEN", "")


def q(sql):
    fd, path = tempfile.mkstemp(suffix=".json")
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        json.dump({"query": sql}, f)
    try:
        r = subprocess.run(
            ["curl", "-s", "-X", "POST",
             f"https://api.supabase.com/v1/projects/{REF}/database/query",
             "-H", f"Authorization: Bearer {token()}",
             "-H", "Content-Type: application/json",
             "--data-binary", f"@{path}"],
            capture_output=True, text=True, encoding="utf-8")
        return json.loads(r.stdout)
    finally:
        os.unlink(path)


lessons = q("""SELECT m.code, m.slug, l.position, l.title, l.content
FROM public.lessons l JOIN public.modules m ON m.id=l.module_id
ORDER BY m.code, l.position;""")

quests = q("""SELECT m.code, qz.tier, qq.position, qq.question
FROM public.quiz_questions qq
JOIN public.quizzes qz ON qz.id=qq.quiz_id
JOIN public.modules m ON m.id=qz.module_id
ORDER BY m.code, qz.tier, qq.position;""")

os.makedirs(OUT, exist_ok=True)
by_mod = {}
for r in lessons:
    by_mod.setdefault(r["code"], {"slug": r["slug"], "lessons": [], "qs": []})
    by_mod[r["code"]]["lessons"].append(r)
for r in quests:
    if r["code"] in by_mod:
        by_mod[r["code"]]["qs"].append(r)

for code, d in by_mod.items():
    path = os.path.join(OUT, f"{code}.md")
    with open(path, "w", encoding="utf-8") as f:
        f.write(f"# {code} — slug: {d['slug']}\n\n")
        f.write("## EXISTING QUESTIONS (do not duplicate these concepts)\n\n")
        for r in d["qs"]:
            f.write(f"- [{r['tier']} p{r['position']}] {r['question']}\n")
        f.write("\n## LESSON CONTENT (source your questions from this)\n\n")
        for r in d["lessons"]:
            f.write(f"\n### Lesson {r['position']}: {r['title']}\n\n")
            f.write((r["content"] or "") + "\n")
    print(f"{code}: {len(d['lessons'])} lessons, {len(d['qs'])} existing questions -> {path}")
