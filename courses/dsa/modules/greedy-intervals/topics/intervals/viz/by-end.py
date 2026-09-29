import json
iv = [[1, 3], [2, 4], [3, 5], [1, 8], [6, 7]]
W = 9
iv.sort(key=lambda x: x[1])
rows = lambda: [["█" if a <= t < b else "" for t in range(W)] for a, b in iv]
steps = [{"compact": True, "grid": rows(), "highlight": [], "vars": {"sorted by end": iv},
          "caption": "Non-overlapping intervals: keep as many as possible (= remove as few as possible). Sort by END; the interval that finishes first leaves the most room."}]
end, kept, removed = float("-inf"), [], []
for k, (a, b) in enumerate(iv):
    if a >= end:
        kept.append(k); end = b
        cap = f"[{a},{b}) starts at or after the last kept end: keep it. New end = {b}."
    else:
        removed.append(k)
        cap = f"[{a},{b}) overlaps the last kept interval (ends at {end}): remove it."
    steps.append({"compact": True, "grid": rows(), "highlight": [[r, t] for r in kept for t in range(iv[r][0], iv[r][1])], "dim": [[r, t] for r in removed for t in range(W)],
                  "vars": {"kept": len(kept), "removed": len(removed)}, "caption": cap})
steps.append({"compact": True, "grid": rows(), "highlight": [[r, t] for r in kept for t in range(iv[r][0], iv[r][1])], "vars": {"answer (removed)": len(removed)},
              "caption": f"Remove {len(removed)}. The same sort-by-end greedy counts arrows for balloons and meeting rooms you can attend."})
print(json.dumps({"title": "Sort by end: keep the one that finishes first", "view": "grid", "steps": steps}))
