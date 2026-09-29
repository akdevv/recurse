---
lc: 69
title: "Sqrt(x)"
difficulty: "Easy"
patterns: ["binary-search"]
lcTags: ["math", "binary-search", "newtons-method"]
entry: {"method": "mySqrt", "params": [{"name": "x", "type": "integer"}], "returns": "integer"}
examples: ["4", "8"]
lcHints: ["Try exploring all integers. (Credits: @annujoshi)", "Use the sorted property of integers to reduced the search space. (Credits: @annujoshi)"]
---

Given a non-negative integer `x`, return *the square root of* `x` *rounded down to the nearest integer*. The returned integer should be **non-negative** as well.

You **must not use** any built-in exponent function or operator.

- For example, do not use `pow(x, 0.5)` in c++ or `x ** 0.5` in python.

**Example 1:**

```
Input: x = 4
Output: 2
Explanation: The square root of 4 is 2, so we return 2.
```

**Example 2:**

```
Input: x = 8
Output: 2
Explanation: The square root of 8 is 2.82842..., and since we round it down to the nearest integer, 2 is returned.
```

**Constraints:**

- `0 <= x <= 2³¹ - 1`

# Starter

```python
class Solution:
    def mySqrt(self, x: int) -> int:
        
```

# Hints

1. You want the largest integer r with r·r ≤ x. As r grows, r·r only grows.
2. Binary search r in [0, x]: if mid·mid ≤ x, mid is a candidate and you try higher; otherwise go lower.

# Key points

- answer = largest r with r*r <= x (a monotonic predicate)
- binary search over 0..x, O(log x)
- careful with x = 0 and x = 1
- Newton's method converges faster but binary search is the interview answer

# Solution: binary-search · Binary Search · O(log x) · O(1) · reference

We define the left boundary of the binary search as `l = 0` and the right boundary as `r = x`, then we search for the square root within the range `[l, r]`.

In each step of the search, we find the middle value `mid = (l + r + 1) / 2`. If `mid > x / mid`, it means the square root is within the range `[l, mid - 1]`, so we set `r = mid - 1`. Otherwise, it means the square root is within the range `[mid, r]`, so we set `l = mid`.

After the search ends, we return l.

The time complexity is O(log x), and the space complexity is O(1).

```python
class Solution:
    def mySqrt(self, x: int) -> int:
        l, r = 0, x
        while l < r:
            mid = (l + r + 1) >> 1
            if mid > x // mid:
                r = mid - 1
            else:
                l = mid
        return l
```

# Tests

```python

```
