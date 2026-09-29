---
lc: 547
title: "Number of Provinces"
difficulty: "Medium"
patterns: ["union-find", "tree-dfs"]
lcTags: ["depth-first-search", "breadth-first-search", "union-find", "graph"]
entry: {"method": "findCircleNum", "params": [{"name": "isConnected", "type": "integer[][]"}], "returns": "integer"}
examples: ["[[1,1,0],[1,1,0],[0,0,1]]", "[[1,0,0],[0,1,0],[0,0,1]]"]
---

There are `n` cities. Some of them are connected, while some are not. If city `a` is connected directly with city `b`, and city `b` is connected directly with city `c`, then city `a` is connected indirectly with city `c`.

A **province** is a group of directly or indirectly connected cities and no other cities outside of the group.

You are given an `n x n` matrix `isConnected` where `isConnected[i][j] = 1` if the `iᵗʰ` city and the `jᵗʰ` city are directly connected, and `isConnected[i][j] = 0` otherwise.

Return *the total number of **provinces***.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/12/24/graph1.jpg)

```
Input: isConnected = [[1,1,0],[1,1,0],[0,0,1]]
Output: 2
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2020/12/24/graph2.jpg)

```
Input: isConnected = [[1,0,0],[0,1,0],[0,0,1]]
Output: 3
```

**Constraints:**

- `1 <= n <= 200`
- `n == isConnected.length`
- `n == isConnected[i].length`
- `isConnected[i][j]` is `1` or `0`.
- `isConnected[i][i] == 1`
- `isConnected[i][j] == isConnected[j][i]`

# Starter

```python
class Solution:
    def findCircleNum(self, isConnected: List[List[int]]) -> int:
        
```

# Hints

1. A province is a connected component in the graph given as an adjacency matrix.
2. For each city not visited yet, count a new province and DFS through isConnected[city]. (Union-find also works.)

# Key points

- count connected components
- DFS/BFS from each unvisited node, or union-find with a component counter
- O(n²) time for the matrix

# Solution: dfs · DFS · O(n²) · O(n) · reference

We create an array vis to record whether each city has been visited.

Next, we traverse each city i. If the city has not been visited, we start a depth-first search from that city. Using the matrix isConnected, we find the cities directly connected to this city. These cities and the current city belong to the same province. We continue the depth-first search for these cities until all cities in the same province have been visited. This counts as one province, so we increment the answer ans by 1. Then, we move to the next unvisited city and repeat the process until all cities have been traversed.

Finally, return the answer.

The time complexity is O(n²), and the space complexity is O(n). Here, n is the number of cities.

```python
class Solution:
    def findCircleNum(self, isConnected: List[List[int]]) -> int:
        def dfs(i: int):
            vis[i] = True
            for j, x in enumerate(isConnected[i]):
                if not vis[j] and x:
                    dfs(j)

        n = len(isConnected)
        vis = [False] * n
        ans = 0
        for i in range(n):
            if not vis[i]:
                dfs(i)
                ans += 1
        return ans
```

# Solution: union-find · Union-Find · O(n² × log n) · O(n)

We can also use the union-find data structure to maintain each connected component. Initially, each city belongs to a different connected component, so the number of provinces is n.

Next, we traverse the matrix isConnected. If there is a connection between two cities `(i, j)` and they belong to two different connected components, they will be merged into one connected component, and the number of provinces is decremented by 1.

Finally, return the number of provinces.

The time complexity is O(n² × log n), and the space complexity is O(n). Here, n is the number of cities, and `log n` is the time complexity of path compression in the union-find data structure.

```python
class Solution:
    def findCircleNum(self, isConnected: List[List[int]]) -> int:
        def find(x: int) -> int:
            if p[x] != x:
                p[x] = find(p[x])
            return p[x]

        n = len(isConnected)
        p = list(range(n))
        ans = n
        for i in range(n):
            for j in range(i + 1, n):
                if isConnected[i][j]:
                    pa, pb = find(i), find(j)
                    if pa != pb:
                        p[pa] = pb
                        ans -= 1
        return ans
```

# Tests

```python
def matrix(rng, n, p):
    m = [[1 if i == j else 0 for j in range(n)] for i in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                m[i][j] = m[j][i] = 1
    return [m]

def edge():
    return [[[[1]]], [[[1, 1, 0], [1, 1, 0], [0, 0, 1]]], [[[1, 0, 0], [0, 1, 0], [0, 0, 1]]], [[[1, 1], [1, 1]]]]

def random_case(rng):
    return matrix(rng, rng.randint(1, 8), 0.25)

def perf(rng):
    return [matrix(rng, 200, 0.01)]
```
