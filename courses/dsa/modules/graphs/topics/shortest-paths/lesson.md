## Core idea

**With weighted edges, fewest edges ≠ cheapest path, so plain BFS isn't enough. Dijkstra always settles the unsettled node with the smallest known distance (using a min-heap); that's correct because weights are non-negative.** When there's an extra limit, like "at most k stops", Bellman-Ford with k + 1 rounds handles it.

## Intuition

Water spreading from a source through pipes of different lengths: it reaches nearby junctions first, and once a junction is wet, no later route can reach it *earlier*. Dijkstra simulates that: the closest unreached node is always the next to be reached for good.

This is why negative weights break it: a later detour through a negative edge could make an already-settled node cheaper.

## Visualization

Dijkstra: settle the closest node, relax its edges:

```viz
dijkstra
```

At most k stops: Bellman-Ford rounds, each adding at most one flight:

```viz
bellman-k
```

## Template code

```python
import heapq

def dijkstra(adj, src, n):
    dist = [float("inf")] * n
    dist[src] = 0
    h = [(0, src)]
    while h:
        d, u = heapq.heappop(h)
        if d > dist[u]:
            continue                        # stale heap entry
        for v, w in adj[u]:
            if d + w < dist[v]:
                dist[v] = d + w
                heapq.heappush(h, (dist[v], v))
    return dist

# Network delay: max(dist) over all nodes, or -1 if any is unreachable

# Minimum effort path: "distance" = max step so far instead of a sum
nd = max(d, abs(h[a][b] - h[r][c]))

# Bellman-Ford limited to k stops (k + 1 edges)
dist = [float("inf")] * n
dist[src] = 0
for _ in range(k + 1):
    prev = dist[:]                          # use last round's values
    for u, v, w in flights:
        if prev[u] + w < dist[v]:
            dist[v] = prev[u] + w
```

## Complexity

| Algorithm | Time | Handles |
|---|---|---|
| BFS | O(V + E) | unweighted (or all weights equal) |
| Dijkstra with a heap | **O((V + E) log V)** | non-negative weights |
| Bellman-Ford | O(V · E), or O(k · E) with a k limit | negative weights, edge-count limits |
| 0-1 BFS (deque) | O(V + E) | weights only 0 or 1 |

## When to use it

- **Weighted graph, cheapest path from one source, weights ≥ 0** → Dijkstra
- **"Time for a signal to reach everyone"** → Dijkstra, answer = the largest distance
- **Path cost is the worst single step, not the sum** → Dijkstra with max
- **"At most k stops / edges"** → Bellman-Ford for k + 1 rounds (or BFS over (node, stops))
- **All edges cost the same** → plain BFS is simpler and faster

## Common traps

- Using Dijkstra with negative weights
- Not skipping stale heap entries (`d > dist[u]`): still correct but slower
- Bellman-Ford with k stops: updating in place lets one round use several edges; relax from a copy
- Returning `dist[target]` when it's still infinity instead of −1
- Using a visited set that marks nodes when pushed (that's BFS); Dijkstra finalises nodes when popped
