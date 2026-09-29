## Core idea

**Some structures show up in system design and senior interviews as "explain it" questions rather than coding tasks.** Know what each one is for, its key trade-off, and its complexity: segment and Fenwick trees for range queries on changing data, skip lists and B-trees for ordered data, suffix structures for text search, Bloom filters for cheap "definitely not here" checks.

## Intuition

Prefix sums answer range sums in O(1), but a single update forces an O(n) rebuild. A **segment tree** is a compromise: each node stores the sum of a range, so a query combines O(log n) stored pieces and an update fixes O(log n) nodes on one path.

A **Bloom filter** is a bouncer with a fuzzy memory: "you're definitely not on the list" is always right; "you might be on the list" occasionally lets in someone who isn't. In exchange it uses a tiny fraction of the memory of a real list.

## Visualization

Segment tree: a range query takes whole stored ranges instead of single elements:

```viz
segment-tree
```

Bloom filter: no false negatives, occasional false positives:

```viz
bloom
```

## Template code

```python
# Fenwick (binary indexed) tree: prefix sums with point updates, O(log n) each
class BIT:
    def __init__(self, n):
        self.t = [0] * (n + 1)
    def add(self, i, delta):          # 1-based index
        while i < len(self.t):
            self.t[i] += delta
            i += i & -i               # jump to the next responsible node
    def prefix(self, i):
        s = 0
        while i > 0:
            s += self.t[i]
            i -= i & -i               # drop the lowest set bit
        return s
    # range sum l..r = prefix(r) - prefix(l - 1)

# Segment tree query idea (recursive):
#   node range fully inside the query → return its stored value
#   no overlap → return 0
#   partial overlap → combine both children
```

## Complexity

| Structure | Main operations | Cost | Typical use |
|---|---|---|---|
| Segment tree | range query + point/range update | O(log n) each | range sum/min/max on changing arrays |
| Fenwick tree | prefix sum + point update | O(log n) each | simpler, smaller than a segment tree for sums |
| Skip list | search / insert / delete in sorted order | O(log n) expected | Redis sorted sets; a randomized alternative to balanced trees |
| B-tree / B+ tree | search / insert / delete | O(log n), very few disk reads | database indexes, filesystems |
| Suffix array / tree | find a pattern in a text | O(m log n) / O(m) | full-text search, genome matching |
| Bloom filter | add / "might contain" | O(k) for k hashes | skip expensive lookups: caches, databases, crawlers |
| A* search | shortest path with a heuristic | depends on the heuristic | maps, games (Dijkstra + a guide toward the goal) |

## When to use it

- **Range queries AND updates on an array** → segment tree or Fenwick tree
- **Only range queries, no updates** → prefix sums are enough
- **Huge sorted data on disk** → B+ tree
- **"Is it in the set?" where memory matters and false positives are OK** → Bloom filter
- **Search many patterns in one big text** → suffix array / suffix tree
- **Shortest path where you know roughly where the goal is** → A*

## Common traps

- Reaching for a segment tree when prefix sums or a sorted list would do
- Claiming a Bloom filter can delete items or never errs: plain Bloom filters can't delete and do give false positives
- Fenwick trees are 1-based: index 0 breaks the `i & -i` loop
- Mixing up B-trees (disk, many keys per node) with binary search trees
- Saying A* is always faster than Dijkstra: only with a good admissible heuristic
