## Core idea

**When the question is "what's the smallest X that works?" (or the largest), and "works" is easy to check, binary search over the possible values of X.** If X works, every bigger X also works, so the yes/no answers flip once and binary search finds the flip.

## Intuition

Choosing the smallest suitcase for a trip. You can't compute the size directly, but for any suitcase you can quickly check "does everything fit?". Bigger suitcases always fit if a smaller one did. So instead of trying every size from small to huge, you try the middle size, then the middle of the remaining range, and so on.

The phrase to listen for is **"minimize the maximum"** or **"maximize the minimum"**: smallest possible largest load, slowest speed that still finishes, largest minimum distance.

## Visualization

Koko Eating Bananas: the speeds form a ✗✗✗✓✓✓ line; find the first ✓:

```viz
predicate
```

Capacity to Ship Packages: guess a capacity, check it with a greedy pass:

```viz
ship
```

## Template code

```python
def feasible(x):                 # usually one greedy O(n) pass
    ...

lo, hi = smallest_possible, largest_possible
while lo < hi:
    mid = (lo + hi) // 2
    if feasible(mid):
        hi = mid                 # mid works: answer is mid or smaller
    else:
        lo = mid + 1             # mid fails: answer is bigger
return lo                        # first value that works

# Koko: hours needed at speed k
hours = sum((p + k - 1) // k for p in piles)     # ceil(p / k) without floats

# Ship / split array: days (or parts) needed with limit cap
days, load = 1, 0
for w in weights:
    if load + w > cap:
        days, load = days + 1, 0
    load += w
```

## Complexity

**O(n · log(range))**: the feasibility check is O(n) and binary search calls it log₂(hi − lo) times. Even with a range of 10⁹ that's only about 30 checks.

| Problem | Search range | Check |
|---|---|---|
| Koko Eating Bananas | speed 1..max(piles) | total hours ≤ h |
| Ship Within D Days | max(w)..sum(w) | greedy days ≤ D |
| Split Array Largest Sum | max(nums)..sum(nums) | greedy parts ≤ k |

## When to use it

- **"Minimum speed / capacity / time such that…"** → search the smallest feasible value
- **"Minimize the largest part" / "maximize the smallest gap"** → same idea, pick the right direction
- **Checking a given answer is easy but computing it directly is hard** → that's the signal
- **The answer is an integer in a known range** → set lo and hi from the input (max, sum)

## Common traps

- Wrong bounds: capacity below the heaviest package can never work, so `lo = max(weights)`, not 1
- Using float division for hours: `ceil(p / k)` with floats can round wrong; use `(p + k − 1) // k`
- Checking feasibility in the wrong direction (returning the last failure instead of the first success)
- A non-monotonic check: binary search only works if "works" stays true as X grows
- Recomputing the check with an O(n²) method: keep it one pass
