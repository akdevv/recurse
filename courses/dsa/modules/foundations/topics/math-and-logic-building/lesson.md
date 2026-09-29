## Core idea

**A number is a stack of digits. `% 10` peeks at the top (last digit), `// 10` pops it.** Most "number" warm-ups come down to this loop, plus two classic algorithms: Euclid's GCD and the Sieve of Eratosthenes.

## Intuition

`1234 % 10 = 4` is the remainder after removing every full ten, which is the last digit.
`1234 // 10 = 123` shifts everything one place right, dropping the last digit.
Going the other way, `rev * 10 + d` shifts left and puts `d` in the ones place. **Pop from one number, push onto another** = reversing.

## Visualization

Reversing 1221 digit by digit to check whether it's a palindrome:

```viz
digit-reverse
```

The sieve crosses out multiples instead of testing each number:

```viz
sieve
```

## Template code

```python
# 1. digit loop (reverse / sum / count digits)
def digits_reversed(x):
    rev = 0
    while x > 0:
        d = x % 10          # last digit
        rev = rev * 10 + d  # push onto rev
        x //= 10            # pop from x
    return rev

# 2. GCD, Euclid's algorithm
def gcd(a, b):
    while b:
        a, b = b, a % b
    return a

# 3. primality test: divisors only up to √n
def is_prime(n):
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True

# 4. all primes below n: Sieve of Eratosthenes
def primes_below(n):
    is_p = [True] * max(n, 2)
    is_p[0] = is_p[1] = False
    for p in range(2, int(n ** 0.5) + 1):
        if is_p[p]:
            for m in range(p * p, n, p):
                is_p[m] = False
    return [i for i in range(n) if is_p[i]]
```

## Complexity

| Algorithm | Time | Space | Why |
|---|---|---|---|
| digit loop | O(d) = O(log n) | O(1) | one iteration per digit; n has ⌊log₁₀ n⌋ + 1 digits |
| Euclid GCD | O(log min(a, b)) | O(1) | the numbers at least halve every two steps |
| is_prime | O(√n) | O(1) | a factor above √n pairs with one below it |
| sieve | O(n log log n) | O(n) | each composite gets crossed out by its prime factors |

## When to use it

- "Reverse / palindrome / sum of digits / count digits" → **digit loop**
- "Common divisor, simplify a fraction, lcm" → **Euclid** (lcm(a, b) = a · b // gcd(a, b))
- "Is n prime?" → **√n trial division**
- "Count / list primes up to n" (many queries) → **sieve**, trading O(n) memory for speed

## Common traps

- **Negative numbers in Python**: `-123 % 10 == 7` and `-123 // 10 == -13`. Take `abs(x)` and reapply the sign
- **Trailing zeros**: reversing 120 gives 21, and 120 is not a palindrome. Any positive number ending in 0 is not a palindrome
- **Overflow**: Python ints never overflow, but interviewers may ask about 32-bit limits (Reverse Integer). Say how you'd check *before* multiplying in Java/C++
- Loop condition `d * d <= n`, not `d < n`: that's the difference between O(√n) and O(n)
- The sieve starts crossing out at `p * p`, not `2 * p` (smaller multiples are already done)
