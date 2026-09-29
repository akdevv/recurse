---
lc: 231
title: "Power of Two"
difficulty: "Easy"
patterns: ["recursion", "bit-manipulation"]
lcTags: ["math", "bit-manipulation", "recursion"]
entry: {"method": "isPowerOfTwo", "params": [{"name": "n", "type": "integer"}], "returns": "boolean"}
examples: ["1", "16", "3"]
---

Given an integer `n`, return *`true` if it is a power of two. Otherwise, return `false`*.

An integer `n` is a power of two, if there exists an integer `x` such that `n == 2ˣ`.

**Example 1:**

```
Input: n = 1
Output: true
Explanation: 20 = 1
```

**Example 2:**

```
Input: n = 16
Output: true
Explanation: 24 = 16
```

**Example 3:**

```
Input: n = 3
Output: false
```

**Constraints:**

- `-2³¹ <= n <= 2³¹ - 1`

**Follow up:** Could you solve it without loops/recursion?

# Starter

```python
class Solution:
    def isPowerOfTwo(self, n: int) -> bool:
        
```

# Hints

1. If n is even, is n a power of two exactly when n / 2 is? What's the base case?
2. Recursive: n == 1 → True; n <= 0 or odd → False; else recurse on n // 2. Bonus: n > 0 and n & (n - 1) == 0.

# Key points

- recursive: base cases n == 1 (True) and n <= 0 or odd (False), step n // 2
- O(log n) calls because n halves each time
- bit trick: a power of two has exactly one 1-bit, so n & (n-1) == 0

# Solution: recursive · Divide by two recursively · O(log n) · O(log n) · reference

## Idea
A power of two keeps halving cleanly down to 1. Anything odd (other than 1), zero or negative fails.

```
16 → 8 → 4 → 2 → 1 ✓        12 → 6 → 3 ✗ (odd)
```

## Complexity
- **Time: O(log n)**: n halves each call.
- **Space: O(log n)**: stack depth (≤ 31 here).

```python
class Solution:
    def isPowerOfTwo(self, n: int) -> bool:
        if n == 1:
            return True
        if n <= 0 or n % 2 == 1:
            return False
        return self.isPowerOfTwo(n // 2)
```

# Solution: bit-trick · n & (n - 1) · O(1) · O(1)

## Idea
Powers of two in binary: `1, 10, 100, 1000…`, exactly one 1-bit. Subtracting 1 flips that bit and all zeros after it (`1000 - 1 = 0111`), so `n & (n-1)` is 0 **only** for powers of two.

Full story in Module 14 (Bit Manipulation).

## Complexity
- **Time: O(1)**, **Space: O(1)**

```python
class Solution:
    def isPowerOfTwo(self, n: int) -> bool:
        return n > 0 and n & (n - 1) == 0
```

# Tests

```python
def edge():
    return [[1], [0], [-1], [-16], [2**30], [2**31 - 1], [-2**31], [3], [6]]

def random_case(rng):
    return [2 ** rng.randint(0, 30) if rng.random() < 0.4 else rng.randint(-100, 2**31 - 1)]
```
