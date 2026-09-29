## Core idea

**Union-find (disjoint set union) keeps track of which items are in the same group while groups merge.** Each item points to a parent; following parents leads to the group's root. `find` returns the root, `union` points one root at the other. With path compression and union by rank, both run in nearly O(1).

## Intuition

Companies merging. Every employee knows their manager; the CEO is the root. Two people work for the same company exactly when their chains end at the same CEO. When two companies merge, one CEO starts reporting to the other: one pointer change, no need to update every employee.

**Path compression** is people remembering the CEO directly after asking once, so next time they don't climb the whole chain. **Union by rank/size** attaches the smaller company under the bigger one so chains stay short.

## Visualization

Unions and path compression:

```viz
union-find
```

Redundant Connection: the first edge between already-connected nodes closes a cycle:

```viz
redundant
```

## Template code

```python
class DSU:
    def __init__(self, n):
        self.parent = list(range(n))
        self.size = [1] * n
        self.groups = n

    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]   # path halving
            x = self.parent[x]
        return x

    def union(self, a, b):
        ra, rb = self.find(a), self.find(b)
        if ra == rb:
            return False                    # already connected (cycle edge)
        if self.size[ra] < self.size[rb]:
            ra, rb = rb, ra
        self.parent[rb] = ra                # smaller under bigger
        self.size[ra] += self.size[rb]
        self.groups -= 1
        return True

# Redundant connection: the edge whose union() returns False
# Components: dsu.groups after all unions
# Network connected: need len(connections) >= n - 1, answer = groups - 1
# Accounts merge: union emails, group by root
```

## Complexity

| Version | find / union |
|---|---|
| naive (no optimisations) | O(n) worst case (long chains) |
| path compression + union by rank/size | **O(α(n))**: effectively constant (α ≤ 4 for any realistic n) |

Space O(n).

## When to use it

- **Groups keep merging, and you ask "are these connected?"** → union-find
- **"Number of connected components / provinces"** → union all edges, count roots
- **"Which edge creates a cycle" (undirected)** → the first union that fails
- **Kruskal's minimum spanning tree** → skip edges whose ends share a root
- **Grouping by shared items (accounts sharing an email)** → union through the shared item
- **Need actual paths or distances** → BFS/DFS instead: union-find only answers "same group?"

## Common traps

- Comparing `parent[a] == parent[b]` instead of `find(a) == find(b)`
- Forgetting path compression and union by size: chains can grow to O(n)
- Union-find for directed graphs: it ignores direction, so it can't detect directed cycles
- Mapping non-integer items (emails, names) to indices first, or using a dict-based parent
- Counting components as `len(set(parent))` without calling `find` on each element first
