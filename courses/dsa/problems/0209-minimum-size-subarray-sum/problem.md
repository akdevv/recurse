---
lc: 209
title: "Minimum Size Subarray Sum"
difficulty: "Medium"
patterns: ["sliding-window"]
lcTags: ["array", "binary-search", "sliding-window", "prefix-sum"]
entry: {"method": "minSubArrayLen", "params": [{"name": "target", "type": "integer"}, {"name": "nums", "type": "integer[]"}], "returns": "integer"}
examples: ["7\n[2,3,1,2,4,3]", "4\n[1,4,4]", "11\n[1,1,1,1,1,1,1,1]"]
---

Given an array of positive integers `nums` and a positive integer `target`, return *the **minimal length** of a* *subarray* *whose sum is greater than or equal to* `target`. If there is no such subarray, return `0` instead.

**Example 1:**

```
Input: target = 7, nums = [2,3,1,2,4,3]
Output: 2
Explanation: The subarray [4,3] has the minimal length under the problem constraint.
```

**Example 2:**

```
Input: target = 4, nums = [1,4,4]
Output: 1
```

**Example 3:**

```
Input: target = 11, nums = [1,1,1,1,1,1,1,1]
Output: 0
```

**Constraints:**

- `1 <= target <= 10⁹`
- `1 <= nums.length <= 10⁵`
- `1 <= nums[i] <= 10⁴`

**Follow up:** If you have figured out the `O(n)` solution, try coding another solution of which the time complexity is `O(n log(n))`.

# Starter

```python
class Solution:
    def minSubArrayLen(self, target: int, nums: list[int]) -> int:
        
```

# Hints

1. All numbers are positive, so growing a window only increases its sum and shrinking only decreases it.
2. Expand right, adding to the sum. While sum ≥ target, record the length and shrink from the left.

# Key points

- positive numbers → window sum is monotonic, so sliding window works
- expand right; while sum ≥ target, update the answer and shrink left
- O(n) time, O(1) space; return 0 if no window reaches the target
- alternative: prefix sums + binary search, O(n log n)

# Solution: all-starts · Every start, extend until big enough · O(n²) · O(1) · slow

## Idea
For each start, extend the end until the sum reaches the target.

## Complexity
- **Time: O(n²)**.
- **Space: O(1)**.

```python
class Solution:
    def minSubArrayLen(self, target: int, nums: list[int]) -> int:
        best = float("inf")
        for i in range(len(nums)):
            s = 0
            for j in range(i, len(nums)):
                s += nums[j]
                if s >= target:
                    best = min(best, j - i + 1)
                    break
        return 0 if best == float("inf") else best
```

# Solution: prefix-bisect · Prefix sums + binary search · O(n log n) · O(n)

## Idea
Prefix sums are increasing (all numbers positive). For each start `i`, binary search the first `j` with `prefix[j] - prefix[i] >= target`.

## Complexity
- **Time: O(n log n)**.
- **Space: O(n)**.

```python
from bisect import bisect_left

class Solution:
    def minSubArrayLen(self, target: int, nums: list[int]) -> int:
        prefix = [0]
        for x in nums:
            prefix.append(prefix[-1] + x)
        best = float("inf")
        for i in range(len(nums)):
            j = bisect_left(prefix, prefix[i] + target)
            if j <= len(nums):
                best = min(best, j - i)
        return 0 if best == float("inf") else best
```

# Solution: sliding · Variable sliding window · O(n) · O(1) · reference

## Idea
Grow the window by moving `r`. As soon as the sum reaches the target, this window is valid; record it and try to make it shorter by moving `l`. Because every number is positive, shrinking only lowers the sum, so once it drops below target we go back to growing.

## Complexity
- **Time: O(n)**: `l` and `r` each move at most n times.
- **Space: O(1)**.

```python
class Solution:
    def minSubArrayLen(self, target: int, nums: list[int]) -> int:
        l = s = 0
        best = float("inf")
        for r, x in enumerate(nums):
            s += x
            while s >= target:
                best = min(best, r - l + 1)
                s -= nums[l]
                l += 1
        return 0 if best == float("inf") else best
```

# Tests

```python
def edge():
    return [[1, [1]], [2, [1]], [4, [1, 4, 4]], [11, [1, 1, 1, 1, 1, 1, 1, 1]], [15, [1, 2, 3, 4, 5]], [7, [2, 3, 1, 2, 4, 3]]]

def random_case(rng):
    return [rng.randint(1, 20), [rng.randint(1, 6) for _ in range(rng.randint(1, 10))]]

def perf(rng):
    return [[10**9, [1] * 100000], [50000, [1] * 100000]]
```
