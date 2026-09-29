---
lc: 1791
title: "Find Center of Star Graph"
difficulty: "Easy"
patterns: ["simulation"]
lcTags: ["graph"]
entry: {"method": "findCenter", "params": [{"name": "edges", "type": "integer[][]"}], "returns": "integer"}
examples: ["[[1,2],[2,3],[4,2]]", "[[1,2],[5,1],[1,3],[1,4]]"]
lcHints: ["The center is the only node that has more than one edge.", "The center is also connected to all other nodes.", "Any two edges must have a common node, which is the center."]
---

There is an undirected **star** graph consisting of `n` nodes labeled from `1` to `n`. A star graph is a graph where there is one **center** node and **exactly** `n - 1` edges that connect the center node with every other node.

You are given a 2D integer array `edges` where each `edges[i] = [uᵢ, vᵢ]` indicates that there is an edge between the nodes `uᵢ` and `vᵢ`. Return the center of the given star graph.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/02/24/star_graph.png)

```
Input: edges = [[1,2],[2,3],[4,2]]
Output: 2
Explanation: As shown in the figure above, node 2 is connected to every other node, so 2 is the center.
```

**Example 2:**

```
Input: edges = [[1,2],[5,1],[1,3],[1,4]]
Output: 1
```

**Constraints:**

- `3 <= n <= 10⁵`
- `edges.length == n - 1`
- `edges[i].length == 2`
- `1 <= u_(i,) vᵢ <= n`
- `uᵢ != vᵢ`
- The given `edges` represent a valid star graph.

# Starter

```python
class Solution:
    def findCenter(self, edges: list[list[int]]) -> int:
        
```

# Hints

1. The center is in every edge. How many edges do you need to look at?
2. It must be the node that edges[0] and edges[1] share.

# Key points

- the center appears in every edge
- compare the first two edges: O(1)

# Solution: directly-compare-the-points-of-the-first · Directly Compare the Points of the First Two Edges · O(1) · O(1) · reference

The characteristic of the center point is that it is connected to all other points. Therefore, as long as we compare the points of the first two edges, if there are the same points, then this point is the center point.

The time complexity is O(1), and the space complexity is O(1).

```python
class Solution:
    def findCenter(self, edges: List[List[int]]) -> int:
        return edges[0][0] if edges[0][0] in edges[1] else edges[0][1]
```

# Tests

```python
def star(rng, n):
    c = rng.randint(1, n)
    e = [[c, v] if rng.random() < 0.5 else [v, c] for v in range(1, n + 1) if v != c]
    rng.shuffle(e)
    return [e]

def edge():
    return [[[[1, 2], [2, 3], [4, 2]]], [[[1, 2], [5, 1], [1, 3], [1, 4]]], [[[3, 1], [3, 2]]]]

def random_case(rng):
    return star(rng, rng.randint(3, 10))

def perf(rng):
    return [star(rng, 100000)]
```
