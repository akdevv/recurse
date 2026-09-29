---
lc: 785
title: "Is Graph Bipartite?"
difficulty: "Medium"
patterns: ["bfs", "union-find"]
lcTags: ["depth-first-search", "breadth-first-search", "union-find", "graph", "graph-coloring", "bipartite-graph"]
entry: {"method": "isBipartite", "params": [{"name": "graph", "type": "integer[][]"}], "returns": "boolean"}
examples: ["[[1,2,3],[0,2],[0,1,3],[0,2]]", "[[1,3],[0,2],[1,3],[0,2]]"]
---

There is an **undirected** graph with `n` nodes, where each node is numbered between `0` and `n - 1`. You are given a 2D array `graph`, where `graph[u]` is an array of nodes that node `u` is adjacent to. More formally, for each `v` in `graph[u]`, there is an undirected edge between node `u` and node `v`. The graph has the following properties:

- There are no self-edges (`graph[u]` does not contain `u`).
- There are no parallel edges (`graph[u]` does not contain duplicate values).
- If `v` is in `graph[u]`, then `u` is in `graph[v]` (the graph is undirected).
- The graph may not be connected, meaning there may be two nodes `u` and `v` such that there is no path between them.

A graph is **bipartite** if the nodes can be partitioned into two independent sets `A` and `B` such that **every** edge in the graph connects a node in set `A` and a node in set `B`.

Return `true` *if and only if it is **bipartite***.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/10/21/bi2.jpg)

```
Input: graph = [[1,2,3],[0,2],[0,1,3],[0,2]]
Output: false
Explanation: There is no way to partition the nodes into two independent sets such that every edge connects a node in one and a node in the other.
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2020/10/21/bi1.jpg)

```
Input: graph = [[1,3],[0,2],[1,3],[0,2]]
Output: true
Explanation: We can partition the nodes into two sets: {0, 2} and {1, 3}.
```

**Constraints:**

- `graph.length == n`
- `1 <= n <= 100`
- `0 <= graph[u].length < n`
- `0 <= graph[u][i] <= n - 1`
- `graph[u]` does not contain `u`.
- All the values of `graph[u]` are **unique**.
- If `graph[u]` contains `v`, then `graph[v]` contains `u`.

# Starter

```python
class Solution:
    def isBipartite(self, graph: list[list[int]]) -> bool:
        
```

# Hints

1. Try to 2-color the graph: neighbours must get different colors. When does that fail?
2. For every uncolored node (the graph may be disconnected), BFS and color neighbours with the opposite color. A neighbour with the same color → not bipartite.

# Key points

- bipartite ⇔ 2-colorable ⇔ no odd cycle
- BFS/DFS coloring from every uncolored node
- O(V + E) time

# Solution: coloring-method-to-determine-bipartite-g · Coloring Method to Determine Bipartite Graph · O(n) · O(n) · reference

Traverse all nodes for coloring. For example, initially color them white, and use DFS to color the adjacent nodes with another color. If the target color to be colored is different from the color that the node has already been colored, it means that it cannot form a bipartite graph.

The time complexity is O(n), and the space complexity is O(n). Where n is the number of nodes.

```python
class Solution:
    def isBipartite(self, graph: List[List[int]]) -> bool:
        def dfs(a: int, c: int) -> bool:
            color[a] = c
            for b in graph[a]:
                if color[b] == c or (color[b] == 0 and not dfs(b, -c)):
                    return False
            return True

        n = len(graph)
        color = [0] * n
        for i in range(n):
            if color[i] == 0 and not dfs(i, 1):
                return False
        return True
```

# Solution: union-find · Union-Find · O(n × log n) · O(n)

For this problem, if it is a bipartite graph, then all adjacent nodes of each vertex in the graph should belong to the same set and not be in the same set as the vertex. Therefore, we can use the union-find method. Traverse each vertex in the graph, and if it is found that the current vertex and its corresponding adjacent nodes are in the same set, it means that it is not a bipartite graph. Otherwise, merge the adjacent nodes of the current node.

The time complexity is O(n × log n), and the space complexity is O(n). Where n is the number of nodes.

```python
class Solution:
    def isBipartite(self, graph: List[List[int]]) -> bool:
        def find(x: int) -> int:
            if p[x] != x:
                p[x] = find(p[x])
            return p[x]

        p = list(range(len(graph)))
        for a, bs in enumerate(graph):
            for b in bs:
                pa, pb = find(a), find(b)
                if pa == pb:
                    return False
                p[pb] = find(bs[0])
        return True
```

# Tests

```python
def graph(rng, n, m):
    edges = set()
    while len(edges) < m:
        a, b = rng.sample(range(n), 2)
        edges.add((min(a, b), max(a, b)))
    adj = [[] for _ in range(n)]
    for a, b in edges:
        adj[a].append(b)
        adj[b].append(a)
    return [adj]

def edge():
    return [[[[]]], [[[1, 2, 3], [0, 2], [0, 1, 3], [0, 2]]], [[[1, 3], [0, 2], [1, 3], [0, 2]]], [[[], [2], [1]]]]

def random_case(rng):
    n = rng.randint(1, 7)
    return graph(rng, n, rng.randint(0, n * (n - 1) // 2 // 2 + 1) if n > 1 else 0)

def perf(rng):
    return [[[[(i + 1) % 100, (i - 1) % 100] for i in range(100)]]]
```
