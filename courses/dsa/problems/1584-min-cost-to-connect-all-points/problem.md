---
lc: 1584
title: "Min Cost to Connect All Points"
difficulty: "Medium"
patterns: ["union-find", "greedy"]
lcTags: ["array", "union-find", "graph", "minimum-spanning-tree", "prims-algorithm", "kruskals-algorithm", "boruvkas-algorithm"]
entry: {"method": "minCostConnectPoints", "params": [{"name": "points", "type": "integer[][]"}], "returns": "integer"}
examples: ["[[0,0],[2,2],[3,10],[5,2],[7,0]]", "[[3,12],[-2,5],[-4,1]]"]
lcHints: ["Connect each pair of points with a weighted edge, the weight being the manhattan distance between those points.", "The problem is now the cost of minimum spanning tree in graph with above edges."]
---

You are given an array `points` representing integer coordinates of some points on a 2D-plane, where `points[i] = [xᵢ, yᵢ]`.

The cost of connecting two points `[xᵢ, yᵢ]` and `[xⱼ, yⱼ]` is the **manhattan distance** between them: `|xᵢ - xⱼ| + |yᵢ - yⱼ|`, where `|val|` denotes the absolute value of `val`.

Return *the minimum cost to make all points connected.* All points are connected if there is **exactly one** simple path between any two points.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/08/26/d.png)

```
Input: points = [[0,0],[2,2],[3,10],[5,2],[7,0]]
Output: 20
Explanation:

![](https://assets.leetcode.com/uploads/2020/08/26/c.png)

We can connect the points as shown above to get the minimum cost of 20.
Notice that there is a unique path between every pair of points.
```

**Example 2:**

```
Input: points = [[3,12],[-2,5],[-4,1]]
Output: 18
```

**Constraints:**

- `1 <= points.length <= 1000`
- `-10⁶ <= xᵢ, yᵢ <= 10⁶`
- All pairs `(xᵢ, yᵢ)` are distinct.

# Starter

```python
class Solution:
    def minCostConnectPoints(self, points: list[list[int]]) -> int:
        
```

# Hints

1. Connect all points with minimum total Manhattan distance: that's a minimum spanning tree on the complete graph.
2. Prim's algorithm with an O(n²) array (dense graph): keep each point's cheapest distance to the tree, repeatedly add the closest point and update.

# Key points

- minimum spanning tree
- dense graph (n² edges) → O(n²) Prim beats sorting all edges for Kruskal
- Kruskal: sort edges + union-find, O(n² log n)

# Solution: solution-1 · Prim's algorithm (dense) · O(n²) · O(n²) · reference

## Idea
Prim's algorithm on the complete graph. `dist[i]` is the cheapest edge from point i to the tree built so far. Repeatedly add the closest point outside the tree and update its neighbours' distances. The O(n²) array version fits a dense graph.

## Complexity
- **Time: O(n²)**
- **Space: O(n²)**

```python
class Solution:
    def minCostConnectPoints(self, points: List[List[int]]) -> int:
        n = len(points)
        g = [[0] * n for _ in range(n)]
        dist = [inf] * n
        vis = [False] * n
        for i, (x1, y1) in enumerate(points):
            for j in range(i + 1, n):
                x2, y2 = points[j]
                t = abs(x1 - x2) + abs(y1 - y2)
                g[i][j] = g[j][i] = t
        dist[0] = 0
        ans = 0
        for _ in range(n):
            i = -1
            for j in range(n):
                if not vis[j] and (i == -1 or dist[j] < dist[i]):
                    i = j
            vis[i] = True
            ans += dist[i]
            for j in range(n):
                if not vis[j]:
                    dist[j] = min(dist[j], g[i][j])
        return ans
```

# Solution: solution-2 · Kruskal's algorithm · O(n² log n) · O(n²)

## Idea
Kruskal's algorithm: list every pair with its Manhattan distance, sort, and add edges from cheapest up, skipping any that connect points already in the same union-find set. Stop after n − 1 edges.

## Complexity
- **Time: O(n² log n)**
- **Space: O(n²)**

```python
class Solution:
    def minCostConnectPoints(self, points: List[List[int]]) -> int:
        def find(x: int) -> int:
            if p[x] != x:
                p[x] = find(p[x])
            return p[x]

        n = len(points)
        g = []
        for i, (x1, y1) in enumerate(points):
            for j in range(i + 1, n):
                x2, y2 = points[j]
                t = abs(x1 - x2) + abs(y1 - y2)
                g.append((t, i, j))
        p = list(range(n))
        ans = 0
        for cost, i, j in sorted(g):
            pa, pb = find(i), find(j)
            if pa == pb:
                continue
            p[pa] = pb
            ans += cost
            n -= 1
            if n == 1:
                break
        return ans
```

# Tests

```python
def pts(rng, n, r):
    s = set()
    while len(s) < n:
        s.add((rng.randint(-r, r), rng.randint(-r, r)))
    return [[list(p) for p in s]]

def edge():
    return [[[[0, 0]]], [[[0, 0], [2, 2], [3, 10], [5, 2], [7, 0]]], [[[3, 12], [-2, 5], [-4, 1]]], [[[0, 0], [1, 1], [1, 0], [-1, 1]]]]

def random_case(rng):
    return pts(rng, rng.randint(1, 8), 10)

def perf(rng):
    return [pts(rng, 1000, 10**6)]
```
