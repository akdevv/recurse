---
lc: 322
title: "Coin Change"
difficulty: "Medium"
patterns: ["dynamic-programming"]
lcTags: ["array", "dynamic-programming", "breadth-first-search", "knapsack-problem", "complete-knapsack"]
entry: {"method": "coinChange", "params": [{"name": "coins", "type": "integer[]"}, {"name": "amount", "type": "integer"}], "returns": "integer"}
examples: ["[1,2,5]\n11", "[2]\n3", "[1]\n0"]
---

You are given an integer array `coins` representing coins of different denominations and an integer `amount` representing a total amount of money.

Return *the fewest number of coins that you need to make up that amount*. If that amount of money cannot be made up by any combination of the coins, return `-1`.

You may assume that you have an infinite number of each kind of coin.

**Example 1:**

```
Input: coins = [1,2,5], amount = 11
Output: 3
Explanation: 11 = 5 + 5 + 1
```

**Example 2:**

```
Input: coins = [2], amount = 3
Output: -1
```

**Example 3:**

```
Input: coins = [1], amount = 0
Output: 0
```

**Constraints:**

- `1 <= coins.length <= 12`
- `1 <= coins[i] <= 2³¹ - 1`
- `0 <= amount <= 10⁴`

# Starter

```python
class Solution:
    def coinChange(self, coins: list[int], amount: int) -> int:
        
```

# Hints

1. Greedy (biggest coin first) fails, e.g. coins [1, 3, 4] and amount 6. Think of the best answer for every smaller amount.
2. dp[a] = min over coins c ≤ a of dp[a − c] + 1, with dp[0] = 0 and infinity for unreachable amounts.

# Key points

- unbounded knapsack: dp over amounts 0..amount
- dp[a] = 1 + min(dp[a - c]) for each coin c
- unreachable → -1
- O(amount × coins) time, O(amount) space

# Solution: dynamic-programming-complete-knapsack · Dynamic Programming (Complete Knapsack) · O(m × n) · O(m × n) · reference

We define `f[i][j]` as the minimum number of coins needed to make up the amount j using the first i types of coins. Initially, `f[0][0] = 0`, and the values of other positions are all positive infinity.

We can enumerate the quantity k of the last coin used, then we have:

```
f[i][j] = min(f[i - 1][j], f[i - 1][j - x] + 1, ..., f[i - 1][j - k × x] + k)
```

where x represents the face value of the i-th type of coin.

Let `j = j - x`, then we have:

```
f[i][j - x] = min(f[i - 1][j - x], f[i - 1][j - 2 × x] + 1, ..., f[i - 1][j - k × x] + k - 1)
```

Substituting the second equation into the first one, we can get the following state transition equation:

```
f[i][j] = min(f[i - 1][j], f[i][j - x] + 1)
```

The final answer is `f[m][n]`.

The time complexity is O(m × n), and the space complexity is O(m × n). Where m and n are the number of types of coins and the total amount, respectively.

```python
class Solution:
    def coinChange(self, coins: List[int], amount: int) -> int:
        m, n = len(coins), amount
        f = [[inf] * (n + 1) for _ in range(m + 1)]
        f[0][0] = 0
        for i, x in enumerate(coins, 1):
            for j in range(n + 1):
                f[i][j] = f[i - 1][j]
                if j >= x:
                    f[i][j] = min(f[i][j], f[i][j - x] + 1)
        return -1 if f[m][n] >= inf else f[m][n]
```

# Solution: optimized-dynamic-programming · Optimized Dynamic Programming · O(m × n) · O(n)

We notice that `f[i][j]` is only related to `f[i - 1][j]` and `f[i][j - x]`. Therefore, we can optimize the two-dimensional array into a one-dimensional array, reducing the space complexity to O(n). The time complexity remains O(m × n).

Similar problems:

- [279. Perfect Squares](https://github.com/doocs/leetcode/blob/main/solution/0200-0299/0279.Perfect%20Squares/README_EN.md)

```python
class Solution:
    def coinChange(self, coins: List[int], amount: int) -> int:
        n = amount
        f = [0] + [inf] * n
        for x in coins:
            for j in range(x, n + 1):
                f[j] = min(f[j], f[j - x] + 1)
        return -1 if f[n] >= inf else f[n]
```

# Tests

```python

```
