import json

arr = list(range(1, 17))
target = 13
lo, hi, step = 0, len(arr) - 1, 0
steps = [{"array": arr, "pointers": {"lo": lo, "hi": hi}, "highlight": [], "dim": [],
          "vars": {"n": len(arr), "steps": 0}, "caption": f"Find {target} in 16 sorted numbers by halving."}]
while lo <= hi:
    mid = (lo + hi) // 2
    step += 1
    dim = [k for k in range(len(arr)) if k < lo or k > hi]
    found = arr[mid] == target
    steps.append({"array": arr, "pointers": {"lo": lo, "mid": mid, "hi": hi}, "highlight": [mid], "dim": dim,
                  "vars": {"n": len(arr), "steps": step, "range size": hi - lo + 1},
                  "caption": f"Check middle {arr[mid]}. " + ("Found it!" if found else
                             f"{'Too small, drop the left half' if arr[mid] < target else 'Too big, drop the right half'}.")})
    if found:
        break
    if arr[mid] < target:
        lo = mid + 1
    else:
        hi = mid - 1
steps.append({"array": arr, "pointers": {}, "highlight": [arr.index(target)], "dim": [],
              "vars": {"n": 16, "steps": step},
              "caption": f"{step} steps for 16 items. 1,000,000 items would need only ~20. That's O(log n)."})
print(json.dumps({"title": "Halving: the range shrinks by half each step", "view": "array", "steps": steps}))
