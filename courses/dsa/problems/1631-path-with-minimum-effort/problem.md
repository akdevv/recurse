---
lc: 1631
title: "Path With Minimum Effort"
difficulty: "Medium"
patterns: ["dijkstra", "binary-search-answer"]
lcTags: ["array", "binary-search", "depth-first-search", "breadth-first-search", "union-find", "heap-priority-queue", "matrix", "dijkstra"]
entry: {"method": "minimumEffortPath", "params": [{"name": "heights", "type": "integer[][]"}], "returns": "integer"}
examples: ["[[1,2,2],[3,8,2],[5,3,5]]", "[[1,2,3],[3,8,4],[5,3,5]]", "[[1,2,1,1,1],[1,2,1,2,1],[1,2,1,2,1],[1,2,1,2,1],[1,1,1,2,1]]"]
lcHints: ["Consider the grid as a graph, where adjacent cells have an edge with cost of the difference between the cells.", "If you are given threshold k, check if it is possible to go from (0, 0) to (n-1, m-1) using only edges of ≤ k cost.", "Binary search the k value."]
---

You are a hiker preparing for an upcoming hike. You are given `heights`, a 2D array of size `rows x columns`, where `heights[row][col]` represents the height of cell `(row, col)`. You are situated in the top-left cell, `(0, 0)`, and you hope to travel to the bottom-right cell, `(rows-1, columns-1)` (i.e., **0-indexed**). You can move **up**, **down**, **left**, or **right**, and you wish to find a route that requires the minimum **effort**.

A route's **effort** is the **maximum absolute difference** in heights between two consecutive cells of the route.

Return *the minimum **effort** required to travel from the top-left cell to the bottom-right cell.*

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/10/04/ex1.png)

```
Input: heights = [[1,2,2],[3,8,2],[5,3,5]]
Output: 2
Explanation: The route of [1,3,5,3,5] has a maximum absolute difference of 2 in consecutive cells.
This is better than the route of [1,2,2,2,5], where the maximum absolute difference is 3.
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2020/10/04/ex2.png)

```
Input: heights = [[1,2,3],[3,8,4],[5,3,5]]
Output: 1
Explanation: The route of [1,2,3,4,5] has a maximum absolute difference of 1 in consecutive cells, which is better than route [1,3,5,3,5].
```

**Example 3:**

![](https://assets.leetcode.com/uploads/2020/10/04/ex3.png)

```
Input: heights = [[1,2,1,1,1],[1,2,1,2,1],[1,2,1,2,1],[1,2,1,2,1],[1,1,1,2,1]]
Output: 0
Explanation: This route does not require any effort.
```

**Constraints:**

- `rows == heights.length`
- `columns == heights[i].length`
- `1 <= rows, columns <= 100`
- `1 <= heights[i][j] <= 10⁶`

# Starter

```python
class Solution:
    def minimumEffortPath(self, heights: list[list[int]]) -> int:
        
```

# Hints

1. A path's cost is its single largest step, not the sum. Dijkstra still works if "distance" means max step so far.
2. Dijkstra on the grid where the cost to enter a neighbour is max(current effort, |height difference|). Stop when you pop the bottom-right cell.

# Key points

- Dijkstra with max instead of sum
- alternatives: binary search the effort + BFS, or union-find adding edges by weight
- O(m·n log(m·n)) time

# Solution: union-find · Union-Find · O(m × n × log(m × n)) · O(m × n) · reference

For this problem, we can treat each cell as a node in a graph, and the absolute difference in height between two adjacent cells as the weight of the edge. Therefore, this problem is to solve the connectivity problem from the top-left node to the bottom-right node.

We first construct a set of edges, then sort them in ascending order of edge weight, and add edges one by one until the top-left node and the bottom-right node are connected. At this point, the weight of the edge is the minimum physical consumption value required by the problem.

The time complexity is O(m × n × log(m × n)), and the space complexity is O(m × n). Here, m and n are the number of rows and columns in the two-dimensional array, respectively.

```python
class UnionFind:
    def __init__(self, n):
        self.p = list(range(n))
        self.size = [1] * n

    def find(self, x):
        if self.p[x] != x:
            self.p[x] = self.find(self.p[x])
        return self.p[x]

    def union(self, a, b):
        pa, pb = self.find(a), self.find(b)
        if pa == pb:
            return False
        if self.size[pa] > self.size[pb]:
            self.p[pb] = pa
            self.size[pa] += self.size[pb]
        else:
            self.p[pa] = pb
            self.size[pb] += self.size[pa]
        return True

    def connected(self, a, b):
        return self.find(a) == self.find(b)

