## Core idea

**Precompute running totals once, and any range sum becomes a subtraction: `sum(l..r) = prefix[r + 1] − prefix[l]`.** Add a hash map of earlier prefix sums and you can count subarrays with a given sum in one pass.

## Intuition

A car's odometer. You don't add up every trip to know how far you drove between Monday and Thursday: you read the odometer on Thursday evening and subtract Monday morning's reading. A **prefix sum** is that odometer for an array.

Now flip the question: "how many stretches of road were exactly 3 km?" At each point, look at the current reading `s` and ask how many earlier readings were `s − 3`. A hash map of past readings answers that instantly.

## Visualization

Build the prefix array once, then answer ranges in O(1):

```viz
prefix-build
```

Counting subarrays with sum k: running sum + a map of how often each prefix sum appeared:

```viz
subarray-k
```

## Template code

```python
# Build: prefix has n + 1 entries, prefix[0] = 0
prefix = [0]
for x in nums:
    prefix.append(prefix[-1] + x)
range_sum = prefix[r + 1] - prefix[l]          # sum of nums[l..r]

# Total minus running left sum (pivot / balance questions)
total, left = sum(nums), 0
for i, x in enumerate(nums):
    right = total - left - x
    left += x

# Count subarrays with sum k (works with negatives)
from collections import defaultdict
seen = defaultdict(int)
seen[0] = 1                                    # the empty prefix
s = count = 0
for x in nums:
    s += x
    count += seen[s - k]
    seen[s] += 1

# Prefix / suffix products (product except self, no division)
out = [1] * n
for i in range(1, n):
    out[i] = out[i - 1] * nums[i - 1]          # product of everything left
right = 1
for i in range(n - 1, -1, -1):
    out[i] *= right                            # times everything right
    right *= nums[i]
```

## Complexity

| Task | Cost |
|---|---|
| build prefix sums | O(n) time, O(n) space |
| each range query afterwards | **O(1)** |
| subarray sum = k with a prefix map | O(n) time, O(n) space |
| recomputing each range from scratch | O(n) per query |

Prefix sums work because the array doesn't change. If values get updated between queries, you need a Fenwick or segment tree (Module 15).

## When to use it

- **Many "sum from i to j" queries** on an array that doesn't change → prefix array
- **"Left sum equals right sum", "balance point"** → total and a running left sum
- **"Number of subarrays with sum k"** (negatives allowed) → prefix sum + hash map
- **"Product of everything except…"** → prefix and suffix products
- **Sums over a 2D grid** → 2D prefix sums (same idea per rectangle)

## Common traps

- Off-by-one: with `prefix[0] = 0`, the sum of `nums[l..r]` is `prefix[r + 1] − prefix[l]`
- Forgetting `seen[0] = 1`, which misses subarrays that start at index 0
- Recording `s` in the map *before* looking up `s − k`: with k = 0 every position would count itself
- Using a sliding window when numbers can be negative: shrinking no longer lowers the sum
- Dividing the total product for "except self": breaks on zeros
