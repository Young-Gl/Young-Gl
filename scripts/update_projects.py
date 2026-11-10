#!/usr/bin/env python3
"""Rebuild the projects section of the profile README from public repositories."""
import json, os, re, time, urllib.request

USER = "Young-Gl"
README = "README.md"
START, END = "<!-- PROJECTS:START -->", "<!-- PROJECTS:END -->"
SKIP = {USER.lower()}          # the profile repo itself
MAX_PROJECTS = 6

def api(path, tries=3):
    last = None
    for _ in range(tries):
        try:
            return _api_once(path)
        except Exception as e:
            last = e
            time.sleep(2)
    raise last

def _api_once(path):
    req = urllib.request.Request(
        f"https://api.github.com{path}",
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {os.environ['GH_TOKEN']}",
            "User-Agent": "profile-readme-bot",
        },
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)

def has_release(repo):
    try:
        api(f"/repos/{USER}/{repo}/releases/latest")
        return True
    except Exception:
        return False

repos = api(f"/users/{USER}/repos?per_page=100&sort=pushed&type=public")
repos = [r for r in repos if not r["fork"] and r["name"].lower() not in SKIP]
repos.sort(key=lambda r: (r["stargazers_count"], r["pushed_at"]), reverse=True)
repos = repos[:MAX_PROJECTS]

def pretty(name):
    n = name.replace("-Mac", "").replace("-mac", "")
    return n.replace("_", " ").replace("-", " ").strip().title()

def card(r):
    name = r["name"]
    label = pretty(name)
    url = r["html_url"]
    desc = (r["description"] or "").strip()
    desc = desc.split("。")[0].split(". ")[0]
    if len(desc) > 120:
        desc = desc[:117] + "…"
    tail = []
    if r.get("language"):
        tail.append(r["language"])
    if has_release(name):
        tail.append(f"[Download]({url}/releases/latest)")
    if r["stargazers_count"]:
        tail.append(f"★ {r['stargazers_count']}")
    meta = (" · " + " · ".join(tail)) if tail else ""
    return f"**[{label}]({url})** — {desc}{meta}"

items = [card(r) for r in repos]
block = f"{START}\n" + "\n\n".join(items) + f"\n{END}"

# ---- metrics line -------------------------------------------------------
all_repos = api(f"/users/{USER}/repos?per_page=100&type=public")
own = [r for r in all_repos if not r["fork"] and r["name"].lower() not in SKIP]
stars = sum(r["stargazers_count"] for r in own)
langs = {}
for r in own:
    if r.get("language"):
        langs[r["language"]] = langs.get(r["language"], 0) + 1
top_lang = max(langs, key=langs.get) if langs else "Swift"
try:
    since = api(f"/users/{USER}")["created_at"][:4]
except Exception:
    since = "2020"
n = len(own)
metrics = (f"{n} public repositor{'y' if n == 1 else 'ies'} · "
           f"{stars} star{'s' if stars != 1 else ''} · "
           f"{top_lang} · since {since}")

# ---- notes section ------------------------------------------------------
import glob

def read_meta(path):
    txt = open(path, encoding="utf-8").read()
    m = re.match(r"^---\n(.*?)\n---\n", txt, re.S)
    meta = {}
    if m:
        for line in m.group(1).splitlines():
            if ":" in line:
                k, v = line.split(":", 1)
                meta[k.strip()] = v.strip()
    return meta

files = [f for f in glob.glob("essays/*.md") if not f.endswith("essays/README.md")]
entries = sorted(((read_meta(f), f) for f in files),
                 key=lambda e: e[0].get("date", ""), reverse=True)

def note_line(meta, path):
    title = meta.get("title", "Untitled")
    date = meta.get("date", "")
    summary = meta.get("summary", "")
    return f'- [{title}]({path}) — {date}'

top_notes = entries[:3]
notes_block = "\n".join(note_line(m, f) for m, f in top_notes) or "_No notes yet._"

# essays index
index = ["# Notes\n", "<sub>Short pieces on tools, time and legibility.</sub>\n"]
for meta, path in entries:
    index.append(f'- **{meta.get("date","")}** — [{meta.get("title","Untitled")}]'
                 f'({path.split("/")[-1]}) — {meta.get("summary","")}')
index.append("")
open("essays/README.md", "w", encoding="utf-8").write("\n".join(index))

src = open(README, encoding="utf-8").read()
if START not in src or END not in src:
    raise SystemExit("markers not found in README")
new = re.sub(re.escape(START) + r".*?" + re.escape(END), block, src, flags=re.S)
new = new.replace("<!-- METRICS -->", metrics)
new = re.sub(r"<!-- NOTES:START -->.*?<!-- NOTES:END -->",
             f"<!-- NOTES:START -->\n{notes_block}\n<!-- NOTES:END -->",
             new, flags=re.S)
open(README, "w", encoding="utf-8").write(new)
print(f"updated with {len(repos)} project(s)")
