---
lc: 200
title: "Number of Islands"
difficulty: "Medium"
patterns: ["island-traversal"]
lcTags: ["array", "depth-first-search", "breadth-first-search", "union-find", "matrix"]
entry: {"method": "numIslands", "params": [{"name": "grid", "type": "character[][]"}], "returns": "integer"}
examples: ["[[\"1\",\"1\",\"1\",\"1\",\"0\"],[\"1\",\"1\",\"0\",\"1\",\"0\"],[\"1\",\"1\",\"0\",\"0\",\"0\"],[\"0\",\"0\",\"0\",\"0\",\"0\"]]", "[[\"1\",\"1\",\"0\",\"0\",\"0\"],[\"1\",\"1\",\"0\",\"0\",\"0\"],[\"0\",\"0\",\"1\",\"0\",\"0\"],[\"0\",\"0\",\"0\",\"1\",\"1\"]]"]
---

Given an `m x n` 2D binary grid `grid` which represents a map of `'1'`s (land) and `'0'`s (water), return *the number of islands*.

An **island** is surrounded by water and is formed by connecting adjacent lands horizontally or vertically. You may assume all four edges of the grid are all surrounded by water.

**Example 1:**

```
Input: grid = [
  ["1","1","1","1","0"],
  ["1","1","0","1","0"],
  ["1","1","0","0","0"],
  ["0","0","0","0","0"]
]
Output: 1
```

**Example 2:**

```
Input: grid = [
  ["1","1","0","0","0"],
  ["1","1","0","0","0"],
  ["0","0","1","0","0"],
  ["0","0","0","1","1"]
]
Output: 3
```

**Constraints:**

- `m == grid.length`
- `n == grid[i].length`
- `1 <= m, n <= 300`
- `grid[i][j]` is `'0'` or `'1'`.

# Starter

```python
class Solution:
    def numIslands(self, grid: List[List[str]]) -> int:
        
```

# Hints

1. Every time you find an unvisited '1', you've found a new island. How do you make sure you don't count its other cells again?
2. Loop over cells. On a '1', count it and flood the whole island (DFS/BFS), turning its cells into '0'.

# Key points

- scan grid; each unvisited land cell starts a new island
- DFS/BFS sinks the island (marks visited)
- O(m·n) time; union-find is an alternative

# Solution: dfs · DFS · O(m × n) · O(m × n) · reference

We can use depth-first search (DFS) to traverse each island. We iterate through each cell `(i, j)` in the grid. If the cell's value is '1', it means we have found a new island. We can start a DFS from this cell, marking all connected land cells as '0' to avoid duplicate counting. Each time we find a new island, we increment the island count by 1.

The time complexity is O(m × n), and the space complexity is O(m × n). Where m and n are the number of rows and columns in the grid, respectively.

```python
class Solution:
    def numIslands(self, grid: List[List[str]]) -> int:
        def dfs(i, j):
            grid[i][j] = '0'
            for a, b in pairwise(dirs):
                x, y = i + a, j + b
                if 0 <= x < m and 0 <= y < n and grid[x][y] == '1':
                    dfs(x, y)

        ans = 0
        dirs = (-1, 0, 1, 0, -1)
        m, n = len(grid), len(grid[0])
        for i in range(m):
            for j in range(n):
                if grid[i][j] == '1':
                    dfs(i, j)
                    ans += 1
        return ans
```

# Solution: bfs · BFS · O(m × n) · O(m × n)

We can also use breadth-first search (BFS) to traverse each island. We iterate through each cell `(i, j)` in the grid. If the cell's value is '1', it means we have found a new island. We can start a BFS from this cell, marking all connected land cells as '0' to avoid duplicate counting. Each time we find a new island, we increment the island count by 1.

The specific BFS process is as follows:

1. Enqueue the starting cell `(i, j)` and mark its value as '0'.
2. While the queue is not empty, perform the following operations:
    - Dequeue a cell p.
    - Iterate through the four adjacent cells `(x, y)` of p. If `(x, y)` is within the grid bounds and its value is '1', enqueue it and mark its value as '0'.

The time complexity is O(m × n), and the space complexity is O(m × n). Where m and n are the number of rows and columns in the grid, respectively.

```python
class Solution:
    def numIslands(self, grid: List[List[str]]) -> int:
        def bfs(i, j):
            grid[i][j] = '0'
            q = deque([(i, j)])
            while q:
                i, j = q.popleft()
                for a, b in pairwise(dirs):
                    x, y = i + a, j + b
                    if 0 <= x < m and 0 <= y < n and grid[x][y] == '1':
                        q.append((x, y))
                        grid[x][y] = 0

        ans = 0
        dirs = (-1, 0, 1, 0, -1)
        m, n = len(grid), len(grid[0])
        for i in range(m):
            for j in range(n):
                if grid[i][j] == '1':
                    bfs(i, j)
                    ans += 1
        return ans
```

# Solution: union-find · Union-Find · O(m × n × log (m × n)) · O(m × n)

We can use the Union-Find data structure to solve this problem. We traverse each cell `(i, j)` in the grid, and if the cell's value is '1', we merge it with adjacent land cells. Finally, we count the number of distinct root nodes in the Union-Find structure, which represents the number of islands.

The time complexity is O(m × n × log (m × n)), and the space complexity is O(m × n). Where m and n are the number of rows and columns in the grid, respectively.

```python
class Solution:
    def numIslands(self, grid: List[List[str]]) -> int:
        def find(x):
            if p[x] != x:
                p[x] = find(p[x])
            return p[x]

        dirs = (0, 1, 0)
        m, n = len(grid), len(grid[0])
        p = list(range(m * n))
        for i in range(m):
            for j in range(n):
                if grid[i][j] == '1':
                    for a, b in pairwise(dirs):
                        x, y = i + a, j + b
                        if x < m and y < n and grid[x][y] == '1':
                            p[find(i * n + j)] = find(x * n + y)
        return sum(
            grid[i][j] == '1' and i * n + j == find(i * n + j)
            for i in range(m)
            for j in range(n)
        )
```

# Tests

```python

```
