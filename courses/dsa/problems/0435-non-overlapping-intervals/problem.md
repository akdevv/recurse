---
lc: 435
title: "Non-overlapping Intervals"
difficulty: "Medium"
patterns: ["merge-intervals", "greedy"]
lcTags: ["array", "dynamic-programming", "greedy", "sorting"]
entry: {"method": "eraseOverlapIntervals", "params": [{"name": "intervals", "type": "integer[][]"}], "returns": "integer"}
examples: ["[[1,2],[2,3],[3,4],[1,3]]", "[[1,2],[1,2],[1,2]]", "[[1,2],[2,3]]"]
---

Given an array of intervals `intervals` where `intervals[i] = [startᵢ, endᵢ]`, return *the minimum number of intervals you need to remove to make the rest of the intervals non-overlapping*.

**Note** that intervals which only touch at a point are **non-overlapping**. For example, `[1, 2]` and `[2, 3]` are non-overlapping.

**Example 1:**

```
Input: intervals = [[1,2],[2,3],[3,4],[1,3]]
Output: 1
Explanation: [1,3] can be removed and the rest of the intervals are non-overlapping.
```

**Example 2:**

```
Input: intervals = [[1,2],[1,2],[1,2]]
Output: 2
Explanation: You need to remove two [1,2] to make the rest of the intervals non-overlapping.
```

**Example 3:**

```
Input: intervals = [[1,2],[2,3]]
Output: 0
Explanation: You don't need to remove any of the intervals since they're already non-overlapping.
```

**Constraints:**

- `1 <= intervals.length <= 10⁵`
- `intervals[i].length == 2`
- `-5 * 10⁴ <= startᵢ < endᵢ <= 5 * 10⁴`

# Starter

```python
class Solution:
    def eraseOverlapIntervals(self, intervals: list[list[int]]) -> int:
        
```

# Hints

1. Keeping the most intervals = removing the fewest. Which interval should you keep first?
2. Sort by end. Keep an interval if it starts at or after the last kept end; otherwise remove it. Answer = removed count.

# Key points

- greedy: always keep the interval that ends earliest
- sort by end, count the ones that overlap the last kept
- touching intervals ([1,2], [2,3]) don't overlap
- O(n log n) time

# Solution: sorting-greedy · Sorting + Greedy · O(n × log n) · O(log n) · reference

We first sort the intervals in ascending order by their right boundary. We use a variable pre to record the right boundary of the previous interval and a variable ans to record the number of intervals that need to be removed. Initially, `ans = intervals.length`.

Then we iterate through the intervals. For each interval:

- If the left boundary of the current interval is greater than or equal to pre, it means that this interval does not need to be removed. We directly update pre to the right boundary of the current interval and decrement ans by one;
- Otherwise, it means that this interval needs to be removed, and we do not need to update pre and ans.

Finally, we return ans.

The time complexity is O(n × log n), and the space complexity is O(log n), where n is the number of intervals.

```python
class Solution:
    def eraseOverlapIntervals(self, intervals: List[List[int]]) -> int:
        intervals.sort(key=lambda x: x[1])
        ans = len(intervals)
        pre = -inf
        for l, r in intervals:
            if pre <= l:
                ans -= 1
                pre = r
        return ans
```

# Tests

```python
def iv(rng, n, lo, hi):
    out = []
    for _ in range(n):
        a = rng.randint(lo, hi - 1)
        out.append([a, rng.randint(a + 1, hi)])
    return out

def edge():
    return [[[[1, 2]]], [[[1, 2], [2, 3], [3, 4], [1, 3]]], [[[1, 2], [1, 2], [1, 2]]], [[[1, 2], [2, 3]]], [[[-50000, 50000], [0, 1]]]]

def random_case(rng):
    return [iv(rng, rng.randint(1, 7), -5, 10)]

def perf(rng):
    return [[iv(rng, 100000, -5 * 10**4, 5 * 10**4)]]
```
