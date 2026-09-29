"""Import LeetCode problems into courses/<course>/problems/<lc id>-<slug>/problem.md.

Refreshes the LeetCode fields (statement, starter, entry, examples); hand-authored sections are kept.
"""
import json, re, time, urllib.request
from html.parser import HTMLParser
from pathlib import Path

from common import cli, problem_dirs
import pyjudge

Q = """query q($s:String!){question(titleSlug:$s){
  questionFrontendId title titleSlug difficulty isPaidOnly content hints
  exampleTestcaseList metaData topicTags{slug} codeSnippets{langSlug code}}}"""
INLINE = {"strong", "b", "em", "i", "code", "sup", "sub", "u", "a"}
TABLE = {"table", "thead", "tbody", "tr", "td", "th"}
SUP = str.maketrans("0123456789+-=()abcdefghijklmnoprstuvwxyzABDEGHIJKLMNOPRTUVW",
                    "⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻⁼⁽⁾ᵃᵇᶜᵈᵉᶠᵍʰⁱʲᵏˡᵐⁿᵒᵖʳˢᵗᵘᵛʷˣʸᶻᴬᴮᴰᴱᴳᴴᴵᴶᴷᴸᴹᴺᴼᴾᴿᵀᵁⱽᵂ")
SUB = str.maketrans("0123456789+-=()aehijklmnoprstuvx", "₀₁₂₃₄₅₆₇₈₉₊₋₌₍₎ₐₑₕᵢⱼₖₗₘₙₒₚᵣₛₜᵤᵥₓ")


def code_script(tag, core):
    """<sup>/<sub> inside inline code (where HTML won't render): Unicode if possible (iᵗʰ, startᵢ), else ^x / _x."""
    table, mark = (SUP, "^") if tag == "sup" else (SUB, "_")
    if core and all(ord(c) in table for c in core):
        return core.translate(table)
    return f"{mark}{core}" if len(core) == 1 else f"{mark}({core})"


class _MD(HTMLParser):
    """LeetCode statement HTML → markdown. Tables, <u> and letter superscripts stay inline HTML."""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.out, self.inl, self.lists = [], [], []
        self.pre = self.table = 0
        self.skipws = True

    def block(self, s="\n\n"):
        self.out.append(s)
        self.skipws = True

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if self.table or tag in TABLE:
            self.table += tag == "table"
            self.out.append(self.get_starttag_text())
        elif tag in INLINE:
            self.inl.append((tag, len(self.out), a))
        elif tag == "pre":
            self.pre = len(self.out) + 1
            self.block()
        elif tag in ("p", "div"):
            self.block()
        elif tag in ("ul", "ol"):
            self.lists.append(tag)
            self.block("\n" if len(self.lists) > 1 else "\n\n")
        elif tag == "li":
            self.block("\n" + "  " * (len(self.lists) - 1) + ("1. " if self.lists and self.lists[-1] == "ol" else "- "))
        elif tag == "br":
            self.out.append("\n" if self.pre else "<br>")
        elif tag == "img":
            self.block()
            self.out.append(f"![{a.get('alt') or ''}]({a.get('src', '')})")
            self.block()

    def handle_endtag(self, tag):
        if self.table:
            self.out.append(f"</{tag}>")
            self.table -= tag == "table"
            if not self.table:
                self.block()
        elif tag in INLINE and self.inl and self.inl[-1][0] == tag:
            _, pos, a = self.inl.pop()
            inner = "".join(self.out[pos:])
            del self.out[pos:]
            core = inner.strip()
            if self.pre or not core:
                self.out.append(inner)
                return
            lead, trail = inner[: len(inner) - len(inner.lstrip())], inner[len(inner.rstrip()):]
            if tag in ("strong", "b"):
                w = f"**{core}**"
            elif tag in ("em", "i"):
                w = f"*{core}*"
            elif tag == "code":
                w = f"`{core}`" if "`" not in core else f"`` {core} ``"
            elif tag in ("sup", "sub") and any(t == "code" for t, _, _ in self.inl):
                w = code_script(tag, core)
            elif tag == "sup":
                w = core.translate(SUP) if re.fullmatch(r"[0-9+-]+", core) else f"<sup>{core}</sup>"
            elif tag == "sub":
                w = core.translate(SUB) if core.isdigit() else f"<sub>{core}</sub>"
            elif tag == "a":
                w = f"[{core}]({a.get('href', '')})"
            else:
                w = f"<{tag}>{core}</{tag}>"
            self.out.append(lead + w + trail)
        elif tag == "pre" and self.pre:
            body = "".join(self.out[self.pre:]).strip("\n")
            del self.out[self.pre:]
            self.pre = 0
            self.out.append("```\n" + body + "\n```")
            self.block()
        elif tag in ("p", "div"):
            self.block()
        elif tag in ("ul", "ol"):
            self.lists.pop()
            self.block("\n" if self.lists else "\n\n")

    def handle_data(self, d):
        if self.pre or self.table:
            self.out.append(d)
            return
        d = re.sub(r"\s+", " ", d.replace("\xa0", " "))
        if not any(t == "code" for t, _, _ in self.inl):
            d = d.replace("*", r"\*").replace("<", "&lt;")
        if self.skipws:
            d = d.lstrip()
        if d:
            self.skipws = False
            self.out.append(d)


