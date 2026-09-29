---
lc: 191
title: "Number of 1 Bits"
difficulty: "Easy"
patterns: ["bit-manipulation"]
lcTags: ["divide-and-conquer", "bit-manipulation"]
entry: {"method": "hammingWeight", "params": [{"name": "n", "type": "integer"}], "returns": "integer"}
examples: ["11", "128", "2147483645"]
---

Given a positive integer `n`, write a function that returns the number of set bits in its binary representation (also known as the [Hamming weight](http://en.wikipedia.org/wiki/Hamming_weight)).

**Example 1:**

**Input:** n = 11

**Output:** 3

**Explanation:**

The input binary string **1011** has a total of three set bits.

**Example 2:**

**Input:** n = 128

**Output:** 1

**Explanation:**

The input binary string **10000000** has a total of one set bit.

**Example 3:**

**Input:** n = 2147483645

**Output:** 30

**Explanation:**

The input binary string **1111111111111111111111111111101** has a total of thirty set bits.

**Constraints:**

- `1 <= n <= 2³¹ - 1`

**Follow up:** If this function is called many times, how would you optimize it?

# Starter

```python
class Solution:
    def hammingWeight(self, n: int) -> int:
        
```

# Hints

1. n & (n − 1) clears the lowest set bit. How many times can you do that before n becomes 0?
2. count = 0; while n: n &= n − 1; count += 1. (Or check n & 1 and shift right 32 times.)

# Key points

- n & (n - 1) removes the lowest 1-bit
- loop runs once per set bit
- bin(n).count("1") works in Python but explain the bit trick

# Solution: solution-1 · Clear the lowest set bit (n & (n − 1)) · O(log n) · O(1) · reference

## Idea
`n & (n − 1)` clears the lowest 1-bit. Count how many times you can do that before n reaches 0: one step per set bit.

## Complexity
- **Time: O(log n)**
- **Space: O(1)**

```python
class Solution:
    def hammingWeight(self, n: int) -> int:
        ans = 0
        while n:
            n &= n - 1
            ans += 1
        return ans
```

# Solution: solution-2 · Subtract the lowest set bit (n & −n) · O(log n) · O(1)

## Idea
`n & −n` isolates the lowest 1-bit. Subtracting it removes that bit, so the loop again runs once per set bit.

## Complexity
- **Time: O(log n)**
- **Space: O(1)**

```python
class Solution:
    def hammingWeight(self, n: int) -> int:
        ans = 0
        while n:
            n -= n & -n
            ans += 1
        return ans
```

# Tests

```python

```
