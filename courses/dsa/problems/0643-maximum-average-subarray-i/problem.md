---
lc: 643
title: "Maximum Average Subarray I"
difficulty: "Easy"
patterns: ["sliding-window"]
lcTags: ["array", "sliding-window"]
compare: "float"
entry: {"method": "findMaxAverage", "params": [{"name": "nums", "type": "integer[]"}, {"name": "k", "type": "integer"}], "returns": "double"}
examples: ["[1,12,-5,-6,50,3]\n4", "[5]\n1"]
---

You are given an integer array `nums` consisting of `n` elements, and an integer `k`.

Find a contiguous subarray whose **length is equal to** `k` that has the maximum average value and return *this value*. Any answer with a calculation error less than `10⁻⁵` will be accepted.

**Example 1:**

```
Input: nums = [1,12,-5,-6,50,3], k = 4
Output: 12.75000
Explanation: Maximum average is (12 - 5 - 6 + 50) / 4 = 51 / 4 = 12.75
```

**Example 2:**

```
Input: nums = [5], k = 1
Output: 5.00000
```

**Constraints:**

- `n == nums.length`
- `1 <= k <= n <= 10⁵`
- `-10⁴ <= nums[i] <= 10⁴`

# Starter

```python
class Solution:
    def findMaxAverage(self, nums: list[int], k: int) -> float:
        
```

# Hints

1. Maximizing the average of length-k windows is the same as maximizing their sum.
2. Compute the first window's sum, then slide: add nums[i], subtract nums[i − k]. Track the best sum, divide by k at the end.

# Key points

- fixed-size window: add the new right element, drop the old left one
- max average = max sum / k, so track sums
- O(n) time, O(1) space vs O(n·k) recomputing each window

# Solution: recompute · Sum every window · O(n·k) · O(1) · slow

## Idea
Sum each window from scratch.

## Complexity
- **Time: O(n·k)**.
- **Space: O(1)**.

```python
class Solution:
    def findMaxAverage(self, nums: list[int], k: int) -> float:
        best = float("-inf")
        for i in range(len(nums) - k + 1):
            s = 0
            for j in range(i, i + k):
                s += nums[j]
            best = max(best, s)
        return best / k
```

# Solution: sliding · Sliding window sum · O(n) · O(1) · reference

## Idea
Neighbouring windows share k − 1 elements. Moving right by one means adding `nums[i]` and removing `nums[i - k]`, O(1) per step.

## Complexity
- **Time: O(n)**.
- **Space: O(1)**.

```python
class Solution:
    def findMaxAverage(self, nums: list[int], k: int) -> float:
        s = best = sum(nums[:k])
        for i in range(k, len(nums)):
            s += nums[i] - nums[i - k]
            best = max(best, s)
        return best / k
```

# Tests

```python
def edge():
    return [[[5], 1], [[-1], 1], [[1, 2], 2], [[0, 4, 0, 3, 2], 1], [[-5, -2, -9], 2]]

def random_case(rng):
    n = rng.randint(1, 10)
    return [[rng.randint(-10, 10) for _ in range(n)], rng.randint(1, n)]

def perf(rng):
    return [[[rng.randint(-10**4, 10**4) for _ in range(100000)], 50000]]
```
