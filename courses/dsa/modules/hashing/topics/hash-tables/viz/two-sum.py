import json

nums, target = [3, 8, 11, 2, 7], 9
seen = {}
steps = [{"array": nums, "pointers": {}, "highlight": [], "vars": {"target": target, "seen": {}},
          "caption": f"Two Sum with target {target}. For each number x, its partner must be {target} − x. The dict `seen` maps value → index."}]
for i, x in enumerate(nums):
    need = target - x
    if need in seen:
        steps.append({"array": nums, "pointers": {"i": i, "partner": seen[need]}, "highlight": [seen[need], i],
                      "vars": {"x": x, "need": need, "seen": dict(seen)},
                      "caption": f"x = {x}, need {need}. {need} is in `seen` at index {seen[need]}: answer [{seen[need]}, {i}]. One pass, O(1) per lookup."})
        break
    steps.append({"array": nums, "pointers": {"i": i}, "highlight": [i], "vars": {"x": x, "need": need, "seen": dict(seen)},
                  "caption": f"x = {x}, need {need}. Not in `seen` yet, so store {x} → {i} for a later number to find."})
    seen[x] = i
print(json.dumps({"title": "Two Sum in one pass with a hash map", "view": "array", "steps": steps}))
