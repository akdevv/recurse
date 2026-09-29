## Core idea

**If you can look at the middle and decide which half can't contain the answer, throw that half away. Repeat.** n shrinks to 1 in log₂ n steps: a million elements take 20 looks.

## Intuition

Guessing a number between 1 and 100 when someone says "higher" or "lower": you guess 50, then 25 or 75, and so on. You never need more than 7 guesses. Looking up a word in a paper dictionary works the same way.

The requirement isn't really "sorted", it's **a yes/no question that flips exactly once** across the range: "is a[i] ≥ target?" gives no, no, no, yes, yes. Binary search finds the flip.

## Visualization

Classic search: every comparison halves the range:

```viz
binary-search
```

Rotated sorted array: one half around `mid` is always in order. Check whether the target lies in that half:

```viz
rotated
```

## Template code

```python
# Exact match
lo, hi = 0, len(a) - 1
while lo <= hi:
    mid = (lo + hi) // 2
    if a[mid] == target:
        return mid
    if a[mid] < target:
        lo = mid + 1
    else:
        hi = mid - 1
return -1

# Lower bound: first index with a[i] >= target (can be len(a))
lo, hi = 0, len(a)
while lo < hi:
    mid = (lo + hi) // 2
    if a[mid] < target:
        lo = mid + 1
    else:
        hi = mid
return lo

from bisect import bisect_left, bisect_right
first = bisect_left(a, t)            # first index >= t
last = bisect_right(a, t) - 1        # last index <= t

# 2D matrix with rows chained in order: index i ↔ (i // cols, i % cols)
```

## Complexity

| Search | Time | Space |
|---|---|---|
| linear scan | O(n) | O(1) |
| binary search | **O(log n)** | O(1) iterative |
| sorting first, then searching once | O(n log n) | – |

Sorting just to search once is slower than a linear scan. Binary search pays off when the data is already sorted or you search many times.

## When to use it

- **Sorted array + find a value / insert position / first or last occurrence** → lower/upper bound
- **Rotated sorted array** → find the sorted half at each step
- **Minimum of a rotated array** → compare `a[mid]` with `a[hi]`
- **"Find a peak"** → move toward the larger neighbour
- **An API that answers yes/no and flips once (First Bad Version)** → search for the first "yes"
- **Integer square root, "largest x with f(x) ≤ n"** → search over values, not indexes

## Common traps

- Mixing templates: `lo <= hi` goes with `hi = mid − 1`; `lo < hi` goes with `hi = mid`. Mixing them loops forever or skips answers
- `hi = len(a) − 1` when the answer can be "past the end" (insert position)
- Rotated arrays: using `<` where `<=` is needed when `lo == mid`
- Finding one occurrence and scanning outward for first/last: O(n) on `[7, 7, 7, …]`
- In other languages `(lo + hi) / 2` can overflow: use `lo + (hi - lo) / 2`
