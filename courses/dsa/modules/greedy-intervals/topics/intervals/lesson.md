## Core idea

**Interval problems almost always start by sorting.** Sort by **start** to merge or insert (overlapping intervals end up next to each other). Sort by **end** to keep the most non-overlapping intervals or use the fewest points (the one that finishes first leaves the most room).

## Intuition

Booking a meeting room: you want to fit as many meetings as possible. Always pick the meeting that **ends earliest** among those that can still start: it frees the room soonest and never blocks more than any other choice would.

Merging is like calendar cleanup: line up events by start time; an event that starts before the previous block ends belongs to that block.

Two intervals `[a, b]` and `[c, d]` overlap when `a <= d and c <= b`. Whether "touching" (`b == c`) counts as overlapping depends on the problem: read it carefully.

## Visualization

Merge: sort by start, then extend or start a new block:

```viz
merge
```

Sort by end: keep the interval that finishes first, remove the ones that clash:

```viz
by-end
```

## Template code

```python
# Merge overlapping intervals
intervals.sort()                                # by start
merged = []
for s, e in intervals:
    if merged and s <= merged[-1][1]:
        merged[-1][1] = max(merged[-1][1], e)   # overlap: extend
    else:
        merged.append([s, e])

# Insert into a sorted, non-overlapping list (one pass, three phases)
res, i = [], 0
while i < n and intervals[i][1] < new[0]:
    res.append(intervals[i]); i += 1            # entirely before
while i < n and intervals[i][0] <= new[1]:
    new = [min(new[0], intervals[i][0]), max(new[1], intervals[i][1])]; i += 1
res.append(new)
res += intervals[i:]                            # entirely after

# Max non-overlapping (min removals): sort by end
intervals.sort(key=lambda x: x[1])
end, kept = float("-inf"), 0
for s, e in intervals:
    if s >= end:                                # touching is fine here
        kept, end = kept + 1, e
removed = len(intervals) - kept

# Min arrows (points that hit every balloon): same, but touching counts
arrows, end = 0, float("-inf")
for s, e in sorted(points, key=lambda x: x[1]):
    if s > end:
        arrows, end = arrows + 1, e

# Summary ranges: extend a run while the next number is previous + 1
```

## Complexity

**O(n log n)** for the sort, then an **O(n)** scan. Insert Interval on an already sorted list is O(n) with no sort.

## When to use it

- **"Merge overlapping intervals / time ranges"** → sort by start, extend the last one
- **"Insert a new interval"** → three phases: before, overlapping, after
- **"Remove the fewest intervals so none overlap"**, **"attend the most meetings"** → sort by end, greedy
- **"Minimum arrows / points to cover all intervals"** → sort by end, one point at each chosen end
- **"How many rooms are needed at once"** → sort starts and ends, or a min-heap of end times

## Common traps

- Sorting by start for the "max non-overlapping" problem: a long early interval blocks many short ones
- Replacing the end when merging instead of taking `max` (a short interval inside a long one)
- Touching intervals: `[1, 2]` and `[2, 3]` overlap in Merge Intervals and Balloons, but not in Non-overlapping Intervals
- Mutating input lists you still need, or aliasing: append copies when needed
- Forgetting the empty list case in Insert Interval
