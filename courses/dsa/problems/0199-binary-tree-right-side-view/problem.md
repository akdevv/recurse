---
lc: 199
title: "Binary Tree Right Side View"
difficulty: "Medium"
patterns: ["bfs", "tree-dfs"]
lcTags: ["tree", "depth-first-search", "breadth-first-search", "binary-tree"]
entry: {"method": "rightSideView", "params": [{"name": "root", "type": "TreeNode"}], "returns": "list<integer>"}
examples: ["[1,2,3,null,5,null,4]", "[1,2,3,4,null,null,null,5]", "[1,null,3]", "[]"]
---

Given the `root` of a binary tree, imagine yourself standing on the **right side** of it, return *the values of the nodes you can see ordered from top to bottom*.

**Example 1:**

**Input:** root = [1,2,3,null,5,null,4]

**Output:** [1,3,4]

**Explanation:**

![](https://assets.leetcode.com/uploads/2024/11/24/tmpd5jn43fs-1.png)

**Example 2:**

**Input:** root = [1,2,3,4,null,null,null,5]

**Output:** [1,3,4,5]

**Explanation:**

![](https://assets.leetcode.com/uploads/2024/11/24/tmpkpe40xeh-1.png)

**Example 3:**

**Input:** root = [1,null,3]

**Output:** [1,3]

**Example 4:**

**Input:** root = []

**Output:** []

**Constraints:**

- The number of nodes in the tree is in the range `[0, 100]`.
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
    def rightSideView(self, root: TreeNode | None) -> list[int]:
        
```

# Hints

1. From the right you see the last node of every level.
2. Level-order BFS and record the last node of each level. (DFS visiting right before left also works: record the first node seen at each depth.)

# Key points

- BFS: last node per level
- DFS alternative: right child first, record when depth == len(result)
- O(n) time

# Solution: bfs · BFS · O(n) · O(n) · reference

We can use breadth-first search (BFS) and define a queue q to store the nodes. We start by putting the root node into the queue. Each time, we take out all the nodes of the current level from the queue. For the current node, we first check if the right subtree exists; if it does, we put the right subtree into the queue. Then, we check if the left subtree exists; if it does, we put the left subtree into the queue. This way, the first node taken out from the queue each time is the rightmost node of that level.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def rightSideView(self, root: Optional[TreeNode]) -> List[int]:
        ans = []
        if root is None:
            return ans
        q = deque([root])
        while q:
            ans.append(q[0].val)
            for _ in range(len(q)):
                node = q.popleft()
                if node.right:
                    q.append(node.right)
                if node.left:
                    q.append(node.left)
        return ans
```

# Solution: dfs · DFS · O(n) · O(n)

Use DFS (depth-first search) to traverse the binary tree. Each time, traverse the right subtree first, then the left subtree. This way, the first node visited at each level is the rightmost node of that level.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def rightSideView(self, root: Optional[TreeNode]) -> List[int]:
        def dfs(root: Optional[TreeNode], depth: int) -> None:
            if root is None:
                return
            if len(ans) == depth:
                ans.append(root.val)
            dfs(root.right, depth + 1)
            dfs(root.left, depth + 1)

        ans = []
        dfs(root, 0)
        return ans
```

# Tests

```python

```
