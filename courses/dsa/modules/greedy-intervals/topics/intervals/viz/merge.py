import json
iv = [[1, 3], [8, 10], [2, 6], [15, 18], [9, 11]]
W = 19
def bars(items, hl=()):
    return [["█" if a <= t <= b else "" for t in range(W)] for a, b in items]
steps = [{"compact": True, "grid": bars(iv), "highlight": [], "vars": {"intervals": iv}, "caption": "Each row is an interval on a timeline 0..18. Merge all the overlapping ones."}]
iv.sort()
steps.append({"compact": True, "grid": bars(iv), "highlight": [], "vars": {"sorted": iv}, "caption": "Sort by start. Now any interval that overlaps the merged ones must overlap the LAST merged interval."})
merged = []
for a, b in iv:
    if merged and a <= merged[-1][1]:
        old = merged[-1][:]
        merged[-1][1] = max(merged[-1][1], b)
        cap = f"[{a},{b}] starts at {a} ≤ {old[1]} (end of the last merged): overlap. Extend it to [{merged[-1][0]},{merged[-1][1]}]."
    else:
        merged.append([a, b])
        cap = f"[{a},{b}] starts after the last merged interval ends: start a new one."
    steps.append({"compact": True, "grid": bars(merged), "highlight": [[len(merged) - 1, t] for t in range(merged[-1][0], merged[-1][1] + 1)], "vars": {"merged": [m[:] for m in merged]}, "caption": cap})
steps.append({"compact": True, "grid": bars(merged), "highlight": [], "vars": {"answer": merged}, "caption": "O(n log n) for the sort, then one O(n) pass."})
print(json.dumps({"title": "Merge intervals: sort by start, extend or start new", "view": "grid", "steps": steps}))
