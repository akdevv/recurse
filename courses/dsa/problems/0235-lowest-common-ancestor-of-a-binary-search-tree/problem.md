---
lc: 235
title: "Lowest Common Ancestor of a Binary Search Tree"
difficulty: "Medium"
patterns: ["tree-dfs", "binary-search"]
lcTags: ["tree", "depth-first-search", "binary-search-tree", "binary-tree", "binary-lifting", "lowest-common-ancestor"]
entry: {"method": "lowestCommonAncestor", "params": [{"name": "root", "type": "TreeNode"}, {"name": "p", "type": "integer"}, {"name": "q", "type": "integer"}], "returns": "TreeNode", "interactive": true}
examples: ["[6,2,8,0,4,7,9,null,null,3,5]\n2\n8", "[6,2,8,0,4,7,9,null,null,3,5]\n2\n4", "[2,1]\n2\n1"]
---

Given a binary search tree (BST), find the lowest common ancestor (LCA) node of two given nodes in the BST.

According to the [definition of LCA on Wikipedia](https://en.wikipedia.org/wiki/Lowest_common_ancestor): “The lowest common ancestor is defined between two nodes `p` and `q` as the lowest node in `T` that has both `p` and `q` as descendants (where we allow **a node to be a descendant of itself**).”

**Example 1:**

![](https://assets.leetcode.com/uploads/2018/12/14/binarysearchtree_improved.png)

```
Input: root = [6,2,8,0,4,7,9,null,null,3,5], p = 2, q = 8
Output: 6
Explanation: The LCA of nodes 2 and 8 is 6.
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2018/12/14/binarysearchtree_improved.png)

```
Input: root = [6,2,8,0,4,7,9,null,null,3,5], p = 2, q = 4
Output: 2
Explanation: The LCA of nodes 2 and 4 is 2, since a node can be a descendant of itself according to the LCA definition.
```

**Example 3:**

```
Input: root = [2,1], p = 2, q = 1
Output: 2
```

**Constraints:**

- The number of nodes in the tree is in the range `[2, 10⁵]`.
- `-10⁹ <= Node.val <= 10⁹`
- All `Node.val` are **unique**.
- `p != q`
- `p` and `q` will exist in the BST.

# Starter

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, x):
#         self.val = x
#         self.left = None
#         self.right = None

class Solution:
    def lowestCommonAncestor(self, root: 'TreeNode', p: 'TreeNode', q: 'TreeNode') -> 'TreeNode':
        
```

# Hints

1. Use the BST property: if both p and q are smaller than the node, the LCA is on the left.
2. Walk from the root: both smaller → go left; both larger → go right; otherwise (they split, or one equals the node) this node is the LCA.

# Key points

- the LCA is the first node where p and q fall on different sides
- no need to search both subtrees: O(h) time, O(1) space iteratively
- the tests pass p and q as values and check the returned node's value

# Solution: iteration · Iteration · O(n) · O(1) · reference

Starting from the root node, we traverse the tree. If the current node's value is less than both p and q values, it means that p and q should be in the right subtree of the current node, so we move to the right child. If the current node's value is greater than both p and q values, it means that p and q should be in the left subtree, so we move to the left child. Otherwise, it means the current node is the lowest common ancestor of p and q, so we return the current node.

The time complexity is O(n), where n is the number of nodes in the binary search tree. The space complexity is O(1).

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, x):
#         self.val = x
#         self.left = None
#         self.right = None

class Solution:
    def lowestCommonAncestor(
        self, root: 'TreeNode', p: 'TreeNode', q: 'TreeNode'
    ) -> 'TreeNode':
        while 1:
            if root.val < min(p.val, q.val):
                root = root.right
            elif root.val > max(p.val, q.val):
                root = root.left
            else:
                return root
```

# Solution: recursion · Recursion · O(n) · O(n)

We can also use a recursive approach to solve this problem.

We first check if the current node's value is less than both p and q values. If it is, we recursively traverse the right subtree. If the current node's value is greater than both p and q values, we recursively traverse the left subtree. Otherwise, it means the current node is the lowest common ancestor of p and q, so we return the current node.

The time complexity is O(n), and the space complexity is O(n). Where n is the number of nodes in the binary search tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, x):
#         self.val = x
#         self.left = None
#         self.right = None

class Solution:
    def lowestCommonAncestor(
        self, root: 'TreeNode', p: 'TreeNode', q: 'TreeNode'
    ) -> 'TreeNode':
        if root.val < min(p.val, q.val):
            return self.lowestCommonAncestor(root.right, p, q)
        if root.val > max(p.val, q.val):
            return self.lowestCommonAncestor(root.left, p, q)
        return root
```

# Tests

```python
def prepare(args):
    vals, p, q = args
    root = to_tree(vals)
    found, stack = {}, [root]
    while stack:
        n = stack.pop()
        if n:
            found[n.val] = n
            stack += [n.left, n.right]
    return [root, found[p], found[q]], {}

def output(ret):
    return ret.val if ret else None

def bst(vals):
    root = None
    def ins(node, v):
        if node is None:
            return [v, None, None]
        if v < node[0]:
            node[1] = ins(node[1], v)
        else:
            node[2] = ins(node[2], v)
        return node
    for v in vals:
        root = ins(root, v)
    out, q = [], [root]
    while q:
        n = q.pop(0)
        out.append(n[0] if n else None)
        if n:
            q += [n[1], n[2]]
    while out[-1] is None:
        out.pop()
    return out

def edge():
    t = [6, 2, 8, 0, 4, 7, 9, None, None, 3, 5]
    return [[t, 2, 8], [t, 2, 4], [t, 3, 5], [[2, 1], 2, 1]]

def random_case(rng):
    vals = rng.sample(range(-30, 30), rng.randint(2, 12))
    p, q = rng.sample(vals, 2)
    return [bst(vals), p, q]

def perf(rng):
    vals = rng.sample(range(-10**9, 10**9), 100000)
    return [[bst(vals), vals[-1], vals[-2]]]
```
