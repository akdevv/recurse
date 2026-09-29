---
lc: 111
title: "Minimum Depth of Binary Tree"
difficulty: "Easy"
patterns: ["bfs"]
lcTags: ["tree", "depth-first-search", "breadth-first-search", "binary-tree"]
entry: {"method": "minDepth", "params": [{"name": "root", "type": "TreeNode"}], "returns": "integer"}
examples: ["[3,9,20,null,null,15,7]", "[2,null,3,null,4,null,5,null,6]"]
---

Given a binary tree, find its minimum depth.

The minimum depth is the number of nodes along the shortest path from the root node down to the nearest leaf node.

**Note:** A leaf is a node with no children.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/10/12/ex_depth.jpg)

```
Input: root = [3,9,20,null,null,15,7]
Output: 2
```

**Example 2:**

```
Input: root = [2,null,3,null,4,null,5,null,6]
Output: 5
```

**Constraints:**

- The number of nodes in the tree is in the range `[0, 10⁵]`.
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
    def minDepth(self, root: TreeNode | None) -> int:
        
```

# Hints

1. The minimum depth is the distance to the nearest leaf. BFS reaches the nearest leaf first.
2. BFS level by level; return the level number of the first node with no children. (Recursive: careful, a node with one child isn't a leaf.)

# Key points

- BFS stops at the first leaf → often faster than DFS
- recursion trap: if one child is missing, use the other child's depth, not min
- empty tree → 0

# Solution: recursion · Recursion · O(n) · O(n) · reference

The termination condition for recursion is when the current node is null, at which point return 0. If one of the left or right subtrees of the current node is null, return the minimum depth of the non-null subtree plus 1. If neither the left nor right subtree of the current node is null, return the smaller value of the minimum depths of the left and right subtrees plus 1.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def minDepth(self, root: Optional[TreeNode]) -> int:
        if root is None:
            return 0
        if root.left is None:
            return 1 + self.minDepth(root.right)
        if root.right is None:
            return 1 + self.minDepth(root.left)
        return 1 + min(self.minDepth(root.left), self.minDepth(root.right))
```

# Solution: bfs · BFS · O(n) · O(n)

Use a queue to implement breadth-first search, initially adding the root node to the queue. Each time, take a node from the queue. If this node is a leaf node, directly return the current depth. If this node is not a leaf node, add all non-null child nodes of this node to the queue. Continue to search the next layer of nodes until a leaf node is found.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def minDepth(self, root: Optional[TreeNode]) -> int:
        if root is None:
            return 0
        q = deque([root])
        ans = 0
        while 1:
            ans += 1
            for _ in range(len(q)):
                node = q.popleft()
                if node.left is None and node.right is None:
                    return ans
                if node.left:
                    q.append(node.left)
                if node.right:
                    q.append(node.right)
```

# Tests

```python

```
