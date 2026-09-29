import json

nums = [100, 4, 200, 1, 3, 2]
s = set(nums)
best = 0
steps = [{"array": nums, "pointers": {}, "highlight": [], "vars": {"set": sorted(s), "best": 0},
          "caption": "Longest consecutive sequence. Put everything in a set so 'is x + 1 present?' is O(1)."}]
for i, x in enumerate(nums):
    if x - 1 in s:
        steps.append({"array": nums, "pointers": {"x": i}, "highlight": [], "dim": [i], "vars": {"x": x, "x - 1 in set": True, "best": best},
                      "caption": f"{x - 1} is in the set, so {x} is in the middle of a run. Skip it: the run gets counted from its start."})
        continue
    y = x
    while y + 1 in s:
        y += 1
    best = max(best, y - x + 1)
    run = [j for j, v in enumerate(nums) if x <= v <= y]
    steps.append({"array": nums, "pointers": {"x": i}, "highlight": run, "vars": {"x": x, "run": f"{x}..{y}", "length": y - x + 1, "best": best},
                  "caption": f"{x - 1} isn't in the set, so {x} starts a run. Walk up while x + 1 exists: {x}..{y}, length {y - x + 1}."})
steps.append({"array": nums, "pointers": {}, "highlight": [], "vars": {"answer": best},
              "caption": f"Answer {best}. Each number is walked over by at most one run, so the whole thing is O(n) despite the inner loop."})
print(json.dumps({"title": "Only start counting at the beginning of a run", "view": "array", "steps": steps}))
