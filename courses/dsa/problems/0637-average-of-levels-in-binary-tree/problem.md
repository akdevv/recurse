---
lc: 637
title: "Average of Levels in Binary Tree"
difficulty: "Easy"
patterns: ["bfs"]
lcTags: ["tree", "depth-first-search", "breadth-first-search", "binary-tree"]
compare: "float"
entry: {"method": "averageOfLevels", "params": [{"name": "root", "type": "TreeNode"}], "returns": "list<double>"}
examples: ["[3,9,20,null,null,15,7]", "[3,9,20,15,7]"]
---

Given the `root` of a binary tree, return *the average value of the nodes on each level in the form of an array*. Answers within `10⁻⁵` of the actual answer will be accepted.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/03/09/avg1-tree.jpg)

```
Input: root = [3,9,20,null,null,15,7]
Output: [3.00000,14.50000,11.00000]
Explanation: The average value of nodes on level 0 is 3, on level 1 is 14.5, and on level 2 is 11.
Hence return [3, 14.5, 11].
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2021/03/09/avg2-tree.jpg)

```
Input: root = [3,9,20,15,7]
Output: [3.00000,14.50000,11.00000]
```

**Constraints:**

- The number of nodes in the tree is in the range `[1, 10⁴]`.
- `-2³¹ <= Node.val <= 2³¹ - 1`

# Starter

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def averageOfLevels(self, root: TreeNode | None) -> list[float]:
        
```

# Hints

1. Process the tree level by level. What tells you where one level ends?
2. BFS with a queue: at each step, the queue length is the number of nodes in the current level. Sum them, divide, then add their children.

# Key points

- level-order BFS, level size = len(queue) at the start of the level
- average = level sum / level size
- O(n) time, O(w) space (w = max width)

# Solution: bfs · BFS · O(n) · O(n) · reference

We can use the Breadth-First Search (BFS) method to traverse the nodes of each level and calculate the average value of each level.

Specifically, we define a queue q, initially adding the root node to the queue. Each time, we take out all the nodes in the queue, calculate their average value, add it to the answer array, and then add their child nodes to the queue. Repeat this process until the queue is empty.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def averageOfLevels(self, root: Optional[TreeNode]) -> List[float]:
        q = deque([root])
        ans = []
        while q:
            s, n = 0, len(q)
            for _ in range(n):
                root = q.popleft()
                s += root.val
                if root.left:
                    q.append(root.left)
                if root.right:
                    q.append(root.right)
            ans.append(s / n)
        return ans
```

# Solution: dfs · DFS · O(n) · O(n)

We can also use the Depth-First Search (DFS) method to calculate the average value of each level.

Specifically, we define an array s, where `s[i]` is a tuple representing the sum of node values and the number of nodes at the i-th level. We perform a depth-first search on the tree. For each node, we add the node's value to the corresponding `s[i]` and increment the node count by one. Finally, for each `s[i]`, we calculate the average value and add it to the answer array.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def averageOfLevels(self, root: Optional[TreeNode]) -> List[float]:
        def dfs(root, i):
            if root is None:
                return
            if len(s) == i:
                s.append([root.val, 1])
            else:
                s[i][0] += root.val
                s[i][1] += 1
            dfs(root.left, i + 1)
            dfs(root.right, i + 1)

        s = []
        dfs(root, 0)
        return [a / b for a, b in s]
```

# Tests

```python

```
