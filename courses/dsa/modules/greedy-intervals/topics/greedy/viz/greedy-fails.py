import json
coins, amount = [1, 3, 4], 6
steps = [{"array": coins, "pointers": {}, "highlight": [], "vars": {"amount": amount},
          "caption": f"Greedy isn't always right. Make {amount} with coins {coins} using as few coins as possible."}]
left, used = amount, []
for c in sorted(coins, reverse=True):
    while left >= c:
        left -= c; used.append(c)
        steps.append({"array": coins, "pointers": {"take": coins.index(c)}, "highlight": [coins.index(c)], "vars": {"greedy picks": used[:], "left": left},
                      "caption": f"Greedy: take the biggest coin that fits ({c}). Left: {left}."})
steps.append({"array": coins, "pointers": {}, "highlight": [1], "vars": {"greedy": f"{len(used)} coins {used}", "best": "2 coins [3, 3]"},
              "caption": "Greedy used 3 coins, but 3 + 3 uses 2. Taking the 4 first looked best locally and ruined the rest. This needs dynamic programming (Module 12)."})
print(json.dumps({"title": "When greedy fails: coin change", "view": "array", "steps": steps}))
