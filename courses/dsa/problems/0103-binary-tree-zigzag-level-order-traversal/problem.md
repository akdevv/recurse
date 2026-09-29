---
lc: 103
title: "Binary Tree Zigzag Level Order Traversal"
difficulty: "Medium"
patterns: ["bfs"]
lcTags: ["tree", "breadth-first-search", "binary-tree"]
entry: {"method": "zigzagLevelOrder", "params": [{"name": "root", "type": "TreeNode"}], "returns": "list<list<integer>>"}
examples: ["[3,9,20,null,null,15,7]", "[1]", "[]"]
---

Given the `root` of a binary tree, return *the zigzag level order traversal of its nodes' values*. (i.e., from left to right, then right to left for the next level and alternate between).

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/02/19/tree1.jpg)

```
Input: root = [3,9,20,null,null,15,7]
Output: [[3],[20,9],[15,7]]
```

**Example 2:**

```
Input: root = [1]
Output: [[1]]
```

**Example 3:**

```
Input: root = []
Output: []
```

**Constraints:**

- The number of nodes in the tree is in the range `[0, 2000]`.
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
    def zigzagLevelOrder(self, root: TreeNode | None) -> list[list[int]]:
        
```

# Hints

1. It's level order, but every other level is reversed.
2. Normal BFS by levels; reverse the level's values on odd levels (or append to the front of a deque).

# Key points

- ordinary level-order traversal
- flip direction each level
- O(n) time

# Solution: bfs · BFS · O(n) · O(n) · reference

To implement zigzag level order traversal, we need to add a flag `left` on the basis of level order traversal. This flag is used to mark the order of the node values in the current level. If `left` is `true`, the node values of the current level are stored in the result array `ans` from left to right. If `left` is `false`, the node values of the current level are stored in the result array `ans` from right to left.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def zigzagLevelOrder(self, root: Optional[TreeNode]) -> List[List[int]]:
        ans = []
        if root is None:
            return ans
        q = deque([root])
        ans = []
        left = 1
        while q:
            t = []
            for _ in range(len(q)):
                node = q.popleft()
                t.append(node.val)
                if node.left:
                    q.append(node.left)
                if node.right:
                    q.append(node.right)
            ans.append(t if left else t[::-1])
            left ^= 1
        return ans
```

# Tests

```python

```
