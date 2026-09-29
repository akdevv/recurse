---
lc: 54
title: "Spiral Matrix"
difficulty: "Medium"
patterns: ["simulation"]
lcTags: ["array", "matrix", "simulation"]
entry: {"method": "spiralOrder", "params": [{"name": "matrix", "type": "integer[][]"}], "returns": "list<integer>"}
examples: ["[[1,2,3],[4,5,6],[7,8,9]]", "[[1,2,3,4],[5,6,7,8],[9,10,11,12]]"]
lcHints: ["Well for some problems, the best way really is to come up with some algorithms for simulation. Basically, you need to simulate what the problem asks us to do.", "We go boundary by boundary and move inwards. That is the essential operation. First row, last column, last row, first column, and then we move inwards by 1 and repeat. That's all. That is all the simulation that we need.", "Think about when you want to switch the progress on one of the indexes. If you progress on i out of [i, j], you'll shift in the same column. Similarly, by changing values for j, you'd be shifting in the same row.\r\nAlso, keep track of the end of a boundary so that you can move inwards and then keep repeating. It's always best to simulate edge cases like a single column or a single row to see if anything breaks or not."]
---

Given an `m x n` `matrix`, return *all elements of the* `matrix` *in spiral order*.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/11/13/spiral1.jpg)

```
Input: matrix = [[1,2,3],[4,5,6],[7,8,9]]
Output: [1,2,3,6,9,8,7,4,5]
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2020/11/13/spiral.jpg)

```
Input: matrix = [[1,2,3,4],[5,6,7,8],[9,10,11,12]]
Output: [1,2,3,4,8,12,11,10,9,5,6,7]
```

**Constraints:**

- `m == matrix.length`
- `n == matrix[i].length`
- `1 <= m, n <= 10`
- `-100 <= matrix[i][j] <= 100`

# Starter

```python
class Solution:
    def spiralOrder(self, matrix: list[list[int]]) -> list[int]:
        
```

# Hints

1. Keep four boundaries: top, bottom, left, right. Walk one edge, then shrink that boundary.
2. Go right along top, down along right, left along bottom, up along left. Check the boundaries before the last two legs, or single rows/columns get read twice.

# Key points

- four shrinking boundaries: top, bottom, left, right
- each lap reads the top row, right column, bottom row, left column, then moves every boundary inward
- guard the bottom and left legs (top <= bottom, left <= right) so a leftover single row or column isn't repeated

# Solution: boundaries · Shrinking boundaries · O(m·n) · O(1) extra · reference

## Idea
Peel the matrix like an onion. The unread part is always the rectangle `top..bottom × left..right`. Each lap reads its four edges and pulls each boundary in by one.

## The trap
After reading the top row and right column, the rectangle may have collapsed to nothing, or to a single row or column. The `if top <= bottom` and `if left <= right` checks stop the bottom and left legs from re-reading cells.

## Complexity
- **Time: O(m·n)**, every cell once.
- **Space: O(1) extra** besides the output.

```python
class Solution:
    def spiralOrder(self, matrix: list[list[int]]) -> list[int]:
        top, bottom = 0, len(matrix) - 1
        left, right = 0, len(matrix[0]) - 1
        out = []
        while top <= bottom and left <= right:
            for c in range(left, right + 1):
                out.append(matrix[top][c])
            top += 1
            for r in range(top, bottom + 1):
                out.append(matrix[r][right])
            right -= 1
            if top <= bottom:
                for c in range(right, left - 1, -1):
                    out.append(matrix[bottom][c])
                bottom -= 1
            if left <= right:
                for r in range(bottom, top - 1, -1):
                    out.append(matrix[r][left])
                left += 1
        return out
```

# Solution: direction-visited · Walk and turn when blocked · O(m·n) · O(m·n)

## Idea
Simulate a walker: keep going in the current direction and turn right (the next entry of the direction array) when the next cell is off the grid or already visited.

The **direction array** `[(0,1), (1,0), (0,-1), (-1,0)]` is a pattern you'll reuse in every grid problem.

## Complexity
- **Time: O(m·n)**.
- **Space: O(m·n)** for `seen`.

```python
class Solution:
    def spiralOrder(self, matrix: list[list[int]]) -> list[int]:
        m, n = len(matrix), len(matrix[0])
        seen = [[False] * n for _ in range(m)]
        dirs = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        r = c = d = 0
        out = []
        for _ in range(m * n):
            out.append(matrix[r][c])
            seen[r][c] = True
            nr, nc = r + dirs[d][0], c + dirs[d][1]
            if not (0 <= nr < m and 0 <= nc < n) or seen[nr][nc]:
                d = (d + 1) % 4
                nr, nc = r + dirs[d][0], c + dirs[d][1]
            r, c = nr, nc
        return out
```

# Tests

```python
def edge():
    return [
        [[[1]]],
        [[[1, 2, 3]]],
        [[[1], [2], [3]]],
        [[[1, 2], [3, 4]]],
        [[[1, 2, 3], [4, 5, 6], [7, 8, 9]]],
        [[[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12]]],
        [[[1, 2], [3, 4], [5, 6]]],
    ]

def random_case(rng):
    m, n = rng.randint(1, 6), rng.randint(1, 6)
    return [[[rng.randint(-100, 100) for _ in range(n)] for _ in range(m)]]

def perf(rng):
    return []
```
