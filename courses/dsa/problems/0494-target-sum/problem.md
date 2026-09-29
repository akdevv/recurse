---
lc: 494
title: "Target Sum"
difficulty: "Medium"
patterns: ["dynamic-programming", "backtracking"]
lcTags: ["array", "dynamic-programming", "backtracking", "knapsack-problem", "0-1-knapsack"]
entry: {"method": "findTargetSumWays", "params": [{"name": "nums", "type": "integer[]"}, {"name": "target", "type": "integer"}], "returns": "integer"}
examples: ["[1,1,1,1,1]\n3", "[1]\n1"]
---

You are given an integer array `nums` and an integer `target`.

You want to build an **expression** out of nums by adding one of the symbols `'+'` and `'-'` before each integer in nums and then concatenate all the integers.

- For example, if `nums = [2, 1]`, you can add a `'+'` before `2` and a `'-'` before `1` and concatenate them to build the expression `"+2-1"`.

Return the number of different **expressions** that you can build, which evaluates to `target`.

**Example 1:**

```
Input: nums = [1,1,1,1,1], target = 3
Output: 5
Explanation: There are 5 ways to assign symbols to make the sum of nums be target 3.
-1 + 1 + 1 + 1 + 1 = 3
+1 - 1 + 1 + 1 + 1 = 3
+1 + 1 - 1 + 1 + 1 = 3
+1 + 1 + 1 - 1 + 1 = 3
+1 + 1 + 1 + 1 - 1 = 3
```

**Example 2:**

```
Input: nums = [1], target = 1
Output: 1
```

**Constraints:**

- `1 <= nums.length <= 20`
- `0 <= nums[i] <= 1000`
- `0 <= sum(nums[i]) <= 1000`
- `-1000 <= target <= 1000`

# Starter

```python
class Solution:
    def findTargetSumWays(self, nums: list[int], target: int) -> int:
        
```

# Hints

1. Pick a set P of numbers to be positive. Then sum(P) − (total − sum(P)) = target, so sum(P) = (total + target) / 2.
2. If (total + target) is odd or |target| > total, return 0. Otherwise count subsets with sum (total + target) / 2 using 0/1 knapsack counting.

# Key points

- turn +/- assignment into "count subsets with a given sum"
- dp[s] += dp[s - x], iterating s downward
- brute force over 2ⁿ sign choices is fine for n = 20 but DP is the lesson
- zeros double the count (both signs)

# Solution: dynamic-programming · Dynamic Programming · O(m × n) · O(m × n) · reference

Let's denote the sum of all elements in the array nums as s, and the sum of elements to which we assign a negative sign as x. Therefore, the sum of elements with a positive sign is `s - x`. We have:

```
(s - x) - x = target \Rightarrow x = (s - target) / (2)
```

Since `x >= 0` and x must be an integer, it follows that `s >= target` and `s - target` must be even. If these two conditions are not met, we directly return 0.

Next, we can transform the problem into: selecting several elements from the array nums such that the sum of these elements equals `(s - target) / (2)`. We are asked how many ways there are to make such a selection.

We can use dynamic programming to solve this problem. Define `f[i][j]` as the number of ways to select several elements from the first i elements of the array nums such that the sum of these elements equals j.

For `nums[i - 1]`, we have two choices: to select or not to select. If we do not select `nums[i - 1]`, then `f[i][j] = f[i - 1][j]`; if we do select `nums[i - 1]`, then `f[i][j] = f[i - 1][j - nums[i - 1]]`. Therefore, the state transition equation is:

```
f[i][j] = f[i - 1][j] + f[i - 1][j - nums[i - 1]]
```

This selection is based on the premise that `j >= nums[i - 1]`.

The final answer is `f[m][n]`, where m is the length of the array nums, and `n = (s - target) / (2)`.

The time complexity is O(m × n), and the space complexity is O(m × n).

```python
class Solution:
    def findTargetSumWays(self, nums: List[int], target: int) -> int:
        s = sum(nums)
        if s < target or (s - target) % 2:
            return 0
        m, n = len(nums), (s - target) // 2
        f = [[0] * (n + 1) for _ in range(m + 1)]
        f[0][0] = 1
        for i, x in enumerate(nums, 1):
            for j in range(n + 1):
                f[i][j] = f[i - 1][j]
                if j >= x:
                    f[i][j] += f[i - 1][j - x]
        return f[m][n]
```

# Solution: dynamic-programming-space-optimization · Dynamic Programming (Space Optimization) · O(m × n) · O(n)

We can observe that in the state transition equation of Solution 1, the value of `f[i][j]` is only related to `f[i - 1][j]` and `f[i - 1][j - nums[i - 1]]`. Therefore, we can eliminate the first dimension of the space and use only a one-dimensional array.

The time complexity is O(m × n), and the space complexity is O(n).

```python
class Solution:
    def findTargetSumWays(self, nums: List[int], target: int) -> int:
        s = sum(nums)
        if s < target or (s - target) % 2:
            return 0
        n = (s - target) // 2
        f = [0] * (n + 1)
        f[0] = 1
        for x in nums:
            for j in range(n, x - 1, -1):
                f[j] += f[j - x]
        return f[n]
```

# Tests

```python
def edge():
    return [[[1, 1, 1, 1, 1], 3], [[1], 1], [[1], 2], [[0, 0, 0], 0], [[1000], -1000], [[1, 0], 1]]

def random_case(rng):
    nums = [rng.randint(0, 5) for _ in range(rng.randint(1, 8))]
    return [nums, rng.randint(-sum(nums) - 1, sum(nums) + 1)]

def perf(rng):
    return [[[50] * 20, 0], [[rng.randint(0, 50) for _ in range(20)], 10]]
```
