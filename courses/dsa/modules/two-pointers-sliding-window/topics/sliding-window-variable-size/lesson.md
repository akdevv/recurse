## Core idea

**Grow the window by moving `right`; whenever it breaks the rule, shrink it by moving `left` until it's valid again.** Neither pointer ever moves backwards, so even though there's a loop inside a loop, the total work is O(n).

## Intuition

A caterpillar crawling along a branch. Its head stretches forward to eat; when its body gets too long (the window breaks a rule), the tail pulls in. It never crawls backwards. Over the whole branch the head passes each leaf once and the tail passes each leaf once.

Two questions decide everything: **what makes the window invalid**, and **when do you record the answer**. For "longest", record after the window is fixed up. For "shortest", record while it's still valid, just before each shrink.

## Visualization

Longest substring without repeating characters (longest valid window):

```viz
longest-unique
```

Shortest subarray with sum ≥ target (shortest valid window):

```viz
min-window-sum
```

## Template code

```python
# Longest valid window
l = 0
for r, x in enumerate(nums):
    add(x)                                   # extend the window
    while not valid():
        remove(nums[l]); l += 1              # shrink until valid
    best = max(best, r - l + 1)

# Shortest valid window
l = 0
for r, x in enumerate(nums):
    add(x)
    while valid():
        best = min(best, r - l + 1)          # record before shrinking
        remove(nums[l]); l += 1

# Jump the left edge with a last-seen map (no repeats)
last = {}
for r, c in enumerate(s):
    if c in last:
        l = max(l, last[c] + 1)              # never move l backwards
    last[c] = r

# Count subarrays with at most k of something:
#   exactly(k) = at_most(k) - at_most(k - 1)
```

## Complexity

| Approach | Time | Space |
|---|---|---|
| try every start and end | O(n²) or worse | O(1) |
| variable sliding window | **O(n)**: each pointer moves ≤ n times | O(1)–O(k) for the state |

## When to use it

- **"Longest / shortest substring or subarray such that…"** → variable window
- **Condition is monotonic**: growing only makes it "more", shrinking only "less" (positive sums, distinct counts, char counts)
- **"At most k distinct / k replacements"** → track counts, shrink when the rule breaks
- **"Contains all characters of t"** → need/have counts with a `missing` counter
- **"Number of subarrays with exactly k…"** → at_most(k) − at_most(k − 1)
- **Stock prices "buy low, sell later"** → the left edge jumps to each new minimum

## Common traps

- Negative numbers break "sum ≥ target" windows (shrinking might raise the sum): use prefix sums + a hash map
- Recording "longest" before the window is fixed up, or "shortest" after shrinking past validity
- Moving `l` backwards with a last-seen map: always `l = max(l, last[c] + 1)`
- Forgetting to remove the left element from the state when shrinking
- Using `if` instead of `while` to shrink when one step may not be enough
