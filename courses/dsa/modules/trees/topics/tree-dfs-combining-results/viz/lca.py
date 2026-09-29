import json, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[5]))
from vizlib import build, nodes, all_nodes, N

root = build([3, 5, 1, 6, 2, 0, 8, None, None, 7, 4])
p, q = 7, 8
vals, steps = {}, []
steps.append({"nodes": nodes(root), "values": {}, "caption": f"Lowest common ancestor of {p} and {q}. Each call reports up: \"I found p or q\" (the node) or nothing."})
ans = [None]
def lca(n):
    if not n:
        return None
    if n.val in (p, q):
        vals[n.id] = "found"
        steps.append({"nodes": nodes(root), "active": n.id, "values": dict(vals), "caption": f"{n.val} is one of the targets: return it upward."})
        return n
    l, r = lca(n.left), lca(n.right)
    if l and r:
        vals[n.id] = "LCA"
        ans[0] = n
        steps.append({"nodes": nodes(root), "active": n.id, "values": dict(vals), "caption": f"At {n.val}: a target came back from BOTH sides. The paths split here, so {n.val} is the LCA."})
        return n
    res = l or r
    if res:
        vals[n.id] = "↑"
        steps.append({"nodes": nodes(root), "active": n.id, "values": dict(vals), "caption": f"At {n.val}: only one side found something. Pass it up."})
    return res
lca(root)
steps.append({"nodes": nodes(root), "highlight": [ans[0].id], "values": dict(vals), "caption": f"Answer {ans[0].val}. One postorder pass: O(n)."})
print(json.dumps({"title": "Lowest common ancestor: results bubble up", "view": "tree", "steps": steps}))
