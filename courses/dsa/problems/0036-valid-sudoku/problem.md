---
lc: 36
title: "Valid Sudoku"
difficulty: "Medium"
patterns: ["hash-map"]
lcTags: ["array", "hash-table", "matrix"]
entry: {"method": "isValidSudoku", "params": [{"name": "board", "type": "character[][]"}], "returns": "boolean"}
examples: ["[[\"5\",\"3\",\".\",\".\",\"7\",\".\",\".\",\".\",\".\"],[\"6\",\".\",\".\",\"1\",\"9\",\"5\",\".\",\".\",\".\"],[\".\",\"9\",\"8\",\".\",\".\",\".\",\".\",\"6\",\".\"],[\"8\",\".\",\".\",\".\",\"6\",\".\",\".\",\".\",\"3\"],[\"4\",\".\",\".\",\"8\",\".\",\"3\",\".\",\".\",\"1\"],[\"7\",\".\",\".\",\".\",\"2\",\".\",\".\",\".\",\"6\"],[\".\",\"6\",\".\",\".\",\".\",\".\",\"2\",\"8\",\".\"],[\".\",\".\",\".\",\"4\",\"1\",\"9\",\".\",\".\",\"5\"],[\".\",\".\",\".\",\".\",\"8\",\".\",\".\",\"7\",\"9\"]]", "[[\"8\",\"3\",\".\",\".\",\"7\",\".\",\".\",\".\",\".\"],[\"6\",\".\",\".\",\"1\",\"9\",\"5\",\".\",\".\",\".\"],[\".\",\"9\",\"8\",\".\",\".\",\".\",\".\",\"6\",\".\"],[\"8\",\".\",\".\",\".\",\"6\",\".\",\".\",\".\",\"3\"],[\"4\",\".\",\".\",\"8\",\".\",\"3\",\".\",\".\",\"1\"],[\"7\",\".\",\".\",\".\",\"2\",\".\",\".\",\".\",\"6\"],[\".\",\"6\",\".\",\".\",\".\",\".\",\"2\",\"8\",\".\"],[\".\",\".\",\".\",\"4\",\"1\",\"9\",\".\",\".\",\"5\"],[\".\",\".\",\".\",\".\",\"8\",\".\",\".\",\"7\",\"9\"]]"]
---

Determine if a `9 x 9` Sudoku board is valid. Only the filled cells need to be validated **according to the following rules**:

1. Each row must contain the digits `1-9` without repetition.
1. Each column must contain the digits `1-9` without repetition.
1. Each of the nine `3 x 3` sub-boxes of the grid must contain the digits `1-9` without repetition.

**Note:**

- A Sudoku board (partially filled) could be valid but is not necessarily solvable.
- Only the filled cells need to be validated according to the mentioned rules.

**Example 1:**

![](https://upload.wikimedia.org/wikipedia/commons/thumb/f/ff/Sudoku-by-L2G-20050714.svg/250px-Sudoku-by-L2G-20050714.svg.png)

```
Input: board =
[["5","3",".",".","7",".",".",".","."]
,["6",".",".","1","9","5",".",".","."]
,[".","9","8",".",".",".",".","6","."]
,["8",".",".",".","6",".",".",".","3"]
,["4",".",".","8",".","3",".",".","1"]
,["7",".",".",".","2",".",".",".","6"]
,[".","6",".",".",".",".","2","8","."]
,[".",".",".","4","1","9",".",".","5"]
,[".",".",".",".","8",".",".","7","9"]]
Output: true
```

**Example 2:**

```
Input: board =
[["8","3",".",".","7",".",".",".","."]
,["6",".",".","1","9","5",".",".","."]
,[".","9","8",".",".",".",".","6","."]
,["8",".",".",".","6",".",".",".","3"]
,["4",".",".","8",".","3",".",".","1"]
,["7",".",".",".","2",".",".",".","6"]
,[".","6",".",".",".",".","2","8","."]
,[".",".",".","4","1","9",".",".","5"]
,[".",".",".",".","8",".",".","7","9"]]
Output: false
Explanation: Same as Example 1, except with the 5 in the top left corner being modified to 8. Since there are two 8's in the top left 3x3 sub-box, it is invalid.
```

**Constraints:**

- `board.length == 9`
- `board[i].length == 9`
- `board[i][j]` is a digit `1-9` or `'.'`.

# Starter

```python
class Solution:
    def isValidSudoku(self, board: list[list[str]]) -> bool:
        
```

# Hints

1. Only the filled cells matter. Each digit may appear once per row, once per column and once per 3×3 box.
2. Box index for cell (r, c) is (r // 3, c // 3). Keep a set per row, column and box, or one set of tuples like ("row", r, d).

# Key points

- check rows, columns and 3×3 boxes for repeats
- box id = (r // 3, c // 3)
- one pass with sets; the board is fixed at 9×9 so it's O(1) (O(n²) for an n×n board)
- we only validate the filled cells, not whether the puzzle is solvable

# Solution: one-pass · One pass with sets · O(81) · O(81) · reference

## Idea
Tag each filled cell three ways: its row, its column, and its box `(r // 3, c // 3)`. If any tag was already seen, that digit repeats in that unit.

## Complexity
- **Time: O(1)**: always 81 cells (O(n²) for an n×n board).
- **Space: O(1)**, at most 243 tags.

```python
class Solution:
    def isValidSudoku(self, board: list[list[str]]) -> bool:
        seen = set()
        for r in range(9):
            for c in range(9):
                d = board[r][c]
                if d == ".":
                    continue
                keys = (("row", r, d), ("col", c, d), ("box", r // 3, c // 3, d))
                if any(k in seen for k in keys):
                    return False
                seen.update(keys)
        return True
```

# Tests

```python
BASE = [list("534678912"), list("672195348"), list("198342567"), list("859761423"), list("426853791"),
        list("713924856"), list("961537284"), list("287419635"), list("345286179")]

def edge():
    empty = [["."] * 9 for _ in range(9)]
    same_box = [["."] * 9 for _ in range(9)]; same_box[0][0] = same_box[1][1] = "5"
    same_col = [["."] * 9 for _ in range(9)]; same_col[0][4] = same_col[8][4] = "9"
    return [[empty], [same_box], [same_col], [[row[:] for row in BASE]]]

def random_case(rng):
    b = [[BASE[r][c] if rng.random() < 0.4 else "." for c in range(9)] for r in range(9)]
    if rng.random() < 0.5:
        r, c = rng.randrange(9), rng.randrange(9)
        b[r][c] = str(rng.randint(1, 9))
    return [b]
```
