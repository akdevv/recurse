---
lc: 416
title: "Partition Equal Subset Sum"
difficulty: "Medium"
patterns: ["dynamic-programming"]
lcTags: ["array", "dynamic-programming", "knapsack-problem", "0-1-knapsack"]
entry: {"method": "canPartition", "params": [{"name": "nums", "type": "integer[]"}], "returns": "boolean"}
examples: ["[1,5,11,5]", "[1,2,3,5]"]
---

Given an integer array `nums`, return `true` *if you can partition the array into two subsets such that the sum of the elements in both subsets is equal or* `false` *otherwise*.

**Example 1:**

```
Input: nums = [1,5,11,5]
Output: true
Explanation: The array can be partitioned as [1, 5, 5] and [11].
```

**Example 2:**

```
Input: nums = [1,2,3,5]
Output: false
Explanation: The array cannot be partitioned into equal sum subsets.
```

**Constraints:**

- `1 <= nums.length <= 200`
- `1 <= nums[i] <= 100`

# Starter

```python
class Solution:
    def canPartition(self, nums: list[int]) -> bool:
        
```

# Hints

1. If the total is odd, it's impossible. Otherwise: is there a subset summing to total / 2?
2. 0/1 knapsack on sums: dp = {0}; for each x: dp |= {s + x for s in dp}. (Or a boolean array iterated from high to low.)

# Key points

- reduce to subset sum with target = total / 2
- 0/1 knapsack: iterate sums downward so each number is used once
- O(n × target) time, O(target) space

# Solution: dynamic-programming · Dynamic Programming · O(m × n) · O(m × n) · reference

First, we calculate the total sum s of the array. If the total sum is odd, it cannot be divided into two subsets with equal sums, so we directly return `false`. If the total sum is even, we set the target subset sum to `m = (s) / (2)`. The problem is then transformed into: does there exist a subset whose element sum is m?

We define `f[i][j]` to represent whether it is possible to select several numbers from the first i numbers so that their sum is exactly j. Initially, `f[0][0] = true` and the rest `f[i][j] = false`. The answer is `f[n][m]`.

Considering `f[i][j]`, if we select the i-th number x, then `f[i][j] = f[i - 1][j - x]`. If we do not select the i-th number x, then `f[i][j] = f[i - 1][j]`. Therefore, the state transition equation is:

```
f[i][j] = f[i - 1][j]  or  f[i - 1][j - x]  if  j >= x
```

The final answer is `f[n][m]`.

The time complexity is O(m × n), and the space complexity is O(m × n). Where m and n are half of the total sum of the array and the length of the array, respectively.

```python
class Solution:
    def canPartition(self, nums: List[int]) -> bool:
        m, mod = divmod(sum(nums), 2)
        if mod:
            return False
        n = len(nums)
        f = [[False] * (m + 1) for _ in range(n + 1)]
        f[0][0] = True
        for i, x in enumerate(nums, 1):
            for j in range(m + 1):
                f[i][j] = f[i - 1][j] or (j >= x and f[i - 1][j - x])
        return f[n][m]
```

# Solution: dynamic-programming-space-optimization · Dynamic Programming (Space Optimization) · O(n × m) · O(m)

We notice that in Solution 1, `f[i][j]` is only related to `f[i - 1][·]`. Therefore, we can compress the two-dimensional array into a one-dimensional array.

The time complexity is O(n × m), and the space complexity is O(m). Where n is the length of the array, and m is half of the total sum of the array.

```python
class Solution:
    def canPartition(self, nums: List[int]) -> bool:
        m, mod = divmod(sum(nums), 2)
        if mod:
            return False
        f = [True] + [False] * m
        for x in nums:
            for j in range(m, x - 1, -1):
                f[j] = f[j] or f[j - x]
        return f[m]
```

# Tests

```python

```
