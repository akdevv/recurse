---
lc: 1319
title: "Number of Operations to Make Network Connected"
difficulty: "Medium"
patterns: ["union-find"]
lcTags: ["depth-first-search", "breadth-first-search", "union-find", "graph"]
entry: {"method": "makeConnected", "params": [{"name": "n", "type": "integer"}, {"name": "connections", "type": "integer[][]"}], "returns": "integer"}
examples: ["4\n[[0,1],[0,2],[1,2]]", "6\n[[0,1],[0,2],[0,3],[1,2],[1,3]]", "6\n[[0,1],[0,2],[0,3],[1,2]]"]
lcHints: ["As long as there are at least (n - 1) connections, there is definitely a way to connect all computers.", "Use DFS to determine the number of isolated computer clusters."]
---

There are `n` computers numbered from `0` to `n - 1` connected by ethernet cables `connections` forming a network where `connections[i] = [aᵢ, bᵢ]` represents a connection between computers `aᵢ` and `bᵢ`. Any computer can reach any other computer directly or indirectly through the network.

You are given an initial computer network `connections`. You can extract certain cables between two directly connected computers, and place them between any pair of disconnected computers to make them directly connected.

Return *the minimum number of times you need to do this in order to make all the computers connected*. If it is not possible, return `-1`.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/01/02/sample_1_1677.png)

```
Input: n = 4, connections = [[0,1],[0,2],[1,2]]
Output: 1
Explanation: Remove cable between computer 1 and 2 and place between computers 1 and 3.
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2020/01/02/sample_2_1677.png)

```
Input: n = 6, connections = [[0,1],[0,2],[0,3],[1,2],[1,3]]
Output: 2
```

**Example 3:**

```
Input: n = 6, connections = [[0,1],[0,2],[0,3],[1,2]]
Output: -1
Explanation: There are not enough cables.
```

**Constraints:**

- `1 <= n <= 10⁵`
- `1 <= connections.length <= min(n * (n - 1) / 2, 10⁵)`
- `connections[i].length == 2`
- `0 <= aᵢ, bᵢ < n`
- `aᵢ != bᵢ`
- There are no repeated connections.
- No two computers are connected by more than one cable.

# Starter

```python
class Solution:
    def makeConnected(self, n: int, connections: list[list[int]]) -> int:
        
```

# Hints

1. Connecting c components needs c − 1 cables. Do you have enough spare cables?
2. If connections < n − 1 return −1. Otherwise count components with union-find (or DFS) and return components − 1.

# Key points

- need at least n - 1 cables in total
- answer = number of components - 1
- every redundant cable can be moved to join two components
- O(n + e) time

# Solution: union-find · Union-Find · O(m × log n) · O(n) · reference

We can use a union-find data structure to maintain the connectivity between computers. Traverse all connections, and for each connection `(a, b)`, if a and b are already connected, then this connection is redundant, and we increment the count of redundant connections. Otherwise, we connect a and b, and decrement the number of connected components.

Finally, if the number of connected components minus one is greater than the number of redundant connections, it means we cannot connect all computers, so we return -1. Otherwise, we return the number of connected components minus one.

The time complexity is O(m × log n), and the space complexity is O(n). Here, n and m are the number of computers and the number of connections, respectively.

```python
class Solution:
    def makeConnected(self, n: int, connections: List[List[int]]) -> int:
        def find(x: int) -> int:
            if p[x] != x:
                p[x] = find(p[x])
            return p[x]

        cnt = 0
        p = list(range(n))
        for a, b in connections:
            pa, pb = find(a), find(b)
            if pa == pb:
                cnt += 1
            else:
                p[pa] = pb
                n -= 1
        return -1 if n - 1 > cnt else n - 1
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
    return [[4, [[0, 1], [0, 2], [1, 2]]], [6, [[0, 1], [0, 2], [0, 3], [1, 2], [1, 3]]], [6, [[0, 1], [0, 2], [0, 3], [1, 2]]], [2, [[0, 1]]]]

def random_case(rng):
    n = rng.randint(2, 8)
    return [n, graph(rng, n, rng.randint(1, n * (n - 1) // 2))]

def perf(rng):
    n = 100000
    e = {(i, i + 1) for i in range(0, n - 1, 2)} | {tuple(x) for x in graph(rng, 1000, 20000)}
    return [[n, [list(x) for x in e]]]
```
