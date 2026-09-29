---
lc: 700
title: "Search in a Binary Search Tree"
difficulty: "Easy"
patterns: ["binary-search"]
lcTags: ["tree", "binary-search-tree", "binary-tree"]
entry: {"method": "searchBST", "params": [{"name": "root", "type": "TreeNode"}, {"name": "val", "type": "integer"}], "returns": "TreeNode"}
examples: ["[4,2,7,1,3]\n2", "[4,2,7,1,3]\n5"]
---

You are given the `root` of a binary search tree (BST) and an integer `val`.

Find the node in the BST that the node's value equals `val` and return the subtree rooted with that node. If such a node does not exist, return `null`.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/01/12/tree1.jpg)

```
Input: root = [4,2,7,1,3], val = 2
Output: [2,1,3]
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2021/01/12/tree2.jpg)

```
Input: root = [4,2,7,1,3], val = 5
Output: []
```

**Constraints:**

- The number of nodes in the tree is in the range `[1, 5000]`.
- `1 <= Node.val <= 10⁷`
- `root` is a binary search tree.
- `1 <= val <= 10⁷`

# Starter

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def searchBST(self, root: TreeNode | None, val: int) -> TreeNode | None:
        
```

# Hints

1. In a BST, smaller values are always on the left. Compare val with the current node to know which way to go.
2. Loop: if node.val == val return node; go left if val < node.val, else right. Return None if you fall off.

# Key points

- BST property decides the direction at every node
- O(h) time: O(log n) balanced, O(n) skewed
- iterative version uses O(1) space

# Solution: recursion · Recursion · O(n) · O(n) · reference

We check if the current node is null or if the current node's value equals the target value. If so, we return the current node.

Otherwise, if the current node's value is greater than the target value, we recursively search the left subtree; otherwise, we recursively search the right subtree.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def searchBST(self, root: Optional[TreeNode], val: int) -> Optional[TreeNode]:
        if root is None or root.val == val:
            return root
        return (
            self.searchBST(root.left, val)
            if root.val > val
            else self.searchBST(root.right, val)
        )
```

# Tests

```python
def bst(rng, vals):
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
    return [[[4, 2, 7, 1, 3], 2], [[4, 2, 7, 1, 3], 5], [[1], 1], [[1], 2]]

def random_case(rng):
    vals = rng.sample(range(1, 30), rng.randint(1, 10))
    return [bst(rng, vals), rng.choice(vals) if rng.random() < 0.6 else rng.randint(1, 31)]
```
