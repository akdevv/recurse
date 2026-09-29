---
lc: 210
title: "Course Schedule II"
difficulty: "Medium"
patterns: ["topological-sort"]
lcTags: ["depth-first-search", "breadth-first-search", "graph", "topological-sort"]
compare: "check"
entry: {"method": "findOrder", "params": [{"name": "numCourses", "type": "integer"}, {"name": "prerequisites", "type": "integer[][]"}], "returns": "integer[]"}
examples: ["2\n[[1,0]]", "4\n[[1,0],[2,0],[3,1],[3,2]]", "1\n[]"]
lcHints: ["This problem is equivalent to finding the topological order in a directed graph. If a cycle exists, no topological ordering exists and therefore it will be impossible to take all courses.", "<a href=\"https://www.youtube.com/watch?v=ozso3xxkVGU\" target=\"_blank\">Topological Sort via DFS</a> - A great video tutorial (21 minutes) on Coursera explaining the basic concepts of Topological Sort.", "Topological sort could also be done via <a href=\"http://en.wikipedia.org/wiki/Topological_sorting#Algorithms\" target=\"_blank\">BFS</a>."]
---

There are a total of `numCourses` courses you have to take, labeled from `0` to `numCourses - 1`. You are given an array `prerequisites` where `prerequisites[i] = [aᵢ, bᵢ]` indicates that you **must** take course `bᵢ` first if you want to take course `aᵢ`.

- For example, the pair `[0, 1]`, indicates that to take course `0` you have to first take course `1`.

Return *the ordering of courses you should take to finish all courses*. If there are many valid answers, return **any** of them. If it is impossible to finish all courses, return **an empty array**.

**Example 1:**

```
Input: numCourses = 2, prerequisites = [[1,0]]
Output: [0,1]
Explanation: There are a total of 2 courses to take. To take course 1 you should have finished course 0. So the correct course order is [0,1].
```

**Example 2:**

```
Input: numCourses = 4, prerequisites = [[1,0],[2,0],[3,1],[3,2]]
Output: [0,2,1,3]
Explanation: There are a total of 4 courses to take. To take course 3 you should have finished both courses 1 and 2. Both courses 1 and 2 should be taken after you finished course 0.
So one correct course order is [0,1,2,3]. Another correct ordering is [0,2,1,3].
```

**Example 3:**

```
Input: numCourses = 1, prerequisites = []
Output: [0]
```

**Constraints:**

- `1 <= numCourses <= 2000`
- `0 <= prerequisites.length <= numCourses * (numCourses - 1)`
- `prerequisites[i].length == 2`
- `0 <= aᵢ, bᵢ < numCourses`
- `aᵢ != bᵢ`
- All the pairs `[aᵢ, bᵢ]` are **distinct**.

# Starter

```python
class Solution:
    def findOrder(self, numCourses: int, prerequisites: list[list[int]]) -> list[int]:
        
```

# Hints

1. You need an actual order: a topological sort of the prerequisite graph.
2. Kahn's algorithm: repeatedly take a course with in-degree 0, append it to the order, and decrement its dependents. If the order has fewer than n courses, return [].

# Key points

- topological sort with in-degrees (BFS) or DFS postorder
- a cycle leaves some courses unprocessed → return []
- many valid orders; any is accepted
- O(V + E) time

# Solution: solution-1 · Topological sort (Kahn's BFS) · O(n + m) · O(n + m) · reference

## Idea
Kahn's algorithm. Count incoming edges (prerequisites) for each course. Start with the courses that have none; each time you take one, lower its dependents' counts and queue those that reach 0. If fewer than n courses were taken there's a cycle, so return [].

## Complexity
- **Time: O(n + m)**
- **Space: O(n + m)**

```python
class Solution:
    def findOrder(self, numCourses: int, prerequisites: List[List[int]]) -> List[int]:
        g = defaultdict(list)
        indeg = [0] * numCourses
        for a, b in prerequisites:
            g[b].append(a)
            indeg[a] += 1
        ans = []
        q = deque(i for i, x in enumerate(indeg) if x == 0)
        while q:
            i = q.popleft()
            ans.append(i)
            for j in g[i]:
                indeg[j] -= 1
                if indeg[j] == 0:
                    q.append(j)
        return ans if len(ans) == numCourses else []
```

# Tests

```python
def check(args, got, expected):
    n, pre = args
    if not expected:
        return got == []
    if sorted(got) != list(range(n)):
        return False
    pos = {c: i for i, c in enumerate(got)}
    return all(pos[b] < pos[a] for a, b in pre)

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
    return [[1, []], [2, [[1, 0]]], [2, [[1, 0], [0, 1]]], [4, [[1, 0], [2, 0], [3, 1], [3, 2]]]]

def random_case(rng):
    n = rng.randint(2, 7)
    return [n, pairs(rng, n, rng.randint(0, n), rng.random() < 0.6)]

def perf(rng):
    return [[2000, pairs(rng, 2000, 5000, True)]]
```
