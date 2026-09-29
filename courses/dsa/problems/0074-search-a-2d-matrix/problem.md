---
lc: 74
title: "Search a 2D Matrix"
difficulty: "Medium"
patterns: ["binary-search"]
lcTags: ["array", "binary-search", "matrix"]
entry: {"method": "searchMatrix", "params": [{"name": "matrix", "type": "integer[][]"}, {"name": "target", "type": "integer"}], "returns": "boolean"}
examples: ["[[1,3,5,7],[10,11,16,20],[23,30,34,60]]\n3", "[[1,3,5,7],[10,11,16,20],[23,30,34,60]]\n13"]
---

You are given an `m x n` integer matrix `matrix` with the following two properties:

- Each row is sorted in non-decreasing order.
- The first integer of each row is greater than the last integer of the previous row.

Given an integer `target`, return `true` *if* `target` *is in* `matrix` *or* `false` *otherwise*.

You must write a solution in `O(log(m * n))` time complexity.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/10/05/mat.jpg)

```
Input: matrix = [[1,3,5,7],[10,11,16,20],[23,30,34,60]], target = 3
Output: true
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2020/10/05/mat2.jpg)

```
Input: matrix = [[1,3,5,7],[10,11,16,20],[23,30,34,60]], target = 13
Output: false
```

**Constraints:**

- `m == matrix.length`
- `n == matrix[i].length`
- `1 <= m, n <= 100`
- `-10⁴ <= matrix[i][j], target <= 10⁴`

# Starter

```python
class Solution:
    def searchMatrix(self, matrix: list[list[int]], target: int) -> bool:
        
```

# Hints

1. Reading the matrix row by row gives one sorted list of m·n numbers.
2. Binary search over indices 0..m·n − 1, mapping index i to matrix[i // n][i % n].

# Key points

- the rows chained together are one sorted array
- index i ↔ (i // n, i % n)
- O(log(m·n)) time, O(1) space

# Solution: binary-search · Binary Search · O(log(m × n)) · O(1) · reference

We can logically unfold the two-dimensional matrix and then perform binary search.

The time complexity is O(log(m × n)), where m and n are the number of rows and columns of the matrix, respectively. The space complexity is O(1).

```python
class Solution:
    def searchMatrix(self, matrix: List[List[int]], target: int) -> bool:
        m, n = len(matrix), len(matrix[0])
        left, right = 0, m * n - 1
        while left < right:
            mid = (left + right) >> 1
            x, y = divmod(mid, n)
            if matrix[x][y] >= target:
                right = mid
            else:
                left = mid + 1
        return matrix[left // n][left % n] == target
```

# Solution: search-from-the-bottom-left-or-top-right · Search from the Bottom Left or Top Right · O(m + n) · O(1)

Here, we start searching from the bottom left corner and move towards the top right direction. We compare the current element `matrix[i][j]` with target:

- If `matrix[i][j] = target`, we have found the target value and return `true`.
- If `matrix[i][j] > target`, all elements to the right of the current position in this row are greater than target, so we should move the pointer i upwards, i.e., `i = i - 1`.
- If `matrix[i][j] < target`, all elements above the current position in this column are less than target, so we should move the pointer j to the right, i.e., `j = j + 1`.

If we still can't find target after the search, return `false`.

The time complexity is O(m + n), where m and n are the number of rows and columns of the matrix, respectively. The space complexity is O(1).

```python
class Solution:
    def searchMatrix(self, matrix: List[List[int]], target: int) -> bool:
        m, n = len(matrix), len(matrix[0])
        i, j = m - 1, 0
        while i >= 0 and j < n:
            if matrix[i][j] == target:
                return True
            if matrix[i][j] > target:
                i -= 1
            else:
                j += 1
        return False
```

# Tests

```python
def edge():
    return [[[[1]], 1], [[[1]], 2], [[[1, 3]], 3], [[[1], [3]], 3], [[[1, 3, 5, 7], [10, 11, 16, 20], [23, 30, 34, 60]], 3], [[[1, 3, 5, 7], [10, 11, 16, 20], [23, 30, 34, 60]], 13]]

def random_case(rng):
    m, n = rng.randint(1, 4), rng.randint(1, 4)
    vals = sorted(rng.sample(range(-40, 40), m * n))
    grid = [vals[r * n:(r + 1) * n] for r in range(m)]
    return [grid, rng.choice(vals) if rng.random() < 0.5 else rng.randint(-41, 41)]
```
