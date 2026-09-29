"""Test inputs for problems with an empty `# Tests` block, from `entry` types + the **Constraints:** list.

Raises Manual when a constraint isn't understood or promises structure (sorted, unique, BST, valid, …).
"""
import random, re
from types import SimpleNamespace

SUPS = str.maketrans("⁰¹²³⁴⁵⁶⁷⁸⁹⁻", "0123456789-")
SPECIAL = re.compile(r"sorted|increasing|decreasing|unique|distinct|guarantee|exactly|permutation|valid|"
                     r"at most one|binary search tree|BST|connected|edge|cycle|pos\b|sum of|rotated|palindrome|"
                     r"only one|no two|there is|there are|appear|at least|answer|pairs|each|all the|"
                     r"will|intersect|subset|not |is a |are |ith|sum\(", re.I)
CHARSETS = [("lowercase English letter", "abcdefghijklmnopqrstuvwxyz"),
            ("uppercase English letter", "ABCDEFGHIJKLMNOPQRSTUVWXYZ"),
            ("English letter", "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"),
            ("digits", "0123456789"),
            ("printable ASCII", "".join(chr(c) for c in range(32, 127)))]
TOTAL_CAP = 100_000


class Manual(Exception):
    pass


def num(expr, env):
    """'-10⁴', '2³¹ - 1', '5 * 10⁴', 'nums.length', 'min(50, nums.length)' → int."""
    e = re.sub(r"(\d+)([⁰¹²³⁴⁵⁶⁷⁸⁹]+)", lambda m: f"({m[1]}**{m[2].translate(SUPS)})", norm(expr.strip()))
    for k in sorted(env, key=len, reverse=True):
        e = re.sub(r"(?<![\w.])" + re.escape(k) + r"(?![\w.\[])", f"({env[k]})", e)
    if not re.fullmatch(r"(?:[\d\s()*+\-/,]|min|max)+", e):
        raise Manual(f"can't evaluate {expr!r}")
    return int(eval(e))


def norm(v):
    """grid[r][c] → grid[i][j], nums[k] → nums[i], so lookups don't depend on the index letter."""
    v = re.sub(r"(\w)\[\w+\]\[\w+\]", r"\1[i][j]", v)
    return re.sub(r"(\w)\[(?!i\]\[j\])\w+\]", r"\1[i]", v)


def constraint_lines(stmt):
    if "**Constraints:**" not in stmt:
        raise Manual("no constraints section")
    out = []
    for line in stmt.split("**Constraints:**")[1].strip().split("\n"):
        if not line.startswith("- "):
            break
        out.append(line[2:].replace("`", "").replace("&lt;", "<").replace("**", "").strip().rstrip("."))
    return out


