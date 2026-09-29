## Core idea

**A graph is a set of nodes connected by edges. Edges can be directed (one-way) or undirected, weighted or not. The first step of almost every graph problem is turning the input into an adjacency list: node → its neighbours.** Trees and linked lists are just special graphs.

## Intuition

A city map: intersections are nodes, streets are edges. One-way streets are directed edges; distances or travel times are weights. A social network is a graph of people with "follows" (directed) or "friends" (undirected) edges.

Two numbers describe how a node sits in the graph: its **degree** (how many edges touch it). For directed graphs that splits into **in-degree** (arrows coming in) and **out-degree** (arrows going out). Many "easy" graph problems are just counting degrees.

## Visualization

Edge list → adjacency list, and degrees:

```viz
representations
```

Directed edges: in-degree and out-degree find the town judge:

```viz
town-judge
```

## Template code

```python
from collections import defaultdict

# Undirected edge list → adjacency list
adj = defaultdict(list)
for a, b in edges:
    adj[a].append(b)
    adj[b].append(a)          # both directions

# Directed: only a → b, and track in-degrees
adj = defaultdict(list)
indeg = [0] * n
for a, b in edges:
    adj[a].append(b)
    indeg[b] += 1

# Weighted: store (neighbour, weight)
for u, v, w in times:
    adj[u].append((v, w))

# Adjacency matrix (dense graphs, or when given as input)
connected = isConnected[i][j] == 1

# Degree counting (Town Judge, star center)
score = [0] * (n + 1)
for a, b in trust:
    score[a] -= 1             # out-edge
    score[b] += 1             # in-edge
```

## Complexity

| Representation | Space | Check edge (u, v) | List neighbours of u |
|---|---|---|---|
| edge list | O(E) | O(E) | O(E) |
| adjacency list | **O(V + E)** | O(deg u) | **O(deg u)** |
| adjacency matrix | O(V²) | **O(1)** | O(V) |

Most graphs in interviews are sparse (E much less than V²), so adjacency lists are the default. Any full traversal is O(V + E).

## When to use it

- **Input is pairs like `[[a, b], …]`** → build an adjacency list first
- **"Who is trusted/followed by everyone", "center of a star"** → count degrees
- **"Is there a path", "how many groups"** → BFS/DFS or union-find (next topics)
- **Dependencies ("a before b")** → directed graph → topological sort
- **Grid problems** → the grid is an implicit graph: each cell's neighbours are up/down/left/right

## Common traps

- Adding only one direction for an undirected edge
- Nodes numbered 1..n but the array sized n (off by one)
- Forgetting isolated nodes that appear in no edge (they're still nodes)
- Using a matrix for 10⁵ nodes: 10¹⁰ cells
- Mixing up in-degree and out-degree for directed edges
