---
lc: 202
title: "Happy Number"
difficulty: "Easy"
patterns: ["fast-slow-pointers"]
lcTags: ["hash-table", "math", "two-pointers", "floyds-cycle-finding-algorithm"]
entry: {"method": "isHappy", "params": [{"name": "n", "type": "integer"}], "returns": "boolean"}
examples: ["19", "2"]
---

Write an algorithm to determine if a number `n` is happy.

A **happy number** is a number defined by the following process:

- Starting with any positive integer, replace the number by the sum of the squares of its digits.
- Repeat the process until the number equals 1 (where it will stay), or it **loops endlessly in a cycle** which does not include 1.
- Those numbers for which this process **ends in 1** are happy.

Return `true` *if* `n` *is a happy number, and* `false` *if not*.

**Example 1:**

```
Input: n = 19
Output: true
Explanation:
12 + 92 = 82
82 + 22 = 68
62 + 82 = 100
12 + 02 + 02 = 1
```

**Example 2:**

```
Input: n = 2
Output: false
```

**Constraints:**

- `1 <= n <= 2³¹ - 1`

# Starter

```python
class Solution:
    def isHappy(self, n: int) -> bool:
        
```

# Hints

1. Repeating "sum of squares of digits" either reaches 1 or loops forever. How do you detect a loop?
2. Treat it like a linked list: slow applies the step once, fast twice. If they meet at something other than 1, it's not happy. (A seen set also works.)

# Key points

- the sequence of numbers is an implicit linked list
- a cycle that isn't 1 means not happy; detect with a set or Floyd's fast/slow
- values drop quickly below ~243, so it's fast either way

# Solution: solution-1 · Seen set · O(log n) · O(log n) · reference

## Idea
Keep applying "sum of squared digits". Store every number seen: reaching 1 means happy, seeing a number again means a loop that never reaches 1.

## Complexity
- **Time: O(log n)**
- **Space: O(log n)**

```python
class Solution:
    def isHappy(self, n: int) -> bool:
        vis = set()
        while n != 1 and n not in vis:
            vis.add(n)
            x = 0
            while n:
                n, v = divmod(n, 10)
                x += v * v
            n = x
        return n == 1
```

# Solution: solution-2 · Fast and slow pointers · O(log n) · O(1)

## Idea
The sequence behaves like a linked list. Move `slow` one step and `fast` two steps; they must meet. If they meet at 1 the number is happy, otherwise they met inside a cycle.

## Complexity
- **Time: O(log n)**
- **Space: O(1)**

```python
class Solution:
    def isHappy(self, n: int) -> bool:
        def next(x):
            y = 0
            while x:
                x, v = divmod(x, 10)
                y += v * v
            return y

        slow, fast = n, next(n)
        while slow != fast:
            slow, fast = next(slow), next(next(fast))
        return slow == 1
```

# Tests

```python

```
