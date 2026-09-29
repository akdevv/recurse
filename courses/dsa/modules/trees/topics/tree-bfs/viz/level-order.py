import json, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[5]))
from vizlib import build, nodes, all_nodes, N

root = build([3, 9, 20, None, None, 15, 7])
from collections import deque
q, levels, steps = deque([root]), [], []
steps.append({"nodes": nodes(root), "highlight": [], "vars": {"queue": [3], "levels": []}, "caption": "Level order: a queue holds the next level. Its length at the start of a round = how many nodes are on this level."})
seen = []
while q:
    size = len(q)
    level = []
    for _ in range(size):
        n = q.popleft()
        level.append(n.val)
        seen.append(n.id)
        q.extend(c for c in (n.left, n.right) if c)
    levels.append(level)
    steps.append({"nodes": nodes(root), "highlight": list(seen), "vars": {"this level": level, "queue": [n.val for n in q], "levels": [l[:] for l in levels]},
                  "caption": f"Take exactly {size} node(s) from the queue: {level}. Their children join the queue for the next round."})
steps.append({"nodes": nodes(root), "highlight": list(seen), "vars": {"levels": levels}, "caption": "Queue empty: every level recorded. O(n) time, O(width) queue space."})
print(json.dumps({"title": "Breadth-first: one level per round", "view": "tree", "steps": steps}))
