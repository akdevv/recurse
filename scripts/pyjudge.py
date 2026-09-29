"""Python judge core. Used by the live judge (stdin → stdout JSON) and by scripts/gen_tests.py.

stdin:  {"code": str, "problemDir": str, "mode": "run"|"submit", "custom": [str, ...] | null}
stdout: {"verdict", "passed", "total", "results": [...], "error"?}
"""
import copy, io, json, math, re, signal, sys, time, traceback
from collections import deque
from contextlib import redirect_stdout
from pathlib import Path

sys.setrecursionlimit(10_000)


class TLE(Exception):
    pass


def _alarm(*_):
    raise TLE()


CODE_BLOCK = re.compile(r"```python\n(.*?)```", re.S)


def split_sections(body):
    """Split markdown on top-level '# ' headings (ignoring code fences) → (intro, [(heading, text)])."""
    parts, head, cur, fence = [], None, [], False
    for line in body.split("\n"):
        if line.startswith("```"):
            fence = not fence
        if not fence and line.startswith("# "):
            parts.append((head, "\n".join(cur).strip()))
            head, cur = line[2:].strip(), []
        else:
            cur.append(line)
    parts.append((head, "\n".join(cur).strip()))
    return parts[0][1], parts[1:]


def load_problem(pdir):
    pdir = Path(pdir)
    _, fm, body = (pdir / "problem.md").read_text().split("---\n", 2)
    meta = {k: json.loads(v) for k, v in (line.split(": ", 1) for line in fm.strip().split("\n"))}
    slug = re.sub(r"^\d+-", "", pdir.name)
    statement, sections = split_sections(body)
    p = {"id": slug, "lc": {"id": meta["lc"], "slug": slug} if meta.get("lc") else None,
         "title": meta["title"], "difficulty": meta["difficulty"], "patterns": meta.get("patterns", []),
         "lcTags": meta.get("lcTags", []), "starter": "", "entry": meta["entry"], "examples": meta["examples"],
         "judge": {"compare": meta.get("compare", "exact"), "timeLimitMs": meta.get("timeLimitMs", 2000)},
         "solutions": [], "hints": [], "lcHints": meta.get("lcHints", []), "explain": {"keyPoints": []},
         "statement": statement, "code": {}, "notes": {}, "gen": ""}
    for head, text in sections:
        blocks = CODE_BLOCK.findall(text)
        if head == "Starter":
            p["starter"] = blocks[0][:-1]
            if p["entry"].get("design"):  # LeetCode ignores what void methods return
                p["entry"]["voids"] = re.findall(r"def (\w+)\(.*\)\s*->\s*None", p["starter"])
        elif head == "Hints":
            p["hints"] = [re.sub(r"^\d+\.\s*", "", l) for l in text.split("\n") if re.match(r"\d+\. ", l)]
        elif head == "Key points":
            p["explain"]["keyPoints"] = [l[2:] for l in text.split("\n") if l.startswith("- ")]
        elif head == "Tests":
            p["gen"] = blocks[0]
        elif head.startswith("Solution:"):
            sid, title, time_, space, *flags = [x.strip() for x in head[len("Solution:"):].split(" · ")]
            p["solutions"].append({"id": sid, "title": title, "time": time_, "space": space,
                                   **{f: True for f in flags}})
            code = blocks[-1]
            p["code"][sid] = code
            p["notes"][sid] = text[: text.rindex("```python\n" + code)].strip()
    return p


def parse_example(example, params):
    return [json.loads(line) for line in example.split("\n")[: len(params)]]


class ListNode:
    def __init__(self, val=0, next=None):
        self.val, self.next = val, next


class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val, self.left, self.right = val, left, right


def to_list_node(vals):
    head = cur = ListNode()
    for v in vals:
        cur.next = ListNode(v)
        cur = cur.next
    return head.next


def from_list_node(node):
    out = []
    while node and len(out) < 100_000:
        out.append(node.val)
        node = node.next
    return out


