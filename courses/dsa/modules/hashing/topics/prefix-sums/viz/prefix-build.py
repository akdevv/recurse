import json

nums = [3, 1, 4, 1, 5, 9]
prefix = [0]
steps = [{"array": [0], "pointers": {}, "highlight": [0], "vars": {"nums": nums},
          "caption": "prefix[i] = sum of the first i numbers. Start with prefix[0] = 0 (the empty prefix)."}]
for i, x in enumerate(nums):
    prefix.append(prefix[-1] + x)
    steps.append({"array": list(prefix), "pointers": {"i+1": i + 1}, "highlight": [i + 1], "vars": {"nums[i]": x, "prefix[i+1]": f"{prefix[-2]} + {x} = {prefix[-1]}"},
                  "caption": f"prefix[{i + 1}] = prefix[{i}] + nums[{i}] = {prefix[-1]}. Built once in O(n)."})
l, r = 2, 4
steps.append({"array": list(prefix), "pointers": {"l": l, "r+1": r + 1}, "highlight": [l, r + 1], "vars": {"sum(nums[2..4])": f"prefix[5] − prefix[2] = {prefix[r + 1]} − {prefix[l]} = {prefix[r + 1] - prefix[l]}"},
              "caption": f"Sum of nums[{l}..{r}] = (everything up to {r}) − (everything before {l}) = prefix[{r + 1}] − prefix[{l}] = {prefix[r + 1] - prefix[l]}. Any range in O(1)."})
print(json.dumps({"title": "Building prefix sums, then answering a range query in O(1)", "view": "array", "steps": steps}))
