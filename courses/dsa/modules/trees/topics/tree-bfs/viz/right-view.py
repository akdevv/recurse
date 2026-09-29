import json, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[5]))
from vizlib import build, nodes, all_nodes, N

root = build([1, 2, 3, None, 5, None, 4, 7])
from collections import deque
q, view, steps = deque([root]), [], []
steps.append({"nodes": nodes(root), "highlight": [], "vars": {"view": []}, "caption": "Right side view: standing on the right you see the LAST node of every level."})
while q:
    size = len(q)
    for k in range(size):
        n = q.popleft()
        if k == size - 1:
            view.append(n.val)
            last = n
        q.extend(c for c in (n.left, n.right) if c)
    steps.append({"nodes": nodes(root), "highlight": [x.id for x in all_nodes(root) if x.val in view], "active": last.id, "vars": {"view": view[:]},
                  "caption": f"Last node of this level: {last.val}. Note it can come from a left subtree when the right side is shorter."})
print(json.dumps({"title": "Right side view: last node per level", "view": "tree", "steps": steps}))
