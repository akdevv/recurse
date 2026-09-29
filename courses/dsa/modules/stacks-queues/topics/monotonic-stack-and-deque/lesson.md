## Core idea

**Keep a stack whose values are always sorted (e.g. decreasing from bottom to top). When a new element breaks the order, pop until it fits, and every pop is an answer: the new element is the popped one's "next greater".** Each element is pushed and popped once, so "next greater/smaller" for every element costs O(n) instead of O(n²).

## Intuition

People standing in a queue looking right, each waiting to see someone taller. When a tall person arrives, everyone shorter at the back of the line finally sees someone taller: they're answered and leave. A short person arriving answers nobody and just joins the end.

Why pop them for good? A shorter person standing behind a taller, closer one can never be the answer for anyone arriving later: the taller one blocks the view. Keeping only the useful candidates is what makes the stack sorted.

## Visualization

Daily Temperatures: days waiting for a warmer day:

```viz
daily-temps
```

Sliding window maximum: the same idea with a deque, plus dropping indexes that leave the window:

```viz
window-max
```

## Template code

```python
# Next greater element to the right (for every index)
ans = [-1] * n
stack = []                             # indexes, values decreasing
for i, x in enumerate(nums):
    while stack and nums[stack[-1]] < x:
        ans[stack.pop()] = x           # x is their next greater
    stack.append(i)

# Previous smaller / next smaller (histogram): flip the comparison
# Largest rectangle: when a bar is popped, its right boundary is i,
# its left boundary is the new stack top.

# Sliding window maximum with a decreasing deque of indexes
from collections import deque
dq = deque()
for i, x in enumerate(nums):
    while dq and nums[dq[-1]] <= x:
        dq.pop()                       # smaller & older: useless
    dq.append(i)
    if dq[0] <= i - k:
        dq.popleft()                   # left the window
    if i >= k - 1:
        out.append(nums[dq[0]])

# Online span (Stock Spanner): store (price, span) and absorb smaller ones
```

## Complexity

| Task | Brute force | Monotonic stack / deque |
|---|---|---|
| next greater for every element | O(n²) | **O(n)** |
| largest rectangle in a histogram | O(n²) | **O(n)** |
| max of every window of size k | O(n·k) | **O(n)** |

The loop-inside-a-loop is still O(n) because each index is pushed once and popped at most once over the whole run.

## When to use it

- **"Next greater / next smaller / previous greater"** → monotonic stack
- **"How many days until…", "span of days"** → store indexes (or spans), not just values
- **"Largest rectangle", "trapping water" style boundaries** → nearest smaller on both sides
- **"Max/min of every sliding window"** → monotonic deque
- **Cars/fleets merging, things blocked by something ahead** → stack of the ones still "visible"

## Common traps

- Storing values when you need distances: store indexes
- Mixing up `<` and `<=`: decide how equal values should behave (strictly greater vs greater-or-equal)
- Forgetting leftovers: elements still on the stack at the end have no answer (−1 or 0)
- Deque: removing expired indexes from the back instead of the front
- Histogram: forgetting a final 0-height bar (or a cleanup loop) to flush the stack
