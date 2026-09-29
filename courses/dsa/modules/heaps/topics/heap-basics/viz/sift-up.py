import json, sys, heapq
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[5]))
from vizlib import build, nodes

h = [2, 5, 3, 8, 9, 6]
steps = [{"nodes": nodes(build(h)), "highlight": [], "vars": {"array": h[:]},
          "caption": "A min-heap: every parent ≤ its children, so the minimum is at the root. It's stored in an array: children of i are 2i+1 and 2i+2."}]
h.append(1)
i = len(h) - 1
steps.append({"nodes": nodes(build(h)), "active": f"n{i}", "vars": {"array": h[:]},
              "caption": "push(1): put it at the next free slot (the end of the array), keeping the tree complete."})
while i and h[(i - 1) // 2] > h[i]:
    p = (i - 1) // 2
    h[i], h[p] = h[p], h[i]
    steps.append({"nodes": nodes(build(h)), "active": f"n{p}", "vars": {"array": h[:]},
                  "caption": f"{h[p]} < its parent {h[i]}: swap them (sift up). Parent of index {i} is ({i} − 1) // 2 = {p}."})
    i = p
steps.append({"nodes": nodes(build(h)), "highlight": ["n0"], "vars": {"array": h[:]},
              "caption": "Heap order restored. At most one swap per level: O(log n)."})
print(json.dumps({"title": "Push: add at the end, sift up", "view": "tree", "steps": steps}))
