## Core idea

**Recursion = solve a problem by trusting a smaller copy of the same problem to be solved, plus a base case that stops the chain.**

## Intuition

You're in a movie theater line and want to know your row number. You ask the person in front: "what row are you in?" They ask the person in front of *them*, and so on, until the front person says "row 1" (**base case**). The answers come back: 2, 3, 4… each person adds 1 (**recursive case**).

Nobody needed to see the whole theater. Each person solved a tiny problem and **trusted** the rest.

Three questions for every recursive function:
1. **What's the smallest input I can answer directly?** → base case
2. **How does a smaller answer help me build mine?** → recursive case
3. **Does every call move toward the base case?** → otherwise it never ends

## Visualization

The call stack while computing `factorial(4)`: calls pile up until the base case, then return values flow back down.

```viz
factorial-stack
```

The recursion tree for naive `fib(4)`: notice `fib(2)` computed twice, `fib(1)` three times. That repetition is why it's exponential.

```viz
fib-tree
```

## Template code

```python
def solve(problem):
    if is_small_enough(problem):          # 1. base case(s) first
        return direct_answer(problem)
    smaller = shrink(problem)             # 2. make progress toward the base case
    sub = solve(smaller)                  # 3. trust the recursive call
    return combine(problem, sub)          # 4. build your answer from it

# examples
def factorial(n):
    if n <= 1:
        return 1
    return n * factorial(n - 1)

def fib(n):                               # two recursive calls → a tree of calls
    if n < 2:
        return n
    return fib(n - 1) + fib(n - 2)

from functools import cache
@cache                                    # memoization: each fib(k) computed once
def fib_memo(n):
    if n < 2:
        return n
    return fib_memo(n - 1) + fib_memo(n - 2)
```

## Complexity

**Time = (number of calls) × (work per call).** **Space = maximum stack depth** (+ any memo).

| Function | Calls | Time | Space (depth) |
|---|---|---|---|
| factorial(n) | n | O(n) | O(n) |
| fib(n), naive | ~2ⁿ | O(2ⁿ) | O(n) |
| fib(n), memoized | n | O(n) | O(n) |
| power(x, n), halving | log n | O(log n) | O(log n) |

Draw the **recursion tree**: branching factor b, depth d → about bᵈ calls. One call per level (a chain) is linear; two calls per level that each shrink by 1 is exponential; halving each time is logarithmic.

## When to use it

- The problem is defined in terms of itself: factorials, Fibonacci, powers
- The data is recursive: **trees, nested lists, graphs** (Modules 7–10)
- "Try every choice": subsets, permutations → **backtracking** (Module 7)
- Split in half and combine → **divide and conquer** (merge sort, fast power)

Prefer iteration when the recursion is a simple chain and the input is large: Python's default recursion limit is **1000** frames.

## Common traps

- **Missing or wrong base case** → `RecursionError: maximum recursion depth exceeded`
- **Not shrinking the input** (calling `f(n)` inside `f(n)`)
- **Calling the same sub-problem twice when once is enough**: `power(x, n//2) * power(x, n//2)` is O(n); store `half` and square it for O(log n)
- **Forgetting stack space**: "no extra data structures" still costs O(depth) memory
- **Deep recursion in Python**: 10⁵ nested calls will crash; switch to a loop (Reverse String shows this)
- **Forgetting to return** the recursive result (`fib(n-1) + fib(n-2)` computed but not returned)
