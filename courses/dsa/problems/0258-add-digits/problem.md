---
lc: 258
title: "Add Digits"
difficulty: "Easy"
patterns: ["digit-math"]
lcTags: ["math", "simulation", "number-theory"]
entry: {"method": "addDigits", "params": [{"name": "num", "type": "integer"}], "returns": "integer"}
examples: ["38", "0"]
lcHints: ["A naive implementation of the above process is trivial. Could you come up with other methods?", "What are all the possible results?", "How do they occur, periodically or randomly?", "You may find this <a href=\"https://en.wikipedia.org/wiki/Digital_root\" target=\"_blank\">Wikipedia article</a> useful."]
---

Given an integer `num`, repeatedly add all its digits until the result has only one digit, and return it.

**Example 1:**

```
Input: num = 38
Output: 2
Explanation: The process is
38 --> 3 + 8 --> 11
11 --> 1 + 1 --> 2
Since 2 has only one digit, return it.
```

**Example 2:**

```
Input: num = 0
Output: 0
```

**Constraints:**

- `0 <= num <= 2³¹ - 1`

**Follow up:** Could you do it without any loop/recursion in `O(1)` runtime?

# Starter

```python
class Solution:
    def addDigits(self, num: int) -> int:
        
```

# Hints

1. Write a helper that sums the digits of a number once; repeat while the result has more than one digit.
2. Follow-up (O(1)): look at results for 1..20. The answer cycles 1..9, related to num % 9.

# Key points

- digit sum with % 10 and // 10, repeated until one digit
- digital root formula: 0 if num == 0, else 1 + (num - 1) % 9
- why: a number and its digit sum leave the same remainder mod 9

# Solution: simulate · Repeat digit sums · O(log n) · O(1) · reference

## Idea
Do exactly what the problem says: sum the digits, and repeat until one digit is left.

## Complexity
- **Time: O(log n)**: the first pass handles d ≈ log₁₀ n digits; each later pass works on a much smaller number (≤ 9d).
- **Space: O(1)**

```python
class Solution:
    def addDigits(self, num: int) -> int:
        while num >= 10:
            total = 0
            while num > 0:
                total += num % 10
                num //= 10
            num = total
        return num
```

# Solution: digital-root · Digital root formula · O(1) · O(1)

## Idea
10 ≡ 1 (mod 9), so every power of 10 ≡ 1 (mod 9). That means a number and **the sum of its digits have the same remainder mod 9**. Repeating keeps that remainder, and the final single digit (1..9) *is* that remainder, with 9 instead of 0.

`1 + (num - 1) % 9` maps 9 → 9, 18 → 9, 10 → 1, …; `num == 0` is the only way to get 0.

## Complexity
- **Time: O(1)**, **Space: O(1)**

Interview tip: lead with the simulation, then mention the math follow-up. Nobody expects you to derive this cold.

```python
class Solution:
    def addDigits(self, num: int) -> int:
        if num == 0:
            return 0
        return 1 + (num - 1) % 9
```

# Tests

```python
def edge():
    return [[0], [9], [10], [18], [19], [2**31 - 1]]

def random_case(rng):
    return [rng.choice([rng.randint(0, 100), rng.randint(0, 2**31 - 1)])]
```
