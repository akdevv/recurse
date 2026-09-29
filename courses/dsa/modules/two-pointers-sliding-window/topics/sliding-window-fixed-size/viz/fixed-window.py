import json

nums, k = [2, 1, 5, 1, 3, 2], 3
s = sum(nums[:k])
best = s
steps = [{"array": nums, "pointers": {"left": 0, "right": k - 1}, "highlight": list(range(k)), "vars": {"window sum": s, "best": best},
          "caption": f"Max sum of a window of size {k}. Sum the first window once: {s}."}]
for r in range(k, len(nums)):
    out, inn = nums[r - k], nums[r]
    s += inn - out
    best = max(best, s)
    steps.append({"array": nums, "pointers": {"left": r - k + 1, "right": r}, "highlight": list(range(r - k + 1, r + 1)), "dim": [r - k],
                  "vars": {"in": inn, "out": out, "window sum": s, "best": best},
                  "caption": f"Slide right: add {inn}, remove {out}. Sum = {s} in O(1), no re-adding the whole window."})
print(json.dumps({"title": "Fixed-size window: add the one entering, drop the one leaving", "view": "array", "steps": steps}))
