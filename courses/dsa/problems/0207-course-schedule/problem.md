---
lc: 207
title: "Course Schedule"
difficulty: "Medium"
patterns: ["topological-sort"]
lcTags: ["depth-first-search", "breadth-first-search", "graph", "topological-sort", "directed-acyclic-graph"]
entry: {"method": "canFinish", "params": [{"name": "numCourses", "type": "integer"}, {"name": "prerequisites", "type": "integer[][]"}], "returns": "boolean"}
examples: ["2\n[[1,0]]", "2\n[[1,0],[0,1]]"]
lcHints: ["This problem is equivalent to finding if a cycle exists in a directed graph. If a cycle exists, no topological ordering exists and therefore it will be impossible to take all courses.", "<a href=\"https://www.cs.princeton.edu/~wayne/kleinberg-tardos/pdf/03Graphs.pdf\" target=\"_blank\">Topological Sort via DFS</a> - A great tutorial explaining the basic concepts of Topological Sort.", "Topological sort could also be done via <a href=\"http://en.wikipedia.org/wiki/Topological_sorting#Algorithms\" target=\"_blank\">BFS</a>."]
---

There are a total of `numCourses` courses you have to take, labeled from `0` to `numCourses - 1`. You are given an array `prerequisites` where `prerequisites[i] = [aᵢ, bᵢ]` indicates that you **must** take course `bᵢ` first if you want to take course `aᵢ`.

- For example, the pair `[0, 1]`, indicates that to take course `0` you have to first take course `1`.

Return `true` if you can finish all courses. Otherwise, return `false`.

**Example 1:**

```
Input: numCourses = 2, prerequisites = [[1,0]]
Output: true
Explanation: There are a total of 2 courses to take.
To take course 1 you should have finished course 0. So it is possible.
```

**Example 2:**

```
Input: numCourses = 2, prerequisites = [[1,0],[0,1]]
Output: false
Explanation: There are a total of 2 courses to take.
To take course 1 you should have finished course 0, and to take course 0 you should also have finished course 1. So it is impossible.
```

**Constraints:**

- `1 <= numCourses <= 2000`
- `0 <= prerequisites.length <= 5000`
- `prerequisites[i].length == 2`
- `0 <= aᵢ, bᵢ < numCourses`
- All the pairs prerequisites[i] are **unique**.

# Starter

```python
class Solution:
    def canFinish(self, numCourses: int, prerequisites: list[list[int]]) -> bool:
        
```

# Hints

1. You can finish all courses exactly when the prerequisite graph has no cycle.
2. Kahn's algorithm: compute in-degrees, start with courses that have none, remove them and decrement neighbours. If you process all courses, there's no cycle.

# Key points

- cycle in a directed graph ⇔ impossible
- Kahn's BFS (in-degrees) or DFS with three colors
- O(V + E) time

# Solution: topological-sorting · Topological Sorting · O(n + m) · O(n + m) · reference

For this problem, we can consider the courses as nodes in a graph, and prerequisites as edges in the graph. Thus, we can transform this problem into determining whether there is a cycle in the directed graph.

Specifically, we can use the idea of topological sorting. For each node with an in-degree of 0, we reduce the in-degree of its out-degree nodes by 1, until all nodes have been traversed.

If all nodes have been traversed, it means there is no cycle in the graph, and we can complete all courses; otherwise, we cannot complete all courses.

The time complexity is O(n + m), and the space complexity is O(n + m). Here, n and m are the number of courses and prerequisites respectively.

```python
class Solution:
    def canFinish(self, numCourses: int, prerequisites: List[List[int]]) -> bool:
        g = [[] for _ in range(numCourses)]
        indeg = [0] * numCourses
        for a, b in prerequisites:
            g[b].append(a)
            indeg[a] += 1
        q = [i for i, x in enumerate(indeg) if x == 0]
        for i in q:
            numCourses -= 1
            for j in g[i]:
                indeg[j] -= 1
                if indeg[j] == 0:
                    q.append(j)
        return numCourses == 0
```

# Tests

```python
def pairs(rng, n, m, dag):
    order = list(range(n))
    rng.shuffle(order)
    pos = {c: i for i, c in enumerate(order)}
    out = set()
    tries = 0
    while len(out) < m and tries < 1000:
        tries += 1
        a, b = rng.sample(range(n), 2)
        if dag and pos[a] < pos[b]:
            a, b = b, a
        out.add((a, b))
    return [list(p) for p in out]

def edge():
    return [[1, []], [2, [[1, 0]]], [2, [[1, 0], [0, 1]]], [3, [[1, 0], [2, 1]]], [3, [[0, 1], [1, 2], [2, 0]]]]

def random_case(rng):
    n = rng.randint(2, 7)
    return [n, pairs(rng, n, rng.randint(0, n), rng.random() < 0.5)]

def perf(rng):
    return [[2000, pairs(rng, 2000, 5000, True)], [2000, [[i + 1, i] for i in range(1999)] + [[0, 1999]]]]
```
