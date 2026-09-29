---
lc: 236
title: "Lowest Common Ancestor of a Binary Tree"
difficulty: "Medium"
patterns: ["tree-dfs"]
lcTags: ["tree", "depth-first-search", "binary-tree", "binary-lifting", "lowest-common-ancestor"]
entry: {"method": "lowestCommonAncestor", "params": [{"name": "root", "type": "TreeNode"}, {"name": "p", "type": "integer"}, {"name": "q", "type": "integer"}], "returns": "TreeNode", "interactive": true}
examples: ["[3,5,1,6,2,0,8,null,null,7,4]\n5\n1", "[3,5,1,6,2,0,8,null,null,7,4]\n5\n4", "[1,2]\n1\n2"]
---

Given a binary tree, find the lowest common ancestor (LCA) of two given nodes in the tree.

According to the [definition of LCA on Wikipedia](https://en.wikipedia.org/wiki/Lowest_common_ancestor): “The lowest common ancestor is defined between two nodes `p` and `q` as the lowest node in `T` that has both `p` and `q` as descendants (where we allow **a node to be a descendant of itself**).”

**Example 1:**

![](https://assets.leetcode.com/uploads/2018/12/14/binarytree.png)

```
Input: root = [3,5,1,6,2,0,8,null,null,7,4], p = 5, q = 1
Output: 3
Explanation: The LCA of nodes 5 and 1 is 3.
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2018/12/14/binarytree.png)

```
Input: root = [3,5,1,6,2,0,8,null,null,7,4], p = 5, q = 4
Output: 5
Explanation: The LCA of nodes 5 and 4 is 5, since a node can be a descendant of itself according to the LCA definition.
```

**Example 3:**

```
Input: root = [1,2], p = 1, q = 2
Output: 1
```

**Constraints:**

- The number of nodes in the tree is in the range `[2, 10⁵]`.
- `-10⁹ <= Node.val <= 10⁹`
- All `Node.val` are **unique**.
- `p != q`
- `p` and `q` will exist in the tree.

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

1. Ask each subtree: "did you find p or q?" What does it mean if both the left and the right answer yes?
2. lca(node): if node is None, p or q, return node. Recurse left and right. If both are non-None, node is the LCA; otherwise return whichever is non-None.

# Key points

- postorder: results bubble up from the children
- both sides found something → current node is the split point = LCA
- a node can be its own ancestor (p above q)
- O(n) time, O(h) space; the tests pass p and q as values and check the returned node's value

# Solution: recursion · Recursion · O(n) · O(n) · reference

We recursively traverse the binary tree:

If the current node is null or equals to p or q, then we return the current node;

Otherwise, we recursively traverse the left and right subtrees, and record the returned results as left and right. If both left and right are not null, it means that p and q are in the left and right subtrees respectively, so the current node is the nearest common ancestor; If only one of left and right is not null, we return the one that is not null.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, x):
#         self.val = x
#         self.left = None
#         self.right = None

class Solution:
    def lowestCommonAncestor(
        self, root: "TreeNode", p: "TreeNode", q: "TreeNode"
    ) -> "TreeNode":
        if root in (None, p, q):
            return root
        left = self.lowestCommonAncestor(root.left, p, q)
        right = self.lowestCommonAncestor(root.right, p, q)
        return root if left and right else (left or right)
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

def tree(rng, n):
    vals = rng.sample(range(-20, 21), n)
    out, slots, i = [vals[0]], 2, 1
    while i < n:
        if slots > 1 and rng.random() < 0.3:
            out.append(None); slots -= 1
        else:
            out.append(vals[i]); i += 1; slots += 1
    while out[-1] is None:
        out.pop()
    return out, vals

def edge():
    return [[[3, 5, 1, 6, 2, 0, 8, None, None, 7, 4], 5, 1], [[3, 5, 1, 6, 2, 0, 8, None, None, 7, 4], 5, 4], [[1, 2], 1, 2], [[1, None, 2], 2, 1]]

def random_case(rng):
    t, vals = tree(rng, rng.randint(2, 12))
    p, q = rng.sample(vals, 2)
    return [t, p, q]

def perf(rng):
    n = 100000
    return [[list(range(n)), n - 1, n - 2]]
```
