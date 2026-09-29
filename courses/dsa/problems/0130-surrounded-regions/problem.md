---
lc: 130
title: "Surrounded Regions"
difficulty: "Medium"
patterns: ["island-traversal"]
lcTags: ["array", "depth-first-search", "breadth-first-search", "union-find", "matrix"]
entry: {"method": "solve", "params": [{"name": "board", "type": "character[][]"}], "returns": "void", "outputParam": 0}
examples: ["[[\"X\",\"X\",\"X\",\"X\"],[\"X\",\"O\",\"O\",\"X\"],[\"X\",\"X\",\"O\",\"X\"],[\"X\",\"O\",\"X\",\"X\"]]", "[[\"X\"]]"]
---

You are given an `m x n` matrix `board` containing **letters** `'X'` and `'O'`, **capture regions** that are **surrounded**:

- **Connect**: A cell is connected to adjacent cells horizontally or vertically.
- **Region**: To form a region **connect every** `'O'` cell.
- **Surround**: A region is surrounded if none of the `'O'` cells in that region are on the edge of the board. Such regions are **completely enclosed** by `'X'` cells.

To capture a **surrounded region**, replace all `'O'`s with `'X'`s **in-place** within the original board. You do not need to return anything.

**Example 1:**

**Input:** board = [["X","X","X","X"],["X","O","O","X"],["X","X","O","X"],["X","O","X","X"]]

**Output:** [["X","X","X","X"],["X","X","X","X"],["X","X","X","X"],["X","O","X","X"]]

**Explanation:**

![](https://assets.leetcode.com/uploads/2021/02/19/xogrid.jpg)

In the above diagram, the bottom region is not captured because it is on the edge of the board and cannot be surrounded.

**Example 2:**

**Input:** board = [["X"]]

**Output:** [["X"]]

**Constraints:**

- `m == board.length`
- `n == board[i].length`
- `1 <= m, n <= 200`
- `board[i][j]` is `'X'` or `'O'`.

# Starter

```python
class Solution:
    def solve(self, board: list[list[str]]) -> None:
        """
        Do not return anything, modify board in-place instead.
        """
        
```

# Hints

1. An 'O' survives only if it's connected to the border. It's easier to find the survivors than the captured ones.
2. DFS from every border 'O' and mark those cells (e.g. 'S'). Then flip every remaining 'O' to 'X' and every 'S' back to 'O'.

# Key points

- start from the border: those regions can't be captured
- mark safe cells, flip the rest, restore the safe ones
- O(m·n) time

# Solution: depth-first-search-dfs · Depth-First Search (DFS) · O(m × n) · O(m × n) · reference

We can start from the boundary of the matrix, taking each 'O' on the matrix boundary as a starting point, and perform depth-first search. All 'O's found in the search are replaced with '.'.

Then we traverse the matrix again, for each position:

- If it is '.', replace it with 'O';
- Otherwise, if it is 'O', replace it with 'X'.

The time complexity is O(m × n), and the space complexity is O(m × n). Here, m and n are the number of rows and columns in the matrix, respectively.

```python
class Solution:
    def solve(self, board: List[List[str]]) -> None:
        def dfs(i: int, j: int):
            if not (0 <= i < m and 0 <= j < n and board[i][j] == "O"):
                return
            board[i][j] = "."
            for a, b in pairwise((-1, 0, 1, 0, -1)):
                dfs(i + a, j + b)

        m, n = len(board), len(board[0])
        for i in range(m):
            dfs(i, 0)
            dfs(i, n - 1)
        for j in range(n):
            dfs(0, j)
            dfs(m - 1, j)
        for i in range(m):
            for j in range(n):
                if board[i][j] == ".":
                    board[i][j] = "O"
                elif board[i][j] == "O":
                    board[i][j] = "X"
```

# Solution: union-find-set · Union-Find Set · O(m × n × \alpha(m × n)) · O(m × n)

We can also use a union-find set, connecting each 'O' on the matrix boundary with a super node `m × n`, and connecting each 'O' in the matrix with the 'O's above, below, left, and right of it.

Then we traverse this matrix, for each position, if it is 'O' and it is not connected to the super node, then we replace it with 'X'.

The time complexity is O(m × n × \alpha(m × n)), and the space complexity is O(m × n). Here, m and n are the number of rows and columns in the matrix, respectively, and `\alpha` is the inverse Ackermann function.

```python
class Solution:
    def solve(self, board: List[List[str]]) -> None:
        def find(x: int) -> int:
            if p[x] != x:
                p[x] = find(p[x])
            return p[x]

        m, n = len(board), len(board[0])
        p = list(range(m * n + 1))
        for i in range(m):
            for j in range(n):
                if board[i][j] == "O":
                    if i in (0, m - 1) or j in (0, n - 1):
                        p[find(i * n + j)] = find(m * n)
                    else:
                        for a, b in pairwise((-1, 0, 1, 0, -1)):
                            x, y = i + a, j + b
                            if board[x][y] == "O":
                                p[find(x * n + y)] = find(i * n + j)
        for i in range(m):
            for j in range(n):
                if board[i][j] == "O" and find(i * n + j) != find(m * n):
                    board[i][j] = "X"
```

# Tests

```python

```