def parse(p):
    """→ bounds {var: [(lo_exprs, hi_exprs)]}, aliases {name: var}, charset or None."""
    body = p["statement"].split("**Constraints:**")[0]
    if re.search(r"\bsorted\b|non-decreasing|strictly increasing|ascending order", body, re.I):
        raise Manual("statement promises sorted input")
    if re.search(r"binary search tree|\bBST\b", body, re.I):
        raise Manual("statement promises a BST")
    bounds, alias, charset = {}, {}, None
    for plain in constraint_lines(p["statement"]):
        cs = [c for name, c in CHARSETS if name.lower() in plain.lower()]
        rng_q = re.search(r"in the range \['(.)', '(.)'\]", plain)
        quoted = "".join(re.findall(r"'([^']+)'", plain)) if not rng_q else \
            "".join(chr(c) for c in range(ord(rng_q[1]), ord(rng_q[2]) + 1))
        if (cs or quoted) and re.search(r"\b(only|consists?|either|is|are)\b", plain) and "<=" not in plain \
                and not SPECIAL.search(re.sub(r"consists? (only )?of|is (either )?(a |an )?|are |only", "", plain)):
            charset = "".join(dict.fromkeys((charset or "") + "".join(cs) + quoted))
            continue
        m = re.fullmatch(r"([\w.\[\]]+) is (?:either )?(-?\d+) or (-?\d+)", plain)
        if m and abs(int(m[3]) - int(m[2])) == 1:
            bounds[norm(m[1])] = [([m[2]], [m[3]])]
            continue
        m = re.fullmatch(r"The number of (?:the )?nodes (?:in|of) .*?(?:is )?(?:in )?the range \[(.+?), (.+?)\]", plain)
        if m:
            bounds["#nodes"] = [([m[1]], [m[2]])]
            continue
        m = re.fullmatch(r"The number of (?:the )?nodes in the (?:tree|list) is (\w+)", plain)
        if m:
            alias[m[1]] = "#nodes"
            continue
        m = re.fullmatch(r"[\w.\[\]]+(?: ==? [\w.\[\]]+)+", plain)
        if m:
            names = [norm(x) for x in re.split(r" ==? ", plain)]
            for a in names[:-1]:
                alias[a] = names[-1]
            continue
        terms = [norm(t.strip()) for t in re.split(r"<=|(?<!<)<(?!=)", plain)]
        strict = [x.strip() == "<" for x in re.findall(r"<=|<", plain)]
        if len(terms) >= 3 and not SPECIAL.search(plain):
            for i in range(1, len(terms) - 1):
                lo_adj = " + 1" if strict[i - 1] else ""
                hi_adj = " - 1" if strict[i] else ""
                los = [terms[i - 1] + lo_adj] + ([terms[0]] if i > 1 else [])
                his = [terms[i + 1] + hi_adj] + ([terms[-1]] if i < len(terms) - 2 else [])
                for v in terms[i].split(","):
                    bounds.setdefault(v.strip(), []).append((los, his))
            continue
        raise Manual(f"constraint not understood: {plain!r}")
    return bounds, alias, charset