def to_tree(vals):
    if not vals or vals[0] is None:
        return None
    root = TreeNode(vals[0])
    q, i = deque([root]), 1
    while q and i < len(vals):
        n = q.popleft()
        for side in ("left", "right"):
            if i < len(vals) and vals[i] is not None:
                setattr(n, side, TreeNode(vals[i]))
                q.append(getattr(n, side))
            i += 1
    return root


def from_tree(root):
    out, q = [], deque([root])
    while q:
        n = q.popleft()
        out.append(n.val if n else None)
        if n:
            q += [n.left, n.right]
    while out and out[-1] is None:
        out.pop()
    return out


def to_input(v, t):
    if t == "ListNode":
        return to_list_node(v)
    if t == "ListNode[]":
        return [to_list_node(x) for x in v]
    if t == "TreeNode":
        return to_tree(v)
    return copy.deepcopy(v)


def to_output(v, t):
    if t == "ListNode":
        return from_list_node(v)
    if t == "TreeNode":
        return from_tree(v)
    return v


def load_solution(code, entry):
    name = entry["method"] if entry.get("design") else "Solution"
    ns = {"ListNode": ListNode, "TreeNode": TreeNode}
    # same names LeetCode's Python 3 environment pre-imports
    exec("from typing import *\nimport collections, heapq, bisect, math, itertools, functools, operator, string, re\n"
         "from collections import *\nfrom functools import *\nfrom heapq import *\nfrom bisect import *\n"
         "from math import *\nfrom itertools import *\nfrom operator import *\nfrom string import *\nfrom random import *\n", ns)
    exec(code, ns)
    if name not in ns:
        raise ValueError(f"No `class {name}` found")
    return ns[name]


def load_hooks(problem):
    """`# Tests` code doubles as judge hooks (only loaded for compare "check" or entry.interactive):
    check(args, got, expected) -> bool          custom answer check
    prepare(args) -> (call_args, globals)       build the real call args (cycles, shared nodes, APIs like
                                                isBadVersion); globals are injected for the solution
    output(ret) -> json-able                    optional: turn the return value into something comparable"""
    if problem["judge"]["compare"] != "check" and not problem["entry"].get("interactive"):
        return {}
    ns = {"ListNode": ListNode, "TreeNode": TreeNode, "to_list_node": to_list_node, "to_tree": to_tree,
          "from_list_node": from_list_node, "from_tree": from_tree}
    exec(problem["gen"], ns)
    return ns


def call(sol_cls, entry, args, hooks=None):
    if entry.get("interactive"):
        ins, inject = hooks["prepare"](copy.deepcopy(args))
        getattr(sol_cls, entry["method"]).__globals__.update(inject)
        ret = getattr(sol_cls(), entry["method"])(*ins)
        return hooks["output"](ret) if "output" in hooks else to_output(ret, entry["returns"])
    if entry.get("design"):  # LeetCode design format: ["Cls", "op", ...], [[ctor args], [op args], ...]
        ops, argss = copy.deepcopy(args)
        obj = sol_cls(*argss[0])
        voids = set(entry.get("voids", []))
        out = [None]
        for op, a in zip(ops[1:], argss[1:]):
            r = getattr(obj, op)(*a)
            out.append(None if op in voids else r)
        return out
    ins = [to_input(a, p["type"]) for a, p in zip(args, entry["params"])]
    ret = getattr(sol_cls(), entry["method"])(*ins)
    if "outputParam" in entry:
        i = entry["outputParam"]
        out = to_output(ins[i], entry["params"][i]["type"])
        if entry.get("kPrefix"):  # return value k = length of the kept prefix; order inside it is free unless "ordered"
            if not (isinstance(ret, int) and 0 <= ret <= len(out)):
                return None
            return out[:ret] if entry["kPrefix"] == "ordered" else sorted(out[:ret])
        return out
    return to_output(ret, entry["returns"])


