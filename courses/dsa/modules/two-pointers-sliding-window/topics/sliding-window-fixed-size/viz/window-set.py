import json

nums, k = [1, 2, 3, 4, 2, 5], 3
window = set()
steps = [{"array": nums, "pointers": {}, "highlight": [], "vars": {"k": k, "window": []},
          "caption": f"Contains Duplicate II: is there a repeat at most {k} apart? Keep a set of the last {k} values."}]
for i, x in enumerate(nums):
    if x in window:
        steps.append({"array": nums, "pointers": {"i": i}, "highlight": list(range(max(0, i - k), i + 1)), "vars": {"x": x, "window": sorted(window)},
                      "caption": f"{x} is already in the window of the last {k} values: duplicate within distance {k}. True."})
        break
    window.add(x)
    msg = f"Add {x}."
    if len(window) > k:
        window.remove(nums[i - k])
        msg += f" Window has {k + 1} values, drop nums[{i - k}] = {nums[i - k]}."
    steps.append({"array": nums, "pointers": {"i": i}, "highlight": list(range(max(0, i - k + 1), i + 1)), "vars": {"x": x, "window": sorted(window)},
                  "caption": msg})
print(json.dumps({"title": "A window of the last k values in a set", "view": "array", "steps": steps}))
