import json

a = [29, 10, 14, 37, 13]
steps = [{"array": list(a), "pointers": {}, "highlight": [], "vars": {},
          "caption": "Selection sort: find the smallest remaining value and swap it into the next position."}]
for i in range(len(a) - 1):
    m = min(range(i, len(a)), key=lambda k: a[k])
    steps.append({"array": list(a), "pointers": {"i": i, "min": m}, "highlight": list(range(i)), "vars": {"smallest left": a[m]},
                  "caption": f"Scan indices {i}..{len(a) - 1}: the smallest is {a[m]} at index {m}."})
    a[i], a[m] = a[m], a[i]
    steps.append({"array": list(a), "pointers": {"i": i}, "highlight": list(range(i + 1)), "vars": {},
                  "caption": f"Swap it into index {i}. Positions 0..{i} are final."})
steps.append({"array": list(a), "pointers": {}, "highlight": list(range(len(a))), "vars": {},
              "caption": "Always n²/2 comparisons, even on sorted input, but at most n − 1 swaps."})
print(json.dumps({"title": "Selection sort: pick the minimum each round", "view": "array", "steps": steps}))
