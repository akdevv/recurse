---
lc: 973
title: "K Closest Points to Origin"
difficulty: "Medium"
patterns: ["top-k-heap"]
lcTags: ["array", "math", "divide-and-conquer", "geometry", "sorting", "heap-priority-queue", "quickselect", "k-d-tree"]
compare: "unordered"
entry: {"method": "kClosest", "params": [{"name": "points", "type": "integer[][]"}, {"name": "k", "type": "integer"}], "returns": "integer[][]"}
examples: ["[[1,3],[-2,2]]\n1", "[[3,3],[5,-1],[-2,4]]\n2"]
---

Given an array of `points` where `points[i] = [xᵢ, yᵢ]` represents a point on the **X-Y** plane and an integer `k`, return the `k` closest points to the origin `(0, 0)`.

The distance between two points on the **X-Y** plane is the Euclidean distance (i.e., `√(x₁ - x₂)² + (y₁ - y₂)²`).

You may return the answer in **any order**. The answer is **guaranteed** to be **unique** (except for the order that it is in).

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/03/03/closestplane1.jpg)

```
Input: points = [[1,3],[-2,2]], k = 1
Output: [[-2,2]]
Explanation:
The distance between (1, 3) and the origin is sqrt(10).
The distance between (-2, 2) and the origin is sqrt(8).
Since sqrt(8) < sqrt(10), (-2, 2) is closer to the origin.
We only want the closest k = 1 points from the origin, so the answer is just [[-2,2]].
```

**Example 2:**

```
Input: points = [[3,3],[5,-1],[-2,4]], k = 2
Output: [[3,3],[-2,4]]
Explanation: The answer [[-2,4],[3,3]] would also be accepted.
```

**Constraints:**

- `1 <= k <= points.length <= 10⁴`
- `-10⁴ <= xᵢ, yᵢ <= 10⁴`

# Starter

```python
class Solution:
    def kClosest(self, points: list[list[int]], k: int) -> list[list[int]]:
        
```

# Hints

1. Compare squared distances x² + y²; no need for sqrt.
2. Keep a max-heap of size k keyed by −distance; push each point and pop when the heap exceeds k. (Sorting by distance is O(n log n) and also fine.)

# Key points

- compare x*x + y*y, skip the square root
- max-heap of size k → O(n log k); sort → O(n log n); quickselect → O(n) average
- answer in any order

# Solution: custom-sorting · Custom Sorting · O(n log n) · O(log n) · reference

We sort all points by their distance from the origin in ascending order, and then take the first k points.

The time complexity is O(n log n), and the space complexity is O(log n). Here, n is the length of the array points.

```python
class Solution:
    def kClosest(self, points: List[List[int]], k: int) -> List[List[int]]:
        points.sort(key=lambda p: hypot(p[0], p[1]))
        return points[:k]
```

# Solution: priority-queue-max-heap · Priority Queue (Max Heap) · O(n × log k) · O(k)

We can use a priority queue (max heap) to maintain the k closest points to the origin.

The time complexity is O(n × log k), and the space complexity is O(k). Here, n is the length of the array points.

```python
class Solution:
    def kClosest(self, points: List[List[int]], k: int) -> List[List[int]]:
        max_q = []
        for i, (x, y) in enumerate(points):
            dist = math.hypot(x, y)
            heappush(max_q, (-dist, i))
            if len(max_q) > k:
                heappop(max_q)
        return [points[i] for _, i in max_q]
```

# Solution: binary-search · Binary Search · O(n × log M) · O(n)

We notice that as the distance increases, the number of points increases as well. There exists a critical value such that the number of points before this value is less than or equal to k, and the number of points after this value is greater than k.

Therefore, we can use binary search to enumerate the distance. In each binary search iteration, we count the number of points whose distance is less than or equal to the current distance. If the count is greater than or equal to k, it indicates that the critical value is on the left side, so we set the right boundary equal to the current distance; otherwise, the critical value is on the right side, so we set the left boundary equal to the current distance plus one.

After the binary search is finished, we just need to return the points whose distance is less than or equal to the left boundary.

The time complexity is O(n × log M), and the space complexity is O(n). Here, n is the length of the array points, and M is the maximum value of the distance.

```python
class Solution:
    def kClosest(self, points: List[List[int]], k: int) -> List[List[int]]:
        dist = [x * x + y * y for x, y in points]
        l, r = 0, max(dist)
        while l < r:
            mid = (l + r) >> 1
            cnt = sum(d <= mid for d in dist)
            if cnt >= k:
                r = mid
            else:
                l = mid + 1
        return [points[i] for i, d in enumerate(dist) if d <= l]
```

# Tests

```python
def pts(rng, n, r):
    seen = set()
    while len(seen) < n:
        seen.add((rng.randint(-r, r), rng.randint(-r, r)))
    return [list(p) for p in seen]

def unique_k(points, k):
    d = sorted(x * x + y * y for x, y in points)
    return k == len(d) or d[k - 1] != d[k]

def edge():
    return [[[[1, 3], [-2, 2]], 1], [[[3, 3], [5, -1], [-2, 4]], 2], [[[0, 0]], 1], [[[1, 1], [2, 2]], 2]]

def random_case(rng):
    while True:
        p = pts(rng, rng.randint(1, 8), 6)
        k = rng.randint(1, len(p))
        if unique_k(p, k):
            return [p, k]

def perf(rng):
    p = [[i, 0] for i in range(10000)]
    rng.shuffle(p)
    return [[p, 5000]]
```
