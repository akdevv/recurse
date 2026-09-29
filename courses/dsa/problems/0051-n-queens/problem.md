---
lc: 51
title: "N-Queens"
difficulty: "Hard"
patterns: ["backtracking"]
lcTags: ["array", "backtracking", "algorithm-x"]
compare: "unordered"
entry: {"method": "solveNQueens", "params": [{"name": "n", "type": "integer"}], "returns": "list<list<string>>"}
examples: ["4", "1"]
---

The **n-queens** puzzle is the problem of placing `n` queens on an `n x n` chessboard such that no two queens attack each other.

Given an integer `n`, return *all distinct solutions to the **n-queens puzzle***. You may return the answer in **any order**.

Each solution contains a distinct board configuration of the n-queens' placement, where `'Q'` and `'.'` both indicate a queen and an empty space, respectively.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/11/13/queens.jpg)

```
Input: n = 4
Output: [[".Q..","...Q","Q...","..Q."],["..Q.","Q...","...Q",".Q.."]]
Explanation: There exist two distinct solutions to the 4-queens puzzle as shown above
```

**Example 2:**

```
Input: n = 1
Output: [["Q"]]
```

**Constraints:**

- `1 <= n <= 9`

# Starter

```python
class Solution:
    def solveNQueens(self, n: int) -> list[list[str]]:
        
```

# Hints

1. Place one queen per row. What do you need to know to check a new queen quickly?
2. Keep sets of used columns, diagonals (r − c) and anti-diagonals (r + c). For each row try each free column, recurse, then remove it.

# Key points

- one queen per row, so recursion depth = row index
- conflicts: same column, same r - c, same r + c; sets make checks O(1)
- build the board strings when row == n
- O(n!) time roughly

# Solution: dfs-backtracking · DFS (Backtracking) · O(n² × n!) · O(n) · reference

We define three arrays col, dg, and udg to represent whether there is a queen in the column, the main diagonal, and the anti-diagonal, respectively. If there is a queen at position `(i, j)`, then `col[j]`, `dg[i + j]`, and `udg[n - i + j]` are all 1. In addition, we use an array g to record the current state of the chessboard, where all elements in g are initially `'.'`.

Next, we define a function `dfs(i)`, which represents placing queens starting from the ith row.

In `dfs(i)`, if `i = n`, it means that we have completed the placement of all queens. We put the current g into the answer array and end the recursion.

Otherwise, we enumerate each column j of the current row. If there is no queen at position `(i, j)`, that is, `col[j]`, `dg[i + j]`, and `udg[n - i + j]` are all 0, then we can place a queen, that is, change `g[i][j]` to `'Q'`, and set `col[j]`, `dg[i + j]`, and `udg[n - i + j]` to 1. Then we continue to search the next row, that is, call `dfs(i + 1)`. After the recursion ends, we need to change `g[i][j]` back to `'.'` and set `col[j]`, `dg[i + j]`, and `udg[n - i + j]` to 0.

In the main function, we call `dfs(0)` to start recursion, and finally return the answer array.

The time complexity is O(n² × n!), and the space complexity is O(n). Here, n is the integer given in the problem.

```python
class Solution:
    def solveNQueens(self, n: int) -> List[List[str]]:
        def dfs(i: int):
            if i == n:
                ans.append(["".join(row) for row in g])
                return
            for j in range(n):
                if col[j] + dg[i + j] + udg[n - i + j] == 0:
                    g[i][j] = "Q"
                    col[j] = dg[i + j] = udg[n - i + j] = 1
                    dfs(i + 1)
                    col[j] = dg[i + j] = udg[n - i + j] = 0
                    g[i][j] = "."

        ans = []
        g = [["."] * n for _ in range(n)]
        col = [0] * n
        dg = [0] * (n << 1)
        udg = [0] * (n << 1)
        dfs(0)
        return ans
```

# Tests

```python

```
