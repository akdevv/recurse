---
lc: 1971
title: "Find if Path Exists in Graph"
difficulty: "Easy"
patterns: ["bfs", "union-find"]
lcTags: ["depth-first-search", "breadth-first-search", "union-find", "graph"]
entry: {"method": "validPath", "params": [{"name": "n", "type": "integer"}, {"name": "edges", "type": "integer[][]"}, {"name": "source", "type": "integer"}, {"name": "destination", "type": "integer"}], "returns": "boolean"}
examples: ["3\n[[0,1],[1,2],[2,0]]\n0\n2", "6\n[[0,1],[0,2],[3,5],[5,4],[4,3]]\n0\n5"]
---

There is a **bi-directional** graph with `n` vertices, where each vertex is labeled from `0` to `n - 1` (**inclusive**). The edges in the graph are represented as a 2D integer array `edges`, where each `edges[i] = [uᵢ, vᵢ]` denotes a bi-directional edge between vertex `uᵢ` and vertex `vᵢ`. Every vertex pair is connected by **at most one** edge, and no vertex has an edge to itself.

You want to determine if there is a **valid path** that exists from vertex `source` to vertex `destination`.

Given `edges` and the integers `n`, `source`, and `destination`, return `true` *if there is a **valid path** from* `source` *to* `destination`*, or* `false` *otherwise*.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/08/14/validpath-ex1.png)

```
Input: n = 3, edges = [[0,1],[1,2],[2,0]], source = 0, destination = 2
Output: true
Explanation: There are two paths from vertex 0 to vertex 2:
- 0 → 1 → 2
- 0 → 2
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2021/08/14/validpath-ex2.png)

```
Input: n = 6, edges = [[0,1],[0,2],[3,5],[5,4],[4,3]], source = 0, destination = 5
Output: false
Explanation: There is no path from vertex 0 to vertex 5.
```

**Constraints:**

- `1 <= n <= 2 * 10⁵`
- `0 <= edges.length <= 2 * 10⁵`
- `edges[i].length == 2`
- `0 <= uᵢ, vᵢ <= n - 1`
- `uᵢ != vᵢ`
- `0 <= source, destination <= n - 1`
- There are no duplicate edges.
- There are no self edges.

# Starter

```python
class Solution:
    def validPath(self, n: int, edges: list[list[int]], source: int, destination: int) -> bool:
        
```

# Hints

1. Build an adjacency list, then search from source. Can you reach destination?
2. BFS/DFS from source with a visited set, or union-find all edges and compare the roots of source and destination.

# Key points

- adjacency list for an undirected graph (add both directions)
- BFS/DFS with visited, or union-find
- O(n + e) time

# Solution: dfs · DFS · O(n + m) · O(n + m) · reference

We first convert edges into an adjacency list g, then use DFS to determine whether there is a path from source to destination.

During the process, we use an array vis to record the vertices that have already been visited to avoid revisiting them.

The time complexity is O(n + m), and the space complexity is O(n + m). Here, n and m are the number of nodes and edges, respectively.

```python
class Solution:
    def validPath(
        self, n: int, edges: List[List[int]], source: int, destination: int
    ) -> bool:
        def dfs(i: int) -> bool:
            if i == destination:
                return True
            vis.add(i)
            for j in g[i]:
                if j not in vis and dfs(j):
                    return True
            return False

        g = [[] for _ in range(n)]
        for u, v in edges:
            g[u].append(v)
            g[v].append(u)
        vis = set()
        return dfs(source)
```

# Solution: bfs · BFS · O(n + m) · O(n + m)

We can also use BFS to determine whether there is a path from source to destination.

Specifically, we define a queue q, initially adding source to the queue. Additionally, we use a set vis to record the vertices that have already been visited to avoid revisiting them.

Next, we continuously take vertices i from the queue. If `i = destination`, it means there is a path from source to destination, and we return true. Otherwise, we traverse all adjacent vertices j of i. If j has not been visited, we add j to the queue q and mark j as visited.

Finally, if the queue is empty, it means there is no path from source to destination, and we return false.

The time complexity is O(n + m), and the space complexity is O(n + m). Here, n and m are the number of nodes and edges, respectively.

```python
class Solution:
    def validPath(
        self, n: int, edges: List[List[int]], source: int, destination: int
    ) -> bool:
        g = [[] for _ in range(n)]
        for u, v in edges:
            g[u].append(v)
            g[v].append(u)
        q = deque([source])
        vis = {source}
        while q:
            i = q.popleft()
            if i == destination:
                return True
            for j in g[i]:
                if j not in vis:
                    vis.add(j)
                    q.append(j)
        return False
```

# Solution: union-find · Union-Find · O(n log n + m) · O(n)

Union-Find is a tree-like data structure that, as the name suggests, is used to handle some disjoint set **merge** and **query** problems. It supports two operations:

1. Find: Determine which subset an element belongs to. The time complexity of a single operation is O(\alpha(n)).
2. Union: Merge two subsets into one set. The time complexity of a single operation is O(\alpha(n)).

For this problem, we can use the Union-Find set to merge the edges in `edges`, and then determine whether `source` and `destination` are in the same set.

The time complexity is O(n log n + m) or O(n \alpha(n) + m), and the space complexity is O(n). Where n and m are the number of nodes and edges, respectively.

```python
class UnionFind:
    def __init__(self, n):
        self.p = list(range(n))
        self.size = [1] * n

    def find(self, x):
        if self.p[x] != x:
            self.p[x] = self.find(self.p[x])
        return self.p[x]

    def union(self, a, b):
        pa, pb = self.find(a), self.find(b)
        if pa == pb:
            return False
        if self.size[pa] > self.size[pb]:
            self.p[pb] = pa
            self.size[pa] += self.size[pb]
        else:
            self.p[pa] = pb
            self.size[pb] += self.size[pa]
        return True

class Solution:
    def validPath(
        self, n: int, edges: List[List[int]], source: int, destination: int
    ) -> bool:
        uf = UnionFind(n)
        for u, v in edges:
            uf.union(u, v)
        return uf.find(source) == uf.find(destination)
```

# Tests

```python
def graph(rng, n, m):
    edges = set()
    while len(edges) < m:
        a, b = rng.sample(range(n), 2)
        edges.add((min(a, b), max(a, b)))
    return [list(e) for e in edges]

def edge():
    return [[1, [], 0, 0], [3, [[0, 1], [1, 2], [2, 0]], 0, 2], [6, [[0, 1], [0, 2], [3, 5], [5, 4], [4, 3]], 0, 5], [2, [], 0, 1]]

def random_case(rng):
    n = rng.randint(1, 8)
    m = rng.randint(0, n * (n - 1) // 2) // 2
    return [n, graph(rng, n, m), rng.randrange(n), rng.randrange(n)]

def perf(rng):
    n = 200000
    return [[n, [[rng.randrange(i), i] for i in range(1, n)], 0, n - 1]]
```
