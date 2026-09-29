import json, math

piles, h = [3, 6, 7, 11], 8
speeds = list(range(1, 12))
ok = lambda k: sum(math.ceil(p / k) for p in piles) <= h
labels = ["?"] * len(speeds)
lo, hi = 1, 11
steps = [{"array": [f"{s}" for s in speeds], "pointers": {"lo": 0, "hi": 10}, "highlight": [], "vars": {"piles": piles, "hours": h},
          "caption": "Koko Eating Bananas. Don't search an array, search the ANSWER: speeds 1..max(piles). Question per speed: can she finish in h hours?"}]
while lo < hi:
    mid = (lo + hi) // 2
    hours = sum(math.ceil(p / mid) for p in piles)
    good = hours <= h
    for s in (range(mid, 12) if good else range(1, mid + 1)):
        labels[s - 1] = "✓" if good else "✗"
    steps.append({"array": [f"{s}{labels[s - 1]}" for s in speeds], "pointers": {"lo": lo - 1, "mid": mid - 1, "hi": hi - 1},
                  "highlight": [s - 1 for s in speeds if labels[s - 1] == "✓"], "dim": [s - 1 for s in speeds if labels[s - 1] == "✗"],
                  "vars": {"speed": mid, "hours needed": hours},
                  "caption": f"Speed {mid} needs {hours} hours: {'fits, so every faster speed fits too. Try slower: hi = mid.' if good else 'too slow, so every slower speed fails too. lo = mid + 1.'}"})
    if good:
        hi = mid
    else:
        lo = mid + 1
steps.append({"array": [f"{s}{labels[s - 1]}" for s in speeds], "pointers": {"answer": lo - 1}, "highlight": [lo - 1], "vars": {"answer": lo},
              "caption": f"The yes/no answers look like ✗✗✗…✓✓✓ (monotonic). Binary search found the first ✓: speed {lo}. O(n log max) checks."})
print(json.dumps({"title": "Binary search on the answer: find the first speed that works", "view": "array", "steps": steps}))
