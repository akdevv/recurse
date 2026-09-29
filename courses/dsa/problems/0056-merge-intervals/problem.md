---
lc: 56
title: "Merge Intervals"
difficulty: "Medium"
patterns: ["merge-intervals"]
lcTags: ["array", "sorting", "quicksort"]
entry: {"method": "merge", "params": [{"name": "intervals", "type": "integer[][]"}], "returns": "integer[][]"}
examples: ["[[1,3],[2,6],[8,10],[15,18]]", "[[1,4],[4,5]]", "[[4,7],[1,4]]"]
---

Given an array of `intervals` where `intervals[i] = [startᵢ, endᵢ]`, merge all overlapping intervals, and return *an array of the non-overlapping intervals that cover all the intervals in the input*.

**Example 1:**

```
Input: intervals = [[1,3],[2,6],[8,10],[15,18]]
Output: [[1,6],[8,10],[15,18]]
Explanation: Since intervals [1,3] and [2,6] overlap, merge them into [1,6].
```

**Example 2:**

```
Input: intervals = [[1,4],[4,5]]
Output: [[1,5]]
Explanation: Intervals [1,4] and [4,5] are considered overlapping.
```

**Example 3:**

```
Input: intervals = [[4,7],[1,4]]
Output: [[1,7]]
Explanation: Intervals [1,4] and [4,7] are considered overlapping.
```

**Constraints:**

- `1 <= intervals.length <= 10⁴`
- `intervals[i].length == 2`
- `0 <= startᵢ <= endᵢ <= 10⁴`

# Starter

```python
class Solution:
    def merge(self, intervals: list[list[int]]) -> list[list[int]]:
        
```

# Hints

1. After sorting by start, overlapping intervals are next to each other.
2. Sort by start. For each interval: if it starts after the last merged one ends, append it; otherwise extend the last one's end to max(end, current end).

# Key points

- sort by start
- overlap if start <= last end (touching counts)
- extend with max, don't just overwrite the end
- O(n log n) time

# Solution: sorting-one-pass-traversal · Sorting + One-pass Traversal · O(n × log n) · O(log n) · reference

We can sort the intervals in ascending order by the left endpoint, and then traverse the intervals for merging operations.

The specific merging operation is as follows.

First, we add the first interval to the answer. Then, we consider each subsequent interval in turn:

- If the right endpoint of the last interval in the answer array is less than the left endpoint of the current interval, it means that the two intervals will not overlap, so we can directly add the current interval to the end of the answer array;
- Otherwise, it means that the two intervals overlap. We need to use the right endpoint of the current interval to update the right endpoint of the last interval in the answer array, setting it to the larger of the two.

Finally, we return the answer array.

The time complexity is O(n × log n), and the space complexity is O(log n). Here, n is the number of intervals.

```python
class Solution:
    def merge(self, intervals: List[List[int]]) -> List[List[int]]:
        intervals.sort()
        ans = []
        st, ed = intervals[0]
        for s, e in intervals[1:]:
            if ed < s:
                ans.append([st, ed])
                st, ed = s, e
            else:
                ed = max(ed, e)
        ans.append([st, ed])
        return ans
```

# Solution: solution-2 · Sort, then merge in place · O(n log n) · O(log n)

## Idea
Sort by start. Keep the merged list; if the next interval starts after the last merged one ends, it's a new interval, otherwise stretch the last one's end to cover it.

## Complexity
- **Time: O(n log n)**
- **Space: O(log n)**

```python
class Solution:
    def merge(self, intervals: List[List[int]]) -> List[List[int]]:
        intervals.sort()
        ans = [intervals[0]]
        for s, e in intervals[1:]:
            if ans[-1][1] < s:
                ans.append([s, e])
            else:
                ans[-1][1] = max(ans[-1][1], e)
        return ans
```

# Tests

```python
def iv(rng, n, hi):
    out = []
    for _ in range(n):
        a = rng.randint(0, hi)
        out.append([a, rng.randint(a, hi)])
    return out

def edge():
    return [[[[1, 3]]], [[[1, 3], [2, 6], [8, 10], [15, 18]]], [[[1, 4], [4, 5]]], [[[1, 4], [2, 3]]], [[[4, 7], [1, 4]]], [[[0, 0], [0, 0]]]]

def random_case(rng):
    return [iv(rng, rng.randint(1, 7), 12)]

def perf(rng):
    return [[iv(rng, 10000, 10**4)]]
```
