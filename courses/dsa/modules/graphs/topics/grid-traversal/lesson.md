## Core idea

**A grid is a graph in disguise: every cell is a node and its 4 neighbours (up, down, left, right) are its edges.** Flood fill with DFS or BFS from a cell visits its whole connected region. Start BFS from many cells at once (multi-source BFS) to find distances or spreading times from the nearest source.

## Intuition

Spilling paint on a tiled floor: it spreads to every touching tile of the same colour and stops at borders. Counting islands is "how many separate spills do I need to cover all the land?"

Rotting oranges is a fire spreading from several places at once: after 1 minute, everything next to a fire is burning; after 2 minutes, everything next to *those*. That's BFS with all fires in the queue from the start, where each BFS level is one minute.

## Visualization

Number of islands: each unvisited land cell starts a new flood:

```viz
islands
```

Multi-source BFS: every level is one minute:

```viz
rotting
```

## Template code

```python
DIRS = ((1, 0), (-1, 0), (0, 1), (0, -1))
m, n = len(grid), len(grid[0])

# DFS flood fill (marks visited by changing the cell)
def dfs(r, c):
    if not (0 <= r < m and 0 <= c < n) or grid[r][c] != "1":
        return 0
    grid[r][c] = "0"                        # mark visited
    return 1 + sum(dfs(r + dr, c + dc) for dr, dc in DIRS)

islands = 0
for r in range(m):
    for c in range(n):
        if grid[r][c] == "1":
            islands += 1
            dfs(r, c)

# Multi-source BFS (distances to the nearest source)
from collections import deque
q = deque((r, c) for r in range(m) for c in range(n) if is_source(r, c))
dist = [[-1] * n for _ in range(m)]
for r, c in q:
    dist[r][c] = 0
while q:
    r, c = q.popleft()
    for dr, dc in DIRS:
        a, b = r + dr, c + dc
        if 0 <= a < m and 0 <= b < n and dist[a][b] == -1 and passable(a, b):
            dist[a][b] = dist[r][c] + 1
            q.append((a, b))

# "Reach the border": start from the border cells instead (Surrounded Regions, Pacific Atlantic)
```

## Complexity

**O(m · n) time**: every cell is visited a constant number of times. Space is O(m · n) in the worst case for the recursion stack or queue (a grid full of land). Recursive DFS on a 300×300 grid can exceed Python's recursion limit; BFS or an explicit stack avoids that.

## When to use it

- **"Number of islands / regions / connected areas"** → loop + flood fill
- **"Largest area", "perimeter"** → flood fill returning a size, or count edges
- **"Minimum time/distance from the nearest X"** → multi-source BFS from all X
- **"Which cells can reach the border / both oceans"** → search backwards from the border
- **Shortest path in an unweighted grid** → BFS (DFS doesn't give shortest paths)

## Common traps

- Checking bounds after indexing `grid[r][c]`
- Marking cells visited when *popped* instead of when *pushed* in BFS: cells get queued many times
- Flood fill where the new colour equals the old colour: infinite loop without an early return
- Single-source BFS repeated from every source: O((mn)²); put all sources in the queue at once
- Grids of characters (`"1"`) vs integers (`1`): compare with the right type
