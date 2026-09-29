---
lc: 122
title: "Best Time to Buy and Sell Stock II"
difficulty: "Medium"
patterns: ["greedy", "dynamic-programming"]
lcTags: ["array", "dynamic-programming", "greedy"]
entry: {"method": "maxProfit", "params": [{"name": "prices", "type": "integer[]"}], "returns": "integer"}
examples: ["[7,1,5,3,6,4]", "[1,2,3,4,5]", "[7,6,4,3,1]"]
---

You are given an integer array `prices` where `prices[i]` is the price of a given stock on the `iᵗʰ` day.

On each day, you may decide to buy and/or sell the stock. You can only hold **at most one** share of the stock at any time. However, you can sell and buy the stock multiple times on the **same day**, ensuring you never hold more than one share of the stock.

Find and return *the **maximum** profit you can achieve*.

**Example 1:**

```
Input: prices = [7,1,5,3,6,4]
Output: 7
Explanation: Buy on day 2 (price = 1) and sell on day 3 (price = 5), profit = 5-1 = 4.
Then buy on day 4 (price = 3) and sell on day 5 (price = 6), profit = 6-3 = 3.
Total profit is 4 + 3 = 7.
```

**Example 2:**

```
Input: prices = [1,2,3,4,5]
Output: 4
Explanation: Buy on day 1 (price = 1) and sell on day 5 (price = 5), profit = 5-1 = 4.
Total profit is 4.
```

**Example 3:**

```
Input: prices = [7,6,4,3,1]
Output: 0
Explanation: There is no way to make a positive profit, so we never buy the stock to achieve the maximum profit of 0.
```

**Constraints:**

- `1 <= prices.length <= 3 * 10⁴`
- `0 <= prices[i] <= 10⁴`

# Starter

```python
class Solution:
    def maxProfit(self, prices: list[int]) -> int:
        
```

# Hints

1. You can trade as often as you like. Any upward move between two days can be captured.
2. Sum every positive difference prices[i] − prices[i − 1].

# Key points

- total profit = sum of all positive day-to-day increases
- equivalent to buying at every valley and selling at every peak
- O(n) time, O(1) space; a two-state DP (hold / not hold) gives the same result

# Solution: greedy-algorithm · Greedy Algorithm · O(n) · O(1) · reference

Starting from the second day, if the stock price is higher than the previous day, buy on the previous day and sell on the current day to make a profit. If the stock price is lower than the previous day, do not buy or sell. In other words, buy and sell on all rising trading days, and do not trade on all falling trading days. The final profit will be the maximum.

The time complexity is O(n), where n is the length of the `prices` array. The space complexity is O(1).

```python
class Solution:
    def maxProfit(self, prices: List[int]) -> int:
        return sum(max(0, b - a) for a, b in pairwise(prices))
```

# Solution: dynamic-programming · Dynamic Programming · O(n) · O(n)

We define `f[i][j]` as the maximum profit after trading on the ith day, where j indicates whether we currently hold the stock. When holding the stock, `j=0`, and when not holding the stock, `j=1`. The initial state is `f[0][0]=-prices[0]`, and all other states are 0.

If we currently hold the stock, it may be that we held the stock the day before and do nothing today, i.e., `f[i][0]=f[i-1][0]`. Or it may be that we did not hold the stock the day before and bought the stock today, i.e., `f[i][0]=f[i-1][1]-prices[i]`.

If we currently do not hold the stock, it may be that we did not hold the stock the day before and do nothing today, i.e., `f[i][1]=f[i-1][1]`. Or it may be that we held the stock the day before and sold the stock today, i.e., `f[i][1]=f[i-1][0]+prices[i]`.

Therefore, we can write the state transition equation as:

```
\begin{cases}
f[i][0]=max(f[i-1][0],f[i-1][1]-prices[i])\\
f[i][1]=max(f[i-1][1],f[i-1][0]+prices[i])
\end{cases}
```

The final answer is `f[n-1][1]`, where n is the length of the `prices` array.

The time complexity is O(n), and the space complexity is O(n). Here, n is the length of the `prices` array.

```python
class Solution:
    def maxProfit(self, prices: List[int]) -> int:
        n = len(prices)
        f = [[0] * 2 for _ in range(n)]
        f[0][0] = -prices[0]
        for i in range(1, n):
            f[i][0] = max(f[i - 1][0], f[i - 1][1] - prices[i])
            f[i][1] = max(f[i - 1][1], f[i - 1][0] + prices[i])
        return f[n - 1][1]
```

# Solution: dynamic-programming-space-optimization · Dynamic Programming (Space Optimization) · O(n) · O(1)

We can find that in Solution 2, the state of the ith day is only related to the state of the `i-1`th day. Therefore, we can use only two variables to maintain the state of the `i-1`th day, thereby optimizing the space complexity to O(1).

The time complexity is O(n), where n is the length of the `prices` array. The space complexity is O(1).

```python
class Solution:
    def maxProfit(self, prices: List[int]) -> int:
        n = len(prices)
        f = [-prices[0], 0]
        for i in range(1, n):
            g = [0] * 2
            g[0] = max(f[0], f[1] - prices[i])
            g[1] = max(f[1], f[0] + prices[i])
            f = g
        return f[1]
```

# Tests

```python

```
