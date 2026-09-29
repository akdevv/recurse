import json
coins, amount = [1, 2, 5], 5
dp = [1] + [0] * amount
steps = [{"array": dp[:], "pointers": {}, "highlight": [0], "vars": {"coins": coins},
          "caption": "Coin Change II: count COMBINATIONS that make each amount. dp[0] = 1 (use no coins). Coins go in the OUTER loop."}]
for c in coins:
    for a in range(c, amount + 1):
        dp[a] += dp[a - c]
    steps.append({"array": dp[:], "pointers": {}, "highlight": list(range(c, amount + 1)), "vars": {"coin": c},
                  "caption": f"Allow coin {c}: for a = {c}..{amount} (upward, coin reusable) dp[a] += dp[a − {c}]. Now dp counts combinations using coins up to {c}."})
steps.append({"array": dp[:], "pointers": {"answer": amount}, "highlight": [amount], "vars": {"answer": dp[amount]},
              "caption": f"{dp[amount]} ways: 5, 2+2+1, 2+1+1+1, 1×5. Coins outside means each combination is built in one fixed coin order, so [1,2] and [2,1] aren't double counted."})
print(json.dumps({"title": "Unbounded knapsack: counting combinations", "view": "array", "steps": steps}))
