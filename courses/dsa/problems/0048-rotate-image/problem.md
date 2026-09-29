---
lc: 48
title: "Rotate Image"
difficulty: "Medium"
patterns: ["simulation"]
lcTags: ["array", "math", "matrix"]
entry: {"method": "rotate", "params": [{"name": "matrix", "type": "integer[][]"}], "returns": "void", "outputParam": 0}
examples: ["[[1,2,3],[4,5,6],[7,8,9]]", "[[5,1,9,11],[2,4,8,10],[13,3,6,7],[15,14,12,16]]"]
---

You are given an `n x n` 2D `matrix` representing an image, rotate the image by **90** degrees (clockwise).

You have to rotate the image [**in-place**](https://en.wikipedia.org/wiki/In-place_algorithm), which means you have to modify the input 2D matrix directly. **DO NOT** allocate another 2D matrix and do the rotation.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/08/28/mat1.jpg)

```
Input: matrix = [[1,2,3],[4,5,6],[7,8,9]]
Output: [[7,4,1],[8,5,2],[9,6,3]]
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2020/08/28/mat2.jpg)

```
Input: matrix = [[5,1,9,11],[2,4,8,10],[13,3,6,7],[15,14,12,16]]
Output: [[15,13,2,5],[14,3,4,1],[12,6,8,9],[16,7,10,11]]
```

**Constraints:**

- `n == matrix.length == matrix[i].length`
- `1 <= n <= 20`
- `-1000 <= matrix[i][j] <= 1000`

# Starter

```python
class Solution:
    def rotate(self, matrix: list[list[int]]) -> None:
        """
        Do not return anything, modify matrix in-place instead.
        """
        
```

# Hints

1. Where does cell (r, c) end up after a 90° clockwise turn? Try it on a 3×3.
2. A clockwise rotation is a transpose followed by reversing every row. Both can be done in place.

# Key points

- (r, c) moves to (c, n-1-r) after a clockwise turn
- in place: transpose (swap across the diagonal), then reverse each row
- O(n²) time, O(1) extra space; only swap cells with c > r when transposing, or you swap them back

# Solution: copy · Build a rotated copy · O(n²) · O(n²)

## Idea
After a clockwise turn, row `r` becomes column `n-1-r`: cell `(r, c)` moves to `(c, n-1-r)`. Fill a new matrix, then copy it back.

## Complexity
- **Time: O(n²)**.
- **Space: O(n²)**, which the problem explicitly forbids ("rotate in place").

```python
class Solution:
    def rotate(self, matrix: list[list[int]]) -> None:
        n = len(matrix)
        out = [[0] * n for _ in range(n)]
        for r in range(n):
            for c in range(n):
                out[c][n - 1 - r] = matrix[r][c]
        matrix[:] = out
```

# Solution: transpose-reverse · Transpose, then reverse each row · O(n²) · O(1) · reference

## Idea
Two simple in-place moves compose into a rotation:

```
1 2 3    transpose    1 4 7    reverse rows    7 4 1
4 5 6   ─────────►    2 5 8   ─────────────►   8 5 2
7 8 9                 3 6 9                    9 6 3
```

When transposing, only swap cells above the diagonal (`c > r`). Looping over every cell would swap each pair twice and undo the work.

## Complexity
- **Time: O(n²)**.
- **Space: O(1) extra**.

Counter-clockwise? Transpose, then reverse each **column** (or reverse rows first, then transpose).

```python
class Solution:
    def rotate(self, matrix: list[list[int]]) -> None:
        n = len(matrix)
        for r in range(n):
            for c in range(r + 1, n):
                matrix[r][c], matrix[c][r] = matrix[c][r], matrix[r][c]
        for row in matrix:
            row.reverse()
```

# Tests

```python
def edge():
    return [
        [[[1]]],
        [[[1, 2], [3, 4]]],
        [[[1, 2, 3], [4, 5, 6], [7, 8, 9]]],
        [[[5, 1, 9, 11], [2, 4, 8, 10], [13, 3, 6, 7], [15, 14, 12, 16]]],
    ]

def random_case(rng):
    n = rng.randint(1, 6)
    return [[[rng.randint(-1000, 1000) for _ in range(n)] for _ in range(n)]]

def perf(rng):
    return []
```
