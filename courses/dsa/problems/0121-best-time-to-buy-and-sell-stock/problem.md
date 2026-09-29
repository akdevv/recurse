---
lc: 121
title: "Best Time to Buy and Sell Stock"
difficulty: "Easy"
patterns: ["sliding-window", "greedy"]
lcTags: ["array", "dynamic-programming"]
entry: {"method": "maxProfit", "params": [{"name": "prices", "type": "integer[]"}], "returns": "integer"}
examples: ["[7,1,5,3,6,4]", "[7,6,4,3,1]"]
---

You are given an array `prices` where `prices[i]` is the price of a given stock on the `iᵗʰ` day.

You want to maximize your profit by choosing a **single day** to buy one stock and choosing a **different day in the future** to sell that stock.

Return *the maximum profit you can achieve from this transaction*. If you cannot achieve any profit, return `0`.

**Example 1:**

```
Input: prices = [7,1,5,3,6,4]
Output: 5
Explanation: Buy on day 2 (price = 1) and sell on day 5 (price = 6), profit = 6-1 = 5.
Note that buying on day 2 and selling on day 1 is not allowed because you must buy before you sell.
```

**Example 2:**

```
Input: prices = [7,6,4,3,1]
Output: 0
Explanation: In this case, no transactions are done and the max profit = 0.
```

**Constraints:**

- `1 <= prices.length <= 10⁵`
- `0 <= prices[i] <= 10⁴`

# Starter

```python
class Solution:
    def maxProfit(self, prices: list[int]) -> int:
        
```

# Hints

1. For each day as the selling day, the best buying day is the cheapest day before it.
2. One pass: keep the lowest price so far, and the best profit = max(best, price − lowest).

# Key points

- sell on day i → buy at the minimum price before i
- track the running minimum and the best profit in one pass
- O(n) time, O(1) space; profit 0 if prices only fall

# Solution: pairs · Try every buy/sell pair · O(n²) · O(1) · slow

## Idea
Check every pair of days.

## Complexity
- **Time: O(n²)**.
- **Space: O(1)**.

```python
class Solution:
    def maxProfit(self, prices: list[int]) -> int:
        best = 0
        for i in range(len(prices)):
            for j in range(i + 1, len(prices)):
                best = max(best, prices[j] - prices[i])
        return best
```

# Solution: running-min · Running minimum · O(n) · O(1) · reference

## Idea
Pretend to sell every day. The best buy for that sale is the cheapest price seen before it, which we track as we go. It's a window whose left edge jumps to any new low.

## Complexity
- **Time: O(n)**.
- **Space: O(1)**.

```python
class Solution:
    def maxProfit(self, prices: list[int]) -> int:
        low, best = prices[0], 0
        for p in prices:
            low = min(low, p)
            best = max(best, p - low)
        return best
```

# Tests

```python
def edge():
    return [[[5]], [[7, 6, 4, 3, 1]], [[1, 2]], [[2, 1, 4]], [[3, 3, 3]], [[2, 4, 1, 3]]]

def random_case(rng):
    return [[rng.randint(0, 20) for _ in range(rng.randint(1, 10))]]

def perf(rng):
    return [[list(range(100000, 0, -1))]]
```
