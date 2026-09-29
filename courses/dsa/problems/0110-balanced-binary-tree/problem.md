---
lc: 110
title: "Balanced Binary Tree"
difficulty: "Easy"
patterns: ["tree-dfs"]
lcTags: ["tree", "depth-first-search", "binary-tree"]
entry: {"method": "isBalanced", "params": [{"name": "root", "type": "TreeNode"}], "returns": "boolean"}
examples: ["[3,9,20,null,null,15,7]", "[1,2,2,3,3,null,null,4,4]", "[]"]
---

Given a binary tree, determine if it is **height-balanced**.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/10/06/balance_1.jpg)

```
Input: root = [3,9,20,null,null,15,7]
Output: true
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2020/10/06/balance_2.jpg)

```
Input: root = [1,2,2,3,3,null,null,4,4]
Output: false
```

**Example 3:**

```
Input: root = []
Output: true
```

**Constraints:**

- The number of nodes in the tree is in the range `[0, 5000]`.
- `-10⁴ <= Node.val <= 10⁴`

# Starter

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def isBalanced(self, root: TreeNode | None) -> bool:
        
```

# Hints

1. Computing heights separately for every node is O(n²). Can one DFS return the height and report imbalance?
2. height(node) returns −1 if the subtree is unbalanced. Otherwise compute both child heights; if either is −1 or they differ by more than 1, return −1; else 1 + max.

# Key points

- bottom-up: each call returns the height or a failure marker
- stop early once a subtree is unbalanced
- O(n) time vs O(n²) top-down

# Solution: bottom-up-recursion · Bottom-Up Recursion · O(n) · O(n) · reference

We define a function `height(root)` to calculate the height of a binary tree, with the following logic:

- If the binary tree root is null, return 0.
- Otherwise, recursively calculate the heights of the left and right subtrees, denoted as l and r respectively. If either l or r is -1, or the absolute difference between l and r is greater than 1, then return -1. Otherwise, return `max(l, r) + 1`.

Therefore, if the function `height(root)` returns -1, it means the binary tree root is not balanced. Otherwise, it is balanced.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def isBalanced(self, root: Optional[TreeNode]) -> bool:
        def height(root):
            if root is None:
                return 0
            l, r = height(root.left), height(root.right)
            if l == -1 or r == -1 or abs(l - r) > 1:
                return -1
            return 1 + max(l, r)

        return height(root) >= 0
```

# Tests

```python

```
