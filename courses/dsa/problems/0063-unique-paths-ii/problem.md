---
lc: 63
title: "Unique Paths II"
difficulty: "Medium"
patterns: ["dynamic-programming"]
lcTags: ["array", "dynamic-programming", "matrix"]
entry: {"method": "uniquePathsWithObstacles", "params": [{"name": "obstacleGrid", "type": "integer[][]"}], "returns": "integer"}
examples: ["[[0,0,0],[0,1,0],[0,0,0]]", "[[0,1],[0,0]]"]
lcHints: ["Use dynamic programming since, from each cell, you can move to the right or down.", "assume dp[i][j] is the number of unique paths to reach (i, j). dp[i][j] = dp[i][j -1] + dp[i - 1][j]. Be careful when you encounter an obstacle. set its value in dp to 0."]
---

You are given an `m x n` integer array `grid`. There is a robot initially located at the **top-left corner** (i.e., `grid[0][0]`). The robot tries to move to the **bottom-right corner** (i.e., `grid[m - 1][n - 1]`). The robot can only move either down or right at any point in time.

An obstacle and space are marked as `1` or `0` respectively in `grid`. A path that the robot takes cannot include **any** square that is an obstacle.

Return *the number of possible unique paths that the robot can take to reach the bottom-right corner*.

The testcases are generated so that the answer will be less than or equal to `2 * 10⁹`.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/11/04/robot1.jpg)

```
Input: obstacleGrid = [[0,0,0],[0,1,0],[0,0,0]]
Output: 2
Explanation: There is one obstacle in the middle of the 3x3 grid above.
There are two ways to reach the bottom-right corner:
1. Right -> Right -> Down -> Down
2. Down -> Down -> Right -> Right
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2020/11/04/robot2.jpg)

```
Input: obstacleGrid = [[0,1],[0,0]]
Output: 1
```

**Constraints:**

- `m == obstacleGrid.length`
- `n == obstacleGrid[i].length`
- `1 <= m, n <= 100`
- `obstacleGrid[i][j]` is `0` or `1`.

# Starter

```python
class Solution:
    def uniquePathsWithObstacles(self, obstacleGrid: list[list[int]]) -> int:
        
```

# Hints

1. Same as Unique Paths, but an obstacle cell has 0 ways.
2. dp[c] += dp[c − 1] row by row, setting dp[c] = 0 on obstacles. Start with dp[0] = 1 unless the start is blocked.

# Key points

- same recurrence; obstacles force 0
- blocked start or end → 0
- O(m·n) time, O(n) space

# Solution: memoization-search · Memoization Search · O(m × n) · O(m × n) · reference

We design a function `dfs(i, j)` to represent the number of paths from the grid `(i, j)` to the grid `(m - 1, n - 1)`. Here, m and n are the number of rows and columns of the grid, respectively.

The execution process of the function `dfs(i, j)` is as follows:

- If `i >= m` or `j >= n`, or `obstacleGrid[i][j] = 1`, the number of paths is 0;
- If `i = m - 1` and `j = n - 1`, the number of paths is 1;
- Otherwise, the number of paths is `dfs(i + 1, j) + dfs(i, j + 1)`.

To avoid redundant calculations, we can use memoization.

The time complexity is O(m × n), and the space complexity is O(m × n). Here, m and n are the number of rows and columns of the grid, respectively.

```python
class Solution:
    def uniquePathsWithObstacles(self, obstacleGrid: List[List[int]]) -> int:
        @cache
        def dfs(i: int, j: int) -> int:
            if i >= m or j >= n or obstacleGrid[i][j]:
                return 0
            if i == m - 1 and j == n - 1:
                return 1
            return dfs(i + 1, j) + dfs(i, j + 1)

        m, n = len(obstacleGrid), len(obstacleGrid[0])
        return dfs(0, 0)
```

# Solution: dynamic-programming · Dynamic Programming · O(m × n) · O(m × n)

We can use a dynamic programming approach by defining a 2D array f, where `f[i][j]` represents the number of paths from the grid `(0,0)` to the grid `(i,j)`.

We first initialize all values in the first column and the first row of f, then traverse the other rows and columns with two cases:

- If `obstacleGrid[i][j] = 1`, it means the number of paths is 0, so `f[i][j] = 0`;
- If `obstacleGrid[i][j] = 0`, then `f[i][j] = f[i - 1][j] + f[i][j - 1]`.

Finally, return `f[m - 1][n - 1]`.

The time complexity is O(m × n), and the space complexity is O(m × n). Here, m and n are the number of rows and columns of the grid, respectively.

```python
class Solution:
    def uniquePathsWithObstacles(self, obstacleGrid: List[List[int]]) -> int:
        m, n = len(obstacleGrid), len(obstacleGrid[0])
        f = [[0] * n for _ in range(m)]
        for i in range(m):
            if obstacleGrid[i][0] == 1:
                break
            f[i][0] = 1
        for j in range(n):
            if obstacleGrid[0][j] == 1:
                break
            f[0][j] = 1
        for i in range(1, m):
            for j in range(1, n):
                if obstacleGrid[i][j] == 0:
                    f[i][j] = f[i - 1][j] + f[i][j - 1]
        return f[-1][-1]
```

# Tests

```python

```