class Gen:
    def __init__(self, p):
        e = p["entry"]
        if e.get("design") or e.get("interactive") or p["judge"]["compare"] == "check":
            raise Manual("design / interactive / custom-check problem")
        self.params = e["params"]
        self.bounds, self.alias, self.charset = parse(p)
        for prm in self.params:
            t = prm["type"]
            if t not in ("integer", "integer[]", "integer[][]", "string", "string[]", "character[][]",
                         "boolean", "TreeNode", "ListNode", "long", "double"):
                raise Manual(f"type {t}")
            if t in ("string", "string[]", "character[][]") and self.charset is None:
                raise Manual(f"no charset for {prm['name']}")

    def rng_of(self, names, env):
        for n in names:
            for key in (n, *[a for a, b in self.alias.items() if b == n]):
                for los, his in self.bounds.get(key, []):
                    lo = next((v for v in (self.try_num(x, env) for x in los) if v is not None), None)
                    hi = next((v for v in (self.try_num(x, env) for x in his) if v is not None), None)
                    if lo is not None and hi is not None:
                        return lo, hi
        raise Manual(f"no range for {names}")

    @staticmethod
    def try_num(x, env):
        try:
            return num(x, env)
        except Manual:
            return None

    def setv(self, env, key, val):
        env[key] = val
        for a, b in self.alias.items():
            if b == key:
                env[a] = val

    def make(self, rng, mode):
        env, args = {}, {}
        # containers first: their sizes can bound scalars (1 <= k <= nums.length)
        order = sorted(self.params, key=lambda q: q["type"] in ("integer", "long", "double", "boolean"))
        for prm in order:
            n, t = prm["name"], prm["type"]
            if t in ("integer", "long", "double"):
                lo, hi = self.rng_of([n], env)
                args[n] = self.pick(rng, lo, hi, mode)
                self.setv(env, n, args[n])
            elif t == "boolean":
                args[n] = rng.random() < 0.5
            elif t in ("integer[]", "string", "string[]"):
                llo, lhi = self.rng_of([f"{n}.length"], env)
                size = self.size(rng, llo, lhi, mode)
                self.setv(env, f"{n}.length", size)
                if t == "integer[]":
                    vlo, vhi = self.rng_of([f"{n}[i]"], env)
                    args[n] = [self.pick(rng, vlo, vhi, mode) for _ in range(size)]
                elif t == "string":
                    args[n] = "".join(self.char(rng, mode) for _ in range(size))
                else:
                    wlo, whi = self.rng_of([f"{n}[i].length"], env)
                    args[n] = ["".join(self.char(rng, mode) for _ in range(self.size(rng, wlo, whi, mode, cap=20)))
                               for _ in range(size)]
            elif t in ("integer[][]", "character[][]"):
                rlo, rhi = self.rng_of([f"{n}.length"], env)
                clo, chi = self.rng_of([f"{n}[i].length"], env)
                r = self.size(rng, rlo, rhi, mode, cap=int(TOTAL_CAP ** 0.5))
                c = self.size(rng, clo, chi, mode, cap=int(TOTAL_CAP ** 0.5))
                self.setv(env, f"{n}.length", r)
                self.setv(env, f"{n}[i].length", c)
                if t == "integer[][]":
                    vlo, vhi = self.rng_of([f"{n}[i][j]"], env)
                    args[n] = [[self.pick(rng, vlo, vhi, mode) for _ in range(c)] for _ in range(r)]
                else:
                    args[n] = [[self.char(rng, mode) for _ in range(c)] for _ in range(r)]
            else:  # TreeNode / ListNode
                llo, lhi = self.rng_of(["#nodes"], env)
                size = self.size(rng, llo, lhi, mode)
                self.setv(env, "#nodes", size)
                vlo, vhi = self.rng_of(["Node.val", "node.val"], env)
                vals = [self.pick(rng, vlo, vhi, mode) for _ in range(size)]
                args[n] = vals if t == "ListNode" else self.tree(rng, vals, mode)
        return [args[q["name"]] for q in self.params]

    @staticmethod
    def tree(rng, vals, mode):
        """Random shape in LeetCode level-order form (None = missing child)."""
        if not vals:
            return []
        out, slots, i = [vals[0]], 2, 1
        while i < len(vals):
            if mode != "perf" and slots > 1 and rng.random() < 0.3:
                out.append(None)
                slots -= 1
            else:
                out.append(vals[i])
                i += 1
                slots += 1
        while out and out[-1] is None:
            out.pop()
        return out

    @staticmethod
    def size(rng, lo, hi, mode, cap=TOTAL_CAP):
        hi = min(hi, cap)
        if mode == "min":
            return lo
        if mode == "perf":
            return hi
        return rng.randint(lo, max(lo, min(hi, lo + 8)))

    @staticmethod
    def pick(rng, lo, hi, mode):
        if mode == "min":
            return lo
        if mode == "max":
            return hi
        if mode == "same":
            return (lo + hi) // 2
        if mode == "perf":
            return rng.randint(lo, hi)
        small_lo, small_hi = max(lo, -10), min(hi, 10)
        return rng.randint(small_lo, small_hi) if small_lo <= small_hi else rng.randint(lo, min(hi, lo + 20))

    def char(self, rng, mode):
        cs = self.charset
        if mode in ("min", "same"):
            return cs[0]
        if mode == "max":
            return cs[-1]
        return rng.choice(cs if mode == "perf" else cs[:4] if len(cs) > 4 else cs)


def make(p):
    """edge / random_case / perf for problem dict p, like a handwritten `# Tests` block."""
    g = Gen(p)
    fixed = random.Random(0)
    edge = [g.make(fixed, m) for m in ("min", "max", "same")]
    g.make(random.Random(1), "random")  # raise Manual now, not mid-generation
    return SimpleNamespace(edge=lambda: edge, random_case=lambda rng: g.make(rng, "random"),
                           perf=lambda rng: [g.make(rng, "perf")])
