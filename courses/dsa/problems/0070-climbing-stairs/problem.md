---
lc: 70
title: "Climbing Stairs"
difficulty: "Easy"
patterns: ["dynamic-programming"]
lcTags: ["math", "dynamic-programming", "memoization"]
entry: {"method": "climbStairs", "params": [{"name": "n", "type": "integer"}], "returns": "integer"}
examples: ["2", "3"]
lcHints: ["To reach nth step, what could have been your previous steps? (Think about the step sizes)"]
---

You are climbing a staircase. It takes `n` steps to reach the top.

Each time you can either climb `1` or `2` steps. In how many distinct ways can you climb to the top?

**Example 1:**

```
Input: n = 2
Output: 2
Explanation: There are two ways to climb to the top.
1. 1 step + 1 step
2. 2 steps
```

**Example 2:**

```
Input: n = 3
Output: 3
Explanation: There are three ways to climb to the top.
1. 1 step + 1 step + 1 step
2. 1 step + 2 steps
3. 2 steps + 1 step
```

**Constraints:**

- `1 <= n <= 45`

# Starter

```python
class Solution:
    def climbStairs(self, n: int) -> int:
        
```

# Hints

1. To reach step n, your last move was either 1 step (from n − 1) or 2 steps (from n − 2).
2. ways(n) = ways(n − 1) + ways(n − 2), with ways(1) = 1 and ways(2) = 2. Keep only the last two values.

# Key points

- recurrence: f(n) = f(n - 1) + f(n - 2) (Fibonacci)
- plain recursion is O(2ⁿ); memoization or bottom-up makes it O(n)
- two variables → O(1) space

# Solution: recursion · Recursion · O(n) · O(1) · reference

We define `f[i]` to represent the number of ways to climb to the i-th step, then `f[i]` can be transferred from `f[i - 1]` and `f[i - 2]`, that is:

```
f[i] = f[i - 1] + f[i - 2]
```

The initial conditions are `f[0] = 1` and `f[1] = 1`, that is, the number of ways to climb to the 0th step is 1, and the number of ways to climb to the 1st step is also 1.

The answer is `f[n]`.

Since `f[i]` is only related to `f[i - 1]` and `f[i - 2]`, we can use two variables a and b to maintain the current number of ways, reducing the space complexity to O(1).

The time complexity is O(n), and the space complexity is O(1).

```python
class Solution:
    def climbStairs(self, n: int) -> int:
        a, b = 0, 1
        for _ in range(n):
            a, b = b, a + b
        return b
```

# Tests

```python

```
