---
lc: 79
title: "Word Search"
difficulty: "Medium"
patterns: ["backtracking"]
lcTags: ["array", "string", "backtracking", "depth-first-search", "matrix"]
entry: {"method": "exist", "params": [{"name": "board", "type": "character[][]"}, {"name": "word", "type": "string"}], "returns": "boolean"}
examples: ["[[\"A\",\"B\",\"C\",\"E\"],[\"S\",\"F\",\"C\",\"S\"],[\"A\",\"D\",\"E\",\"E\"]]\n\"ABCCED\"", "[[\"A\",\"B\",\"C\",\"E\"],[\"S\",\"F\",\"C\",\"S\"],[\"A\",\"D\",\"E\",\"E\"]]\n\"SEE\"", "[[\"A\",\"B\",\"C\",\"E\"],[\"S\",\"F\",\"C\",\"S\"],[\"A\",\"D\",\"E\",\"E\"]]\n\"ABCB\""]
---

Given an `m x n` grid of characters `board` and a string `word`, return `true` *if* `word` *exists in the grid*.

The word can be constructed from letters of sequentially adjacent cells, where adjacent cells are horizontally or vertically neighboring. The same letter cell may not be used more than once.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/11/04/word2.jpg)

```
Input: board = [["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], word = "ABCCED"
Output: true
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2020/11/04/word-1.jpg)

```
Input: board = [["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], word = "SEE"
Output: true
```

**Example 3:**

![](https://assets.leetcode.com/uploads/2020/10/15/word3.jpg)

```
Input: board = [["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], word = "ABCB"
Output: false
```

**Constraints:**

- `m == board.length`
- `n = board[i].length`
- `1 <= m, n <= 6`
- `1 <= word.length <= 15`
- `board` and `word` consists of only lowercase and uppercase English letters.

**Follow up:** Could you use search pruning to make your solution faster with a larger `board`?

# Starter

```python
class Solution:
    def exist(self, board: list[list[str]], word: str) -> bool:
        
```

# Hints

1. Try every cell as the start. From a cell, the next letter must be in one of the 4 neighbours, and a cell can't be reused.
2. DFS(r, c, i): fail if out of bounds or board[r][c] != word[i]; succeed if i is the last index. Mark the cell (e.g. set it to '#'), recurse into 4 neighbours, then restore it.

# Key points

- DFS from every cell matching word[0]
- mark visited in place and restore on the way back (backtracking)
- prune: letter mismatch ends the branch immediately
- O(m·n·3^L) time, L = word length

# Solution: dfs-backtracking · DFS (Backtracking) · O(m × n × 3^k) · O(min(m × n, k)) · reference

We can enumerate each position `(i, j)` in the grid as the starting point of the search, and then start a depth-first search from the starting point. If we can search to the end of the word, it means the word exists, otherwise, it means the word does not exist.

Therefore, we design a function `dfs(i, j, k)`, which represents whether we can successfully search from the `(i, j)` position of the grid, starting from the kth character of the word. The execution steps of the function `dfs(i, j, k)` are as follows:

- If `k = |word|-1`, it means that we have searched to the last character of the word. At this time, we only need to judge whether the character at the `(i, j)` position of the grid is equal to `word[k]`. If they are equal, it means the word exists, otherwise, it means the word does not exist. Whether the word exists or not, there is no need to continue to search, so return the result directly.
- Otherwise, if the `word[k]` character is not equal to the character at the `(i, j)` position of the grid, it means that the search failed this time, so return `false` directly.
- Otherwise, we temporarily store the character at the `(i, j)` position of the grid in c, and then modify the character at this position to a special character `'0'`, indicating that the character at this position has been used to prevent it from being reused in subsequent searches. Then we start from the up, down, left, and right directions of the `(i, j)` position to search for the `k+1`th character in the grid. If any direction is successful, it means the search is successful, otherwise, it means the search failed. At this time, we need to restore the character at the `(i, j)` position of the grid, that is, put c back to the `(i, j)` position (backtracking).

In the main function, we enumerate each position `(i, j)` in the grid as the starting point. If calling `dfs(i, j, 0)` returns `true`, it means the word exists, otherwise, it means the word does not exist, so return `false`.

The time complexity is O(m × n × 3^k), and the space complexity is O(min(m × n, k)). Here, m and n are the number of rows and columns of the grid, respectively; and k is the length of the string word.

```python
class Solution:
    def exist(self, board: List[List[str]], word: str) -> bool:
        def dfs(i: int, j: int, k: int) -> bool:
            if k == len(word) - 1:
                return board[i][j] == word[k]
            if board[i][j] != word[k]:
                return False
            c = board[i][j]
            board[i][j] = "0"
            for a, b in pairwise((-1, 0, 1, 0, -1)):
                x, y = i + a, j + b
                ok = 0 <= x < m and 0 <= y < n and board[x][y] != "0"
                if ok and dfs(x, y, k + 1):
                    return True
            board[i][j] = c
            return False

        m, n = len(board), len(board[0])
        return any(dfs(i, j, 0) for i in range(m) for j in range(n))
```

# Tests

```python

```
