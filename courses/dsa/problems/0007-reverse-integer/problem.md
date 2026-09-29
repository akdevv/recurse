---
lc: 7
title: "Reverse Integer"
difficulty: "Medium"
patterns: ["digit-math"]
lcTags: ["math"]
entry: {"method": "reverse", "params": [{"name": "x", "type": "integer"}], "returns": "integer"}
examples: ["123", "-123", "120"]
---

Given a signed 32-bit integer `x`, return `x` *with its digits reversed*. If reversing `x` causes the value to go outside the signed 32-bit integer range `[-2³¹, 2³¹ - 1]`, then return `0`.

**Assume the environment does not allow you to store 64-bit integers (signed or unsigned).**

**Example 1:**

```
Input: x = 123
Output: 321
```

**Example 2:**

```
Input: x = -123
Output: -321
```

**Example 3:**

```
Input: x = 120
Output: 21
```

**Constraints:**

- `-2³¹ <= x <= 2³¹ - 1`

# Starter

```python
class Solution:
    def reverse(self, x: int) -> int:
        
```

# Hints

1. Handle the sign separately: reverse abs(x), then put the sign back.
2. After reversing, check the 32-bit range [-2**31, 2**31 - 1] and return 0 if outside.

# Key points

- pull digits with % 10 / // 10, push with rev * 10 + d
- handle sign separately (Python's % on negatives differs from C/Java)
- check the 32-bit bounds; in Java/C++ you must check *before* the multiply to avoid overflow

# Solution: string · Reverse the string · O(d) · O(d) · reference

## Idea
Strip the sign, reverse the digits as a string, convert back, reapply the sign, then check the 32-bit range.

## Complexity
- **Time: O(d)**, **Space: O(d)** (d = digits ≤ 10).

```python
class Solution:
    def reverse(self, x: int) -> int:
        sign = -1 if x < 0 else 1
        r = sign * int(str(abs(x))[::-1])
        return r if -2**31 <= r <= 2**31 - 1 else 0
```

# Solution: math · Pop and push digits · O(d) · O(1)

## Idea
Same digit loop as Palindrome Number: pop with `% 10`, push with `rev * 10 + digit`.

## Python gotcha
`-123 % 10` is `7` in Python (not `-3` like C/Java), so work on `abs(x)` and reapply the sign.

## Interview note
The real test is overflow. The problem says you *can't store* 64-bit integers, so in Java/C++ you check `rev > (2³¹-1) // 10` **before** multiplying. Python ints never overflow, so we check at the end, but mention this out loud.

## Complexity
- **Time: O(d)**, **Space: O(1)**

```python
class Solution:
    def reverse(self, x: int) -> int:
        sign = -1 if x < 0 else 1
        x, rev = abs(x), 0
        while x:
            rev = rev * 10 + x % 10
            x //= 10
        rev *= sign
        return rev if -2**31 <= rev <= 2**31 - 1 else 0
```

# Tests

```python
def edge():
    return [[0], [-1], [120], [1534236469], [-2147483648], [2147483647], [1463847412], [-1463847412], [1563847412]]

def random_case(rng):
    return [rng.randint(-2**31, 2**31 - 1) if rng.random() < 0.7 else rng.randint(-1000, 1000)]
```
