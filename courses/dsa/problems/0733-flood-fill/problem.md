---
lc: 733
title: "Flood Fill"
difficulty: "Easy"
patterns: ["island-traversal"]
lcTags: ["array", "depth-first-search", "breadth-first-search", "matrix"]
entry: {"method": "floodFill", "params": [{"name": "image", "type": "integer[][]"}, {"name": "sr", "type": "integer"}, {"name": "sc", "type": "integer"}, {"name": "color", "type": "integer"}], "returns": "integer[][]"}
examples: ["[[1,1,1],[1,1,0],[1,0,1]]\n1\n1\n2", "[[0,0,0],[0,0,0]]\n0\n0\n0"]
lcHints: ["Write a recursive function that paints the pixel if it's the correct color, then recurses on neighboring pixels."]
---

You are given an image represented by an `m x n` grid of integers `image`, where `image[i][j]` represents the pixel value of the image. You are also given three integers `sr`, `sc`, and `color`. Your task is to perform a **flood fill** on the image starting from the pixel `image[sr][sc]`.

To perform a **flood fill**:

1. Begin with the starting pixel and change its color to `color`.
1. Perform the same process for each pixel that is **directly adjacent** (pixels that share a side with the original pixel, either horizontally or vertically) and shares the **same color** as the starting pixel.
1. Keep **repeating** this process by checking neighboring pixels of the *updated* pixels and modifying their color if it matches the original color of the starting pixel.
1. The process **stops** when there are **no more** adjacent pixels of the original color to update.

Return the **modified** image after performing the flood fill.

**Example 1:**

**Input:** image = [[1,1,1],[1,1,0],[1,0,1]], sr = 1, sc = 1, color = 2

**Output:** [[2,2,2],[2,2,0],[2,0,1]]

**Explanation:**

![](https://assets.leetcode.com/uploads/2021/06/01/flood1-grid.jpg)

From the center of the image with position `(sr, sc) = (1, 1)` (i.e., the red pixel), all pixels connected by a path of the same color as the starting pixel (i.e., the blue pixels) are colored with the new color.

Note the bottom corner is **not** colored 2, because it is not horizontally or vertically connected to the starting pixel.

**Example 2:**

**Input:** image = [[0,0,0],[0,0,0]], sr = 0, sc = 0, color = 0

**Output:** [[0,0,0],[0,0,0]]

**Explanation:**

The starting pixel is already colored with 0, which is the same as the target color. Therefore, no changes are made to the image.

**Constraints:**

- `m == image.length`
- `n == image[i].length`
- `1 <= m, n <= 50`
- `0 <= image[i][j], color < 2¹⁶`
- `0 <= sr < m`
- `0 <= sc < n`

# Starter

```python
class Solution:
    def floodFill(self, image: list[list[int]], sr: int, sc: int, color: int) -> list[list[int]]:
        
```

# Hints

1. Start at (sr, sc) and spread to 4-directional neighbours with the same original color.
2. DFS/BFS from the start, recoloring as you go. If the new color equals the old color, return immediately (otherwise you'd loop forever).

# Key points

- DFS/BFS over same-colored neighbours
- early exit when color == original color
- recoloring doubles as the visited mark
- O(m·n) time

# Solution: dfs · DFS · O(m × n) · O(m × n) · reference

We denote the initial pixel's color as oc. If oc is not equal to the target color color, we start a depth-first search from `(sr, sc)` to change the color of all eligible pixels to the target color.

The time complexity is O(m × n), and the space complexity is O(m × n). Here, m and n are the number of rows and columns of the 2D array image, respectively.

```python
class Solution:
    def floodFill(
        self, image: List[List[int]], sr: int, sc: int, color: int
    ) -> List[List[int]]:
        def dfs(i: int, j: int):
            image[i][j] = color
            for a, b in pairwise(dirs):
                x, y = i + a, j + b
                if 0 <= x < len(image) and 0 <= y < len(image[0]) and image[x][y] == oc:
                    dfs(x, y)

        oc = image[sr][sc]
        if oc != color:
            dirs = (-1, 0, 1, 0, -1)
            dfs(sr, sc)
        return image
```

# Solution: bfs · BFS · O(m × n) · O(m × n)

We first check if the initial pixel's color is equal to the target color. If it is, we return the original image directly. Otherwise, we can use the breadth-first search method, starting from `(sr, sc)`, to change the color of all eligible pixels to the target color.

Specifically, we define a queue q and add the initial pixel `(sr, sc)` to the queue. Then, we continuously take pixels `(i, j)` from the queue, change their color to the target color, and add the pixels in the four directions (up, down, left, right) that have the same original color as the initial pixel to the queue. When the queue is empty, we have completed the flood fill.

The time complexity is O(m × n), and the space complexity is O(m × n). Here, m and n are the number of rows and columns of the 2D array image, respectively.

```python
class Solution:
    def floodFill(
        self, image: List[List[int]], sr: int, sc: int, color: int
    ) -> List[List[int]]:
        if image[sr][sc] == color:
            return image
        q = deque([(sr, sc)])
        oc = image[sr][sc]
        image[sr][sc] = color
        dirs = (-1, 0, 1, 0, -1)
        while q:
            i, j = q.popleft()
            for a, b in pairwise(dirs):
                x, y = i + a, j + b
                if 0 <= x < len(image) and 0 <= y < len(image[0]) and image[x][y] == oc:
                    q.append((x, y))
                    image[x][y] = color
        return image
```

# Tests

```python

```
