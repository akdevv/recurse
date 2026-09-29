---
lc: 257
title: "Binary Tree Paths"
difficulty: "Easy"
patterns: ["tree-dfs", "backtracking"]
lcTags: ["string", "backtracking", "tree", "depth-first-search", "binary-tree"]
compare: "unordered"
entry: {"method": "binaryTreePaths", "params": [{"name": "root", "type": "TreeNode"}], "returns": "list<string>"}
examples: ["[1,2,3,null,5]", "[1]"]
---

You are given the `root` of a binary tree.

Return all **root-to-leaf** paths in **any order**.

A **leaf** is a node with no children.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/03/12/paths-tree.jpg)

```
Input: root = [1,2,3,null,5]
Output: ["1->2->5","1->3"]
```

**Example 2:**

```
Input: root = [1]
Output: ["1"]
```

**Constraints:**

- The number of nodes in the tree is in the range `[1, 100]`.
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
    def binaryTreePaths(self, root: TreeNode | None) -> list[str]:
        
```

# Hints

1. Carry the path from the root down. When do you record it?
2. DFS(node, path): add node.val; at a leaf, join the path with "->" and record; otherwise recurse into the children.

# Key points

- pass the current path down, record at leaves
- O(n·h) time for building the strings

# Solution: dfs · DFS · O(n²) · O(n) · reference

We can use depth-first search to traverse the entire binary tree. Each time, we add the current node to the path. If the current node is a leaf node, we add the entire path to the answer. Otherwise, we continue to recursively traverse the child nodes of the node. Finally, when the recursion ends and returns to the current node, we need to remove the current node from the path.

The time complexity is O(n²), and the space complexity is O(n). Where n is the number of nodes in the binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def binaryTreePaths(self, root: Optional[TreeNode]) -> List[str]:
        def dfs(root: Optional[TreeNode]):
            if root is None:
                return
            t.append(str(root.val))
            if root.left is None and root.right is None:
                ans.append("->".join(t))
            else:
                dfs(root.left)
                dfs(root.right)
            t.pop()

        ans = []
        t = []
        dfs(root)
        return ans
```

# Tests

```python

```
