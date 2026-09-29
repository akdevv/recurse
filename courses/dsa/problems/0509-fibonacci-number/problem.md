---
lc: 509
title: "Fibonacci Number"
difficulty: "Easy"
patterns: ["recursion", "memoization"]
lcTags: ["math", "dynamic-programming", "recursion", "memoization"]
entry: {"method": "fib", "params": [{"name": "n", "type": "integer"}], "returns": "integer"}
examples: ["2", "3", "4"]
---

The **Fibonacci numbers**, commonly denoted `F(n)` form a sequence, called the **Fibonacci sequence**, such that each number is the sum of the two preceding ones, starting from `0` and `1`. That is,

```
F(0) = 0, F(1) = 1
F(n) = F(n - 1) + F(n - 2), for n > 1.
```

Given `n`, calculate `F(n)`.

**Example 1:**

```
Input: n = 2
Output: 1
Explanation: F(2) = F(1) + F(0) = 1 + 0 = 1.
```

**Example 2:**

```
Input: n = 3
Output: 2
Explanation: F(3) = F(2) + F(1) = 1 + 1 = 2.
```

**Example 3:**

```
Input: n = 4
Output: 3
Explanation: F(4) = F(3) + F(2) = 2 + 1 = 3.
```

**Constraints:**

- `0 <= n <= 30`

# Starter

```python
class Solution:
    def fib(self, n: int) -> int:
        
```

# Hints

1. The definition is already recursive: F(n) = F(n-1) + F(n-2). What are the base cases?
2. Plain recursion recomputes the same values again and again. Draw the tree for F(5). Cache results, or build up from F(0) and F(1).

# Key points

- base cases F(0)=0, F(1)=1, recursive case F(n-1)+F(n-2)
- naive recursion: the tree has ~2ⁿ calls, O(2ⁿ) time, O(n) stack depth
- memoization: each F(k) computed once → O(n)
- iterative with two variables → O(n) time, O(1) space

# Solution: recursive · Plain recursion · O(2ⁿ) · O(n)

## Idea
Translate the definition directly: base cases `F(0) = 0`, `F(1) = 1`, otherwise `F(n-1) + F(n-2)`.

## Complexity
- **Time: O(2ⁿ)**: each call makes two calls, so the recursion tree roughly doubles per level. `F(30)` makes ~1.6 million calls.
- **Space: O(n)**: the deepest path in the tree (the call stack), not the number of calls.

Look at the recursion tree: `F(3)` is computed twice, `F(2)` three times… That repeated work is what the next solutions remove.

```python
class Solution:
    def fib(self, n: int) -> int:
        if n < 2:
            return n
        return self.fib(n - 1) + self.fib(n - 2)
```

# Solution: memo · Recursion + memoization · O(n) · O(n)

## Idea
Same recursion, but **remember** each answer in a dict. The second time we need `F(k)`, it's a lookup.

This is **top-down dynamic programming** (Module 12). In Python you can also decorate with `@functools.cache`.

## Complexity
- **Time: O(n)**: each of F(0..n) is computed once.
- **Space: O(n)** for the memo + call stack.

```python
class Solution:
    def fib(self, n: int) -> int:
        memo = {0: 0, 1: 1}

        def f(k):
            if k not in memo:
                memo[k] = f(k - 1) + f(k - 2)
            return memo[k]

        return f(n)
```

# Solution: iterative · Bottom-up with two variables · O(n) · O(1) · reference

## Idea
Build up from the base cases. Each step only needs the **last two** values, so keep just two variables.

```
n:    0 1 2 3 4 5
a:    0 1 1 2 3 5
```

## Complexity
- **Time: O(n)**, **Space: O(1)**

Interview arc: recursive → "it's exponential because of repeated subproblems" → memo → iterative. That arc *is* the intro to DP.

```python
class Solution:
    def fib(self, n: int) -> int:
        a, b = 0, 1
        for _ in range(n):
            a, b = b, a + b
        return a
```

# Tests

```python
def edge():
    return [[0], [1], [2], [30]]

def random_case(rng):
    return [rng.randint(0, 20)]
```
