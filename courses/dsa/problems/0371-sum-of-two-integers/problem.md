---
lc: 371
title: "Sum of Two Integers"
difficulty: "Medium"
patterns: ["bit-manipulation"]
lcTags: ["math", "bit-manipulation"]
entry: {"method": "getSum", "params": [{"name": "a", "type": "integer"}, {"name": "b", "type": "integer"}], "returns": "integer"}
examples: ["1\n2", "2\n3"]
---

Given two integers `a` and `b`, return *the sum of the two integers without using the operators* `+` *and* `-`.

**Example 1:**

```
Input: a = 1, b = 2
Output: 3
```

**Example 2:**

```
Input: a = 2, b = 3
Output: 5
```

**Constraints:**

- `-1000 <= a, b <= 1000`

# Starter

```python
class Solution:
    def getSum(self, a: int, b: int) -> int:
        
```

# Hints

1. XOR adds bits without carries; AND (shifted left) gives the carries. Repeat until there's no carry.
2. In Python, integers are unbounded, so mask with 0xFFFFFFFF each step and convert back to a negative number at the end if the sign bit is set.

# Key points

- sum without carry = a ^ b, carry = (a & b) << 1
- loop until carry is 0
- Python needs a 32-bit mask to emulate overflow for negatives

# Solution: solution-1 · XOR + carry with a 32-bit mask · O(1) · O(1) · reference

## Idea
`a ^ b` adds without carries and `(a & b) << 1` is the carry. Repeat until there's no carry. Python integers don't overflow, so every step is masked to 32 bits and the result is converted back to a negative number if bit 31 is set.

## Complexity
- **Time: O(1)**
- **Space: O(1)**

```python
class Solution:
    def getSum(self, a: int, b: int) -> int:
        a, b = a & 0xFFFFFFFF, b & 0xFFFFFFFF
        while b:
            carry = ((a & b) << 1) & 0xFFFFFFFF
            a, b = a ^ b, carry
        return a if a < 0x80000000 else ~(a ^ 0xFFFFFFFF)
```

# Tests

```python

```
