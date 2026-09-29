---
lc: 50
title: "Pow(x, n)"
difficulty: "Medium"
patterns: ["recursion", "divide-and-conquer"]
lcTags: ["math", "recursion"]
compare: "float"
entry: {"method": "myPow", "params": [{"name": "x", "type": "double"}, {"name": "n", "type": "integer"}], "returns": "double"}
examples: ["2.00000\n10", "2.10000\n3", "2.00000\n-2"]
---

Implement [pow(x, n)](http://www.cplusplus.com/reference/valarray/pow/), which calculates `x` raised to the power `n` (i.e., `xⁿ`).

**Example 1:**

```
Input: x = 2.00000, n = 10
Output: 1024.00000
```

**Example 2:**

```
Input: x = 2.10000, n = 3
Output: 9.26100
```

**Example 3:**

```
Input: x = 2.00000, n = -2
Output: 0.25000
Explanation: 2-2 = 1/22 = 1/4 = 0.25
```

**Constraints:**

- `-100.0 < x < 100.0`
- `-2³¹ <= n <= 2³¹-1`
- `n` is an integer.
- Either `x` is not zero or `n > 0`.
- `-10⁴ <= xⁿ <= 10⁴`

# Starter

```python
class Solution:
    def myPow(self, x: float, n: int) -> float:
        
```

# Hints

1. Multiplying x by itself n times is O(n). n can be 2³¹. How can you reuse x^(n/2)?
2. x^n = (x^(n//2))², times one extra x if n is odd. Negative n: compute x^(-n) and take 1 / that.

# Key points

- naive loop is O(n), too slow for n = 2³¹
- fast power: x^n = half * half (* x if odd), half = x^(n//2) computed ONCE
- O(log n) time and stack depth
- negative exponent → 1 / x^(-n)

# Solution: loop · Multiply n times · O(n) · O(1) · slow

## Idea
Multiply `x` into the result n times; for negative n use `1/x`.

## Complexity
- **Time: O(n)**: with n = 2³¹ − 1 that's 2 billion multiplications → Time Limit Exceeded.
- **Space: O(1)**

```python
class Solution:
    def myPow(self, x: float, n: int) -> float:
        if n < 0:
            x, n = 1 / x, -n
        result = 1.0
        for _ in range(n):
            result *= x
        return result
```

# Solution: fast-power · Fast power (recursive halving) · O(log n) · O(log n) · reference

## Idea
`x^10 = (x^5)²` and `x^5 = (x^2)² · x`. Each call **halves** n. Compute `half` **once** and square it. Calling `power(x, n//2)` twice would bring it back to O(n).

```
2^10 → 2^5 → 2^2 → 2^1 → 2^0
```

This is **divide and conquer**: split the problem, solve the half, combine.

## Complexity
- **Time: O(log n)**: ~31 calls for n = 2³¹.
- **Space: O(log n)**: recursion depth.

```python
class Solution:
    def myPow(self, x: float, n: int) -> float:
        def power(x, n):
            if n == 0:
                return 1.0
            half = power(x, n // 2)
            return half * half if n % 2 == 0 else half * half * x

        return power(x, n) if n >= 0 else 1 / power(x, -n)
```

# Tests

```python
def edge():
    return [[1.0, 0], [0.0, 5], [2.0, -2], [-2.0, 3], [1.0, 2**31 - 1], [-1.0, -2**31], [2.0, -2**31], [0.5, 10]]

def random_case(rng):
    while True:
        x = round(rng.uniform(-2, 2), 5)
        n = rng.randint(-20, 20)
        if x == 0 and n <= 0:
            continue
        if abs(x) ** n <= 10**4 and (n >= 0 or abs(x) > 1e-3):
            return [x, n]

def perf(rng):
    return [[1.0, 2**31 - 1], [-1.0, -2**31], [1.00001, 123456]]
```
