---
lc: 226
title: "Invert Binary Tree"
difficulty: "Easy"
patterns: ["tree-dfs"]
lcTags: ["tree", "depth-first-search", "breadth-first-search", "binary-tree"]
entry: {"method": "invertTree", "params": [{"name": "root", "type": "TreeNode"}], "returns": "TreeNode"}
examples: ["[4,2,7,1,3,6,9]", "[2,1,3]", "[]"]
---

Given the `root` of a binary tree, invert the tree, and return *its root*.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/03/14/invert1-tree.jpg)

```
Input: root = [4,2,7,1,3,6,9]
Output: [4,7,2,9,6,3,1]
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2021/03/14/invert2-tree.jpg)

```
Input: root = [2,1,3]
Output: [2,3,1]
```

**Example 3:**

```
Input: root = []
Output: []
```

**Constraints:**

- The number of nodes in the tree is in the range `[0, 100]`.
- `-100 <= Node.val <= 100`

# Starter

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def invertTree(self, root: TreeNode | None) -> TreeNode | None:
        
```

# Hints

1. Inverting a tree = swap the children of every node.
2. Recursively invert the left and right subtrees, then swap them (or swap first, then recurse).

# Key points

- visit every node, swap left and right
- any traversal order works (pre, post, BFS)
- O(n) time, O(h) space

# Solution: recursion · Recursion · O(n) · O(n) · reference

First, we check if root is null. If it is, we return null. Then, we recursively invert the left and right subtrees, set the inverted right subtree as the new left subtree, and set the inverted left subtree as the new right subtree. Finally, we return root.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def invertTree(self, root: Optional[TreeNode]) -> Optional[TreeNode]:
        if root is None:
            return None
        l, r = self.invertTree(root.left), self.invertTree(root.right)
        root.left, root.right = r, l
        return root
```

# Tests

```python

```
