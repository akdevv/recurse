import json, sys, heapq
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[5]))
from vizlib import build, nodes

stream, k = [3, 1, 5, 12, 2, 11, 7], 3
h = []
steps = [{"nodes": [], "vars": {"k": k}, "caption": f"k-th largest with a MIN-heap of size {k}: it holds the {k} largest values so far, and its root is the smallest of them = the answer."}]
for x in stream:
    heapq.heappush(h, x)
    cap = f"Push {x}."
    if len(h) > k:
        out = heapq.heappop(h)
        cap += f" Heap has {k + 1} values: pop the smallest ({out}). It can't be in the top {k}."
    steps.append({"nodes": nodes(build(h)), "highlight": ["n0"] if len(h) == k else [], "vars": {"heap": sorted(h), f"{k}-th largest": h[0] if len(h) == k else "-"}, "caption": cap})
steps.append({"nodes": nodes(build(h)), "highlight": ["n0"], "vars": {"answer": h[0]},
              "caption": f"Answer {h[0]}. Each push/pop is O(log k): O(n log k) total, O(k) memory. Sorting would be O(n log n)."})
print(json.dumps({"title": "Top k with a size-k min-heap", "view": "tree", "steps": steps}))
