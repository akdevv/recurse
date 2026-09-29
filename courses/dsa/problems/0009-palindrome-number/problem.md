---
lc: 9
title: "Palindrome Number"
difficulty: "Easy"
patterns: ["digit-math"]
lcTags: ["math"]
entry: {"method": "isPalindrome", "params": [{"name": "x", "type": "integer"}], "returns": "boolean"}
examples: ["121", "-121", "10"]
lcHints: ["Beware of overflow when you reverse the integer."]
---

Given an integer `x`, return `true` if `x` is a **palindrome**, and `false` otherwise.

**Example 1:**

```
Input: x = 121
Output: true
Explanation: 121 reads as 121 from left to right and from right to left.
```

**Example 2:**

```
Input: x = -121
Output: false
Explanation: From left to right, it reads -121. From right to left, it becomes 121-. Therefore it is not a palindrome.
```

**Example 3:**

```
Input: x = 10
Output: false
Explanation: Reads 01 from right to left. Therefore it is not a palindrome.
```

**Constraints:**

- `-2³¹ <= x <= 2³¹ - 1`

**Follow up:** Could you solve it without converting the integer to a string?

# Starter

```python
class Solution:
    def isPalindrome(self, x: int) -> bool:
        
```

# Hints

1. Negative numbers can never be palindromes. Why?
2. Build the reversed number with `rev = rev * 10 + x % 10`; x //= 10. Compare with the original (or reverse only half).

# Key points

- negatives are never palindromes ('-' only on one side)
- extract digits with % 10 and // 10
- string version is O(d) extra space; math version is O(1)
- d = number of digits = O(log₁₀ x)

# Solution: string · Convert to string · O(d) · O(d)

## Idea
Turn it into a string and compare with its reverse. `-121` → `"-121"` vs `"121-"` → not equal, so negatives are handled for free.

## Complexity
d = number of digits (≈ log₁₀ x).
- **Time: O(d)**
- **Space: O(d)** for the string.

The problem's follow-up asks to do it **without** converting to a string. That's the math solution.

```python
class Solution:
    def isPalindrome(self, x: int) -> bool:
        s = str(x)
        return s == s[::-1]
```

# Solution: math · Reverse the digits mathematically · O(d) · O(1) · reference

## Idea
`x % 10` gives the last digit; `x // 10` removes it. Push each popped digit onto `rev`: `rev = rev * 10 + digit`.

```
x=121 rev=0 → x=12 rev=1 → x=1 rev=12 → x=0 rev=121   121 == 121 ✓
```

## Complexity
- **Time: O(d)**, one loop per digit.
- **Space: O(1)**

Refinement: reverse only **half** the digits (stop when `rev >= x`), which avoids overflow in fixed-width languages.

```python
class Solution:
    def isPalindrome(self, x: int) -> bool:
        if x < 0:
            return False
        original, rev = x, 0
        while x > 0:
            rev = rev * 10 + x % 10
            x //= 10
        return rev == original
```

# Tests

```python
def edge():
    return [[0], [-1], [10], [11], [2**31 - 1], [-2**31], [1000000001], [123454321]]

def random_case(rng):
    if rng.random() < 0.4:  # build a palindrome
        half = str(rng.randint(1, 99999))
        return [int(half + half[::-1][rng.randint(0, 1):])]
    return [rng.randint(-1000, 10**9)]
```
