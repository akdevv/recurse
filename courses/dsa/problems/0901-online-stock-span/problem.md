---
lc: 901
title: "Online Stock Span"
difficulty: "Medium"
patterns: ["monotonic-stack"]
lcTags: ["stack", "design", "monotonic-stack", "data-stream"]
entry: {"method": "StockSpanner", "design": true, "params": [{"name": "operations", "type": "string[]"}, {"name": "arguments", "type": "list"}], "returns": "list"}
examples: ["[\"StockSpanner\",\"next\",\"next\",\"next\",\"next\",\"next\",\"next\",\"next\"]\r\n[[],[100],[80],[60],[70],[60],[75],[85]]\r"]
---

Design an algorithm that collects daily price quotes for some stock and returns **the span** of that stock's price for the current day.

The **span** of the stock's price in one day is the maximum number of consecutive days (starting from that day and going backward) for which the stock price was less than or equal to the price of that day.

- For example, if the prices of the stock in the last four days are `[7,2,1,2]` and the price of the stock today is 2, then the span of today is 3 because starting from today, the price of the stock was less than or equal to 2 for 3 consecutive days.
- Also, if the prices of the stock in the last four days is `[7,34,1,2]` and the price of the stock today is `8`, then the span of today is `3` because starting from today, the price of the stock was less than or equal `8` for `3` consecutive days.

Implement the `StockSpanner` class:

- `StockSpanner()` Initializes the object of the class.
- `int next(int price)` Returns the **span** of the stock's price given that today's price is `price`.

**Example 1:**

```
Input
["StockSpanner", "next", "next", "next", "next", "next", "next", "next"]
[[], [100], [80], [60], [70], [60], [75], [85]]
Output
[null, 1, 1, 1, 2, 1, 4, 6]

Explanation
StockSpanner stockSpanner = new StockSpanner();
stockSpanner.next(100); // return 1
stockSpanner.next(80);  // return 1
stockSpanner.next(60);  // return 1
stockSpanner.next(70);  // return 2
stockSpanner.next(60);  // return 1
stockSpanner.next(75);  // return 4, because the last 4 prices (including today's price of 75) were less than or equal to today's price.
stockSpanner.next(85);  // return 6
```

**Constraints:**

- `1 <= price <= 10⁵`
- At most `10⁴` calls will be made to `next`.

# Starter

```python
class StockSpanner:

    def __init__(self):
        

    def next(self, price: int) -> int:
        

# Your StockSpanner object will be instantiated and called as such:
# obj = StockSpanner()
# param_1 = obj.next(price)
```

# Hints

1. If today's price is ≥ yesterday's, today's span includes yesterday's whole span.
2. Keep a stack of (price, span). For a new price, pop while the top price ≤ price, adding their spans. Push (price, total span) and return it.

# Key points

- monotonic decreasing stack of (price, span)
- absorbed entries add their span, so each price is popped once
- amortized O(1) per call

# Solution: monotonic-stack · Monotonic Stack · O(n) · O(n) · reference

Based on the problem description, we know that for the current day's price price, we start from this price and look backwards to find the first price that is larger than this price. The difference in indices cnt between these two prices is the span of the current day's price.

This is actually a classic monotonic stack model, where we find the first element larger than the current element on the left.

We maintain a stack where the prices from the bottom to the top of the stack are monotonically decreasing. Each element in the stack is a `(price, cnt)` data pair, where price represents the price, and cnt represents the span of the current price.

When the price price appears, we compare it with the top element of the stack. If the price of the top element of the stack is less than or equal to price, we add the span cnt of the current day's price to the span of the top element of the stack, and then pop the top element of the stack. This continues until the price of the top element of the stack is greater than price, or the stack is empty.

Finally, we push `(price, cnt)` onto the stack and return cnt.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of times `next(price)` is called.

```python
class StockSpanner:
    def __init__(self):
        self.stk = []

    def next(self, price: int) -> int:
        cnt = 1
        while self.stk and self.stk[-1][0] <= price:
            cnt += self.stk.pop()[1]
        self.stk.append((price, cnt))
        return cnt

# Your StockSpanner object will be instantiated and called as such:
# obj = StockSpanner()
# param_1 = obj.next(price)
```

# Tests

```python
def edge():
    return [[["StockSpanner", "next", "next", "next", "next", "next", "next", "next"], [[], [100], [80], [60], [70], [60], [75], [85]]],
            [["StockSpanner", "next", "next", "next"], [[], [5], [5], [5]]]]

def random_case(rng):
    n = rng.randint(1, 12)
    return [["StockSpanner"] + ["next"] * n, [[]] + [[rng.randint(1, 10)] for _ in range(n)]]

def perf(rng):
    return [[["StockSpanner"] + ["next"] * 10000, [[]] + [[i] for i in range(1, 10001)]]]
```
