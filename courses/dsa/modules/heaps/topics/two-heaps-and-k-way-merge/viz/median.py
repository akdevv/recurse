import json, sys, heapq
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[5]))
from vizlib import build, nodes

stream = [5, 15, 1, 3, 8]
lo, hi = [], []          # lo: max-heap (negated), hi: min-heap
seen = []
steps = [{"array": [], "pointers": {}, "highlight": [], "vars": {"lower (max-heap)": [], "upper (min-heap)": []},
          "caption": "Running median: keep the smaller half in a max-heap and the bigger half in a min-heap. The median sits at their tops."}]
for x in stream:
    heapq.heappush(lo, -x)
    heapq.heappush(hi, -heapq.heappop(lo))
    if len(hi) > len(lo):
        heapq.heappush(lo, -heapq.heappop(hi))
    seen.append(x)
    s = sorted(seen)
    med = -lo[0] if len(lo) > len(hi) else (-lo[0] + hi[0]) / 2
    n_lo = len(lo)
    steps.append({"array": s, "pointers": {"median": (len(s) - 1) // 2} if len(s) % 2 else {"mid": n_lo - 1, "mid+1": n_lo},
                  "highlight": list(range(n_lo)), "vars": {"lower (max-heap)": sorted(-v for v in lo), "upper (min-heap)": sorted(hi), "median": med},
                  "caption": f"Add {x}: push to lower, move lower's max to upper, rebalance so lower has the extra one. Median = " + (f"top of lower = {med}." if len(s) % 2 else f"average of both tops = {med}.")})
print(json.dumps({"title": "Two heaps: the running median", "view": "array", "steps": steps}))