def html_to_md(html):
    m = _MD()
    m.feed(html)
    md = "".join(m.out)
    md = "\n".join(line.rstrip() for line in md.split("\n"))
    return re.sub(r"\n{3,}", "\n\n", md).strip() + "\n"


def write_problem_md(pdir, p, statement_md, code=None, notes=None, gen=""):
    """Write problem.md from a problem dict (problem.json shape). code/notes: {solution id: text}."""
    code, notes = code or {}, notes or {}
    fm = {"lc": p["lc"]["id"] if p.get("lc") else None, "title": p["title"], "difficulty": p["difficulty"],
          "patterns": p.get("patterns", []), "lcTags": p.get("lcTags", [])}
    j = p.get("judge", {})
    if j.get("compare", "exact") != "exact":
        fm["compare"] = j["compare"]
    if j.get("timeLimitMs", 2000) != 2000:
        fm["timeLimitMs"] = j["timeLimitMs"]
    fm["entry"], fm["examples"] = p["entry"], p["examples"]
    if p.get("lcHints"):
        fm["lcHints"] = p["lcHints"]
    out = ["---"] + [f"{k}: {json.dumps(v, ensure_ascii=False)}" for k, v in fm.items()] + ["---", "",
           statement_md.strip(), "", "# Starter", "", "```python", p["starter"], "```", "", "# Hints", ""]
    out += [f"{i}. {h}" for i, h in enumerate(p.get("hints", []), 1)] + ["", "# Key points", ""]
    out += [f"- {k}" for k in p.get("explain", {}).get("keyPoints", [])] + [""]
    for s in p.get("solutions", []):
        flags = [f for f in ("reference", "slow") if s.get(f)]
        out += [f"# Solution: {' · '.join([s['id'], s['title'], s['time'], s['space'], *flags])}", "",
                notes.get(s["id"], "").strip(), "", "```python", code[s["id"]].rstrip("\n"), "```", ""]
    out += ["# Tests", "", "```python", gen.strip("\n"), "```", ""]
    (Path(pdir) / "problem.md").write_text(re.sub(r"\n{3,}", "\n\n", "\n".join(out)))


def fetch(slug):
    req = urllib.request.Request(
        "https://leetcode.com/graphql",
        data=json.dumps({"query": Q, "variables": {"s": slug}}).encode(),
        headers={"Content-Type": "application/json", "Referer": "https://leetcode.com", "User-Agent": "Mozilla/5.0"},
    )
    q = json.load(urllib.request.urlopen(req, timeout=20))["data"]["question"]
    if not q:
        raise SystemExit(f"not found: {slug}")
    if q["isPaidOnly"]:
        raise SystemExit(f"premium, skipping: {slug}")
    return q


if __name__ == "__main__":
    args = cli(__doc__, ("--all", "every problem referenced by a topic.json"), ("--force", "refresh problems that exist"))
    slugs = args.slugs
    if args.all:
        slugs = list(dict.fromkeys(r["id"] for t in sorted(args.dir.glob("modules/*/topics/*/topic.json"))
                                   for r in json.loads(t.read_text())["problems"]))
    base = args.dir / "problems"
    base.mkdir(exist_ok=True)
    existing = problem_dirs(args.dir)
    for slug in slugs:
        if slug in existing and not args.force:
            print("exists, skip (use --force to refresh LC fields):", slug)
            continue
        try:
            q = fetch(slug)
        except SystemExit as e:
            print(e)
            continue
        d = base / f"{int(q['questionFrontendId']):04d}-{slug}"
        d.mkdir(exist_ok=True)
        meta = json.loads(q["metaData"])
        old = pyjudge.load_problem(d) if (d / "problem.md").exists() else {}
        new = {
            "id": slug,
            "lc": {"id": int(q["questionFrontendId"]), "slug": slug},
            "title": q["title"],
            "difficulty": q["difficulty"],
            "patterns": [],
            "lcTags": [t["slug"] for t in q["topicTags"]],
            "starter": next(s["code"] for s in q["codeSnippets"] if s["langSlug"] == "python3"),
            "entry": {
                "method": meta["classname"], "design": True,
                "params": [{"name": "operations", "type": "string[]"}, {"name": "arguments", "type": "list"}],
                "returns": "list",
            } if "classname" in meta else {
                "method": meta["name"],
                "params": [{"name": p["name"], "type": p["type"]} for p in meta["params"]],
                "returns": meta["return"]["type"],
                **({"outputParam": meta["output"]["paramindex"]} if "output" in meta else {}),
            },
            "examples": q["exampleTestcaseList"],
            "judge": {"compare": "exact", "timeLimitMs": 2000},
            "solutions": [],
            "hints": [],
            "lcHints": q["hints"],
            "explain": {"keyPoints": []},
        }
        for k in ("patterns", "judge", "solutions", "hints", "explain"):
            if old.get(k):
                new[k] = old[k]
        write_problem_md(d, new, html_to_md(q["content"]), old.get("code"), old.get("notes"), old.get("gen", ""))
        print("imported", slug, f"(LC {new['lc']['id']})")
        time.sleep(0.3)