def same(got, exp, mode, args=None, hooks=None):
    if mode == "check":
        try:
            return bool(hooks["check"](copy.deepcopy(args), got, exp))
        except Exception:
            return False
    if mode == "float":
        try:
            if isinstance(exp, list):
                return len(got) == len(exp) and all(g == e or math.isclose(g, e, rel_tol=1e-5, abs_tol=1e-5) for g, e in zip(got, exp))
            return math.isclose(got, exp, rel_tol=1e-5, abs_tol=1e-5)
        except TypeError:
            return False
    if mode == "unordered":
        try:
            return sorted(map(json.dumps, got)) == sorted(map(json.dumps, exp))
        except TypeError:
            return False
    if mode == "groups":  # list of lists, order free at both levels
        try:
            return sorted(json.dumps(sorted(g)) for g in got) == sorted(json.dumps(sorted(g)) for g in exp)
        except TypeError:
            return False
    return got == exp


def show(v, limit=300):
    s = json.dumps(v)
    if len(s) > limit:
        size = f" (len {len(v)})" if isinstance(v, (list, str)) else ""
        s = s[:limit] + "…" + size
    return s


def run_one(sol_cls, entry, args, limit_ms, hooks=None):
    buf = io.StringIO()
    signal.signal(signal.SIGALRM, _alarm)
    signal.setitimer(signal.ITIMER_REAL, limit_ms / 1000)
    t0 = time.perf_counter()
    try:
        with redirect_stdout(buf):
            got = call(sol_cls, entry, args, hooks)
        err = None
    except TLE:
        got, err = None, "TLE"
    except Exception:
        got, err = None, traceback.format_exc(limit=-3)
    finally:
        signal.setitimer(signal.ITIMER_REAL, 0)
    return got, err, round((time.perf_counter() - t0) * 1000, 2), buf.getvalue()[:2000]


def judge(code, problem, tests, stop_on_fail):
    try:
        sol_cls = load_solution(code, problem["entry"])
    except Exception:
        return {"verdict": "Compile Error", "passed": 0, "total": len(tests), "results": [],
                "error": traceback.format_exc(limit=-2)}
    entry, j = problem["entry"], problem["judge"]
    hooks = load_hooks(problem)
    results, passed, verdict = [], 0, "Accepted"
    for i, t in enumerate(tests):
        got, err, ms, out = run_one(sol_cls, entry, t["args"], j["timeLimitMs"], hooks)
        if err == "TLE":
            v = "Time Limit Exceeded"
        elif err:
            v = "Runtime Error"
        elif "expected" not in t:
            v = "Ran"  # custom input: no expected answer
        elif same(got, t["expected"], j["compare"], t["args"], hooks):
            v = "Accepted"
        else:
            v = "Wrong Answer"
        ok = v in ("Accepted", "Ran")
        passed += ok
        results.append({"i": i, "kind": t.get("kind", "custom"), "verdict": v, "ms": ms, "stdout": out,
                        "input": [show(a) for a in t["args"]], "expected": show(t["expected"]) if "expected" in t else None,
                        "got": show(got) if not err else None, "error": err if err != "TLE" else None})
        if not ok and verdict == "Accepted":
            verdict = v
            if stop_on_fail:
                break
    return {"verdict": verdict, "passed": passed, "total": len(tests), "results": results}


def main():
    req = json.load(sys.stdin)
    pdir = Path(req["problemDir"])
    problem = load_problem(pdir)
    tests = json.loads((pdir / "tests.json").read_text())["tests"]
    if req["mode"] == "run":
        tests = [t for t in tests if t["kind"] == "example"]
        for c in req.get("custom") or []:
            tests.append({"args": parse_example(c, problem["entry"]["params"]), "kind": "custom"})
        res = judge(req["code"], problem, tests, stop_on_fail=False)
    else:
        res = judge(req["code"], problem, tests, stop_on_fail=True)
        # only return the failing test (or nothing) + counts, like LeetCode
        res["slowestMs"] = max((r["ms"] for r in res["results"]), default=0)
        res["results"] = [r for r in res["results"] if r["verdict"] != "Accepted"]
    print(json.dumps(res))


if __name__ == "__main__":
    main()
