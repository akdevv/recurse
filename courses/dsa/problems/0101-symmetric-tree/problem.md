---
lc: 101
title: "Symmetric Tree"
difficulty: "Easy"
patterns: ["tree-dfs"]
lcTags: ["tree", "depth-first-search", "breadth-first-search", "binary-tree"]
entry: {"method": "isSymmetric", "params": [{"name": "root", "type": "TreeNode"}], "returns": "boolean"}
examples: ["[1,2,2,3,4,4,3]", "[1,2,2,null,3,null,3]"]
---

Given the `root` of a binary tree, *check whether it is a mirror of itself* (i.e., symmetric around its center).

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/02/19/symtree1.jpg)

```
Input: root = [1,2,2,3,4,4,3]
Output: true
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2021/02/19/symtree2.jpg)

```
Input: root = [1,2,2,null,3,null,3]
Output: false
```

**Constraints:**

- The number of nodes in the tree is in the range `[1, 1000]`.
- `-100 <= Node.val <= 100`

**Follow up:** Could you solve it both recursively and iteratively?

# Starter

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def isSymmetric(self, root: TreeNode | None) -> bool:
        
```

# Hints

1. A tree is symmetric if its left subtree is a mirror of its right subtree.
2. mirror(a, b): both None → True; one None or a.val != b.val → False; else mirror(a.left, b.right) and mirror(a.right, b.left).

# Key points

- compare two subtrees as mirrors: outer pair and inner pair
- iterative version: a queue of node pairs
- O(n) time

# Solution: recursion · Recursion · O(n) · O(n) · reference

We design a function `dfs(root1, root2)` to determine whether two binary trees are symmetric. The answer is `dfs(root.left, root.right)`.

The logic of the function `dfs(root1, root2)` is as follows:

- If both root1 and root2 are null, the two binary trees are symmetric, and we return `true`;
- If only one of root1 and root2 is null, or `root1.val != root2.val`, we return `false`;
- Otherwise, we check whether the left subtree of root1 is symmetric with the right subtree of root2, and whether the right subtree of root1 is symmetric with the left subtree of root2, using recursion.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def isSymmetric(self, root: Optional[TreeNode]) -> bool:
        def dfs(root1: Optional[TreeNode], root2: Optional[TreeNode]) -> bool:
            if root1 == root2:
                return True
            if root1 is None or root2 is None or root1.val != root2.val:
                return False
            return dfs(root1.left, root2.right) and dfs(root1.right, root2.left)

        return dfs(root.left, root.right)
```

# Tests

```python

```
