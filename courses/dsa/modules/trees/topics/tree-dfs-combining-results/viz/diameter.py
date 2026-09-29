import json, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[5]))
from vizlib import build, nodes, all_nodes, N

root = build([1, 2, 3, 4, 5, None, None, 8, None, None, 9])
vals, steps, best = {}, [], [0]
steps.append({"nodes": nodes(root), "values": {}, "vars": {"best": 0}, "caption": "Diameter: every path has one highest node where it turns. Through node x its length is height(left) + height(right)."})
def h(n):
    if not n:
        return 0
    l, r = h(n.left), h(n.right)
    through = l + r
    if through > best[0]:
        best[0] = through
    vals[n.id] = 1 + max(l, r)
    steps.append({"nodes": nodes(root), "active": n.id, "values": dict(vals), "vars": {"through here": f"{l} + {r} = {through}", "best": best[0]},
                  "caption": f"At {n.val}: left height {l}, right height {r}. A path turning here has {through} edges. Return height {vals[n.id]} to the parent."})
    return vals[n.id]
h(root)
steps.append({"nodes": nodes(root), "values": dict(vals), "vars": {"diameter": best[0]},
              "caption": f"The function RETURNS heights, but the answer ({best[0]}) is kept in a separate variable. That split is the whole pattern."})
print(json.dumps({"title": "Return one thing, track another: diameter", "view": "tree", "steps": steps}))
