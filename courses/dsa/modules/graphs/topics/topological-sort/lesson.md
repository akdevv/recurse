## Core idea

**A topological order lists the nodes of a directed graph so that every edge points forward: every task comes after its prerequisites.** It exists exactly when the graph has no cycle. Kahn's algorithm builds it by repeatedly taking a node with no remaining prerequisites (in-degree 0).

## Intuition

Getting dressed: socks before shoes, shirt before tie. Some orders work, some don't, and many valid orders exist. Kahn's algorithm is how you'd actually do it: look at what you can put on right now (nothing left that has to go on first), put one on, and see what that unlocks.

If two things each require the other first ("A before B" and "B before A"), you're stuck forever: that's a **cycle**, and no valid order exists.

## Visualization

Kahn's algorithm with in-degrees:

```viz
kahn
```

A cycle: those nodes never reach in-degree 0:

```viz
cycle
```

## Template code

```python
from collections import deque, defaultdict

def topo_order(n, prerequisites):
    adj = defaultdict(list)
    indeg = [0] * n
    for course, pre in prerequisites:        # pre → course
        adj[pre].append(course)
        indeg[course] += 1
    q = deque(i for i in range(n) if indeg[i] == 0)
    order = []
    while q:
        u = q.popleft()
        order.append(u)
        for v in adj[u]:
            indeg[v] -= 1
            if indeg[v] == 0:
                q.append(v)
    return order if len(order) == n else []   # [] → there's a cycle

can_finish = len(topo_order(n, prerequisites)) == n

# DFS alternative: 3 colours (0 = new, 1 = on the current path, 2 = done)
# reaching a node coloured 1 means a cycle; reverse postorder is a topological order
```

## Complexity

**O(V + E)** time and space: every node enters the queue once and every edge lowers one in-degree once.

## When to use it

- **"Prerequisites", "dependencies", "build order", "can all tasks finish"** → topological sort
- **"Is there a cycle in a directed graph"** → Kahn (not all nodes processed) or DFS colours
- **"Order of letters in an alien dictionary"** → build edges from adjacent words, then topological sort
- **Longest path / earliest finish time in a DAG** → DP over the topological order
- **Undirected cycle detection** → union-find or DFS with a parent check, not in-degrees

## Common traps

- Getting the edge direction backwards: `[a, b]` in Course Schedule means **b before a** (b → a)
- Returning the partial order instead of `[]` when a cycle exists
- Using a visited set alone to find directed cycles: a node reached twice isn't necessarily a cycle; you need "on the current path"
- Forgetting nodes with no edges at all: they have in-degree 0 and belong in the order too
- Several valid orders exist; don't assume the test expects one specific order unless told
