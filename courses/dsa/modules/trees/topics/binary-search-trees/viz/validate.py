import json, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[5]))
from vizlib import build, nodes, all_nodes, N

root = build([5, 3, 8, 1, 4, 6, 9, None, None, None, None, 2])
vals, steps = {}, []
steps.append({"nodes": nodes(root), "values": {}, "caption": "Validate a BST: every node must fit in a (low, high) range inherited from ALL its ancestors, not just its parent."})
bad = [None]
def ok(n, lo, hi):
    if not n or bad[0]:
        return True
    rng = f"({'-∞' if lo is None else lo}, {'∞' if hi is None else hi})"
    fits = (lo is None or lo < n.val) and (hi is None or n.val < hi)
    vals[n.id] = "✓" if fits else "✗"
    steps.append({"nodes": nodes(root), "active": n.id, "values": dict(vals), "vars": {"allowed": rng},
                  "caption": f"{n.val} must be in {rng}: " + (f"fits. Its left child gets high = {n.val}, its right child gets low = {n.val}." if fits else "it doesn't fit, because an ancestor forbids it. Not a BST.")})
    if not fits:
        bad[0] = n
        return False
    return ok(n.left, lo, n.val) and ok(n.right, n.val, hi)
ok(root, None, None)
steps.append({"nodes": nodes(root), "values": dict(vals), "highlight": [bad[0].id] if bad[0] else [],
              "caption": "The 2 is fine compared with its parent 6, but it's in 5's RIGHT subtree, so it must be > 5. Only the passed-down range catches that."})
print(json.dumps({"title": "Validate a BST with ranges passed down", "view": "tree", "steps": steps}))
