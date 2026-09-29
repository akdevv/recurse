import json

nums, val = [0, 1, 2, 2, 3, 0, 4, 2], 2
a = list(nums)
steps = [{"array": list(a), "pointers": {"read": 0, "k": 0}, "highlight": [], "vars": {"val": val, "k": 0},
          "caption": f"Remove every {val} in place. `read` scans everything, `k` is where the next kept value goes."}]
k = 0
for i, x in enumerate(nums):
    if x != val:
        a[k] = x
        steps.append({"array": list(a), "pointers": {"read": i, "k": k}, "highlight": list(range(k + 1)), "vars": {"x": x, "k": k + 1},
                      "caption": f"{x} ≠ {val}: keep it. Write it to slot {k}, then k = {k + 1}."})
        k += 1
    else:
        steps.append({"array": list(a), "pointers": {"read": i, "k": k}, "highlight": list(range(k)), "dim": [i], "vars": {"x": x, "k": k},
                      "caption": f"{x} = {val}: skip it. k stays at {k}; a later kept value will overwrite this area."})
steps.append({"array": list(a), "pointers": {}, "highlight": list(range(k)), "dim": list(range(k, len(a))), "vars": {"return": k},
              "caption": f"Done in one pass. The first {k} slots hold the kept values; whatever is after them doesn't matter."})
print(json.dumps({"title": "Read pointer + write pointer: compacting an array in place", "view": "array", "steps": steps}))
