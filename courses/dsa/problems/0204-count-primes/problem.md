---
lc: 204
title: "Count Primes"
difficulty: "Medium"
patterns: ["number-theory"]
lcTags: ["array", "math", "enumeration", "number-theory", "primality-test", "sieve-theory", "prime-number-sieve"]
timeLimitMs: 4000
entry: {"method": "countPrimes", "params": [{"name": "n", "type": "integer"}], "returns": "integer"}
examples: ["10", "0", "1"]
lcHints: ["Checking all the integers in the range [1, n - 1] is not efficient. Think about a better approach.", "Since most of the numbers are not primes, we need a fast approach to exclude the non-prime integers.", "Use Sieve of Eratosthenes."]
---

Given an integer `n`, return *the number of prime numbers that are strictly less than* `n`.

**Example 1:**

```
Input: n = 10
Output: 4
Explanation: There are 4 prime numbers less than 10, they are 2, 3, 5, 7.
```

**Example 2:**

```
Input: n = 0
Output: 0
```

**Example 3:**

```
Input: n = 1
Output: 0
```

**Constraints:**

- `0 <= n <= 5 * 10⁶`

# Starter

```python
class Solution:
    def countPrimes(self, n: int) -> int:
        
```

# Hints

1. Checking each number for primality separately repeats a lot of work. Can you cross numbers *out* instead?
2. Sieve of Eratosthenes: for each prime p ≤ √n, mark p*p, p*p+p, … as not prime.

# Key points

- trial division is O(n√n), too slow for 5·10⁶
- sieve: mark multiples of each prime as composite
- start marking at p*p (smaller multiples are already marked), stop at √n
- O(n log log n) time, O(n) space

# Solution: trial-division · Test each number · O(n√n) · O(1) · slow

## Idea
For each k < n, try divisors 2..√k. (A factor above √k pairs with one below it, so √k is enough.)

## Complexity
- **Time: O(n√n)**: for n = 5·10⁶ that's ~10¹⁰ operations → Time Limit Exceeded.
- **Space: O(1)**

```python
class Solution:
    def countPrimes(self, n: int) -> int:
        def is_prime(k):
            if k < 2:
                return False
            d = 2
            while d * d <= k:
                if k % d == 0:
                    return False
                d += 1
            return True
        return sum(is_prime(k) for k in range(n))
```

# Solution: sieve · Sieve of Eratosthenes · O(n log log n) · O(n) · reference

## Idea
Assume everything is prime, then **cross out multiples** of each prime. Whatever survives is prime.

- Start at `p * p`: smaller multiples like `2p`, `3p` were already crossed out by 2, 3, …
- Stop when `p * p ≥ n`: any composite below n has a factor ≤ √n.
- `is_prime[p*p::p] = [False] * …` is slice assignment, which is much faster in Python than an inner loop.

## Complexity
- **Time: O(n log log n)**: n/2 + n/3 + n/5 + … (sum over primes) grows like n log log n, practically linear.
- **Space: O(n)** for the boolean array. Classic **time vs space trade-off**.

```python
class Solution:
    def countPrimes(self, n: int) -> int:
        if n < 3:
            return 0
        is_prime = [True] * n
        is_prime[0] = is_prime[1] = False
        p = 2
        while p * p < n:
            if is_prime[p]:
                is_prime[p * p :: p] = [False] * len(range(p * p, n, p))
            p += 1
        return sum(is_prime)
```

# Tests

```python
def edge():
    return [[0], [1], [2], [3], [10], [100]]

def random_case(rng):
    return [rng.randint(0, 3000)]

def perf(rng):
    return [[5 * 10**6], [4999999]]
```
