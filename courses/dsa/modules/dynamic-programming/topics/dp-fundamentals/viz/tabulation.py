import json
cost = [10, 15, 20, 5, 10]
n = len(cost)
dp = ["?"] * (n + 1)
dp[0] = dp[1] = 0
steps = [{"array": dp[:], "pointers": {}, "highlight": [0, 1], "vars": {"cost": cost},
          "caption": "Min Cost Climbing Stairs, bottom-up. dp[i] = cheapest way to STAND on step i. You may start on step 0 or 1 for free."}]
for i in range(2, n + 1):
    a, b = dp[i - 1] + cost[i - 1], dp[i - 2] + cost[i - 2]
    dp[i] = min(a, b)
    steps.append({"array": dp[:], "pointers": {"i": i}, "highlight": [i], "dim": [], "vars": {"from i−1": f"{dp[i-1]} + {cost[i-1]} = {a}", "from i−2": f"{dp[i-2]} + {cost[i-2]} = {b}"},
                  "caption": f"dp[{i}] = min(dp[{i-1}] + cost[{i-1}], dp[{i-2}] + cost[{i-2}]) = {dp[i]}. Both inputs were filled earlier: that's the order that makes tabulation work."})
steps.append({"array": dp[:], "pointers": {"top": n}, "highlight": [n], "vars": {"answer": dp[n]},
              "caption": f"dp[{n}] = {dp[n]}. Each value only needs the previous two, so two variables are enough: O(1) space."})
print(json.dumps({"title": "Tabulation: fill the table from the base cases up", "view": "array", "steps": steps}))
