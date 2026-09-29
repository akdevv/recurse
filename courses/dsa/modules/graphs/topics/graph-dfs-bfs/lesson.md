## Core idea

**DFS goes as deep as possible before backing up; BFS explores in rings of increasing distance. Both visit every reachable node once with a `visited` set, in O(V + E).** BFS also gives shortest paths when every edge costs the same. Graphs (unlike trees) have cycles, so the visited set is not optional.

## Intuition

Exploring a cave system. **DFS** is one explorer with a ball of string: follow one tunnel to the end, back up to the last fork, try the next tunnel. **BFS** is a search party sweeping outward: first every chamber one tunnel away, then two tunnels away, and so on. The first time the search party reaches a chamber, they've found the shortest route to it.

Without marking visited chambers you'd walk in circles forever.

## Visualization

BFS: numbers are distances from A in edges:

```viz
bfs
```

DFS: restart it from every unvisited node to count connected components:

```viz
dfs
```

## Template code

```python
from collections import deque

# BFS (shortest path in edges from src)
dist = {src: 0}
q = deque([src])
while q:
    u = q.popleft()
    for v in adj[u]:
        if v not in dist:              # mark when you PUSH
            dist[v] = dist[u] + 1
            q.append(v)

# DFS (iterative, avoids recursion limits)
seen = {src}
stack = [src]
while stack:
    u = stack.pop()
    for v in adj[u]:
        if v not in seen:
            seen.add(v)
            stack.append(v)

# Connected components
components = 0
for node in range(n):
    if node not in seen:
        components += 1
        explore(node)                  # BFS or DFS

# Bipartite check: 2-colour with BFS/DFS
color = {}
# neighbour with the same colour → not bipartite

# Clone a graph: map old node → new node doubles as the visited set
```

## Complexity

| | BFS | DFS |
|---|---|---|
| time | O(V + E) | O(V + E) |
| space | O(V) queue + visited | O(V) stack/recursion + visited |
| shortest path (unweighted) | **yes** | no |
| natural for | levels, nearest, fewest steps | components, cycles, backtracking, topological order |

## When to use it

- **"Is there a path", "can you reach"** → either (BFS or DFS)
- **"Fewest steps / moves / transformations"** → BFS (Word Ladder)
- **"How many groups / provinces"** → DFS/BFS from each unvisited node, or union-find
- **"Can it be split into two groups" / "2-colourable"** → bipartite colouring
- **"Copy the graph"** → DFS with a map old → new
- **Implicit graphs (words differing by one letter, lock combinations)** → generate neighbours on the fly and BFS

## Common traps

- No visited set → infinite loop on cycles
- Marking visited on pop instead of push in BFS → duplicates in the queue, slower and sometimes wrong distances
- Forgetting disconnected parts: loop over all nodes, not just node 0
- Recursive DFS on 10⁵ nodes in Python → RecursionError; use a stack
- Word Ladder: checking every pair of words (O(n² · L)) instead of changing one letter at a time
