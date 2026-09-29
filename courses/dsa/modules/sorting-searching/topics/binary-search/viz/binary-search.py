import json

a = [2, 5, 8, 12, 16, 23, 38, 56, 72, 91]
t = 23
lo, hi = 0, len(a) - 1
steps = [{"array": a, "pointers": {"lo": lo, "hi": hi}, "highlight": [], "vars": {"target": t},
          "caption": f"Find {t} in a sorted array. Look at the middle; one comparison discards half the range."}]
while lo <= hi:
    mid = (lo + hi) // 2
    dim = [k for k in range(len(a)) if k < lo or k > hi]
    if a[mid] == t:
        steps.append({"array": a, "pointers": {"lo": lo, "mid": mid, "hi": hi}, "highlight": [mid], "dim": dim, "vars": {"a[mid]": a[mid]},
                      "caption": f"a[{mid}] = {t}. Found in {len(steps)} looks instead of up to {len(a)}."})
        break
    if a[mid] < t:
        steps.append({"array": a, "pointers": {"lo": lo, "mid": mid, "hi": hi}, "highlight": [mid], "dim": dim, "vars": {"a[mid]": a[mid]},
                      "caption": f"a[{mid}] = {a[mid]} < {t}: the target must be to the right. lo = mid + 1."})
        lo = mid + 1
    else:
        steps.append({"array": a, "pointers": {"lo": lo, "mid": mid, "hi": hi}, "highlight": [mid], "dim": dim, "vars": {"a[mid]": a[mid]},
                      "caption": f"a[{mid}] = {a[mid]} > {t}: the target must be to the left. hi = mid − 1."})
        hi = mid - 1
print(json.dumps({"title": "Binary search: halve the range every step", "view": "array", "steps": steps}))
