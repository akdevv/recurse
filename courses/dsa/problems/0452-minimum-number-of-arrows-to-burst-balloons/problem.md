---
lc: 452
title: "Minimum Number of Arrows to Burst Balloons"
difficulty: "Medium"
patterns: ["merge-intervals", "greedy"]
lcTags: ["array", "greedy", "sorting"]
entry: {"method": "findMinArrowShots", "params": [{"name": "points", "type": "integer[][]"}], "returns": "integer"}
examples: ["[[10,16],[2,8],[1,6],[7,12]]", "[[1,2],[3,4],[5,6],[7,8]]", "[[1,2],[2,3],[3,4],[4,5]]"]
---

There are some spherical balloons taped onto a flat wall that represents the XY-plane. The balloons are represented as a 2D integer array `points` where `points[i] = [xₛₜₐᵣₜ, x_(end)]` denotes a balloon whose **horizontal diameter** stretches between `xₛₜₐᵣₜ` and `x_(end)`. You do not know the exact y-coordinates of the balloons.

Arrows can be shot up **directly vertically** (in the positive y-direction) from different points along the x-axis. A balloon with `xₛₜₐᵣₜ` and `x_(end)` is **burst** by an arrow shot at `x` if `xₛₜₐᵣₜ <= x <= x_(end)`. There is **no limit** to the number of arrows that can be shot. A shot arrow keeps traveling up infinitely, bursting any balloons in its path.

Given the array `points`, return *the **minimum** number of arrows that must be shot to burst all balloons*.

**Example 1:**

```
Input: points = [[10,16],[2,8],[1,6],[7,12]]
Output: 2
Explanation: The balloons can be burst by 2 arrows:
- Shoot an arrow at x = 6, bursting the balloons [2,8] and [1,6].
- Shoot an arrow at x = 11, bursting the balloons [10,16] and [7,12].
```

**Example 2:**

```
Input: points = [[1,2],[3,4],[5,6],[7,8]]
Output: 4
Explanation: One arrow needs to be shot for each balloon for a total of 4 arrows.
```

**Example 3:**

```
Input: points = [[1,2],[2,3],[3,4],[4,5]]
Output: 2
Explanation: The balloons can be burst by 2 arrows:
- Shoot an arrow at x = 2, bursting the balloons [1,2] and [2,3].
- Shoot an arrow at x = 4, bursting the balloons [3,4] and [4,5].
```

**Constraints:**

- `1 <= points.length <= 10⁵`
- `points[i].length == 2`
- `-2³¹ <= xₛₜₐᵣₜ < x_(end) <= 2³¹ - 1`

# Starter

```python
class Solution:
    def findMinArrowShots(self, points: list[list[int]]) -> int:
        
```

# Hints

1. One arrow bursts every balloon that contains its x. Sort by end: where should the first arrow go?
2. Sort by end. Shoot at the first balloon's end; skip every balloon that starts at or before that x; the next balloon needs a new arrow at its end.

# Key points

- sort by end, shoot at the end of the first unburst balloon
- balloons touching at a point share an arrow (start <= x)
- O(n log n) time

# Solution: solution-1 · Sort by end, greedy · O(n log n) · O(log n) · reference

## Idea
Sort balloons by their end. Shoot an arrow at the end of the first balloon; it bursts every balloon starting at or before that point. The next balloon starting after it needs a new arrow at its end.

## Complexity
- **Time: O(n log n)**
- **Space: O(log n)**

```python
class Solution:
    def findMinArrowShots(self, points: List[List[int]]) -> int:
        ans, last = 0, -inf
        for a, b in sorted(points, key=lambda x: x[1]):
            if a > last:
                ans += 1
                last = b
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
    return [[[[1, 2]]], [[[10, 16], [2, 8], [1, 6], [7, 12]]], [[[1, 2], [3, 4], [5, 6], [7, 8]]], [[[1, 2], [2, 3], [3, 4], [4, 5]]], [[[-2**31, 2**31 - 1]]]]

def random_case(rng):
    return [iv(rng, rng.randint(1, 7), -5, 10)]

def perf(rng):
    return [[iv(rng, 100000, -2**31, 2**31 - 1)]]
```
