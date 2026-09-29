## Core idea

**Sometimes what a node must return to its parent is different from the answer to the question.** Diameter returns *height* but the answer is *left height + right height* at the best node. Keep the answer in a separate variable, updated as you go, and return what the parent needs.

## Intuition

Every path in a tree has exactly one highest node, where it "turns": it comes up one side and goes down the other. So to find the longest path, stand at each node and ask: "how deep does it go on my left, and on my right?" That's the longest path turning here.

But your parent can't use a path that turns at you; it can only extend a path that goes *straight up through* you. So you report upward only the deeper of your two sides. Two different quantities: one for the global answer, one for the parent.

## Visualization

Diameter: return heights, track the best turn:

```viz
diameter
```

Lowest common ancestor: results bubble up; the first node that hears from both sides is the answer:

```viz
lca
```

## Template code

```python
# Diameter: return height, update a global best
best = 0
def height(n):
    nonlocal best
    if not n:
        return 0
    l, r = height(n.left), height(n.right)
    best = max(best, l + r)              # path turning at n
    return 1 + max(l, r)                 # what the parent can extend

# Balanced check in one pass: return -1 to signal "unbalanced"
def h(n):
    if not n: return 0
    l, r = h(n.left), h(n.right)
    if l < 0 or r < 0 or abs(l - r) > 1: return -1
    return 1 + max(l, r)

# Max path sum: drop negative branches
def gain(n):
    nonlocal best
    if not n: return 0
    l, r = max(gain(n.left), 0), max(gain(n.right), 0)
    best = max(best, n.val + l + r)
    return n.val + max(l, r)

# Pass state DOWN instead (good nodes: max so far on the path)
def good(n, mx):
    if not n: return 0
    return (n.val >= mx) + good(n.left, max(mx, n.val)) + good(n.right, max(mx, n.val))

# LCA: return a found target or None; both sides non-None → this node
def lca(n):
    if not n or n is p or n is q: return n
    l, r = lca(n.left), lca(n.right)
    return n if l and r else l or r
```

## Complexity

All of these visit each node once: **O(n) time, O(h) space**. The naive versions (computing heights separately at every node) are O(n²) on skewed trees.

## When to use it

- **"Longest path between any two nodes" (diameter, max path sum)** → return one-sided value, track two-sided best
- **"Is the tree balanced"** → return height, or −1 as a failure signal
- **Condition depends on ancestors (good nodes, ranges)** → pass state down as parameters
- **"Lowest common ancestor"** → return what you found; the split point is the answer
- **Build a tree from traversals** → preorder gives roots, inorder splits left/right

## Common traps

- Returning the diameter instead of the height from the recursive function
- Max path sum: forgetting that a branch with a negative sum should be dropped (use 0)
- Max path sum with all-negative values: initialise the answer to −∞, not 0
- Recomputing height inside isBalanced at every node: O(n²)
- Diameter counts edges, not nodes
