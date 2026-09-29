---
lc: 338
title: "Counting Bits"
difficulty: "Easy"
patterns: ["bit-manipulation", "dynamic-programming"]
lcTags: ["dynamic-programming", "bit-manipulation"]
entry: {"method": "countBits", "params": [{"name": "n", "type": "integer"}], "returns": "integer[]"}
examples: ["2", "5"]
lcHints: ["You should make use of what you have produced already.", "Divide the numbers in ranges like [2-3], [4-7], [8-15] and so on. And try to generate new range from previous.", "Or does the odd/even status of the number help you in calculating the number of 1s?"]
---

Given an integer `n`, return *an array* `ans` *of length* `n + 1` *such that for each* `i` (`0 <= i <= n`)*,* `ans[i]` *is the **number of*** `1`***'s** in the binary representation of* `i`.

Do not solve it with built-in functions (i.e., like `__builtin_popcount` in C++).

**Example 1:**

```
Input: n = 2
Output: [0,1,1]
Explanation:
0 --> 0
1 --> 1
2 --> 10
```

**Example 2:**

```
Input: n = 5
Output: [0,1,1,2,1,2]
Explanation:
0 --> 0
1 --> 1
2 --> 10
3 --> 11
4 --> 100
5 --> 101
```

**Constraints:**

- `0 <= n <= 10⁵`

**Follow up:**

- It is very easy to come up with a solution with a runtime of `O(n log n)`. Can you do it in linear time `O(n)` and possibly in a single pass?

# Starter

```python
class Solution:
    def countBits(self, n: int) -> list[int]:
        
```

# Hints

1. i >> 1 is i without its last bit, and you already know its count.
2. ans[i] = ans[i >> 1] + (i & 1). (Or ans[i] = ans[i & (i − 1)] + 1.)

# Key points

- reuse smaller answers: dp over bits
- ans[i] = ans[i >> 1] + (i & 1)
- O(n) time, one pass

# Solution: solution-1 · Count each number's bits · O(n log n) · O(1) · reference

## Idea
Count the set bits of every number from 0 to n with `bit_count()`. Simple, but each count costs O(log i).

## Complexity
- **Time: O(n log n)**
- **Space: O(1)**

```python
class Solution:
    def countBits(self, n: int) -> List[int]:
        return [i.bit_count() for i in range(n + 1)]
```

# Solution: solution-2 · DP with i & (i − 1) · O(n) · O(1)

## Idea
`i & (i − 1)` is i with its lowest 1-bit removed, a smaller number whose answer is already known. So `ans[i] = ans[i & (i − 1)] + 1`.

## Complexity
- **Time: O(n)**
- **Space: O(1)**

```python
class Solution:
    def countBits(self, n: int) -> List[int]:
        ans = [0] * (n + 1)
        for i in range(1, n + 1):
            ans[i] = ans[i & (i - 1)] + 1
        return ans
```

# Tests

```python

```
