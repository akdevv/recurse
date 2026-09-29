---
lc: 463
title: "Island Perimeter"
difficulty: "Easy"
patterns: ["island-traversal"]
lcTags: ["array", "depth-first-search", "breadth-first-search", "matrix"]
entry: {"method": "islandPerimeter", "params": [{"name": "grid", "type": "integer[][]"}], "returns": "integer"}
examples: ["[[0,1,0,0],[1,1,1,0],[0,1,0,0],[1,1,0,0]]", "[[1]]", "[[1,0]]"]
---

You are given `row x col` `grid` representing a map where `grid[i][j] = 1` represents land and `grid[i][j] = 0` represents water.

Grid cells are connected **horizontally/vertically** (not diagonally). The `grid` is completely surrounded by water, and there is exactly one island (i.e., one or more connected land cells).

The island doesn't have "lakes", meaning the water inside isn't connected to the water around the island. One cell is a square with side length 1. The grid is rectangular, width and height don't exceed 100. Determine the perimeter of the island.

**Example 1:**

![](https://assets.leetcode.com/uploads/2018/10/12/island.png)

```
Input: grid = [[0,1,0,0],[1,1,1,0],[0,1,0,0],[1,1,0,0]]
Output: 16
Explanation: The perimeter is the 16 yellow stripes in the image above.
```

**Example 2:**

```
Input: grid = [[1]]
Output: 4
```

**Example 3:**

```
Input: grid = [[1,0]]
Output: 4
```

**Constraints:**

- `row == grid.length`
- `col == grid[i].length`
- `1 <= row, col <= 100`
- `grid[i][j]` is `0` or `1`.
- There is exactly one island in `grid`.

# Starter

```python
class Solution:
    def islandPerimeter(self, grid: list[list[int]]) -> int:
        
```

# Hints

1. Each land cell contributes 4 edges, minus the edges it shares with land neighbours.
2. For every land cell add 4, and subtract 2 for each land neighbour to the right or below (each shared edge removes 2 sides).

# Key points

- count 4 per land cell, subtract 2 per shared edge
- only check right/down neighbours so each edge is counted once
- O(m·n) time, O(1) space

# Solution: solution-1 · Count cells, subtract shared edges · O(m × n) · O(1) · reference

## Idea
Every land cell adds 4 edges. Each pair of adjacent land cells hides 2 of them (one from each cell), so subtract 2 for every land neighbour to the right or below.

## Complexity
- **Time: O(m × n)**
- **Space: O(1)**

```python
class Solution:
    def islandPerimeter(self, grid: List[List[int]]) -> int:
        m, n = len(grid), len(grid[0])
        ans = 0
        for i in range(m):
            for j in range(n):
                if grid[i][j] == 1:
                    ans += 4
                    if i < m - 1 and grid[i + 1][j] == 1:
                        ans -= 2
                    if j < n - 1 and grid[i][j + 1] == 1:
                        ans -= 2
        return ans
```

# Tests

```python
def island(rng, rows, cols, cells):
    g = [[0] * cols for _ in range(rows)]
    r, c = rng.randrange(rows), rng.randrange(cols)
    g[r][c] = 1
    land = [(r, c)]
    for _ in range(cells - 1):
        r, c = rng.choice(land)
        dr, dc = rng.choice([(0, 1), (1, 0), (0, -1), (-1, 0)])
        if 0 <= r + dr < rows and 0 <= c + dc < cols and not g[r + dr][c + dc]:
            g[r + dr][c + dc] = 1
            land.append((r + dr, c + dc))
    return [g]

def edge():
    return [[[[1]]], [[[1, 0]]], [[[0, 1, 0, 0], [1, 1, 1, 0], [0, 1, 0, 0], [1, 1, 0, 0]]], [[[1, 1], [1, 1]]]]

def random_case(rng):
    r, c = rng.randint(1, 5), rng.randint(1, 5)
    return island(rng, r, c, rng.randint(1, r * c))

def perf(rng):
    return [[[[1] * 100 for _ in range(100)]]]
```
