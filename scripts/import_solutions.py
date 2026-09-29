"""Import solutions (explanation + Python code) from doocs/leetcode (CC-BY-SA 4.0) into problem.md.

With no slugs, every problem without solutions. The first solution becomes the reference; "thinking"
blocks are dropped and LaTeX becomes plain text / inline code. Hints, key points and tests are kept.
"""
import json, re, shutil, subprocess, time, urllib.parse, urllib.request
from functools import cache

from common import cli, problem_dirs, selected
from import_lc import write_problem_md
import pyjudge

REPO = "doocs/leetcode"
SUP = str.maketrans("0123456789n+-", "⁰¹²³⁴⁵⁶⁷⁸⁹ⁿ⁺⁻")
TEX = [(r"\\(?:textit|text|texttt|textbf|mathit|mathrm|operatorname)\{([^{}]*)\}", r"\1"),
       (r"\\frac\{([^{}]*)\}\{([^{}]*)\}", r"(\1) / (\2)"), (r"\\sqrt\{([^{}]*)\}", r"sqrt(\1)"),
       (r"\\(?:leq|le)\b", "<="), (r"\\(?:geq|ge)\b", ">="), (r"\\lt\b", "<"), (r"\\gt\b", ">"),
       (r"\\(?:neq|ne)\b", "!="), (r"\\times\b", "×"), (r"\\cdot\b", "·"), (r"\\(?:ldots|dots|cdots)\b", "..."),
       (r"\\infty\b", "inf"), (r"\\in\b", "in"), (r"\\oplus\b", "XOR"), (r"\\(?:bmod|mod)\b", "mod"),
       (r"\\(?:left|right|lfloor|rfloor|lceil|rceil|quad|,|;|!)", ""), (r"\\(log|min|max|sum|land|lor)\b", r"\1"),
       (r"\\([{}_&%#$])", r"\1"), (r"\^\{([0-9n+-]+)\}", lambda m: m[1].translate(SUP)),
       (r"\^([0-9n])", lambda m: m[1].translate(SUP)), (r"\\to\b", "→"), (r"\\rightarrow\b", "→")]
TEX = [(re.compile(a), b) for a, b in TEX]
BIG_O = r"(O\((?:[^()]|\([^()]*\))*\))"


def get(path, raw=True):
    """A file (raw) or directory listing (JSON) under solution/ in the repo."""
    if shutil.which("gh"):  # authenticated: faster, higher rate limits
        cmd = ["gh", "api", f"repos/{REPO}/contents/solution/{path}"]
        r = subprocess.run(cmd + ["-H", "Accept: application/vnd.github.raw"] * raw, capture_output=True, text=True, timeout=60)
        if r.returncode == 0:
            return r.stdout
    url = (f"https://raw.githubusercontent.com/{REPO}/main/solution/" if raw
           else f"https://api.github.com/repos/{REPO}/contents/solution/") + path
    for attempt in range(3):
        try:
            return urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"}), timeout=30).read().decode()
        except Exception:
            if attempt == 2:
                raise
            time.sleep(2)


@cache
def listing(block):
    return [e["name"] for e in json.loads(get(block, raw=False))]


def folder(lc_id):
    lo = lc_id // 100 * 100
    block = f"{lo:04d}-{lo + 99:04d}"
    name = next(n for n in listing(block) if n.startswith(f"{lc_id:04d}."))
    return f"{block}/{urllib.parse.quote(name)}"


def tex(s):
    for a, b in TEX:
        s = a.sub(b, s)
    return s


def math(m):
    inner = tex(m[1]).strip()
    return inner if re.fullmatch(r"O\(.*\)|[\w.]+|-?\d+", inner) else f"`{inner}`"


def clean(md):
    md = re.sub(r"<!-- thinking:start -->.*?<!-- thinking:end -->", "", md, flags=re.S)
    md = re.sub(r"<!--.*?-->", "", md, flags=re.S)
    md = re.sub(r"\$\$(.+?)\$\$", lambda m: f"\n```\n{tex(m[1]).strip()}\n```\n", md, flags=re.S)
    md = re.sub(r"\$(.+?)\$", math, md)
    return re.sub(r"\n{3,}", "\n\n", md).strip()


def complexity(notes):
    t = re.search(r"[Tt]ime complexity[^O]{0,30}?" + BIG_O, notes)
    sp = re.search(r"[Ss]pace complexity[^O]{0,30}?" + BIG_O, notes)
    return {"time": t[1] if t else "?", "space": sp[1] if sp else "?"}


def parse(readme):
    body = readme.split("## Solutions", 1)[-1]
    sols = []
    for title, chunk in re.findall(r"^### Solution \d+[:.]?[ \t]*(.*?)\n(.*?)(?=^### Solution |\Z)", body, re.S | re.M):
        code = re.search(r"#### Python3\s*```python\n(.*?)```", chunk, re.S)
        if not code:
            continue
        notes = clean(chunk.split("<!-- tabs:start -->")[0])
        sid = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")[:40] or f"solution-{len(sols) + 1}"
        while any(s["id"] == sid for s in sols):
            sid += "-2"
        sols.append({"id": sid, "title": title.strip() or f"Solution {len(sols) + 1}", **complexity(notes),
                     "code": code[1], "notes": notes})
    return sols


if __name__ == "__main__":
    args = cli(__doc__, ("--force", "replace existing solutions"))
    for d in selected(problem_dirs(args.dir), args.slugs):
        p = pyjudge.load_problem(d)
        if (p["solutions"] and not args.force) or not p["lc"]:
            continue
        try:
            sols = parse(get(folder(p["lc"]["id"]) + "/README_EN.md"))
        except Exception as e:
            print(f"FAIL {p['id']}: {e!r}")
            continue
        if not sols:
            print(f"FAIL {p['id']}: no Python solution")
            continue
        p["solutions"] = [{k: s[k] for k in ("id", "title", "time", "space")} for s in sols]
        p["solutions"][0]["reference"] = True
        write_problem_md(d, p, p["statement"], {s["id"]: s["code"] for s in sols}, {s["id"]: s["notes"] for s in sols}, p["gen"])
        print(f"ok   {p['id']}: {len(sols)} solutions")
