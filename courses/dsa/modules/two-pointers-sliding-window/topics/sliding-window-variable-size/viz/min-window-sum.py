import json

nums, target = [2, 3, 1, 2, 4, 3], 7
l = total = 0
best = None
steps = [{"array": nums, "pointers": {"l": 0}, "highlight": [], "vars": {"target": target, "sum": 0},
          "caption": f"Shortest subarray with sum ≥ {target}. Expand until valid, then shrink while it stays valid."}]
for r, x in enumerate(nums):
    total += x
    steps.append({"array": nums, "pointers": {"l": l, "r": r}, "highlight": list(range(l, r + 1)), "vars": {"sum": total, "best": best},
                  "caption": f"Add {x}: sum = {total}." + (" Valid, now try to shrink." if total >= target else f" Still < {target}, keep expanding.")})
    while total >= target:
        best = r - l + 1 if best is None else min(best, r - l + 1)
        total -= nums[l]
        l += 1
        steps.append({"array": nums, "pointers": {"l": l, "r": r}, "highlight": list(range(l, r + 1)), "dim": [l - 1], "vars": {"sum": total, "best": best},
                      "caption": f"Record length {r - l + 2}, drop {nums[l - 1]} from the left: sum = {total}." + (" Still valid, shrink again." if total >= target else " Invalid again, go back to expanding.")})
steps.append({"array": nums, "pointers": {}, "highlight": [], "vars": {"answer": best}, "caption": f"Answer {best}. l and r each move at most n times: O(n)."})
print(json.dumps({"title": "Shortest valid window: shrink as long as you can", "view": "array", "steps": steps}))