class Solution:
    def minimumEffortPath(self, heights: List[List[int]]) -> int:
        m, n = len(heights), len(heights[0])
        uf = UnionFind(m * n)
        e = []
        dirs = (0, 1, 0)
        for i in range(m):
            for j in range(n):
                for a, b in pairwise(dirs):
                    x, y = i + a, j + b
                    if 0 <= x < m and 0 <= y < n:
                        e.append(
                            (abs(heights[i][j] - heights[x][y]), i * n + j, x * n + y)
                        )
        e.sort()
        for h, a, b in e:
            uf.union(a, b)
            if uf.connected(0, m * n - 1):
                return h
        return 0
```

# Solution: binary-search-bfs · Binary Search + BFS · O(m × n × log M) · O(m × n)

We notice that if the maximum physical consumption value of a path is x, then for any `y > x`, this path also meets the conditions. This shows monotonicity, so we can use the binary search method to find the minimum physical consumption value that meets the conditions.

We define the left boundary of the binary search as `l=0`, and the right boundary as `r=10⁶`. Each time we take `mid=(l+r)/2`, then use BFS to determine whether there is a path from the top-left corner to the bottom-right corner, so that the absolute difference in height between adjacent nodes on the path is not greater than mid. If it exists, it means that mid may still be the minimum physical consumption value that meets the conditions, so we set `r=mid`, otherwise we set `l=mid+1`.

The time complexity is O(m × n × log M), and the space complexity is O(m × n). Here, m and n are the number of rows and columns in the two-dimensional array, respectively, and M is the maximum value in the two-dimensional array. In this problem, `M=10⁶`.

```python
class Solution:
    def minimumEffortPath(self, heights: List[List[int]]) -> int:
        def check(h: int) -> bool:
            q = deque([(0, 0)])
            vis = {(0, 0)}
            dirs = (-1, 0, 1, 0, -1)
            while q:
                for _ in range(len(q)):
                    i, j = q.popleft()
                    if i == m - 1 and j == n - 1:
                        return True
                    for a, b in pairwise(dirs):
                        x, y = i + a, j + b
                        if (
                            0 <= x < m
                            and 0 <= y < n
                            and (x, y) not in vis
                            and abs(heights[i][j] - heights[x][y]) <= h
                        ):
                            q.append((x, y))
                            vis.add((x, y))
            return False

        m, n = len(heights), len(heights[0])
        return bisect_left(range(10**6), True, key=check)
```

# Solution: heap-optimized-dijkstra-algorithm · Heap-optimized Dijkstra Algorithm · O(m × n × log(m × n)) · O(m × n)

We can treat each cell as a node in a graph, and the absolute difference in height between two adjacent cells as the weight of the edge. Therefore, this problem is to solve the shortest path problem from the top-left node to the bottom-right node.

We can use the Dijkstra algorithm to solve the shortest path problem, and use a priority queue (heap) to optimize the time complexity. Specifically, we maintain a two-dimensional array dist of size `m × n`, where `dist[i][j]` represents the maximum weight of the shortest path from the top-left corner to the node `(i,j)`. Initially, `dist[0][0]=0`, and all other elements are positive infinity.

We use a priority queue (heap) to store nodes, and each time we take out the node with the smallest weight from the priority queue (heap), then update the weights of its adjacent nodes. If the weight of an adjacent node changes, then we add this node to the priority queue (heap). When the priority queue (heap) is empty, it means that we have found the shortest path.

The time complexity is O(m × n × log(m × n)), and the space complexity is O(m × n). Here, m and n are the number of rows and columns in the two-dimensional array, respectively.

```python
class Solution:
    def minimumEffortPath(self, heights: List[List[int]]) -> int:
        m, n = len(heights), len(heights[0])
        dist = [[inf] * n for _ in range(m)]
        dist[0][0] = 0
        dirs = (-1, 0, 1, 0, -1)
        q = [(0, 0, 0)]
        while q:
            t, i, j = heappop(q)
            for a, b in pairwise(dirs):
                x, y = i + a, j + b
                if (
                    0 <= x < m
                    and 0 <= y < n
                    and (d := max(t, abs(heights[i][j] - heights[x][y]))) < dist[x][y]
                ):
                    dist[x][y] = d
                    heappush(q, (d, x, y))
        return int(dist[-1][-1])
```

# Tests

```python

```
