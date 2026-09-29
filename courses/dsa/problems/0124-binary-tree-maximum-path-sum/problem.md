---
lc: 124
title: "Binary Tree Maximum Path Sum"
difficulty: "Hard"
patterns: ["tree-dfs"]
lcTags: ["dynamic-programming", "tree", "depth-first-search", "binary-tree", "dp-on-trees"]
entry: {"method": "maxPathSum", "params": [{"name": "root", "type": "TreeNode"}], "returns": "integer"}
examples: ["[1,2,3]", "[-10,9,20,null,null,15,7]"]
---

A **path** in a binary tree is a sequence of nodes where each pair of adjacent nodes in the sequence has an edge connecting them. A node can only appear in the sequence **at most once**. Note that the path does not need to pass through the root.

The **path sum** of a path is the sum of the node's values in the path.

Given the `root` of a binary tree, return *the maximum **path sum** of any **non-empty** path*.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/10/13/exx1.jpg)

```
Input: root = [1,2,3]
Output: 6
Explanation: The optimal path is 2 -> 1 -> 3 with a path sum of 2 + 1 + 3 = 6.
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2020/10/13/exx2.jpg)

```
Input: root = [-10,9,20,null,null,15,7]
Output: 42
Explanation: The optimal path is 15 -> 20 -> 7 with a path sum of 15 + 20 + 7 = 42.
```

**Constraints:**

- The number of nodes in the tree is in the range `[1, 3 * 10⁴]`.
- `-1000 <= Node.val <= 1000`

# Starter

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def maxPathSum(self, root: TreeNode | None) -> int:
        
```

# Hints

1. Like Diameter: at each node the best path bending through it = node + best gain from left + best gain from right.
2. gain(node) returns node.val + max(0, left gain, right gain) (a path going up can use only one side). Update a global best with node.val + max(0, left) + max(0, right).

# Key points

- return value: best downward path from this node (one side only)
- global answer: path that bends at this node (both sides)
- drop negative gains with max(0, …)
- O(n) time; the answer can be negative (all-negative tree)

# Solution: recursion · Recursion · O(n) · O(n) · reference

When thinking about the classic routine of recursion problems in binary trees, we consider:

1. Termination condition (when to terminate recursion)
2. Recursively process the left and right subtrees
3. Merge the calculation results of the left and right subtrees

For this problem, we design a function `dfs(root)`, which returns the maximum path sum of the binary tree with root as the root node.

The execution logic of the function `dfs(root)` is as follows:

If root does not exist, then `dfs(root)` returns 0;

Otherwise, we recursively calculate the maximum path sum of the left and right subtrees of root, denoted as left and right. If left is less than 0, then we set it to 0, similarly, if right is less than 0, then we set it to 0.

Then, we update the answer with `root.val + left + right`. Finally, the function returns `root.val + max(left, right)`.

In the main function, we call `dfs(root)` to get the maximum path sum of each node, and the maximum value among them is the answer.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def maxPathSum(self, root: Optional[TreeNode]) -> int:
        def dfs(root: Optional[TreeNode]) -> int:
            if root is None:
                return 0
            left = max(0, dfs(root.left))
            right = max(0, dfs(root.right))
            nonlocal ans
            ans = max(ans, root.val + left + right)
            return root.val + max(left, right)

        ans = -inf
        dfs(root)
        return ans
```

# Tests

```python

```
