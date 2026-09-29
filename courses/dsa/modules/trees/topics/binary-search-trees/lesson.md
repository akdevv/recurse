## Core idea

**In a binary search tree, everything in a node's left subtree is smaller than it and everything in its right subtree is bigger.** One comparison at each node tells you which side to go, so search, insert and delete take O(h), and an inorder traversal visits values in sorted order.

## Intuition

Binary search, built into the shape of the tree. Looking for 7 at a node holding 8? It can only be on the left, so you ignore the entire right subtree.

The rule is about **all** descendants, not just direct children. A 2 can't sit anywhere in the right subtree of 5, even if its own parent is 6. That's the classic bug when validating a BST.

## Visualization

Search: one path from the root, the rest is skipped:

```viz
bst-search
```

Validation: pass down the allowed range from the ancestors:

```viz
validate
```

## Template code

```python
# Search (iterative, O(1) space)
n = root
while n and n.val != target:
    n = n.left if target < n.val else n.right
return n

# Insert: walk down, attach a new leaf where the search falls off
def insert(n, v):
    if not n:
        return TreeNode(v)
    if v < n.val: n.left = insert(n.left, v)
    else:         n.right = insert(n.right, v)
    return n

# Validate with bounds
def valid(n, lo=float("-inf"), hi=float("inf")):
    if not n: return True
    return lo < n.val < hi and valid(n.left, lo, n.val) and valid(n.right, n.val, hi)

# Inorder = sorted: k-th smallest, min difference between neighbours
stack, cur = [], root
while cur or stack:
    while cur: stack.append(cur); cur = cur.left
    cur = stack.pop()
    k -= 1
    if k == 0: return cur.val
    cur = cur.right

# LCA in a BST: the first node where p and q split
while True:
    if p.val < n.val and q.val < n.val:   n = n.left
    elif p.val > n.val and q.val > n.val: n = n.right
    else: return n

# Sorted array → balanced BST: middle element as root, recurse on halves
```

## Complexity

| Operation | Balanced BST | Skewed BST |
|---|---|---|
| search / insert / delete | O(log n) | O(n) |
| min / max | O(log n) | O(n) |
| inorder traversal | O(n) | O(n) |

Delete has three cases: a leaf (just remove), one child (replace with the child), two children (copy the inorder successor, the smallest value in the right subtree, then delete it there).

## When to use it

- **"Search / insert / delete in a BST"** → walk one path using the ordering
- **"k-th smallest", "sorted order", "closest values"** → inorder traversal
- **"Is this a valid BST"** → ranges passed down (or inorder strictly increasing)
- **LCA in a BST** → no need to search both sides: follow the values
- **Build a balanced BST from sorted data** → middle as root

## Common traps

- Validating by comparing only with direct children
- Allowing duplicates when the problem says strictly less/greater
- Using `0` or `2³¹` as default bounds: node values can be exactly those; use `None` or ±infinity
- Deleting a node with two children by just unlinking it
- Assuming O(log n): a BST built from sorted input is a linked list (see Balanced trees)
