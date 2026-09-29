---
lc: 518
title: "Coin Change II"
difficulty: "Medium"
patterns: ["dynamic-programming"]
lcTags: ["array", "dynamic-programming", "knapsack-problem", "complete-knapsack"]
entry: {"method": "change", "params": [{"name": "amount", "type": "integer"}, {"name": "coins", "type": "integer[]"}], "returns": "integer"}
examples: ["5\n[1,2,5]", "3\n[2]", "10\n[10]"]
---

You are given an integer array `coins` representing coins of different denominations and an integer `amount` representing a total amount of money.

Return *the number of combinations that make up that amount*. If that amount of money cannot be made up by any combination of the coins, return `0`.

You may assume that you have an infinite number of each kind of coin.

The **final** answer is **guaranteed** to fit into a signed **32-bit** integer.

**Example 1:**

```
Input: amount = 5, coins = [1,2,5]
Output: 4
Explanation: there are four ways to make up the amount:
5=5
5=2+2+1
5=2+1+1+1
5=1+1+1+1+1
```

**Example 2:**

```
Input: amount = 3, coins = [2]
Output: 0
Explanation: the amount of 3 cannot be made up just with coins of 2.
```

**Example 3:**

```
Input: amount = 10, coins = [10]
Output: 1
```

**Constraints:**

- `1 <= coins.length <= 300`
- `1 <= coins[i] <= 5000`
- All the values of `coins` are **unique**.
- `0 <= amount <= 5000`

# Starter

```python
class Solution:
    def change(self, amount: int, coins: list[int]) -> int:
        
```

# Hints

1. Count combinations, not orderings: [1, 2] and [2, 1] are the same. The loop order decides which one you count.
2. dp[0] = 1; for each coin (outer loop), for a from coin to amount: dp[a] += dp[a − coin].

# Key points

- unbounded knapsack counting combinations
- coins in the outer loop → each combination counted once
- swapping the loops counts permutations instead (a different problem)
- O(amount × coins) time

# Solution: dynamic-programming-complete-knapsack · Dynamic Programming (Complete Knapsack) · O(m × n) · O(m × n) · reference

We define `f[i][j]` as the number of coin combinations to make up the amount j using the first i types of coins. Initially, `f[0][0] = 1`, and the values of other positions are all 0.

We can enumerate the quantity k of the last coin used, then we have equation one:

```
f[i][j] = f[i - 1][j] + f[i - 1][j - x] + f[i - 1][j - 2 × x] + ... + f[i - 1][j - k × x]
```

where x represents the face value of the i-th type of coin.

Let `j = j - x`, then we have equation two:

```
f[i][j - x] = f[i - 1][j - x] + f[i - 1][j - 2 × x] + ... + f[i - 1][j - k × x]
```

Substituting equation two into equation one, we can get the following state transition equation:

```
f[i][j] = f[i - 1][j] + f[i][j - x]
```

The final answer is `f[m][n]`.

The time complexity is O(m × n), and the space complexity is O(m × n). Where m and n are the number of types of coins and the total amount, respectively.

```python
class Solution:
    def change(self, amount: int, coins: List[int]) -> int:
        m, n = len(coins), amount
        f = [[0] * (n + 1) for _ in range(m + 1)]
        f[0][0] = 1
        for i, x in enumerate(coins, 1):
            for j in range(n + 1):
                f[i][j] = f[i - 1][j]
                if j >= x:
                    f[i][j] += f[i][j - x]
        return f[m][n]
```

# Solution: optimized-dynamic-programming · Optimized Dynamic Programming · O(m × n) · O(n)

We notice that `f[i][j]` is only related to `f[i - 1][j]` and `f[i][j - x]`. Therefore, we can optimize the two-dimensional array into a one-dimensional array, reducing the space complexity to O(n). The time complexity remains O(m × n).

```python
class Solution:
    def change(self, amount: int, coins: List[int]) -> int:
        n = amount
        f = [1] + [0] * n
        for x in coins:
            for j in range(x, n + 1):
                f[j] += f[j - x]
        return f[n]
```

# Tests

```python
def edge():
    return [[5, [1, 2, 5]], [3, [2]], [10, [10]], [0, [7]], [500, [3, 5, 7, 8, 9, 10, 11]]]

def random_case(rng):
    return [rng.randint(0, 30), rng.sample(range(1, 15), rng.randint(1, 5))]

def perf(rng):
    return [[5000, rng.sample(range(1, 5001), 300)]]
```
