---
lc: 347
title: "Top K Frequent Elements"
difficulty: "Medium"
patterns: ["hash-map", "top-k-heap"]
lcTags: ["array", "hash-table", "divide-and-conquer", "sorting", "heap-priority-queue", "bucket-sort", "counting", "quickselect"]
compare: "unordered"
entry: {"method": "topKFrequent", "params": [{"name": "nums", "type": "integer[]"}, {"name": "k", "type": "integer"}], "returns": "integer[]"}
examples: ["[1,1,1,2,2,3]\n2", "[1]\n1", "[1,2,1,2,1,2,3,1,3,2]\n2"]
---

Given an integer array `nums` and an integer `k`, return *the* `k` *most frequent elements*. You may return the answer in **any order**.

**Example 1:**

**Input:** nums = [1,1,1,2,2,3], k = 2

**Output:** [1,2]

**Example 2:**

**Input:** nums = [1], k = 1

**Output:** [1]

**Example 3:**

**Input:** nums = [1,2,1,2,1,2,3,1,3,2], k = 2

**Output:** [1,2]

**Constraints:**

- `1 <= nums.length <= 10⁵`
- `-10⁴ <= nums[i] <= 10⁴`
- `k` is in the range `[1, the number of unique elements in the array]`.
- It is **guaranteed** that the answer is **unique**.

**Follow up:** Your algorithm's time complexity must be better than `O(n log n)`, where n is the array's size.

# Starter

```python
class Solution:
    def topKFrequent(self, nums: list[int], k: int) -> list[int]:
        
```

# Hints

1. First count every number. Then the question is: which k counts are the largest?
2. Bucket sort by frequency: buckets[f] = numbers seen f times (f ≤ n). Walk buckets from n down and collect until you have k.

# Key points

- count with Counter
- sorting by count is O(n log n); a size-k heap is O(n log k)
- bucket sort: index = frequency (at most n), walk from high to low → O(n)
- answer order doesn't matter

# Solution: sort · Sort by count · O(n log n) · O(n)

## Idea
Count, sort the distinct values by count, take the first k. (`Counter.most_common(k)` does the same with a heap.)

## Complexity
- **Time: O(n log n)**.
- **Space: O(n)**.

```python
from collections import Counter

class Solution:
    def topKFrequent(self, nums: list[int], k: int) -> list[int]:
        counts = Counter(nums)
        return sorted(counts, key=counts.get, reverse=True)[:k]
```

# Solution: buckets · Bucket by frequency · O(n) · O(n) · reference

## Idea
A frequency is between 1 and n, so it can be a list index. Put each value in `buckets[its count]`, then read buckets from the highest frequency down until k values are collected. No comparison sort needed.

## Complexity
- **Time: O(n)**.
- **Space: O(n)** for counts and buckets.

```python
from collections import Counter

class Solution:
    def topKFrequent(self, nums: list[int], k: int) -> list[int]:
        counts = Counter(nums)
        buckets = [[] for _ in range(len(nums) + 1)]
        for x, f in counts.items():
            buckets[f].append(x)
        out = []
        for f in range(len(nums), 0, -1):
            for x in buckets[f]:
                out.append(x)
                if len(out) == k:
                    return out
```

# Tests

```python
def edge():
    return [[[1], 1], [[1, 2], 2], [[-1, -1, 2], 1], [[4, 4, 4, 5, 5, 6], 2]]

def random_case(rng):
    # distinct frequencies keep the answer unique
    m = rng.randint(1, 5)
    vals = rng.sample(range(-20, 20), m)
    freqs = rng.sample(range(1, 7), m)
    nums = [v for v, f in zip(vals, freqs) for _ in range(f)]
    rng.shuffle(nums)
    return [nums, rng.randint(1, m)]

def perf(rng):
    nums = [rng.randint(-10**4, 10**4) for _ in range(100000)] + [7] * 1000
    return [[nums, 1]]
```
