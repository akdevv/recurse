## Core idea

**A BST is only fast if it stays short. Balanced trees (AVL, red-black) restructure themselves with small local "rotations" after inserts and deletes, keeping the height O(log n) no matter what order the data arrives in.** You won't implement one in an interview, but you should be able to explain why they exist and roughly how they work.

## Intuition

Insert 1, 2, 3, 4, 5 into a plain BST and every value goes to the right: you've built a linked list, and search is O(n). A balanced tree notices the lopsidedness and rotates: the middle node moves up, the heavy side moves down, and the BST ordering is kept.

Think of a mobile hanging from the ceiling. When one side gets too heavy, you re-hang it from a different point so it balances again. You don't rebuild the whole thing, you adjust near the problem.

## Visualization

Sorted inserts make a plain BST degenerate:

```viz
degenerate
```

A single rotation fixes a left-left imbalance in O(1):

```viz
rotation
```

## Template code

```python
# Right rotation around y (left-left case). Returns the new subtree root.
def rotate_right(y):
    x = y.left
    y.left = x.right          # x's right subtree moves under y
    x.right = y               # y moves down to the right
    return x                  # x is the new root of this subtree

# AVL balance factor: height(left) - height(right) must stay in {-1, 0, 1}
# Four imbalance cases after an insert:
#   left-left   → rotate_right(node)
#   right-right → rotate_left(node)
#   left-right  → rotate_left(node.left), then rotate_right(node)
#   right-left  → rotate_right(node.right), then rotate_left(node)

# In Python you'd use a library instead:
#   sortedcontainers.SortedList  (not a tree, but O(log n)-ish sorted operations)
#   or bisect on a list for small data
```

## Complexity

| Structure | Search / insert / delete | Notes |
|---|---|---|
| plain BST | O(h): O(log n) to **O(n)** | depends on insert order |
| AVL tree | O(log n) guaranteed | strictly balanced, faster lookups, more rotations |
| red-black tree | O(log n) guaranteed | looser balance, fewer rotations; used by Java's TreeMap, C++ std::map |
| B-tree / B+ tree | O(log n) | many keys per node, few disk reads; used by databases and filesystems |

## When to use it

- **Need a sorted map with fast insert/delete/search** → a balanced tree (TreeMap, std::map, SortedList)
- **Interview asks "what if the BST becomes skewed?"** → explain rotations and O(log n) guarantees
- **Database indexes** → B+ trees: wide nodes, shallow tree, few disk reads
- **Only lookups, no ordering needed** → a hash map is simpler and O(1) on average

## Common traps

- Claiming every BST operation is O(log n): only for balanced trees
- Confusing "balanced" (height O(log n)) with "complete" or "perfect" trees
- Forgetting that a rotation must keep the BST ordering (x.right moves under y)
- Saying Python has a built-in balanced tree: it doesn't (`dict` is a hash map; `heapq` is a heap)
