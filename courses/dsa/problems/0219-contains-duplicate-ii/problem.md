---
lc: 219
title: "Contains Duplicate II"
difficulty: "Easy"
patterns: ["sliding-window", "hash-map"]
lcTags: ["array", "hash-table", "sliding-window"]
entry: {"method": "containsNearbyDuplicate", "params": [{"name": "nums", "type": "integer[]"}, {"name": "k", "type": "integer"}], "returns": "boolean"}
examples: ["[1,2,3,1]\n3", "[1,0,1,1]\n1", "[1,2,3,1,2,3]\n2"]
---

Given an integer array `nums` and an integer `k`, return `true` *if there are two **distinct indices*** `i` *and* `j` *in the array such that* `nums[i] == nums[j]` *and* `abs(i - j) <= k`.

**Example 1:**

```
Input: nums = [1,2,3,1], k = 3
Output: true
```

**Example 2:**

```
Input: nums = [1,0,1,1], k = 1
Output: true
```

**Example 3:**

```
Input: nums = [1,2,3,1,2,3], k = 2
Output: false
```

**Constraints:**

- `1 <= nums.length <= 10⁵`
- `-10⁹ <= nums[i] <= 10⁹`
- `0 <= k <= 10⁵`

# Starter

```python
class Solution:
    def containsNearbyDuplicate(self, nums: list[int], k: int) -> bool:
        
```

# Hints

1. You only care about equal values at most k apart. What's the most recent index where you saw each value?
2. Keep a dict value → last index. At index i, if the value was seen at j and i − j ≤ k, return True. Then update to i.

# Key points

- store each value's most recent index; the latest occurrence is the closest one
- or keep a set holding only the last k values (a sliding window)
- O(n) time, O(min(n, k)) space for the window version

# Solution: pairs · Check the next k values · O(n·k) · O(1) · slow

## Idea
For each `i`, look at the following k values.

## Complexity
- **Time: O(n·k)**.
- **Space: O(1)**.

```python
class Solution:
    def containsNearbyDuplicate(self, nums: list[int], k: int) -> bool:
        for i in range(len(nums)):
            for j in range(i + 1, min(i + k + 1, len(nums))):
                if nums[i] == nums[j]:
                    return True
        return False
```

# Solution: last-index · Last index per value · O(n) · O(n)

## Idea
Only the most recent previous occurrence matters: it's the closest one. Keep value → last index.

## Complexity
- **Time: O(n)**.
- **Space: O(n)**.

```python
class Solution:
    def containsNearbyDuplicate(self, nums: list[int], k: int) -> bool:
        last = {}
        for i, x in enumerate(nums):
            if x in last and i - last[x] <= k:
                return True
            last[x] = i
        return False
```

# Solution: window-set · Set of the last k values · O(n) · O(k) · reference

## Idea
Keep a set holding exactly the previous k values. If `nums[i]` is already in it, there's a duplicate within distance k. Add `nums[i]`, and drop `nums[i - k]` once the window is too big.

## Complexity
- **Time: O(n)**.
- **Space: O(min(n, k))**.

```python
class Solution:
    def containsNearbyDuplicate(self, nums: list[int], k: int) -> bool:
        window = set()
        for i, x in enumerate(nums):
            if x in window:
                return True
            window.add(x)
            if len(window) > k:
                window.remove(nums[i - k])
        return False
```

# Tests

```python
def edge():
    return [[[1], 0], [[1, 1], 0], [[1, 1], 1], [[1, 2, 3, 1], 3], [[1, 0, 1, 1], 1], [[1, 2, 3, 1, 2, 3], 2]]

def random_case(rng):
    return [[rng.randint(0, 5) for _ in range(rng.randint(1, 10))], rng.randint(0, 5)]

def perf(rng):
    return [[list(range(100000)), 100000]]
```
