import json, sys, heapq
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[5]))
from vizlib import build, nodes

h = [1, 5, 2, 8, 9, 6, 3]
steps = [{"nodes": nodes(build(h)), "highlight": ["n0"], "vars": {"array": h[:]}, "caption": "pop(): the minimum is the root. Removing it would leave a hole at the top."}]
top = h[0]
h[0] = h.pop()
steps.append({"nodes": nodes(build(h)), "active": "n0", "vars": {"array": h[:], "popped": top},
              "caption": f"Return {top}. Move the LAST element ({h[0]}) to the root, so the tree stays complete."})
i = 0
while True:
    l, r, s = 2 * i + 1, 2 * i + 2, i
    if l < len(h) and h[l] < h[s]: s = l
    if r < len(h) and h[r] < h[s]: s = r
    if s == i:
        break
    h[i], h[s] = h[s], h[i]
    steps.append({"nodes": nodes(build(h)), "active": f"n{s}", "vars": {"array": h[:]},
                  "caption": f"{h[s]} is bigger than its smaller child {h[i]}: swap with that child (sift down)."})
    i = s
steps.append({"nodes": nodes(build(h)), "highlight": ["n0"], "vars": {"array": h[:]},
              "caption": "Heap order restored, new minimum at the root. O(log n)."})
print(json.dumps({"title": "Pop: move the last element to the root, sift down", "view": "tree", "steps": steps}))
