---
lc: 867
title: "Transpose Matrix"
difficulty: "Easy"
patterns: ["simulation"]
lcTags: ["array", "matrix", "simulation"]
entry: {"method": "transpose", "params": [{"name": "matrix", "type": "integer[][]"}], "returns": "integer[][]"}
examples: ["[[1,2,3],[4,5,6],[7,8,9]]", "[[1,2,3],[4,5,6]]"]
lcHints: ["We don't need any special algorithms to do this. You just need to know what the transpose of a matrix looks like. Rows become columns and vice versa!"]
---

Given a 2D integer array `matrix`, return *the **transpose** of* `matrix`.

The **transpose** of a matrix is the matrix flipped over its main diagonal, switching the matrix's row and column indices.

![](https://assets.leetcode.com/uploads/2021/02/10/hint_transpose.png)

**Example 1:**

```
Input: matrix = [[1,2,3],[4,5,6],[7,8,9]]
Output: [[1,4,7],[2,5,8],[3,6,9]]
```

**Example 2:**

```
Input: matrix = [[1,2,3],[4,5,6]]
Output: [[1,4],[2,5],[3,6]]
```

**Constraints:**

- `m == matrix.length`
- `n == matrix[i].length`
- `1 <= m, n <= 1000`
- `1 <= m * n <= 10⁵`
- `-10⁹ <= matrix[i][j] <= 10⁹`

# Starter

```python
class Solution:
    def transpose(self, matrix: list[list[int]]) -> list[list[int]]:
        
```

# Hints

1. The result has swapped dimensions: an m×n input gives an n×m output.
2. Cell (r, c) of the input goes to (c, r) of the output.

# Key points

- transpose flips across the main diagonal: out[c][r] = matrix[r][c]
- an m×n matrix becomes n×m, so allocate the output with swapped sizes
- O(m·n) time and space; `zip(*matrix)` is the Python shortcut

# Solution: index-loop · Copy (r, c) to (c, r) · O(m·n) · O(m·n) · reference

## Idea
Rows become columns. Make an output with swapped dimensions (`cols` rows of length `rows`) and copy each cell `(r, c)` to `(c, r)`.

Note `[[0] * rows for _ in range(cols)]`: each row must be a separate list. `[[0] * rows] * cols` would repeat the same row object.

## Complexity
- **Time: O(m·n)**, every cell once.
- **Space: O(m·n)** for the output.

```python
class Solution:
    def transpose(self, matrix: list[list[int]]) -> list[list[int]]:
        rows, cols = len(matrix), len(matrix[0])
        out = [[0] * rows for _ in range(cols)]
        for r in range(rows):
            for c in range(cols):
                out[c][r] = matrix[r][c]
        return out
```

# Solution: zip · zip(*matrix) · O(m·n) · O(m·n)

## Idea
`zip(*matrix)` passes every row to `zip`, which then yields the 1st items of all rows, then the 2nd items, and so on: exactly the columns.

## Complexity
- **Time: O(m·n)**.
- **Space: O(m·n)**.

Great to know, but be ready to write the index version: it's what the interviewer wants to see you reason about.

```python
class Solution:
    def transpose(self, matrix: list[list[int]]) -> list[list[int]]:
        return [list(col) for col in zip(*matrix)]
```

# Tests

```python
def edge():
    return [[[[1]]], [[[1, 2, 3]]], [[[1], [2], [3]]], [[[1, 2, 3], [4, 5, 6], [7, 8, 9]]], [[[1, 2, 3], [4, 5, 6]]]]

def random_case(rng):
    m, n = rng.randint(1, 5), rng.randint(1, 5)
    return [[[rng.randint(-99, 99) for _ in range(n)] for _ in range(m)]]

def perf(rng):
    return []
```
