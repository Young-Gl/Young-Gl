#!/usr/bin/env python3
"""Rebuild the projects section of the profile README from public repositories."""
import json, os, re, urllib.request

USER = "Young-Gl"
README = "README.md"
START, END = "<!-- PROJECTS:START -->", "<!-- PROJECTS:END -->"
SKIP = {USER.lower()}          # the profile repo itself
MAX_PROJECTS = 6

def api(path):
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
    if len(desc) > 130:
        desc = desc[:127] + "…"
    links = [f'<a href="{url}">Repository</a>']
    if has_release(name):
        links.append(f'<a href="{url}/releases/latest">Download</a>')
    meta = f'<sub>⌘ {r["language"]}</sub>' if r.get("language") else ""
    stars = f' · ★ {r["stargazers_count"]}' if r["stargazers_count"] else ""
    return (
        '    <td width="50%" valign="top">\n'
        f'      <h4><a href="{url}">{label}</a></h4>\n'
        f'      <p><sub>{desc}</sub></p>\n'
        f'      <p><sub>{" &nbsp;·&nbsp; ".join(links)}{stars}</sub></p>\n'
        '    </td>'
    )

rows = []
for i in range(0, len(repos), 2):
    pair = repos[i:i+2]
    cells = [card(r) for r in pair]
    if len(cells) == 1:
        cells.append('    <td width="50%" valign="top"></td>')
    rows.append("  <tr>\n" + "\n".join(cells) + "\n  </tr>")

block = f"{START}\n<table>\n" + "\n".join(rows) + f"\n</table>\n{END}"

# ---- metrics line -------------------------------------------------------
all_repos = api(f"/users/{USER}/repos?per_page=100&type=public")
own = [r for r in all_repos if not r["fork"] and r["name"].lower() not in SKIP]
stars = sum(r["stargazers_count"] for r in own)
langs = {}
for r in own:
    if r.get("language"):
        langs[r["language"]] = langs.get(r["language"], 0) + 1
top_lang = max(langs, key=langs.get) if langs else "Swift"
since = api(f"/users/{USER}")["created_at"][:4]
n = len(own)
metrics = (f"{n} public repositor{'y' if n == 1 else 'ies'} &nbsp;·&nbsp; "
           f"{stars} star{'s' if stars != 1 else ''} &nbsp;·&nbsp; "
           f"{top_lang} &nbsp;·&nbsp; since {since}")

src = open(README, encoding="utf-8").read()
if START not in src or END not in src:
    raise SystemExit("markers not found in README")
new = re.sub(re.escape(START) + r".*?" + re.escape(END), block, src, flags=re.S)
new = new.replace("<!-- METRICS -->", metrics)
open(README, "w", encoding="utf-8").write(new)
print(f"updated with {len(repos)} project(s)")
