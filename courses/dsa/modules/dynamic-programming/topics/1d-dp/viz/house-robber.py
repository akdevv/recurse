import json
nums = [2, 7, 9, 3, 1]
dp = []
steps = [{"array": nums, "pointers": {}, "highlight": [], "vars": {"dp": []},
          "caption": "House Robber: dp[i] = the most you can steal from houses 0..i. At house i: skip it (dp[i−1]) or rob it (nums[i] + dp[i−2])."}]
for i, x in enumerate(nums):
    skip = dp[i - 1] if i >= 1 else 0
    rob = x + (dp[i - 2] if i >= 2 else 0)
    dp.append(max(skip, rob))
    steps.append({"array": nums, "pointers": {"i": i}, "highlight": [i] if rob >= skip else [], "vars": {"skip": skip, "rob": rob, "dp": dp[:]},
                  "caption": f"House {i} ({x}): skip → {skip}, rob → {x} + {rob - x} = {rob}. dp[{i}] = {dp[-1]}."})
steps.append({"array": nums, "pointers": {}, "highlight": [0, 2, 4], "vars": {"answer": dp[-1]},
              "caption": f"Best {dp[-1]} (houses 0, 2, 4). Only dp[i−1] and dp[i−2] are ever needed: O(n) time, O(1) space."})
print(json.dumps({"title": "House Robber: take it or leave it", "view": "array", "steps": steps}))
