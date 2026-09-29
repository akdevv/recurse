---
lc: 543
title: "Diameter of Binary Tree"
difficulty: "Easy"
patterns: ["tree-dfs"]
lcTags: ["tree", "depth-first-search", "binary-tree", "dp-on-trees"]
entry: {"method": "diameterOfBinaryTree", "params": [{"name": "root", "type": "TreeNode"}], "returns": "integer"}
examples: ["[1,2,3,4,5]", "[1,2]"]
---

Given the `root` of a binary tree, return *the length of the **diameter** of the tree*.

The **diameter** of a binary tree is the **length** of the longest path between any two nodes in a tree. This path may or may not pass through the `root`.

The **length** of a path between two nodes is represented by the number of edges between them.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/03/06/diamtree.jpg)

```
Input: root = [1,2,3,4,5]
Output: 3
Explanation: 3 is the length of the path [4,2,1,3] or [5,2,1,3].
```

**Example 2:**

```
Input: root = [1,2]
Output: 1
```

**Constraints:**

- The number of nodes in the tree is in the range `[1, 10⁴]`.
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
    def diameterOfBinaryTree(self, root: Optional[TreeNode]) -> int:
        
```

# Hints

1. The longest path through a node = depth of its left subtree + depth of its right subtree.
2. One DFS returns each subtree's depth; at each node update a global best with left + right, and return 1 + max(left, right).

# Key points

- the function returns depth, the answer is tracked separately
- diameter through a node = left depth + right depth (in edges)
- the longest path may not pass through the root
- O(n) time

# Solution: enumeration-dfs · Enumeration + DFS · O(n) · O(n) · reference

We can enumerate each node of the binary tree, and for each node, calculate the maximum depth of its left and right subtrees, l and r, respectively. The diameter of the node is `l + r`. The maximum diameter among all nodes is the diameter of the binary tree.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def diameterOfBinaryTree(self, root: TreeNode) -> int:
        def dfs(root):
            if root is None:
                return 0
            nonlocal ans
            left, right = dfs(root.left), dfs(root.right)
            ans = max(ans, left + right)
            return 1 + max(left, right)

        ans = 0
        dfs(root)
        return ans
```

# Tests

```python

```
