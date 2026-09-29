---
lc: 73
title: "Set Matrix Zeroes"
difficulty: "Medium"
patterns: ["hash-map"]
lcTags: ["array", "hash-table", "matrix"]
entry: {"method": "setZeroes", "params": [{"name": "matrix", "type": "integer[][]"}], "returns": "void", "outputParam": 0}
examples: ["[[1,1,1],[1,0,1],[1,1,1]]", "[[0,1,2,0],[3,4,5,2],[1,3,1,5]]"]
lcHints: ["If any cell of the matrix has a zero we can record its row and column number using additional memory.\r\nBut if you don't want to use extra memory then you can manipulate the array instead. i.e. simulating exactly what the question says.", "Setting cell values to zero on the fly while iterating might lead to discrepancies. What if you use some other integer value as your marker?\r\nThere is still a better approach for this problem with O(1) space.", "We could have used 2 sets to keep a record of rows/columns which need to be set to zero. But for an O(1) space solution, you can use one of the rows and and one of the columns to keep track of this information.", "We can use the first cell of every row and column as a flag. This flag would determine whether a row or column has been set to zero."]
---

Given an `m x n` integer matrix `matrix`, if an element is `0`, set its entire row and column to `0`'s.

You must do it [in place](https://en.wikipedia.org/wiki/In-place_algorithm).

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/08/17/mat1.jpg)

```
Input: matrix = [[1,1,1],[1,0,1],[1,1,1]]
Output: [[1,0,1],[0,0,0],[1,0,1]]
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2020/08/17/mat2.jpg)

```
Input: matrix = [[0,1,2,0],[3,4,5,2],[1,3,1,5]]
Output: [[0,0,0,0],[0,4,5,0],[0,3,1,0]]
```

**Constraints:**

- `m == matrix.length`
- `n == matrix[0].length`
- `1 <= m, n <= 200`
- `-2³¹ <= matrix[i][j] <= 2³¹ - 1`

**Follow up:**

- A straightforward solution using `O(mn)` space is probably a bad idea.
- A simple improvement uses `O(m + n)` space, but still not the best solution.
- Could you devise a constant space solution?

# Starter

```python
class Solution:
    def setZeroes(self, matrix: list[list[int]]) -> None:
        """
        Do not return anything, modify matrix in-place instead.
        """
        
```

# Hints

1. Zeroing cells while you scan creates new zeros that spread wrongly. First find, then write.
2. Record which rows and which columns contain a zero (two sets), then zero every cell whose row or column is marked. For O(1) space, store those marks in the first row and first column.

# Key points

- two passes: first record zero rows/columns, then write; writing during the scan corrupts later reads
- sets of rows and columns: O(m·n) time, O(m + n) space
- O(1) space: use the first row/column as markers, with one flag for whether the first row itself had a zero

# Solution: row-col-sets · Remember zero rows and columns · O(m·n) · O(m+n) · reference

## Idea
If you zero things while scanning, the new zeros look like original ones and wipe out too much. So split it into two passes:
1. **Find**: remember every row and every column that has a zero.
2. **Write**: zero each cell whose row or column was remembered.

## Complexity
- **Time: O(m·n)**, two passes.
- **Space: O(m + n)** for the two sets.

```python
class Solution:
    def setZeroes(self, matrix: list[list[int]]) -> None:
        rows, cols = set(), set()
        for r, row in enumerate(matrix):
            for c, v in enumerate(row):
                if v == 0:
                    rows.add(r)
                    cols.add(c)
        for r, row in enumerate(matrix):
            for c in range(len(row)):
                if r in rows or c in cols:
                    row[c] = 0
```

# Solution: first-row-markers · Markers in the first row and column · O(m·n) · O(1)

## Idea
The sets from the first solution are just "one flag per row" and "one flag per column". Store those flags **inside** the matrix: `matrix[r][0]` marks row r, `matrix[0][c]` marks column c.

The first row is used for column markers, so remember separately whether it had a zero of its own (`first_row_zero`) and zero it last.

Writing each row right to left keeps its marker `matrix[r][0]` intact until the rest of that row is done.

## Complexity
- **Time: O(m·n)**.
- **Space: O(1) extra**.

This is the answer to the follow-up question. Get the set version right first.

```python
class Solution:
    def setZeroes(self, matrix: list[list[int]]) -> None:
        m, n = len(matrix), len(matrix[0])
        first_row_zero = any(v == 0 for v in matrix[0])
        for r in range(1, m):
            for c in range(n):
                if matrix[r][c] == 0:
                    matrix[r][0] = 0
                    matrix[0][c] = 0
        for r in range(1, m):
            for c in range(n - 1, -1, -1):
                if matrix[r][0] == 0 or matrix[0][c] == 0:
                    matrix[r][c] = 0
        if matrix[0][0] == 0:
            for r in range(1, m):
                matrix[r][0] = 0
        if first_row_zero:
            for c in range(n):
                matrix[0][c] = 0
```

# Tests

```python
def edge():
    return [
        [[[0]]],
        [[[1]]],
        [[[1, 1, 1], [1, 0, 1], [1, 1, 1]]],
        [[[0, 1, 2, 0], [3, 4, 5, 2], [1, 3, 1, 5]]],
        [[[1, 0, 3]]],
        [[[1], [0], [3]]],
        [[[1, 2], [3, 0]]],
    ]

def random_case(rng):
    m, n = rng.randint(1, 6), rng.randint(1, 6)
    return [[[rng.choice([0, 1, 2, 3, 4, 5]) for _ in range(n)] for _ in range(m)]]

def perf(rng):
    return []
```
