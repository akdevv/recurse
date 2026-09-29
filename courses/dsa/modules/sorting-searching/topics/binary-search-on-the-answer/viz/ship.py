import json

w, days = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 5
def split(cap):
    groups, cur = [[]], 0
    for x in w:
        if cur + x > cap:
            groups.append([]); cur = 0
        groups[-1].append(x); cur += x
    return groups
steps = []
lo, hi = max(w), sum(w)
steps.append({"array": w, "pointers": {}, "highlight": [], "vars": {"days": days, "search range": f"[{lo}, {hi}]"},
              "caption": f"Ship packages in order within {days} days. Capacity is at least the heaviest package ({lo}) and at most everything at once ({hi})."})
while lo < hi:
    mid = (lo + hi) // 2
    g = split(mid)
    steps.append({"array": w, "pointers": {}, "highlight": [i for i, x in enumerate(w) if any(x in grp for grp in g[::2])],
                  "vars": {"capacity": mid, "days used": len(g), "loads": [sum(x) for x in g]},
                  "caption": f"Capacity {mid}: fill each day greedily → {len(g)} days. {'Fits: try smaller.' if len(g) <= days else 'Too many days: need more capacity.'}"})
    if len(g) <= days:
        hi = mid
    else:
        lo = mid + 1
steps.append({"array": w, "pointers": {}, "highlight": [], "vars": {"answer": lo, "loads": [sum(x) for x in split(lo)]},
              "caption": f"Smallest capacity that works: {lo}. The check is a greedy O(n) pass; binary search calls it O(log(sum)) times."})
print(json.dumps({"title": "Guess a capacity, check it greedily, binary search the guess", "view": "array", "steps": steps}))
