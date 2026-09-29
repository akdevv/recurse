import json, sys, heapq
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[5]))
from vizlib import build, nodes

a = [3, 2, 1, 5, 6, 4]
k = 2
target = len(a) - k
lo, hi = 0, len(a) - 1
steps = [{"array": a[:], "pointers": {}, "highlight": [], "vars": {"k": k, "target index": target},
          "caption": f"Quickselect: the {k}nd largest is the value at index {target} in sorted order. Partition, then keep only the side that contains index {target}."}]
while True:
    pivot, i = a[hi], lo
    for j in range(lo, hi):
        if a[j] < pivot:
            a[i], a[j] = a[j], a[i]; i += 1
    a[i], a[hi] = a[hi], a[i]
    side = "found" if i == target else ("right" if i < target else "left")
    steps.append({"array": a[:], "pointers": {"pivot": i}, "highlight": [i], "dim": [x for x in range(len(a)) if x < lo or x > hi], "vars": {"pivot": pivot, "pivot index": i},
                  "caption": f"Partition [{lo}..{hi}] around {pivot}: it lands at index {i}. " + ({"found": "That's the target index. Done.", "right": f"Target {target} is to the right: drop the left side.", "left": f"Target {target} is to the left: drop the right side."}[side])})
    if i == target:
        break
    if i < target: lo = i + 1
    else: hi = i - 1
steps.append({"array": a[:], "pointers": {"answer": target}, "highlight": [target], "vars": {"answer": a[target]},
              "caption": f"Answer {a[target]}. One side per round: n + n/2 + n/4 … ≈ 2n → O(n) on average (O(n²) worst case)."})
print(json.dumps({"title": "Quickselect: partition, keep one side", "view": "array", "steps": steps}))
