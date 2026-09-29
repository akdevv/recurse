---
lc: 198
title: "House Robber"
difficulty: "Medium"
patterns: ["dynamic-programming"]
lcTags: ["array", "dynamic-programming"]
entry: {"method": "rob", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer"}
examples: ["[1,2,3,1]", "[2,7,9,3,1]"]
---

You are a professional robber planning to rob houses along a street. Each house has a certain amount of money stashed, the only constraint stopping you from robbing each of them is that adjacent houses have security systems connected and **it will automatically contact the police if two adjacent houses were broken into on the same night**.

Given an integer array `nums` representing the amount of money of each house, return *the maximum amount of money you can rob tonight **without alerting the police***.

**Example 1:**

```
Input: nums = [1,2,3,1]
Output: 4
Explanation: Rob house 1 (money = 1) and then rob house 3 (money = 3).
Total amount you can rob = 1 + 3 = 4.
```

**Example 2:**

```
Input: nums = [2,7,9,3,1]
Output: 12
Explanation: Rob house 1 (money = 2), rob house 3 (money = 9) and rob house 5 (money = 1).
Total amount you can rob = 2 + 9 + 1 = 12.
```

**Constraints:**

- `1 <= nums.length <= 100`
- `0 <= nums[i] <= 400`

# Starter

```python
class Solution:
    def rob(self, nums: list[int]) -> int:
        
```

# Hints

1. At each house you either rob it (and skip the previous one) or skip it.
2. best(i) = max(best(i − 1), best(i − 2) + nums[i]). Keep two rolling variables.

# Key points

- choice at each house: take (plus best from two back) or skip (best from one back)
- recurrence dp[i] = max(dp[i - 1], dp[i - 2] + nums[i])
- O(n) time, O(1) space

# Solution: memoization-search · Memoization Search · O(n) · O(n) · reference

We design a function `dfs(i)`, which represents the maximum amount of money that can be stolen starting from the i-th house. Thus, the answer is `dfs(0)`.

The execution process of the function `dfs(i)` is as follows:

- If `i >= len(nums)`, it means all houses have been considered, and we directly return 0;
- Otherwise, consider stealing from the i-th house, then `dfs(i) = nums[i] + dfs(i+2)`; if not stealing from the i-th house, then `dfs(i) = dfs(i+1)`.
- Return `max(nums[i] + dfs(i+2), dfs(i+1))`.

To avoid repeated calculations, we use memoization search. The result of `dfs(i)` is saved in an array or hash table. Before each calculation, we first check if it has been calculated. If so, we directly return the result.

The time complexity is O(n), and the space complexity is O(n), where n is the length of the array.

```python
class Solution:
    def rob(self, nums: List[int]) -> int:
        @cache
        def dfs(i: int) -> int:
            if i >= len(nums):
                return 0
            return max(nums[i] + dfs(i + 2), dfs(i + 1))

        return dfs(0)
```

# Solution: dynamic-programming · Dynamic Programming · O(n) · O(n)

We define `f[i]` as the maximum total amount that can be robbed from the first i houses, initially `f[0]=0`, `f[1]=nums[0]`.

Consider the case where `i > 1`, the ith house has two options:

- Do not rob the ith house, the total amount of robbery is `f[i-1]`;
- Rob the ith house, the total amount of robbery is `f[i-2]+nums[i-1]`;

Therefore, we can get the state transition equation:

```
f[i]=
\begin{cases}
0, & i=0 \\
nums[0], & i=1 \\
max(f[i-1],f[i-2]+nums[i-1]), & i > 1
\end{cases}
```

The final answer is `f[n]`, where n is the length of the array.

The time complexity is O(n), and the space complexity is O(n). Where n is the length of the array.

```python
class Solution:
    def rob(self, nums: List[int]) -> int:
        n = len(nums)
        f = [0] * (n + 1)
        f[1] = nums[0]
        for i in range(2, n + 1):
            f[i] = max(f[i - 1], f[i - 2] + nums[i - 1])
        return f[n]
```

# Solution: dynamic-programming-space-optimization · Dynamic Programming (Space Optimization) · O(n) · O(1)

We notice that when `i > 2`, `f[i]` is only related to `f[i-1]` and `f[i-2]`. Therefore, we can use two variables instead of an array to reduce the space complexity to O(1).

```python
class Solution:
    def rob(self, nums: List[int]) -> int:
        f = g = 0
        for x in nums:
            f, g = max(f, g), f + x
        return max(f, g)
```

# Tests

```python

```
