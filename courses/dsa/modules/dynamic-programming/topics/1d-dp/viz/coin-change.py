import json
coins, amount = [1, 3, 4], 6
INF = float("inf")
dp = [0] + [INF] * amount
show = lambda: ["∞" if v == INF else v for v in dp]
steps = [{"array": show(), "pointers": {}, "highlight": [0], "vars": {"coins": coins},
          "caption": f"Coin Change: dp[a] = fewest coins that make amount a. dp[0] = 0; everything else starts as ∞ (unknown)."}]
for a in range(1, amount + 1):
    opts = {c: dp[a - c] + 1 for c in coins if c <= a}
    dp[a] = min(opts.values())
    best = min(opts, key=opts.get)
    steps.append({"array": show(), "pointers": {"a": a, "a − coin": a - best}, "highlight": [a],
                  "vars": {f"last coin {c}": f"dp[{a - c}] + 1 = {v if v != INF else '∞'}" for c, v in opts.items()},
                  "caption": f"Amount {a}: try every coin as the LAST coin and take the best. dp[{a}] = {dp[a]} (last coin {best})."})
steps.append({"array": show(), "pointers": {"answer": amount}, "highlight": [amount], "vars": {"answer": dp[amount]},
              "caption": f"dp[6] = 2 (3 + 3), where greedy would say 3 (4 + 1 + 1). O(amount × coins) time, O(amount) space."})
print(json.dumps({"title": "Coin Change: best answer for every smaller amount", "view": "array", "steps": steps}))
