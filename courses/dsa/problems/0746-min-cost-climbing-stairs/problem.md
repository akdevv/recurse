---
lc: 746
title: "Min Cost Climbing Stairs"
difficulty: "Easy"
patterns: ["dynamic-programming"]
lcTags: ["array", "dynamic-programming"]
entry: {"method": "minCostClimbingStairs", "params": [{"name": "cost", "type": "integer[]"}], "returns": "integer"}
examples: ["[10,15,20]", "[1,100,1,1,1,100,1,1,100,1]"]
lcHints: ["Build an array dp where dp[i] is the minimum cost to climb to the top starting from the ith staircase.", "Assuming we have n staircase labeled from 0 to n - 1 and assuming the top is n, then dp[n] = 0, marking that if you are at the top, the cost is 0.", "Now, looping from n - 1 to 0, the dp[i] = cost[i] + min(dp[i + 1], dp[i + 2]). The answer will be the minimum of dp[0] and dp[1]"]
---

You are given an integer array `cost` where `cost[i]` is the cost of `iᵗʰ` step on a staircase.

Once you pay the cost, you can either climb **one** or **two** steps.

You can either start from the step with index 0, or the step with index 1.

Return the **minimum** cost to reach the top of the staircase, which is the position just past the last step (index `cost.length`).

**Example 1:**

```
Input: cost = [10,15,20]
Output: 15
Explanation: You will start at index 1.
- Pay 15 and climb two steps to reach the top.
The total cost is 15.
```

**Example 2:**

```
Input: cost = [1,100,1,1,1,100,1,1,100,1]
Output: 6
Explanation: You will start at index 0.
- Pay 1 and climb two steps to reach index 2.
- Pay 1 and climb two steps to reach index 4.
- Pay 1 and climb two steps to reach index 6.
- Pay 1 and climb one step to reach index 7.
- Pay 1 and climb two steps to reach index 9.
- Pay 1 and climb one step to reach the top.
The total cost is 6.
```

**Constraints:**

- `2 <= cost.length <= 1000`
- `0 <= cost[i] <= 999`

# Starter

```python
class Solution:
    def minCostClimbingStairs(self, cost: list[int]) -> int:
        
```

# Hints

1. The cheapest way to stand on step i comes from step i − 1 or i − 2, whichever was cheaper including its cost.
2. dp[i] = cost[i] + min(dp[i − 1], dp[i − 2]); the answer is min(dp[n − 1], dp[n − 2]) because you can step off from either.

# Key points

- dp[i] = min cost to reach step i (paying for it)
- the top is past the last step: answer = min of the last two
- O(n) time, O(1) space with two variables

# Solution: memoization-search · Memoization Search · O(n) · O(n) · reference

We design a function `dfs(i)`, which represents the minimum cost required to climb the stairs starting from the i-th step. Therefore, the answer is `min(dfs(0), dfs(1))`.

The execution process of the function `dfs(i)` is as follows:

- If `i >= len(cost)`, it means the current position has exceeded the top of the stairs, and there is no need to climb further, so return 0;
- Otherwise, we can choose to climb 1 step with a cost of `cost[i]`, then recursively call `dfs(i + 1)`; or we can choose to climb 2 steps with a cost of `cost[i]`, then recursively call `dfs(i + 2)`;
- Return the minimum cost between these two options.

To avoid repeated calculations, we use memoization search, saving the results that have already been calculated in an array or hash table.

The time complexity is O(n), and the space complexity is O(n), where n is the length of the array cost.

```python
class Solution:
    def minCostClimbingStairs(self, cost: List[int]) -> int:
        @cache
        def dfs(i: int) -> int:
            if i >= len(cost):
                return 0
            return cost[i] + min(dfs(i + 1), dfs(i + 2))

        return min(dfs(0), dfs(1))
```

# Solution: dynamic-programming · Dynamic Programming · O(n) · O(n)

We define `f[i]` as the minimum cost needed to reach the i-th stair. Initially, `f[0] = f[1] = 0`, and the answer is `f[n]`.

When `i >= 2`, we can reach the i-th stair directly from the `(i - 1)`-th stair with one step, or from the `(i - 2)`-th stair with two steps. Therefore, we have the state transition equation:

```
f[i] = min(f[i - 1] + cost[i - 1], f[i - 2] + cost[i - 2])
```

The final answer is `f[n]`.

The time complexity is O(n), and the space complexity is O(n), where n is the length of the array cost.

```python
class Solution:
    def minCostClimbingStairs(self, cost: List[int]) -> int:
        n = len(cost)
        f = [0] * (n + 1)
        for i in range(2, n + 1):
            f[i] = min(f[i - 2] + cost[i - 2], f[i - 1] + cost[i - 1])
        return f[n]
```

# Solution: dynamic-programming-space-optimization · Dynamic Programming (Space Optimization) · O(n) · O(1)

We notice that the state transition equation for `f[i]` only depends on `f[i - 1]` and `f[i - 2]`. Therefore, we can use two variables f and g to alternately record the values of `f[i - 2]` and `f[i - 1]`, thus optimizing the space complexity to O(1).

```python
class Solution:
    def minCostClimbingStairs(self, cost: List[int]) -> int:
        f = g = 0
        for i in range(2, len(cost) + 1):
            f, g = g, min(f + cost[i - 2], g + cost[i - 1])
        return g
```

# Tests

```python

```
