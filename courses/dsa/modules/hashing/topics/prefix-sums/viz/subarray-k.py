import json
from collections import Counter

nums, k = [1, 2, 1, -1, 2], 3
seen = Counter({0: 1})
s = count = 0
steps = [{"array": nums, "pointers": {}, "highlight": [], "vars": {"k": k, "s": 0, "seen": dict(seen), "count": 0},
          "caption": f"Count subarrays summing to {k}. If the running sum is s now and was s − {k} earlier, the part in between sums to {k}. seen = {{0: 1}} stands for the empty prefix."}]
for i, x in enumerate(nums):
    s += x
    hits = seen[s - k]
    count += hits
    steps.append({"array": nums, "pointers": {"i": i}, "highlight": list(range(i + 1)), "vars": {"s": s, "need s − k": s - k, "found": hits, "count": count, "seen": dict(seen)},
                  "caption": f"s = {s}. Earlier prefixes equal to {s} − {k} = {s - k}: {hits}. Each one ends a subarray summing to {k} here. count = {count}."})
    seen[s] += 1
steps.append({"array": nums, "pointers": {}, "highlight": [], "vars": {"answer": count},
              "caption": f"{count} subarrays. One pass, O(n), and it works with negative numbers, unlike a sliding window."})
print(json.dumps({"title": "Prefix sums + hash map: subarrays that sum to k", "view": "array", "steps": steps}))
