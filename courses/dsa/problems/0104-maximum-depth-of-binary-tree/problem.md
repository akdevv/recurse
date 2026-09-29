---
lc: 104
title: "Maximum Depth of Binary Tree"
difficulty: "Easy"
patterns: ["tree-dfs"]
lcTags: ["tree", "depth-first-search", "breadth-first-search", "binary-tree"]
entry: {"method": "maxDepth", "params": [{"name": "root", "type": "TreeNode"}], "returns": "integer"}
examples: ["[3,9,20,null,null,15,7]", "[1,null,2]"]
---

Given the `root` of a binary tree, return *its maximum depth*.

A binary tree's **maximum depth** is the number of nodes along the longest path from the root node down to the farthest leaf node.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/11/26/tmp-tree.jpg)

```
Input: root = [3,9,20,null,null,15,7]
Output: 3
```

**Example 2:**

```
Input: root = [1,null,2]
Output: 2
```

**Constraints:**

- The number of nodes in the tree is in the range `[0, 10⁴]`.
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
    def maxDepth(self, root: TreeNode | None) -> int:
        
```

# Hints

1. The depth of a tree is 1 + the depth of its deeper subtree.
2. depth(None) = 0; depth(node) = 1 + max(depth(left), depth(right)). BFS counting levels also works.

# Key points

- recursion: ask both children, combine with 1 + max
- empty tree has depth 0
- O(n) time, O(h) space

# Solution: recursion · Recursion · O(n) · O(h) · reference

Recursively traverse the left and right subtrees, calculate the maximum depth of the left and right subtrees, and then take the maximum value plus 1.

The time complexity is O(n), where n is the number of nodes in the binary tree. Each node is traversed only once in the recursion.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def maxDepth(self, root: TreeNode) -> int:
        if root is None:
            return 0
        l, r = self.maxDepth(root.left), self.maxDepth(root.right)
        return 1 + max(l, r)
```

# Tests

```python

```
