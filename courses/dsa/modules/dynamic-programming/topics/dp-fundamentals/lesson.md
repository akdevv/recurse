## Core idea

**Dynamic programming = recursion where the same subproblems repeat, plus remembering each answer so it's computed only once.** Define a state (usually an index), write how its answer comes from smaller states, and either cache the recursion (memoization, top-down) or fill a table from the base cases up (tabulation, bottom-up).

## Intuition

Someone writes 1 + 1 + 1 + 1 + 1 on a board and asks for the total: you count 5. They add "+ 1" and ask again: you say 6 instantly, without recounting. You remembered the previous answer. That's all DP is.

Climbing stairs taking 1 or 2 steps: the ways to reach step n are the ways to reach n − 1 (then 1 step) plus the ways to reach n − 2 (then 2 steps). Written as plain recursion, ways(3) gets recomputed again and again, exponentially many times. Remember each answer and it's n calls.

A recipe that works for most DP problems:
1. **State**: what does `dp[i]` mean? ("number of ways to reach step i")
2. **Choices**: what can happen last at state i? (came from i − 1 or i − 2)
3. **Combine**: sum for counting, min/max for optimising
4. **Base cases** and the **order** to fill the table

## Visualization

Memoization: the recursion tree stops at every already-solved subproblem:

```viz
memo-tree
```

Tabulation: the same recurrence filled from the smallest state up:

```viz
tabulation
```

## Template code

```python
from functools import cache

# 1. Plain recursion: correct, exponential
def ways(n):
    if n <= 1: return 1
    return ways(n - 1) + ways(n - 2)

# 2. Memoization (top-down): add a cache
@cache
def ways(n):
    if n <= 1: return 1
    return ways(n - 1) + ways(n - 2)

# 3. Tabulation (bottom-up): a table filled in order
dp = [0] * (n + 1)
dp[0] = dp[1] = 1
for i in range(2, n + 1):
    dp[i] = dp[i - 1] + dp[i - 2]

# 4. Space optimisation: keep only what the recurrence reads
a, b = 1, 1
for _ in range(n - 1):
    a, b = b, a + b
```

## Complexity

**Time = number of states × work per state.** Space = the table size (or recursion depth + cache).

| Version | Time | Space |
|---|---|---|
| plain recursion (stairs / Fibonacci) | O(2ⁿ) | O(n) stack |
| memoization | O(n) | O(n) cache + O(n) stack |
| tabulation | O(n) | O(n) |
| rolling variables | O(n) | **O(1)** |

## When to use it

- **"Number of ways to…"**, **"minimum/maximum cost to…"**, **"can you reach / is it possible…"** → DP candidates
- **Choices at each step whose effects add up** (take/skip, 1 or 2 steps) → define the state and recurrence
- **Recursion that recomputes the same arguments** → add `@cache`
- **Greedy has a counterexample** → DP
- **"List every solution"** → that's backtracking, not DP (DP counts or optimises)

## Common traps

- Unclear state definition: write down in words what `dp[i]` means before coding
- Wrong base cases (dp[0] for "ways" is usually 1: one way to do nothing)
- Filling the table in an order where `dp[i]` reads values not computed yet
- `@cache` on functions with list arguments: lists aren't hashable, pass indexes instead
- Deep recursion in Python: memoized recursion on n = 10⁵ can hit the recursion limit; use tabulation
