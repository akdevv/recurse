---
lc: 994
title: "Rotting Oranges"
difficulty: "Medium"
patterns: ["bfs"]
lcTags: ["array", "breadth-first-search", "matrix"]
entry: {"method": "orangesRotting", "params": [{"name": "grid", "type": "integer[][]"}], "returns": "integer"}
examples: ["[[2,1,1],[1,1,0],[0,1,1]]", "[[2,1,1],[0,1,1],[1,0,1]]", "[[0,2]]"]
---

You are given an `m x n` `grid` where each cell can have one of three values:

- `0` representing an empty cell,
- `1` representing a fresh orange, or
- `2` representing a rotten orange.

Every minute, any fresh orange that is **4-directionally adjacent** to a rotten orange becomes rotten.

Return *the minimum number of minutes that must elapse until no cell has a fresh orange*. If *this is impossible, return* `-1`.

**Example 1:**

![](https://assets.leetcode.com/uploads/2019/02/16/oranges.png)

```
Input: grid = [[2,1,1],[1,1,0],[0,1,1]]
Output: 4
```

**Example 2:**

```
Input: grid = [[2,1,1],[0,1,1],[1,0,1]]
Output: -1
Explanation: The orange in the bottom left corner (row 2, column 0) is never rotten, because rotting only happens 4-directionally.
```

**Example 3:**

```
Input: grid = [[0,2]]
Output: 0
Explanation: Since there are already no fresh oranges at minute 0, the answer is just 0.
```

**Constraints:**

- `m == grid.length`
- `n == grid[i].length`
- `1 <= m, n <= 10`
- `grid[i][j]` is `0`, `1`, or `2`.

# Starter

```python
class Solution:
    def orangesRotting(self, grid: list[list[int]]) -> int:
        
```

# Hints

1. All rotten oranges spread at the same time. That's BFS starting from every rotten orange at once.
2. Put all rotten cells in a queue (multi-source BFS). Process minute by minute; rot fresh neighbours. At the end, if a fresh orange is left, return −1.

# Key points

- multi-source BFS: all initial rotten oranges start in the queue
- each BFS level = one minute
- count fresh oranges; if some remain, return -1
- O(m·n) time

# Solution: bfs · BFS · O(m × n) · O(m × n) · reference

First, we traverse the entire grid once, count the number of fresh oranges, denoted as cnt, and add the coordinates of all rotten oranges to the queue q.

Next, we perform a breadth-first search. In each round of the search, we let all the rotten oranges in the queue rot the fresh oranges in four directions, until the queue is empty or the number of fresh oranges is 0.

Finally, if the number of fresh oranges is 0, we return the current round number, otherwise, we return -1.

The time complexity is O(m × n), and the space complexity is O(m × n). Where m and n are the number of rows and columns of the grid, respectively.

```python
class Solution:
    def orangesRotting(self, grid: List[List[int]]) -> int:
        m, n = len(grid), len(grid[0])
        cnt = 0
        q = deque()
        for i, row in enumerate(grid):
            for j, x in enumerate(row):
                if x == 2:
                    q.append((i, j))
                elif x == 1:
                    cnt += 1
        ans = 0
        dirs = (-1, 0, 1, 0, -1)
        while q and cnt:
            ans += 1
            for _ in range(len(q)):
                i, j = q.popleft()
                for a, b in pairwise(dirs):
                    x, y = i + a, j + b
                    if 0 <= x < m and 0 <= y < n and grid[x][y] == 1:
                        grid[x][y] = 2
                        q.append((x, y))
                        cnt -= 1
                        if cnt == 0:
                            return ans
        return -1 if cnt else 0
```

# Tests

```python
def edge():
    return [[[[2, 1, 1], [1, 1, 0], [0, 1, 1]]], [[[2, 1, 1], [0, 1, 1], [1, 0, 1]]], [[[0, 2]]], [[[0]]], [[[1]]], [[[2]]]]

def random_case(rng):
    r, c = rng.randint(1, 5), rng.randint(1, 5)
    return [[[rng.choice([0, 1, 1, 2]) for _ in range(c)] for _ in range(r)]]

def perf(rng):
    return [[[[1] * 10 for _ in range(9)] + [[1] * 9 + [2]]]]
```
