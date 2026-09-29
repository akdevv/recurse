## Core idea

**Integers are rows of bits, and the bitwise operators (`&`, `|`, `^`, `~`, `<<`, `>>`) work on all bits at once in O(1).** A handful of identities solve a whole family of interview questions: `x ^ x = 0`, `n & (n − 1)` clears the lowest set bit, `n & 1` reads the last bit, `1 << k` is a mask for bit k.

## Intuition

Think of a number as a row of light switches: 44 is `101100`. AND keeps a light on only if it's on in both rows, OR if it's on in either, XOR if it's on in exactly one. Shifting slides the whole row left (×2) or right (÷2).

XOR is the star: it's its own undo. Flip a switch twice and it's back where it started. That's why XOR-ing a list where everything appears twice except one number leaves exactly that number.

## Visualization

Counting set bits by repeatedly clearing the lowest one:

```viz
count-bits
```

XOR cancels pairs, leaving the single number:

```viz
xor-single
```

## Template code

```python
n & 1                  # last bit: 1 if odd
n >> 1                 # divide by 2 (floor)
n << k                 # multiply by 2^k
(n >> k) & 1           # read bit k
n | (1 << k)           # set bit k
n & ~(1 << k)          # clear bit k
n ^ (1 << k)           # flip bit k
n & (n - 1)            # clear the lowest set bit
n & -n                 # isolate the lowest set bit
n > 0 and n & (n - 1) == 0      # power of two?

# Count bits
count = 0
while n:
    n &= n - 1
    count += 1
# (or bin(n).count("1"), or n.bit_count() in Python 3.10+)

# Counting bits for 0..n with DP
ans = [0] * (n + 1)
for i in range(1, n + 1):
    ans[i] = ans[i >> 1] + (i & 1)

# Single number
from functools import reduce
from operator import xor
reduce(xor, nums)

# Reverse 32 bits
res = 0
for _ in range(32):
    res = (res << 1) | (n & 1)
    n >>= 1

# Add without +: sum = a ^ b, carry = (a & b) << 1, repeat
# (Python ints are unbounded: mask with 0xFFFFFFFF for 32-bit behaviour)
```

## Complexity

Each operator is **O(1)** on fixed-width integers. Loops over the bits of a 32-bit number are O(32) = O(1). Clearing the lowest bit repeatedly costs O(number of set bits).

## When to use it

- **"Every element appears twice except one"** → XOR everything
- **"Missing number in 0..n"** → XOR indexes and values (or sum formula)
- **"Count 1-bits", "power of two"** → `n & (n − 1)`
- **"Counting bits for 0..n"** → DP with `i >> 1` or `i & (i − 1)`
- **Binary strings (Add Binary)** → column addition with a carry
- **Subsets of a small set** → bitmask `0..2ⁿ − 1`, bit i = "element i is included"

## Common traps

- Operator precedence: `n & 1 == 0` is `n & (1 == 0)`; write `(n & 1) == 0`
- Python ints are unbounded and negative numbers have infinitely many leading 1s: mask with `0xFFFFFFFF` to mimic 32-bit
- `~n` in Python is `-n - 1`, not "flip 32 bits"
- Using `>>` on negative numbers expecting a logical shift (Python's is arithmetic)
- Forgetting leading zeros when reversing bits: always loop exactly 32 times
