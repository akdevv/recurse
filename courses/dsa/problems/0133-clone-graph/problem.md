---
lc: 133
title: "Clone Graph"
difficulty: "Medium"
patterns: ["hash-map", "tree-dfs"]
lcTags: ["hash-table", "depth-first-search", "breadth-first-search", "graph"]
entry: {"method": "cloneGraph", "params": [{"name": "adjList", "type": "integer[][]"}], "returns": "integer[][]", "interactive": true}
examples: ["[[2,4],[1,3],[2,4],[1,3]]", "[[]]", "[]"]
---

Given a reference of a node in a **[connected](https://en.wikipedia.org/wiki/Connectivity_(graph_theory)#Connected_graph)** undirected graph.

Return a [**deep copy**](https://en.wikipedia.org/wiki/Object_copying#Deep_copy) (clone) of the graph.

Each node in the graph contains a value (`int`) and a list (`List[Node]`) of its neighbors.

```
class Node {
    public int val;
    public List<Node> neighbors;
}
```

**Test case format:**

For simplicity, each node's value is the same as the node's index (1-indexed). For example, the first node with `val == 1`, the second node with `val == 2`, and so on. The graph is represented in the test case using an adjacency list.

**An adjacency list** is a collection of unordered **lists** used to represent a finite graph. Each list describes the set of neighbors of a node in the graph.

The given node will always be the first node with `val = 1`. You must return the **copy of the given node** as a reference to the cloned graph.

**Example 1:**

![](https://assets.leetcode.com/uploads/2019/11/04/133_clone_graph_question.png)

```
Input: adjList = [[2,4],[1,3],[2,4],[1,3]]
Output: [[2,4],[1,3],[2,4],[1,3]]
Explanation: There are 4 nodes in the graph.
1st node (val = 1)'s neighbors are 2nd node (val = 2) and 4th node (val = 4).
2nd node (val = 2)'s neighbors are 1st node (val = 1) and 3rd node (val = 3).
3rd node (val = 3)'s neighbors are 2nd node (val = 2) and 4th node (val = 4).
4th node (val = 4)'s neighbors are 1st node (val = 1) and 3rd node (val = 3).
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2020/01/07/graph.png)

```
Input: adjList = [[]]
Output: [[]]
Explanation: Note that the input contains one empty list. The graph consists of only one node with val = 1 and it does not have any neighbors.
```

**Example 3:**

```
Input: adjList = []
Output: []
Explanation: This an empty graph, it does not have any nodes.
```

**Constraints:**

- The number of nodes in the graph is in the range `[0, 100]`.
- `1 <= Node.val <= 100`
- `Node.val` is unique for each node.
- There are no repeated edges and no self-loops in the graph.
- The Graph is connected and all nodes can be visited starting from the given node.

# Starter

```python
"""
# Definition for a Node.
class Node:
    def __init__(self, val = 0, neighbors = None):
        self.val = val
        self.neighbors = neighbors if neighbors is not None else []
"""

from typing import Optional
class Solution:
    def cloneGraph(self, node: Optional['Node']) -> Optional['Node']:
        
```

# Hints

1. While copying you'll meet the same node many times (cycles). How do you avoid copying it twice?
2. Dict original → copy. DFS(node): if it's in the dict return the copy; else create the copy, store it, then set its neighbours to DFS(each neighbour).

# Key points

- hash map old → new doubles as the visited set
- create the copy before recursing into neighbours (handles cycles)
- O(V + E) time
- the tests rebuild the adjacency list from your copy and check no node is shared with the original

# Solution: hash-table-dfs · Hash Table + DFS · O(n) · O(n) · reference

We use a hash table g to record the correspondence between each node in the original graph and its copy, and then perform depth-first search.

We define the function `dfs(node)`, which returns the copy of the node. The process of `dfs(node)` is as follows:

- If node is null, then the return value of `dfs(node)` is null.
- If node is in g, then the return value of `dfs(node)` is `g[node]`.
- Otherwise, we create a new node cloned and set the value of `g[node]` to cloned. Then, we traverse all the neighbor nodes nxt of node and add `dfs(nxt)` to the neighbor list of cloned.
- Finally, return cloned.

In the main function, we return `dfs(node)`.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes.

```python
"""
# Definition for a Node.
class Node:
    def __init__(self, val = 0, neighbors = None):
        self.val = val
        self.neighbors = neighbors if neighbors is not None else []
"""

from typing import Optional

class Solution:
    def cloneGraph(self, node: Optional["Node"]) -> Optional["Node"]:
        def dfs(node):
            if node is None:
                return None
            if node in g:
                return g[node]
            cloned = Node(node.val)
            g[node] = cloned
            for nxt in node.neighbors:
                cloned.neighbors.append(dfs(nxt))
            return cloned

        g = defaultdict()
        return dfs(node)
```

# Tests

```python
class Node:
    def __init__(self, val=0, neighbors=None):
        self.val = val
        self.neighbors = neighbors if neighbors is not None else []

ORIG = []

def prepare(args):
    adj = args[0]
    ORIG[:] = [Node(i + 1) for i in range(len(adj))]
    for i, nb in enumerate(adj):
        ORIG[i].neighbors = [ORIG[j - 1] for j in nb]
    return [ORIG[0] if ORIG else None], {"Node": Node}

def output(ret):
    if ret is None:
        return []
    seen, stack = {}, [ret]
    while stack:
        n = stack.pop()
        if any(n is o for o in ORIG):
            return "copy shares nodes with the original"
        if n.val not in seen:
            seen[n.val] = n
            stack += n.neighbors
    return [[m.val for m in seen[v].neighbors] for v in sorted(seen)]

def connected(rng, n):
    edges = {(i, rng.randrange(i)) for i in range(1, n)}
    for _ in range(rng.randint(0, n)):
        a, b = rng.sample(range(n), 2) if n > 1 else (0, 0)
        if a != b:
            edges.add((max(a, b), min(a, b)))
    adj = [[] for _ in range(n)]
    for a, b in edges:
        adj[a].append(b + 1)
        adj[b].append(a + 1)
    return [adj]

def edge():
    return [[[]], [[[]]], [[[2], [1]]], [[[2, 4], [1, 3], [2, 4], [1, 3]]]]

def random_case(rng):
    return connected(rng, rng.randint(1, 8))

def perf(rng):
    return [connected(rng, 100)]
```
