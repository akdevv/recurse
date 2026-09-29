---
lc: 684
title: "Redundant Connection"
difficulty: "Medium"
patterns: ["union-find"]
lcTags: ["depth-first-search", "breadth-first-search", "union-find", "graph"]
entry: {"method": "findRedundantConnection", "params": [{"name": "edges", "type": "integer[][]"}], "returns": "integer[]"}
examples: ["[[1,2],[1,3],[2,3]]", "[[1,2],[2,3],[3,4],[1,4],[1,5]]"]
---

In this problem, a tree is an **undirected graph** that is connected and has no cycles.

You are given a graph that started as a tree with `n` nodes labeled from `1` to `n`, with one additional edge added. The added edge has two **different** vertices chosen from `1` to `n`, and was not an edge that already existed. The graph is represented as an array `edges` of length `n` where `edges[i] = [aᵢ, bᵢ]` indicates that there is an edge between nodes `aᵢ` and `bᵢ` in the graph.

Return *an edge that can be removed so that the resulting graph is a tree of* `n` *nodes*. If there are multiple answers, return the answer that occurs last in the input.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/05/02/reduntant1-1-graph.jpg)

```
Input: edges = [[1,2],[1,3],[2,3]]
Output: [2,3]
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2021/05/02/reduntant1-2-graph.jpg)

```
Input: edges = [[1,2],[2,3],[3,4],[1,4],[1,5]]
Output: [1,4]
```

**Constraints:**

- `n == edges.length`
- `3 <= n <= 1000`
- `edges[i].length == 2`
- `1 <= aᵢ < bᵢ <= edges.length`
- `aᵢ != bᵢ`
- There are no repeated edges.
- The given graph is connected.

# Starter

```python
class Solution:
    def findRedundantConnection(self, edges: list[list[int]]) -> list[int]:
        
```

# Hints

1. Add edges one by one. The redundant edge is the first one whose two endpoints are already connected.
2. Union-find: for each edge, if find(a) == find(b), return it; otherwise union them.

# Key points

- a tree plus one edge has exactly one cycle
- union-find detects the first edge joining already-connected nodes
- that is also the last such edge in the input, as required
- O(n α(n)) time

# Solution: union-find · Union-Find · O(n log n) · O(n) · reference

According to the problem description, we need to find an edge that can be removed so that the remaining part is a tree with n nodes. We can traverse each edge and determine whether the two nodes of this edge are in the same connected component. If they are in the same connected component, it means this edge is redundant and can be removed, so we directly return this edge. Otherwise, we merge the two nodes connected by this edge into the same connected component.

The time complexity is O(n log n), and the space complexity is O(n). Here, n is the number of edges.

```python
class Solution:
    def findRedundantConnection(self, edges: List[List[int]]) -> List[int]:
        def find(x: int) -> int:
            if p[x] != x:
                p[x] = find(p[x])
            return p[x]

        p = list(range(len(edges)))
        for a, b in edges:
            pa, pb = find(a - 1), find(b - 1)
            if pa == pb:
                return [a, b]
            p[pa] = pb
```

# Solution: union-find-template-approach · Union-Find (Template Approach) · O(n \alpha(n)) · O(n)

Here is a template approach using Union-Find for your reference.

The time complexity is O(n \alpha(n)), and the space complexity is O(n). Here, n is the number of edges, and `\alpha(n)` is the inverse Ackermann function, which can be considered a very small constant.

```python
class UnionFind:
    __slots__ = "p", "size"

    def __init__(self, n: int):
        self.p: List[int] = list(range(n))
        self.size: List[int] = [1] * n

    def find(self, x: int) -> int:
        if self.p[x] != x:
            self.p[x] = self.find(self.p[x])
        return self.p[x]

    def union(self, a: int, b: int) -> bool:
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
    def findRedundantConnection(self, edges: List[List[int]]) -> List[int]:
        uf = UnionFind(len(edges))
        for a, b in edges:
            if not uf.union(a - 1, b - 1):
                return [a, b]
```

# Tests

```python
def make(rng, n):
    edges = [[rng.randint(1, i), i + 1] for i in range(1, n)]
    while True:
        a, b = sorted(rng.sample(range(1, n + 1), 2))
        if [a, b] not in edges:
            break
    edges.append([a, b])
    rng.shuffle(edges)
    return [[sorted(e) for e in edges]]

def edge():
    return [[[[1, 2], [1, 3], [2, 3]]], [[[1, 2], [2, 3], [3, 4], [1, 4], [1, 5]]], [[[1, 2], [2, 3], [1, 3]]]]

def random_case(rng):
    return make(rng, rng.randint(3, 9))

def perf(rng):
    return [make(rng, 1000)]
```
