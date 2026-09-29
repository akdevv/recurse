---
lc: 102
title: "Binary Tree Level Order Traversal"
difficulty: "Medium"
patterns: ["bfs"]
lcTags: ["tree", "breadth-first-search", "binary-tree"]
entry: {"method": "levelOrder", "params": [{"name": "root", "type": "TreeNode"}], "returns": "list<list<integer>>"}
examples: ["[3,9,20,null,null,15,7]", "[1]", "[]"]
lcHints: ["Use a queue to perform BFS."]
---

Given the `root` of a binary tree, return *the level order traversal of its nodes' values*. (i.e., from left to right, level by level).

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/02/19/tree1.jpg)

```
Input: root = [3,9,20,null,null,15,7]
Output: [[3],[9,20],[15,7]]
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
    def levelOrder(self, root: TreeNode | None) -> list[list[int]]:
        
```

# Hints

1. A queue gives nodes in the order they were discovered: level by level.
2. While the queue isn't empty: take len(queue) nodes (one level), record their values, and enqueue their children.

# Key points

- BFS with collections.deque
- the level-size loop separates levels
- O(n) time and space

# Solution: bfs · BFS · O(n) · O(n) · reference

We can use the BFS method to solve this problem. First, enqueue the root node, then continuously perform the following operations until the queue is empty:

- Traverse all nodes in the current queue, store their values in a temporary array t, and then enqueue their child nodes.
- Store the temporary array t in the answer array.

Finally, return the answer array.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def levelOrder(self, root: Optional[TreeNode]) -> List[List[int]]:
        ans = []
        if root is None:
            return ans
        q = deque([root])
        while q:
            t = []
            for _ in range(len(q)):
                node = q.popleft()
                t.append(node.val)
                if node.left:
                    q.append(node.left)
                if node.right:
                    q.append(node.right)
            ans.append(t)
        return ans
```

# Tests

```python

```
