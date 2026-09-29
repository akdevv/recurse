import json, sys, heapq
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[5]))
from vizlib import build, nodes

lists = [[1, 4, 7], [2, 5], [3, 6, 9]]
h = [(l[0], i, 0) for i, l in enumerate(lists)]
heapq.heapify(h)
out = []
steps = [{"array": [], "pointers": {}, "highlight": [], "vars": {"lists": lists, "heap": sorted(v for v, _, _ in h)},
          "caption": "Merge k sorted lists: the next output value is the smallest current head. A min-heap holds one head per list."}]
while h:
    v, i, j = heapq.heappop(h)
    out.append(v)
    nxt = ""
    if j + 1 < len(lists[i]):
        heapq.heappush(h, (lists[i][j + 1], i, j + 1))
        nxt = f" Push list {i}'s next value ({lists[i][j + 1]})."
    steps.append({"array": out[:], "pointers": {}, "highlight": [len(out) - 1], "vars": {"heap": sorted(x for x, _, _ in h)},
                  "caption": f"Pop {v} (from list {i}) and append it.{nxt}"})
steps.append({"array": out, "pointers": {}, "highlight": [], "vars": {},
              "caption": "The heap never holds more than k items: O(N log k) for N total values."})
print(json.dumps({"title": "K-way merge with a min-heap", "view": "array", "steps": steps}))
