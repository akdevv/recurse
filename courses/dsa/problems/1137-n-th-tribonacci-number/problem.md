---
lc: 1137
title: "N-th Tribonacci Number"
difficulty: "Easy"
patterns: ["dynamic-programming"]
lcTags: ["math", "dynamic-programming", "memoization"]
entry: {"method": "tribonacci", "params": [{"name": "n", "type": "integer"}], "returns": "integer"}
examples: ["4", "25"]
lcHints: ["Make an array F of length 38, and set F[0] = 0, F[1] = F[2] = 1.", "Now write a loop where you set F[n+3] = F[n] + F[n+1] + F[n+2], and return F[n]."]
---

The Tribonacci sequence T<sub>n</sub> is defined as follows:

T₀ = 0, T₁ = 1, T₂ = 1, and T<sub>n+3</sub> = T<sub>n</sub> + T<sub>n+1</sub> + T<sub>n+2</sub> for n >= 0.

Given `n`, return the value of T<sub>n</sub>.

**Example 1:**

```
Input: n = 4
Output: 4
Explanation:
T_3 = 0 + 1 + 1 = 2
T_4 = 1 + 1 + 2 = 4
```

**Example 2:**

```
Input: n = 25
Output: 1389537
```

**Constraints:**

- `0 <= n <= 37`
- The answer is guaranteed to fit within a 32-bit integer, ie. `answer <= 2^31 - 1`.

# Starter

```python
class Solution:
    def tribonacci(self, n: int) -> int:
        
```

# Hints

1. Each term is the sum of the previous three. You only need to remember three numbers.
2. a, b, c = 0, 1, 1; repeat n − 2 times: a, b, c = b, c, a + b + c. Handle n = 0, 1, 2 directly.

# Key points

- bottom-up with a rolling window of 3 values
- O(n) time, O(1) space
- naive recursion repeats work exponentially

# Solution: dynamic-programming · Dynamic Programming · O(n) · O(1) · reference

According to the recurrence relation given in the problem, we can use dynamic programming to solve it.

We define three variables a, b, c to represent `T_{n-3}`, `T_{n-2}`, `T_{n-1}`, respectively, with initial values of 0, 1, 1.

Then we decrease n to 0, updating the values of a, b, c each time, until n is 0, at which point the answer is a.

The time complexity is O(n), and the space complexity is O(1). Here, n is the given integer.

```python
class Solution:
    def tribonacci(self, n: int) -> int:
        a, b, c = 0, 1, 1
        for _ in range(n):
            a, b, c = b, c, a + b + c
        return a
```

# Tests

```python
def edge():
    return [[0], [1], [2], [3], [4], [25], [37]]

def random_case(rng):
    return [rng.randint(0, 37)]
```
