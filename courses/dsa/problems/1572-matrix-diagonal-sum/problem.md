---
lc: 1572
title: "Matrix Diagonal Sum"
difficulty: "Easy"
patterns: ["simulation"]
lcTags: ["array", "matrix"]
entry: {"method": "diagonalSum", "params": [{"name": "mat", "type": "integer[][]"}], "returns": "integer"}
examples: ["[[1,2,3],[4,5,6],[7,8,9]]", "[[1,1,1,1],[1,1,1,1],[1,1,1,1],[1,1,1,1]]", "[[5]]"]
lcHints: ["There will be overlap of elements in the primary and secondary diagonals if and only if the length of the matrix is odd, which is at the center."]
---

Given a square matrix `mat`, return the sum of the matrix diagonals.

Only include the sum of all the elements on the primary diagonal and all the elements on the secondary diagonal that are not part of the primary diagonal.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/08/14/sample_1911.png)

```
Input: mat = [[1,2,3],
              [4,5,6],
              [7,8,9]]
Output: 25
Explanation: Diagonals sum: 1 + 5 + 9 + 3 + 7 = 25
Notice that element mat[1][1] = 5 is counted only once.
```

**Example 2:**

```
Input: mat = [[1,1,1,1],
              [1,1,1,1],
              [1,1,1,1],
              [1,1,1,1]]
Output: 8
```

**Example 3:**

```
Input: mat = [[5]]
Output: 5
```

**Constraints:**

- `n == mat.length == mat[i].length`
- `1 <= n <= 100`
- `1 <= mat[i][j] <= 100`

# Starter

```python
class Solution:
    def diagonalSum(self, mat: list[list[int]]) -> int:
        
```

# Hints

1. You don't need to look at every cell. Which cells are on the two diagonals?
2. Row i has mat[i][i] and mat[i][n-1-i]. When n is odd they meet in the centre, so don't count it twice.

# Key points

- primary diagonal is (i, i), secondary is (i, n-1-i)
- one loop over i reads both diagonals: O(n) instead of O(n²)
- for odd n the centre cell is on both diagonals, so subtract it once

# Solution: scan-all · Check every cell · O(n²) · O(1)

## Idea
Visit every cell and keep it if it's on a diagonal: `r == c` or `r + c == n - 1`. The `or` naturally counts the centre once.

## Complexity
- **Time: O(n²)**, all n² cells.
- **Space: O(1)**.

```python
class Solution:
    def diagonalSum(self, mat: list[list[int]]) -> int:
        n = len(mat)
        return sum(mat[r][c] for r in range(n) for c in range(n) if r == c or r + c == n - 1)
```

# Solution: two-diagonals · Read both diagonals directly · O(n) · O(1) · reference

## Idea
Row `i` has exactly one cell on each diagonal: `(i, i)` and `(i, n-1-i)`. Add both for every row.

When n is odd the two diagonals cross at `(n//2, n//2)`, and we just added that cell twice, so subtract it once.

## Complexity
- **Time: O(n)**, only 2n cells are read.
- **Space: O(1)**.

```python
class Solution:
    def diagonalSum(self, mat: list[list[int]]) -> int:
        n = len(mat)
        total = sum(mat[i][i] + mat[i][n - 1 - i] for i in range(n))
        if n % 2:
            total -= mat[n // 2][n // 2]
        return total
```

# Tests

```python
def edge():
    return [
        [[[5]]],
        [[[1, 2], [3, 4]]],
        [[[1, 2, 3], [4, 5, 6], [7, 8, 9]]],
        [[[1, 1, 1, 1], [1, 1, 1, 1], [1, 1, 1, 1], [1, 1, 1, 1]]],
    ]

def random_case(rng):
    n = rng.randint(1, 6)
    return [[[rng.randint(1, 100) for _ in range(n)] for _ in range(n)]]

def perf(rng):
    return []
```
