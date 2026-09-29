---
lc: 62
title: "Unique Paths"
difficulty: "Medium"
patterns: ["dynamic-programming"]
lcTags: ["math", "dynamic-programming", "combinatorics"]
entry: {"method": "uniquePaths", "params": [{"name": "m", "type": "integer"}, {"name": "n", "type": "integer"}], "returns": "integer"}
examples: ["3\n7", "3\n2"]
---

There is a robot on an `m x n` grid. The robot is initially located at the **top-left corner** (i.e., `grid[0][0]`). The robot tries to move to the **bottom-right corner** (i.e., `grid[m - 1][n - 1]`). The robot can only move either down or right at any point in time.

Given the two integers `m` and `n`, return *the number of possible unique paths that the robot can take to reach the bottom-right corner*.

The test cases are generated so that the answer will be less than or equal to `2 * 10⁹`.

**Example 1:**

![](https://assets.leetcode.com/uploads/2018/10/22/robot_maze.png)

```
Input: m = 3, n = 7
Output: 28
```

**Example 2:**

```
Input: m = 3, n = 2
Output: 3
Explanation: From the top-left corner, there are a total of 3 ways to reach the bottom-right corner:
1. Right -> Down -> Down
2. Down -> Down -> Right
3. Down -> Right -> Down
```

**Constraints:**

- `1 <= m, n <= 100`

# Starter

```python
class Solution:
    def uniquePaths(self, m: int, n: int) -> int:
        
```

# Hints

1. You can only enter a cell from above or from the left.
2. dp[r][c] = dp[r − 1][c] + dp[r][c − 1], with the first row and column all 1. One row of dp is enough.

# Key points

- paths to a cell = paths to the cell above + paths to the cell on the left
- first row/column: exactly one path
- O(m·n) time, O(n) space; closed form C(m + n - 2, m - 1)

# Solution: dynamic-programming · Dynamic Programming · O(m × n) · O(m × n) · reference

We define `f[i][j]` to represent the number of paths from the top left corner to `(i, j)`, initially `f[0][0] = 1`, and the answer is `f[m - 1][n - 1]`.

Consider `f[i][j]`:

- If `i > 0`, then `f[i][j]` can be reached by taking one step from `f[i - 1][j]`, so `f[i][j] = f[i][j] + f[i - 1][j]`;
- If `j > 0`, then `f[i][j]` can be reached by taking one step from `f[i][j - 1]`, so `f[i][j] = f[i][j] + f[i][j - 1]`.

Therefore, we have the following state transition equation:

```
f[i][j] = \begin{cases}
1 & i = 0, j = 0 \\
f[i - 1][j] + f[i][j - 1] & otherwise
\end{cases}
```

The final answer is `f[m - 1][n - 1]`.

The time complexity is O(m × n), and the space complexity is O(m × n). Here, m and n are the number of rows and columns of the grid, respectively.

```python
class Solution:
    def uniquePaths(self, m: int, n: int) -> int:
        f = [[0] * n for _ in range(m)]
        f[0][0] = 1
        for i in range(m):
            for j in range(n):
                if i:
                    f[i][j] += f[i - 1][j]
                if j:
                    f[i][j] += f[i][j - 1]
        return f[-1][-1]
```

# Solution: dynamic-programming-prefilled-borders · Dynamic Programming (Prefilled Borders) · O(m × n) · O(m × n)

Fill the first row and first column with 1, then only compute interior cells `f[i][j] = f[i-1][j] + f[i][j-1]`. Time and space stay O(m × n).

```python
class Solution:
    def uniquePaths(self, m: int, n: int) -> int:
        f = [[1] * n for _ in range(m)]
        for i in range(1, m):
            for j in range(1, n):
                f[i][j] = f[i - 1][j] + f[i][j - 1]
        return f[-1][-1]
```

# Solution: dynamic-programming-rolling-array · Dynamic Programming (Rolling Array) · O(m × n) · O(n)

`f[i][j]` depends only on the previous row and the left cell, so a 1D array of length n is enough. The time complexity is O(m × n) and the space complexity is O(n).

```python
class Solution:
    def uniquePaths(self, m: int, n: int) -> int:
        f = [1] * n
        for _ in range(1, m):
            for j in range(1, n):
                f[j] += f[j - 1]
        return f[-1]
```

# Tests

```python

```
