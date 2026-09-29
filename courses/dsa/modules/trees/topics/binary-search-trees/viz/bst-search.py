import json, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[5]))
from vizlib import build, nodes, all_nodes, N

root = build([8, 3, 10, 1, 6, None, 14, None, None, 4, 7, 13])
t = 7
steps = [{"nodes": nodes(root), "highlight": [], "caption": f"Search {t} in a BST: smaller values live on the left, bigger on the right. One comparison picks the side."}]
n, path = root, []
while n:
    path.append(n.id)
    if n.val == t:
        steps.append({"nodes": nodes(root), "active": n.id, "highlight": path[:-1], "caption": f"{n.val} = {t}. Found after {len(path)} nodes, not all {len(all_nodes(root))}."})
        break
    go = "left" if t < n.val else "right"
    steps.append({"nodes": nodes(root), "active": n.id, "highlight": path[:-1], "caption": f"{t} {'<' if t < n.val else '>'} {n.val}: go {go}. The whole other subtree is skipped."})
    n = n.left if t < n.val else n.right
print(json.dumps({"title": "BST search: O(height)", "view": "tree", "steps": steps}))
