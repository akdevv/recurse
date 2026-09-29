import json, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[5]))
from vizlib import build, nodes, all_nodes, N

root = build([3, 9, 20, None, None, 15, 7])
vals, steps = {}, []
steps.append({"nodes": nodes(root), "values": {}, "caption": "Max depth: ask each child for its depth, answer 1 + the larger one. An empty child answers 0."})
def depth(n):
    if not n:
        return 0
    steps.append({"nodes": nodes(root), "active": n.id, "values": dict(vals), "caption": f"depth({n.val}): need both children's answers first."})
    l, r = depth(n.left), depth(n.right)
    vals[n.id] = 1 + max(l, r)
    steps.append({"nodes": nodes(root), "active": n.id, "values": dict(vals), "caption": f"depth({n.val}) = 1 + max({l}, {r}) = {vals[n.id]}."})
    return vals[n.id]
d = depth(root)
steps.append({"nodes": nodes(root), "values": dict(vals), "caption": f"The root's answer is the tree's depth: {d}. Every node is visited once: O(n)."})
print(json.dumps({"title": "\"Ask the children, combine\": max depth", "view": "tree", "steps": steps}))
