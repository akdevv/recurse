---
lc: 57
title: "Insert Interval"
difficulty: "Medium"
patterns: ["merge-intervals"]
lcTags: ["array"]
entry: {"method": "insert", "params": [{"name": "intervals", "type": "integer[][]"}, {"name": "newInterval", "type": "integer[]"}], "returns": "integer[][]"}
examples: ["[[1,3],[6,9]]\n[2,5]", "[[1,2],[3,5],[6,7],[8,10],[12,16]]\n[4,8]"]
lcHints: ["Intervals Array is sorted. Can you use Binary Search to find the correct position to insert the new Interval.?", "Can you try merging the overlapping intervals while inserting the new interval?", "This can be done by comparing the end of the last interval with the start of the new interval and vice versa."]
---

You are given an array of non-overlapping intervals `intervals` where `intervals[i] = [startᵢ, endᵢ]` represent the start and the end of the `iᵗʰ` interval and `intervals` is sorted in ascending order by `startᵢ`. You are also given an interval `newInterval = [start, end]` that represents the start and end of another interval.

Two intervals are considered overlapping if they share **at least** one point.

Insert `newInterval` into `intervals` such that `intervals` is still sorted in ascending order by `startᵢ` and `intervals` still does not have any overlapping intervals (merge overlapping intervals if necessary).

Return `intervals` *after the insertion*.

**Note** that you don't need to modify `intervals` in-place. You can make a new array and return it.

**Example 1:**

```
Input: intervals = [[1,3],[6,9]], newInterval = [2,5]
Output: [[1,5],[6,9]]
```

**Example 2:**

```
Input: intervals = [[1,2],[3,5],[6,7],[8,10],[12,16]], newInterval = [4,8]
Output: [[1,2],[3,10],[12,16]]
Explanation: Because the new interval [4,8] overlaps with [3,5],[6,7],[8,10].
```

**Constraints:**

- `0 <= intervals.length <= 10⁴`
- `intervals[i].length == 2`
- `0 <= startᵢ <= endᵢ <= 10⁵`
- `intervals` is sorted by `startᵢ` in **ascending** order.
- `newInterval.length == 2`
- `0 <= start <= end <= 10⁵`

# Starter

```python
class Solution:
    def insert(self, intervals: list[list[int]], newInterval: list[int]) -> list[list[int]]:
        
```

# Hints

1. The list is already sorted and non-overlapping. Three phases: intervals fully before the new one, ones that overlap it, ones fully after.
2. Append all intervals ending before newInterval starts. Merge all that overlap into newInterval (min start, max end). Append the merged interval, then the rest.

# Key points

- one pass in three phases: before, overlapping, after
- merging: start = min, end = max
- O(n) time

# Solution: sorting-interval-merging · Sorting + Interval Merging · O(n × log n) · O(n) · reference

We can first add the new interval `newInterval` to the interval list `intervals`, and then merge according to the regular method of interval merging.

The time complexity is O(n × log n), and the space complexity is O(n). Here, n is the number of intervals.

```python
class Solution:
    def insert(
        self, intervals: List[List[int]], newInterval: List[int]
    ) -> List[List[int]]:
        def merge(intervals: List[List[int]]) -> List[List[int]]:
            intervals.sort()
            ans = [intervals[0]]
            for s, e in intervals[1:]:
                if ans[-1][1] < s:
                    ans.append([s, e])
                else:
                    ans[-1][1] = max(ans[-1][1], e)
            return ans

        intervals.append(newInterval)
        return merge(intervals)
```

# Solution: one-pass-traversal · One-pass Traversal · O(n) · O(1)

We can traverse the interval list `intervals`, let the current interval be `interval`, and there are three situations for each interval:

- The current interval is on the right side of the new interval, that is, `newInterval[1] < interval[0]`. At this time, if the new interval has not been added, then add the new interval to the answer, and then add the current interval to the answer.
- The current interval is on the left side of the new interval, that is, `interval[1] < newInterval[0]`. At this time, add the current interval to the answer.
- Otherwise, it means that the current interval and the new interval intersect. We take the minimum of the left endpoint of the current interval and the left endpoint of the new interval, and the maximum of the right endpoint of the current interval and the right endpoint of the new interval, as the left and right endpoints of the new interval, and then continue to traverse the interval list.

After the traversal, if the new interval has not been added, then add the new interval to the answer.

The time complexity is O(n), where n is the number of intervals. Ignoring the space consumption of the answer array, the space complexity is O(1).

```python
class Solution:
    def insert(
        self, intervals: List[List[int]], newInterval: List[int]
    ) -> List[List[int]]:
        st, ed = newInterval
        ans = []
        insert = False
        for s, e in intervals:
            if ed < s:
                if not insert:
                    ans.append([st, ed])
                    insert = True
                ans.append([s, e])
            elif e < st:
                ans.append([s, e])
            else:
                st = min(st, s)
                ed = max(ed, e)
        if not insert:
            ans.append([st, ed])
        return ans
```

# Tests

```python
def sorted_disjoint(rng, n, hi):
    pts = sorted(rng.sample(range(0, hi), 2 * n))
    return [[pts[2 * i], pts[2 * i + 1]] for i in range(n)]

def edge():
    return [[[], [5, 7]], [[[1, 3], [6, 9]], [2, 5]], [[[1, 2], [3, 5], [6, 7], [8, 10], [12, 16]], [4, 8]], [[[1, 5]], [6, 8]], [[[1, 5]], [0, 0]], [[[1, 5]], [2, 3]]]

def random_case(rng):
    a = rng.randint(0, 20)
    return [sorted_disjoint(rng, rng.randint(0, 5), 25), [a, rng.randint(a, 25)]]

def perf(rng):
    return [[sorted_disjoint(rng, 10000, 10**5), [100, 90000]]]
```
