---
lc: 743
title: "Network Delay Time"
difficulty: "Medium"
patterns: ["dijkstra"]
lcTags: ["depth-first-search", "breadth-first-search", "graph", "heap-priority-queue", "shortest-path", "dijkstra"]
entry: {"method": "networkDelayTime", "params": [{"name": "times", "type": "integer[][]"}, {"name": "n", "type": "integer"}, {"name": "k", "type": "integer"}], "returns": "integer"}
examples: ["[[2,1,1],[2,3,1],[3,4,1]]\n4\n2", "[[1,2,1]]\n2\n1", "[[1,2,1]]\n2\n2"]
lcHints: ["We visit each node at some time, and if that time is better than the fastest time we've reached this node, we travel along outgoing edges in sorted order.  Alternatively, we could use Dijkstra's algorithm."]
---

You are given a network of `n` nodes, labeled from `1` to `n`. You are also given `times`, a list of travel times as directed edges `times[i] = (uᵢ, vᵢ, wᵢ)`, where `uᵢ` is the source node, `vᵢ` is the target node, and `wᵢ` is the time it takes for a signal to travel from source to target.

We will send a signal from a given node `k`. Return *the **minimum** time it takes for all the* `n` *nodes to receive the signal*. If it is impossible for all the `n` nodes to receive the signal, return `-1`.

**Example 1:**

![](https://assets.leetcode.com/uploads/2019/05/23/931_example_1.png)

```
Input: times = [[2,1,1],[2,3,1],[3,4,1]], n = 4, k = 2
Output: 2
```

**Example 2:**

```
Input: times = [[1,2,1]], n = 2, k = 1
Output: 1
```

**Example 3:**

```
Input: times = [[1,2,1]], n = 2, k = 2
Output: -1
```

**Constraints:**

- `1 <= k <= n <= 100`
- `1 <= times.length <= 6000`
- `times[i].length == 3`
- `1 <= uᵢ, vᵢ <= n`
- `uᵢ != vᵢ`
- `0 <= wᵢ <= 100`
- All the pairs `(uᵢ, vᵢ)` are **unique**. (i.e., no multiple edges.)

# Starter

```python
class Solution:
    def networkDelayTime(self, times: list[list[int]], n: int, k: int) -> int:
        
```

# Hints

1. The signal reaches each node along its shortest path from k. The answer is the largest of those shortest distances.
2. Dijkstra from k with a min-heap. If some node is unreachable return −1, else return the max distance.

# Key points

- single-source shortest paths with non-negative weights → Dijkstra
- answer = max over all shortest distances; unreachable → -1
- O(E log V) with a heap

# Solution: naive-dijkstra-algorithm · Naive Dijkstra Algorithm · O(n² + m) · O(n²) · reference

We define `g[u][v]` to represent the edge weight from node u to node v. If there is no edge between node u and node v, then `g[u][v] = +inf`.

We maintain an array dist, where `dist[i]` represents the shortest path length from node k to node i. Initially, we set all `dist[i]` to `+inf`, except for `dist[k - 1] = 0`. We define an array vis, where `vis[i]` indicates whether node i has been visited. Initially, we set all `vis[i]` to false.

Each time, we find the unvisited node t with the smallest distance, and then perform relaxation operations centered on node t. For each node j, if `dist[j] > dist[t] + g[t][j]`, we update `dist[j] = dist[t] + g[t][j]`.

Finally, we return the maximum value in dist as the answer. If the answer is `+inf`, it means there are unreachable nodes, and we return -1.

The time complexity is O(n² + m), and the space complexity is O(n²). Here, n and m are the number of nodes and edges, respectively.

```python
class Solution:
    def networkDelayTime(self, times: List[List[int]], n: int, k: int) -> int:
        g = [[inf] * n for _ in range(n)]
        for u, v, w in times:
            g[u - 1][v - 1] = w
        dist = [inf] * n
        dist[k - 1] = 0
        vis = [False] * n
        for _ in range(n):
            t = -1
            for j in range(n):
                if not vis[j] and (t == -1 or dist[t] > dist[j]):
                    t = j
            vis[t] = True
            for j in range(n):
                dist[j] = min(dist[j], dist[t] + g[t][j])
        ans = max(dist)
        return -1 if ans == inf else ans
```

# Solution: heap-optimized-dijkstra-algorithm · Heap-Optimized Dijkstra Algorithm · O(m × log m + n) · O(n + m)

We can use a priority queue (heap) to optimize the naive Dijkstra algorithm.

We define `g[u]` to represent all adjacent edges of node u, and `dist[u]` to represent the shortest path length from node k to node u. Initially, we set all `dist[u]` to `+inf`, except for `dist[k - 1] = 0`.

We define a priority queue pq, where each element is `(d, u)`, representing the distance d from node u to node k. Each time, we take out the node `(d, u)` with the smallest distance from pq. If `d >`\textit{dist}[u]`, we skip this node. Otherwise, we traverse all adjacent edges of node`u`. For each adjacent edge`(v, w)`, if`\textit{dist}[v] > \textit{dist}[u] + w`, we update`\textit{dist}[v] = \textit{dist}[u] + w`and add`(\textit{dist}[v], v)to\textit{pq}$.

Finally, we return the maximum value in dist as the answer. If the answer is `+inf`, it means there are unreachable nodes, and we return -1.

The time complexity is O(m × log m + n), and the space complexity is O(n + m). Here, n and m are the number of nodes and edges, respectively.

```python
class Solution:
    def networkDelayTime(self, times: List[List[int]], n: int, k: int) -> int:
        g = [[] for _ in range(n)]
        for u, v, w in times:
            g[u - 1].append((v - 1, w))
        dist = [inf] * n
        dist[k - 1] = 0
        pq = [(0, k - 1)]
        while pq:
            d, u = heappop(pq)
            if d > dist[u]:
                continue
            for v, w in g[u]:
                if (nd := d + w) < dist[v]:
                    dist[v] = nd
                    heappush(pq, (nd, v))
        ans = max(dist)
        return -1 if ans == inf else ans
```

# Tests

```python
def make(rng, n, m, wmax):
    pairs = [(u, v) for u in range(1, n + 1) for v in range(1, n + 1) if u != v]
    return [[u, v, rng.randint(0, wmax)] for u, v in rng.sample(pairs, min(m, len(pairs)))]

def edge():
    return [[[[2, 1, 1], [2, 3, 1], [3, 4, 1]], 4, 2], [[[1, 2, 1]], 2, 1], [[[1, 2, 1]], 2, 2], [[[1, 2, 0]], 2, 1]]

def random_case(rng):
    n = rng.randint(2, 6)
    return [make(rng, n, rng.randint(1, n * (n - 1)), 10), n, rng.randint(1, n)]

def perf(rng):
    return [[make(rng, 100, 6000, 100), 100, 1]]
```
