import json

a = [15, 18, 22, 3, 6, 9, 12]
t = 6
lo, hi = 0, len(a) - 1
steps = [{"array": a, "pointers": {"lo": lo, "hi": hi}, "highlight": [], "vars": {"target": t},
          "caption": f"A sorted array rotated at some point. Search {t}. Key fact: around any mid, at least one half is sorted normally."}]
while lo <= hi:
    mid = (lo + hi) // 2
    dim = [k for k in range(len(a)) if k < lo or k > hi]
    if a[mid] == t:
        steps.append({"array": a, "pointers": {"lo": lo, "mid": mid, "hi": hi}, "highlight": [mid], "dim": dim, "vars": {}, "caption": f"a[{mid}] = {t}. Found."})
        break
    if a[lo] <= a[mid]:
        inside = a[lo] <= t < a[mid]
        steps.append({"array": a, "pointers": {"lo": lo, "mid": mid, "hi": hi}, "highlight": list(range(lo, mid + 1)), "dim": dim, "vars": {"sorted half": f"{a[lo]}..{a[mid]}"},
                      "caption": f"a[lo] ≤ a[mid], so the LEFT half {a[lo]}..{a[mid]} is sorted. Is {t} inside it? {'Yes: go left.' if inside else 'No: go right.'}"})
        if inside:
            hi = mid - 1
        else:
            lo = mid + 1
    else:
        inside = a[mid] < t <= a[hi]
        steps.append({"array": a, "pointers": {"lo": lo, "mid": mid, "hi": hi}, "highlight": list(range(mid, hi + 1)), "dim": dim, "vars": {"sorted half": f"{a[mid]}..{a[hi]}"},
                      "caption": f"The RIGHT half {a[mid]}..{a[hi]} is sorted. Is {t} inside it? {'Yes: go right.' if inside else 'No: go left.'}"})
        if inside:
            lo = mid + 1
        else:
            hi = mid - 1
print(json.dumps({"title": "Rotated sorted array: find the sorted half, then decide", "view": "array", "steps": steps}))
