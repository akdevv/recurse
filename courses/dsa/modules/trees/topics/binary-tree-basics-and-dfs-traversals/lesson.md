## Core idea

**A binary tree is a node with a value and up to two children, each of which is again a binary tree.** Because the definition is recursive, most tree solutions are too: handle the empty tree, ask the left and right subtrees for their answers, combine them at the node.

## Intuition

A family tree, an org chart, folders inside folders. Words to know:
- **root**: the top node; **leaf**: a node with no children
- **depth** of a node: edges from the root down to it; **height** of a tree: the longest root-to-leaf path
- **subtree**: any node together with everything below it

"Ask the children, combine" is like a manager asking each of their two team leads "how many people are under you?", adding them up, and counting themselves.

## Visualization

One depth-first walk visits each node three times: before its children (pre), between them (in) and after them (post):

```viz
traversals
```

Max depth by asking the children:

```viz
max-depth
```

## Template code

```python
class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val, self.left, self.right = val, left, right

# The recursive shape of almost every tree solution
def solve(node):
    if not node:
        return BASE                       # empty tree
    left, right = solve(node.left), solve(node.right)
    return combine(node.val, left, right)

def max_depth(n):
    return 0 if not n else 1 + max(max_depth(n.left), max_depth(n.right))

def same(a, b):
    if not a or not b:
        return a is b                     # both None → True
    return a.val == b.val and same(a.left, b.left) and same(a.right, b.right)

# Traversals
def preorder(n):  return [n.val] + preorder(n.left) + preorder(n.right) if n else []
def inorder(n):   return inorder(n.left) + [n.val] + inorder(n.right) if n else []
def postorder(n): return postorder(n.left) + postorder(n.right) + [n.val] if n else []

# Iterative inorder with an explicit stack
out, stack, cur = [], [], root
while cur or stack:
    while cur:
        stack.append(cur); cur = cur.left
    cur = stack.pop()
    out.append(cur.val)
    cur = cur.right
```

## Complexity

| Task | Time | Space |
|---|---|---|
| any full traversal | O(n) | O(h) recursion (h = height) |
| balanced tree height | – | h = O(log n) |
| skewed tree (a "linked list") | – | h = O(n) |

## When to use it

- **Anything computed from both subtrees (depth, size, sum, same/symmetric)** → recursive DFS, postorder style
- **Copy a tree, serialize it, root-first processing** → preorder
- **BST in sorted order** → inorder
- **Delete a tree, compute children before the parent** → postorder
- **Path from root to leaf (path sum, all paths)** → pass the running state down as an argument
- **Very deep trees in Python** → iterative with a stack (default recursion limit is 1000)

## Common traps

- Forgetting the `None` base case
- Path Sum: a node with one child is not a leaf; only nodes with no children end a path
- Symmetric Tree: compare left.left with right.right (outer) and left.right with right.left (inner)
- Mixing up depth (from the top) and height (from the bottom)
- Building lists with `+` in every call is fine for learning but O(n²) on skewed trees; append to a shared list for speed
