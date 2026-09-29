---
lc: 841
title: "Keys and Rooms"
difficulty: "Medium"
patterns: ["tree-dfs", "bfs"]
lcTags: ["depth-first-search", "breadth-first-search", "graph"]
entry: {"method": "canVisitAllRooms", "params": [{"name": "rooms", "type": "list<list<integer>>"}], "returns": "boolean"}
examples: ["[[1],[2],[3],[]]", "[[1,3],[3,0,1],[2],[0]]"]
---

There are `n` rooms labeled from `0` to `n - 1` and all the rooms are locked except for room `0`. Your goal is to visit all the rooms. However, you cannot enter a locked room without having its key.

When you visit a room, you may find a set of **distinct keys** in it. Each key has a number on it, denoting which room it unlocks, and you can take all of them with you to unlock the other rooms.

Given an array `rooms` where `rooms[i]` is the set of keys that you can obtain if you visited room `i`, return `true` *if you can visit **all** the rooms, or* `false` *otherwise*.

**Example 1:**

```
Input: rooms = [[1],[2],[3],[]]
Output: true
Explanation:
We visit room 0 and pick up key 1.
We then visit room 1 and pick up key 2.
We then visit room 2 and pick up key 3.
We then visit room 3.
Since we were able to visit every room, we return true.
```

**Example 2:**

```
Input: rooms = [[1,3],[3,0,1],[2],[0]]
Output: false
Explanation: We can not enter room number 2 since the only key that unlocks it is in that room.
```

**Constraints:**

- `n == rooms.length`
- `2 <= n <= 1000`
- `0 <= rooms[i].length <= 1000`
- `1 <= sum(rooms[i].length) <= 3000`
- `0 <= rooms[i][j] < n`
- All the values of `rooms[i]` are **unique**.

# Starter

```python
class Solution:
    def canVisitAllRooms(self, rooms: list[list[int]]) -> bool:
        
```

# Hints

1. Rooms are nodes and keys are edges. Starting from room 0, which rooms can you reach?
2. DFS/BFS from room 0 with a visited set; return len(visited) == n.

# Key points

- graph reachability from node 0
- visited set, stack or queue
- O(n + total keys) time

# Solution: depth-first-search-dfs · Depth-First Search (DFS) · O(n + m) · O(n) · reference

We can use the Depth-First Search (DFS) method to traverse the entire graph, count the number of reachable nodes, and use an array `vis` to mark whether the current node has been visited to prevent repeated visits.

Finally, we count the number of visited nodes. If it is the same as the total number of nodes, it means that all nodes can be visited; otherwise, there are nodes that cannot be reached.

The time complexity is O(n + m), and the space complexity is O(n), where n is the number of nodes, and m is the number of edges.

```python
class Solution:
    def canVisitAllRooms(self, rooms: List[List[int]]) -> bool:
        def dfs(i: int):
            if i in vis:
                return
            vis.add(i)
            for j in rooms[i]:
                dfs(j)

        vis = set()
        dfs(0)
        return len(vis) == len(rooms)
```

# Solution: bfs · BFS · O(n + m) · O(n)

We can also use the Breadth-First Search (BFS) method to traverse the entire graph. We use a hash table or an array `vis` to mark whether the current node has been visited to prevent repeated visits.

Specifically, we define a queue q, initially put node 0 into the queue, and then continuously traverse the queue. Each time we take out the front node i of the queue, if i has been visited, we skip it directly; otherwise, we mark it as visited, and then add the nodes that i can reach to the queue.

Finally, we count the number of visited nodes. If it is the same as the total number of nodes, it means that all nodes can be visited; otherwise, it means that there are unreachable nodes.

The time complexity is O(n + m), and the space complexity is O(n). Where n is the number of nodes, and m is the number of edges.

```python
class Solution:
    def canVisitAllRooms(self, rooms: List[List[int]]) -> bool:
        vis = set()
        q = deque([0])
        while q:
            i = q.popleft()
            if i in vis:
                continue
            vis.add(i)
            q.extend(j for j in rooms[i])
        return len(vis) == len(rooms)
```

# Tests

```python
def edge():
    return [[[[1], [2], [3], []]], [[[1, 3], [3, 0, 1], [2], [0]]], [[[1], []]], [[[], [0]]]]

def random_case(rng):
    n = rng.randint(2, 7)
    return [[rng.sample(range(n), rng.randint(0, min(3, n))) for _ in range(n)]]

def perf(rng):
    n = 1000
    return [[[[i + 1, (i + 2) % n, (i + 3) % n] if i + 1 < n else [] for i in range(n)]]]
```
