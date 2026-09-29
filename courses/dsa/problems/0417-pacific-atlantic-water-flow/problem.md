---
lc: 417
title: "Pacific Atlantic Water Flow"
difficulty: "Medium"
patterns: ["island-traversal", "bfs"]
lcTags: ["array", "depth-first-search", "breadth-first-search", "matrix"]
compare: "unordered"
entry: {"method": "pacificAtlantic", "params": [{"name": "heights", "type": "integer[][]"}], "returns": "list<list<integer>>"}
examples: ["[[1,2,2,3,5],[3,2,3,4,4],[2,4,5,3,1],[6,7,1,4,5],[5,1,1,2,4]]", "[[1]]"]
---

There is an `m x n` rectangular island that borders both the **Pacific Ocean** and **Atlantic Ocean**. The **Pacific Ocean** touches the island's left and top edges, and the **Atlantic Ocean** touches the island's right and bottom edges.

The island is partitioned into a grid of square cells. You are given an `m x n` integer matrix `heights` where `heights[r][c]` represents the **height above sea level** of the cell at coordinate `(r, c)`.

The island receives a lot of rain, and the rain water can flow to neighboring cells directly north, south, east, and west if the neighboring cell's height is **less than or equal to** the current cell's height. Water can flow from any cell adjacent to an ocean into the ocean.

Return *a **2D list** of grid coordinates* `result` *where* `result[i] = [rᵢ, cᵢ]` *denotes that rain water can flow from cell* `(rᵢ, cᵢ)` *to **both** the Pacific and Atlantic oceans*.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/06/08/waterflow-grid.jpg)

```
Input: heights = [[1,2,2,3,5],[3,2,3,4,4],[2,4,5,3,1],[6,7,1,4,5],[5,1,1,2,4]]
Output: [[0,4],[1,3],[1,4],[2,2],[3,0],[3,1],[4,0]]
Explanation: The following cells can flow to the Pacific and Atlantic oceans, as shown below:
[0,4]: [0,4] -> Pacific Ocean
       [0,4] -> Atlantic Ocean
[1,3]: [1,3] -> [0,3] -> Pacific Ocean
       [1,3] -> [1,4] -> Atlantic Ocean
[1,4]: [1,4] -> [1,3] -> [0,3] -> Pacific Ocean
       [1,4] -> Atlantic Ocean
[2,2]: [2,2] -> [1,2] -> [0,2] -> Pacific Ocean
       [2,2] -> [2,3] -> [2,4] -> Atlantic Ocean
[3,0]: [3,0] -> Pacific Ocean
       [3,0] -> [4,0] -> Atlantic Ocean
[3,1]: [3,1] -> [3,0] -> Pacific Ocean
       [3,1] -> [4,1] -> Atlantic Ocean
[4,0]: [4,0] -> Pacific Ocean
       [4,0] -> Atlantic Ocean
Note that there are other possible paths for these cells to flow to the Pacific and Atlantic oceans.
```

**Example 2:**

```
Input: heights = [[1]]
Output: [[0,0]]
Explanation: The water can flow from the only cell to the Pacific and Atlantic oceans.
```

**Constraints:**

- `m == heights.length`
- `n == heights[r].length`
- `1 <= m, n <= 200`
- `0 <= heights[r][c] <= 10⁵`

# Starter

```python
class Solution:
    def pacificAtlantic(self, heights: list[list[int]]) -> list[list[int]]:
        
```

# Hints

1. Instead of simulating water from every cell, go backwards: from each ocean, climb uphill.
2. BFS/DFS from all Pacific border cells moving to neighbours with height ≥ current; same for the Atlantic. Answer = cells reached by both.

# Key points

- reverse the flow: search from the ocean edges uphill
- two visited sets (Pacific, Atlantic); intersect them
- O(m·n) time

# Solution: bfs · BFS · O(m × n) · O(m × n) · reference

We can start from the boundaries of the Pacific and Atlantic oceans and perform breadth-first search (BFS) respectively to find all cells that can flow to the Pacific and Atlantic oceans. Finally, we take the intersection of the two results, which represents cells that can flow to both the Pacific and Atlantic oceans.

Specifically, we define a queue q_1 to store all cells adjacent to the Pacific ocean, and define a boolean matrix vis_1 to record which cells can flow to the Pacific ocean. Similarly, we define queue q_2 and boolean matrix vis_2 to handle the Atlantic ocean. Initially, we add all cells adjacent to the Pacific ocean to queue q_1 and mark them as visited in vis_1. Similarly, we add all cells adjacent to the Atlantic ocean to queue q_2 and mark them as visited in vis_2.

Then, we perform BFS on q_1 and q_2 respectively. In each BFS, we dequeue a cell `(x, y)` from the queue and check its four adjacent cells `(nx, ny)`. If an adjacent cell is within the matrix bounds, has not been visited, and its height is not less than the current cell's height (i.e., water can flow to that cell), we add it to the queue and mark it as visited.

Finally, we traverse the entire matrix to find cells that are marked as visited in both vis_1 and vis_2. These cells are our answer.

The time complexity is O(m × n) and the space complexity is O(m × n), where m and n are the number of rows and columns in the matrix, respectively.

```python
class Solution:
    def pacificAtlantic(self, heights: List[List[int]]) -> List[List[int]]:
        def bfs(q: Deque[Tuple[int, int]], vis: List[List[bool]]) -> None:
            while q:
                x, y = q.popleft()
                for dx, dy in pairwise(dirs):
                    nx, ny = x + dx, y + dy
                    if (
                        0 <= nx < m
                        and 0 <= ny < n
                        and not vis[nx][ny]
                        and heights[nx][ny] >= heights[x][y]
                    ):
                        vis[nx][ny] = True
                        q.append((nx, ny))

        m, n = len(heights), len(heights[0])
        vis1 = [[False] * n for _ in range(m)]
        vis2 = [[False] * n for _ in range(m)]
        q1: Deque[Tuple[int, int]] = deque()
        q2: Deque[Tuple[int, int]] = deque()
        dirs = (-1, 0, 1, 0, -1)

        for i in range(m):
            q1.append((i, 0))
            vis1[i][0] = True
            q2.append((i, n - 1))
            vis2[i][n - 1] = True

        for j in range(n):
            q1.append((0, j))
            vis1[0][j] = True
            q2.append((m - 1, j))
            vis2[m - 1][j] = True

        bfs(q1, vis1)
        bfs(q2, vis2)

        return [(i, j) for i in range(m) for j in range(n) if vis1[i][j] and vis2[i][j]]
```

# Tests

```python

```
