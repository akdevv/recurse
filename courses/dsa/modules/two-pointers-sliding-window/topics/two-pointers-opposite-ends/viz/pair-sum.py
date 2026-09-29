import json

nums, target = [1, 3, 4, 6, 8, 11], 10
l, r = 0, len(nums) - 1
steps = [{"array": nums, "pointers": {"l": l, "r": r}, "highlight": [], "vars": {"target": target},
          "caption": f"Sorted input, find two numbers summing to {target}. Start at both ends."}]
while l < r:
    s = nums[l] + nums[r]
    if s == target:
        steps.append({"array": nums, "pointers": {"l": l, "r": r}, "highlight": [l, r], "vars": {"sum": s},
                      "caption": f"{nums[l]} + {nums[r]} = {s}. Found the pair."})
        break
    if s < target:
        steps.append({"array": nums, "pointers": {"l": l, "r": r}, "highlight": [l, r], "dim": list(range(l + 1)), "vars": {"sum": s},
                      "caption": f"{nums[l]} + {nums[r]} = {s} < {target}. Even the largest partner is too small for {nums[l]}, so {nums[l]} can't be in the answer: l += 1."})
        l += 1
    else:
        steps.append({"array": nums, "pointers": {"l": l, "r": r}, "highlight": [l, r], "dim": list(range(r, len(nums))), "vars": {"sum": s},
                      "caption": f"{nums[l]} + {nums[r]} = {s} > {target}. Even the smallest partner is too big for {nums[r]}, so drop it: r -= 1."})
        r -= 1
print(json.dumps({"title": "Two pointers on a sorted array: every step rules one number out", "view": "array", "steps": steps}))
