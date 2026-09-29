---
lc: 64
title: "Minimum Path Sum"
difficulty: "Medium"
patterns: ["dynamic-programming"]
lcTags: ["array", "dynamic-programming", "matrix"]
entry: {"method": "minPathSum", "params": [{"name": "grid", "type": "integer[][]"}], "returns": "integer"}
examples: ["[[1,3,1],[1,5,1],[4,2,1]]", "[[1,2,3],[4,5,6]]"]
---

Given a `m x n` `grid` filled with non-negative numbers, find a path from top left to bottom right, which minimizes the sum of all numbers along its path.

**Note:** You can only move either down or right at any point in time.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/11/05/minpath.jpg)

```
Input: grid = [[1,3,1],[1,5,1],[4,2,1]]
Output: 7
Explanation: Because the path 1 → 3 → 1 → 1 → 1 minimizes the sum.
```

**Example 2:**

```
Input: grid = [[1,2,3],[4,5,6]]
Output: 12
```

**Constraints:**

- `m == grid.length`
- `n == grid[i].length`
- `1 <= m, n <= 200`
- `0 <= grid[i][j] <= 200`

# Starter

```python
class Solution:
    def minPathSum(self, grid: list[list[int]]) -> int:
        
```

# Hints

1. The cheapest way into a cell comes from above or from the left.
2. dp[r][c] = grid[r][c] + min(dp[r − 1][c], dp[r][c − 1]), treating out-of-grid as infinity. You can update the grid in place.

# Key points

- dp over the grid, min of top and left
- first row/column only have one way in
- O(m·n) time, O(1) extra space if done in place

# Solution: dynamic-programming · Dynamic Programming · O(m × n) · O(m × n) · reference

We define `f[i][j]` to represent the minimum path sum from the top left corner to `(i, j)`. Initially, `f[0][0] = grid[0][0]`, and the answer is `f[m - 1][n - 1]`.

Consider `f[i][j]`:

- If `j = 0`, then `f[i][j] = f[i - 1][j] + grid[i][j]`;
- If `i = 0`, then `f[i][j] = f[i][j - 1] + grid[i][j]`;
- If `i > 0` and `j > 0`, then `f[i][j] = min(f[i - 1][j], f[i][j - 1]) + grid[i][j]`.

Finally, return `f[m - 1][n - 1]`.

The time complexity is O(m × n), and the space complexity is O(m × n). Here, m and n are the number of rows and columns of the grid, respectively.

```python
class Solution:
    def minPathSum(self, grid: List[List[int]]) -> int:
        m, n = len(grid), len(grid[0])
        f = [[0] * n for _ in range(m)]
        f[0][0] = grid[0][0]
        for i in range(1, m):
            f[i][0] = f[i - 1][0] + grid[i][0]
        for j in range(1, n):
            f[0][j] = f[0][j - 1] + grid[0][j]
        for i in range(1, m):
            for j in range(1, n):
                f[i][j] = min(f[i - 1][j], f[i][j - 1]) + grid[i][j]
        return f[-1][-1]
```

# Tests

```python

```
