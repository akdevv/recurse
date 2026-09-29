---
lc: 112
title: "Path Sum"
difficulty: "Easy"
patterns: ["tree-dfs"]
lcTags: ["tree", "depth-first-search", "breadth-first-search", "binary-tree"]
entry: {"method": "hasPathSum", "params": [{"name": "root", "type": "TreeNode"}, {"name": "targetSum", "type": "integer"}], "returns": "boolean"}
examples: ["[5,4,8,11,null,13,4,7,2,null,null,null,1]\n22", "[1,2,3]\n5", "[]\n0"]
---

Given the `root` of a binary tree and an integer `targetSum`, return `true` if the tree has a **root-to-leaf** path such that adding up all the values along the path equals `targetSum`.

A **leaf** is a node with no children.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/01/18/pathsum1.jpg)

```
Input: root = [5,4,8,11,null,13,4,7,2,null,null,null,1], targetSum = 22
Output: true
Explanation: The root-to-leaf path with the target sum is shown.
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2021/01/18/pathsum2.jpg)

```
Input: root = [1,2,3], targetSum = 5
Output: false
Explanation: There are two root-to-leaf paths in the tree:
(1 --> 2): The sum is 3.
(1 --> 3): The sum is 4.
There is no root-to-leaf path with sum = 5.
```

**Example 3:**

```
Input: root = [], targetSum = 0
Output: false
Explanation: Since the tree is empty, there are no root-to-leaf paths.
```

**Constraints:**

- The number of nodes in the tree is in the range `[0, 5000]`.
- `-1000 <= Node.val <= 1000`
- `-1000 <= targetSum <= 1000`

# Starter

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def hasPathSum(self, root: TreeNode | None, targetSum: int) -> bool:
        
```

# Hints

1. Subtract each node's value from the target as you go down. What must be true at a leaf?
2. hasPathSum(node, t): None → False; leaf → t == node.val; else recurse on both children with t − node.val.

# Key points

- pass the remaining sum down the recursion
- only leaves can end a path (a node with one child is not a leaf)
- empty tree → False
- O(n) time

# Solution: recursion · Recursion · O(n) · O(h) · reference

Starting from the root node, recursively traverse the tree and update the value of the node to the path sum from the root node to that node. When you traverse to a leaf node, determine whether this path sum is equal to the target value. If it is equal, return `true`, otherwise return `false`.

The time complexity is O(n), where n is the number of nodes in the binary tree. Each node is visited once.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def hasPathSum(self, root: Optional[TreeNode], targetSum: int) -> bool:
        def dfs(root, s):
            if root is None:
                return False
            s += root.val
            if root.left is None and root.right is None and s == targetSum:
                return True
            return dfs(root.left, s) or dfs(root.right, s)

        return dfs(root, 0)
```

# Tests

```python

```
