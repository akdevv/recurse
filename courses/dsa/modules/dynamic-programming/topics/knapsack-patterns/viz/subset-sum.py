import json
nums = [1, 5, 11, 5]
target = sum(nums) // 2
can = [True] + [False] * target
steps = [{"array": ["T"] + ["·"] * target, "pointers": {}, "highlight": [0], "vars": {"nums": nums, "target": target},
          "caption": f"Partition Equal Subset Sum → is there a subset summing to {sum(nums)} / 2 = {target}? can[s] = some subset of the numbers seen so far sums to s. can[0] = True (empty set)."}]
for x in nums:
    new = []
    for s in range(target, x - 1, -1):
        if can[s - x] and not can[s]:
            can[s] = True; new.append(s)
    steps.append({"array": ["T" if v else "·" for v in can], "pointers": {}, "highlight": new, "vars": {"item": x, "new sums": sorted(new)},
                  "caption": f"Item {x}: every reachable sum s − {x} makes s reachable. Loop s from HIGH to LOW so {x} is used at most once (0/1 knapsack)."})
steps.append({"array": ["T" if v else "·" for v in can], "pointers": {"target": target}, "highlight": [target], "vars": {"answer": can[target]},
              "caption": f"can[{target}] = {can[target]}: {{1, 5, 5}} and {{11}}. O(n × target) time, O(target) space."})
print(json.dumps({"title": "0/1 knapsack: reachable sums, iterate downward", "view": "array", "steps": steps}))
