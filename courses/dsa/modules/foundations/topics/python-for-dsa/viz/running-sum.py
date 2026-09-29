import json

nums = [3, 1, 4, 1, 5]
steps = [{"array": nums, "pointers": {}, "highlight": [], "vars": {"total": 0, "out": []},
          "caption": "Start with total = 0 and an empty output list."}]
total, out = 0, []
for i, x in enumerate(nums):
    total += x
    out.append(total)
    steps.append({"array": nums, "pointers": {"i": i}, "highlight": list(range(i + 1)),
                  "vars": {"x": x, "total": total, "out": list(out)},
                  "caption": f"total += {x} → {total}. It already contains everything before index {i}, so no re-adding."})
steps.append({"array": out, "pointers": {}, "highlight": [], "vars": {"out": out},
              "caption": "Done in one pass: O(n). This output is the prefix-sum array."})
print(json.dumps({"title": "Running sum: one variable carries the work forward", "view": "array", "steps": steps}))
