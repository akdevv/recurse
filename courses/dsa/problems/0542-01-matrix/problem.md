---
lc: 542
title: "01 Matrix"
difficulty: "Medium"
patterns: ["bfs"]
lcTags: ["array", "dynamic-programming", "breadth-first-search", "matrix"]
entry: {"method": "updateMatrix", "params": [{"name": "mat", "type": "integer[][]"}], "returns": "integer[][]"}
examples: ["[[0,0,0],[0,1,0],[0,0,0]]", "[[0,0,0],[0,1,0],[1,1,1]]"]
---

Given an `m x n` binary matrix `mat`, return *the distance of the nearest* `0` *for each cell*.

The distance between two cells sharing a common edge is `1`.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/04/24/01-1-grid.jpg)

```
Input: mat = [[0,0,0],[0,1,0],[0,0,0]]
Output: [[0,0,0],[0,1,0],[0,0,0]]
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2021/04/24/01-2-grid.jpg)

```
Input: mat = [[0,0,0],[0,1,0],[1,1,1]]
Output: [[0,0,0],[0,1,0],[1,2,1]]
```

**Constraints:**

- `m == mat.length`
- `n == mat[i].length`
- `1 <= m, n <= 10⁴`
- `1 <= m * n <= 10⁴`
- `mat[i][j]` is either `0` or `1`.
- There is at least one `0` in `mat`.

**Note:** This question is the same as 1765: [https://leetcode.com/problems/map-of-highest-peak/](https://leetcode.com/problems/map-of-highest-peak/description/)

# Starter

```python
class Solution:
    def updateMatrix(self, mat: list[list[int]]) -> list[list[int]]:
        
```

# Hints

1. Distance to the nearest 0: instead of searching from every 1, search from all the 0s at once.
2. Multi-source BFS: start with every 0 (distance 0) in the queue; each step outward sets the distance of unvisited neighbours to current + 1.

# Key points

- multi-source BFS from all zeros
- first time a cell is reached = its shortest distance
- O(m·n) time; a two-pass DP (top-left, then bottom-right) also works

# Solution: bfs · BFS · O(m × n) · O(m × n) · reference

We create a matrix ans of the same size as mat and initialize all elements to -1.

Then, we traverse mat, adding the coordinates `(i, j)` of all 0 elements to the queue q, and setting `ans[i][j]` to 0.

Next, we use Breadth-First Search (BFS), removing an element `(i, j)` from the queue and traversing its four directions. If the element in that direction `(x, y)` satisfies `0 <= x < m`, `0 <= y < n` and `ans[x][y] = -1`, then we set `ans[x][y]` to `ans[i][j] + 1` and add `(x, y)` to the queue q.

Finally, we return ans.

The time complexity is O(m × n), and the space complexity is O(m × n). Here, m and n are the number of rows and columns in the matrix mat, respectively.

```python
class Solution:
    def updateMatrix(self, mat: List[List[int]]) -> List[List[int]]:
        m, n = len(mat), len(mat[0])
        ans = [[-1] * n for _ in range(m)]
        q = deque()
        for i, row in enumerate(mat):
            for j, x in enumerate(row):
                if x == 0:
                    ans[i][j] = 0
                    q.append((i, j))
        dirs = (-1, 0, 1, 0, -1)
        while q:
            i, j = q.popleft()
            for a, b in pairwise(dirs):
                x, y = i + a, j + b
                if 0 <= x < m and 0 <= y < n and ans[x][y] == -1:
                    ans[x][y] = ans[i][j] + 1
                    q.append((x, y))
        return ans
```

# Tests

```python
def edge():
    return [[[[0]]], [[[0, 1]]], [[[0, 0, 0], [0, 1, 0], [0, 0, 0]]], [[[0, 0, 0], [0, 1, 0], [1, 1, 1]]]]

def random_case(rng):
    r, c = rng.randint(1, 5), rng.randint(1, 5)
    g = [[rng.choice([0, 1, 1]) for _ in range(c)] for _ in range(r)]
    g[rng.randrange(r)][rng.randrange(c)] = 0
    return [g]

def perf(rng):
    g = [[1] * 100 for _ in range(100)]
    g[0][0] = 0
    return [[g]]
```
