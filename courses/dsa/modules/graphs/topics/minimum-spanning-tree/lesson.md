## Core idea

**A minimum spanning tree connects all nodes of a weighted undirected graph using V − 1 edges with the smallest possible total weight, and no cycles.** Kruskal picks edges globally from cheapest to most expensive, skipping any that would form a cycle (union-find). Prim grows one tree, always adding the cheapest edge that leaves it (min-heap).

## Intuition

Laying cables to connect several towns as cheaply as possible. You don't need every town wired to every other town, you just need everyone reachable. Any loop in your network means one cable is wasted, so the result is a tree.

Both algorithms are **greedy**, and greed is safe here: the cheapest edge crossing between two parts of the graph is always part of some MST. Kruskal is "buy the cheapest cable anywhere that still connects something new". Prim is "start in one town and keep adding the cheapest cable that reaches a new town".

## Visualization

Kruskal: sorted edges, skip cycles:

```viz
kruskal
```

Prim: grow the tree from one node:

```viz
prim
```

## Template code

```python
# Kruskal: sort edges, union-find to skip cycles
def kruskal(n, edges):                      # edges: (w, u, v)
    dsu = DSU(n)
    total = used = 0
    for w, u, v in sorted(edges):
        if dsu.union(u, v):
            total += w
            used += 1
            if used == n - 1:
                break
    return total

# Prim with a heap
import heapq
seen = {0}
h = [(w, v) for v, w in adj[0]]
heapq.heapify(h)
total = 0
while h and len(seen) < n:
    w, v = heapq.heappop(h)
    if v in seen:
        continue
    seen.add(v)
    total += w
    for x, wx in adj[v]:
        if x not in seen:
            heapq.heappush(h, (wx, x))

# Dense graph (every pair is an edge, e.g. points): O(V²) Prim with an array
dist = [inf] * n; dist[0] = 0; in_tree = [False] * n
for _ in range(n):
    u = min((i for i in range(n) if not in_tree[i]), key=dist.__getitem__)
    in_tree[u] = True; total += dist[u]
    for v in range(n):
        if not in_tree[v]:
            dist[v] = min(dist[v], cost(u, v))
```

## Complexity

| Algorithm | Time | Best for |
|---|---|---|
| Kruskal | O(E log E) (sorting) | sparse graphs, edge lists |
| Prim with a heap | O(E log V) | adjacency lists |
| Prim with an array | **O(V²)** | dense / complete graphs (all pairs of points) |

For 1000 points there are ~500,000 pairs: the O(V²) Prim avoids building and sorting them.

## When to use it

- **"Connect all points/cities with minimum total cost"** → MST
- **Edges given as a list** → Kruskal
- **Every pair is implicitly connected (points on a plane)** → O(V²) Prim
- **"Cheapest path between two specific nodes"** → that's shortest paths (Dijkstra), not MST
- **Graph not connected** → an MST doesn't exist; you get a minimum spanning *forest*

## Common traps

- Confusing MST with shortest paths: an MST minimises the total, not any single route
- Kruskal without union-find: checking cycles by DFS each time is O(V) per edge
- Prim: adding a node twice when it was pushed with several costs (skip if already in the tree)
- Stopping Kruskal before checking all needed edges, or not stopping at V − 1 edges
- Building all O(V²) edges for dense point sets when the array Prim is simpler and faster
