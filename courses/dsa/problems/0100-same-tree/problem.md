---
lc: 100
title: "Same Tree"
difficulty: "Easy"
patterns: ["tree-dfs"]
lcTags: ["tree", "depth-first-search", "breadth-first-search", "binary-tree"]
entry: {"method": "isSameTree", "params": [{"name": "p", "type": "TreeNode"}, {"name": "q", "type": "TreeNode"}], "returns": "boolean"}
examples: ["[1,2,3]\n[1,2,3]", "[1,2]\n[1,null,2]", "[1,2,1]\n[1,1,2]"]
---

Given the roots of two binary trees `p` and `q`, write a function to check if they are the same or not.

Two binary trees are considered the same if they are structurally identical, and the nodes have the same value.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/12/20/ex1.jpg)

```
Input: p = [1,2,3], q = [1,2,3]
Output: true
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2020/12/20/ex2.jpg)

```
Input: p = [1,2], q = [1,null,2]
Output: false
```

**Example 3:**

![](https://assets.leetcode.com/uploads/2020/12/20/ex3.jpg)

```
Input: p = [1,2,1], q = [1,1,2]
Output: false
```

**Constraints:**

- The number of nodes in both trees is in the range `[0, 100]`.
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
    def isSameTree(self, p: TreeNode | None, q: TreeNode | None) -> bool:
        
```

# Hints

1. Two trees are equal if their roots match and both pairs of subtrees are equal.
2. If both are None → True; if one is None or values differ → False; else recurse on left pair and right pair.

# Key points

- compare structure and values together
- base cases: both empty (True), one empty (False)
- O(n) time

# Solution: dfs · DFS · O(min(m, n)) · O(min(m, n)) · reference

We can use the DFS recursive method to solve this problem.

First, determine whether the root nodes of the two binary trees are the same. If both root nodes are null, then the two binary trees are the same. If only one of the root nodes is null, then the two binary trees are definitely different. If both root nodes are not null, then determine whether their values are the same. If they are not the same, then the two binary trees are definitely different. If they are the same, then determine whether the left subtrees of the two binary trees are the same and whether the right subtrees are the same. The two binary trees are the same only when all the above conditions are met.

The time complexity is O(min(m, n)), and the space complexity is O(min(m, n)). Here, m and n are the number of nodes in the two binary trees, respectively. The space complexity mainly depends on the number of layers of recursive calls, which will not exceed the number of nodes in the smaller binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def isSameTree(self, p: Optional[TreeNode], q: Optional[TreeNode]) -> bool:
        if p == q:
            return True
        if p is None or q is None or p.val != q.val:
            return False
        return self.isSameTree(p.left, q.left) and self.isSameTree(p.right, q.right)
```

# Solution: bfs · BFS · O(min(m, n)) · O(min(m, n))

We can also use the BFS iterative method to solve this problem.

First, add the root nodes of the two binary trees to two queues. Each time, take out one node from each of the two queues and perform the following comparison operations. If the values of the two nodes are not the same, then the structures of the two binary trees are definitely different. If the values of the two nodes are the same, then determine whether the child nodes of the two nodes are null. If only the left child node of one node is null, then the structures of the two binary trees are definitely different. If only the right child node of one node is null, then the structures of the two binary trees are definitely different. If the structures of the left and right child nodes are the same, then add the left and right child nodes of the two nodes to the two queues respectively. For the next iteration, take out one node from each of the two queues for comparison. When both queues are empty at the same time, it means that we have compared all the nodes, and the structures of the two binary trees are completely the same.

The time complexity is O(min(m, n)), and the space complexity is O(min(m, n)). Here, m and n are the number of nodes in the two binary trees, respectively. The space complexity mainly depends on the number of elements in the queue, which will not exceed the number of nodes in the smaller binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def isSameTree(self, p: TreeNode, q: TreeNode) -> bool:
        if p == q:
            return True
        if p is None or q is None:
            return False
        q1, q2 = deque([p]), deque([q])
        while q1 and q2:
            a, b = q1.popleft(), q2.popleft()
            if a.val != b.val:
                return False
            la, ra = a.left, a.right
            lb, rb = b.left, b.right
            if (la and not lb) or (lb and not la):
                return False
            if (ra and not rb) or (rb and not ra):
                return False
            if la:
                q1.append(la)
                q2.append(lb)
            if ra:
                q1.append(ra)
                q2.append(rb)
        return True
```

# Tests

```python

```
