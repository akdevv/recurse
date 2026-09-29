---
lc: 530
title: "Minimum Absolute Difference in BST"
difficulty: "Easy"
patterns: ["tree-dfs"]
lcTags: ["tree", "depth-first-search", "breadth-first-search", "binary-search-tree", "binary-tree"]
entry: {"method": "getMinimumDifference", "params": [{"name": "root", "type": "TreeNode"}], "returns": "integer"}
examples: ["[4,2,6,1,3]", "[1,0,48,null,null,12,49]"]
---

Given the `root` of a Binary Search Tree (BST), return *the minimum absolute difference between the values of any two different nodes in the tree*.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/02/05/bst1.jpg)

```
Input: root = [4,2,6,1,3]
Output: 1
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2021/02/05/bst2.jpg)

```
Input: root = [1,0,48,null,null,12,49]
Output: 1
```

**Constraints:**

- The number of nodes in the tree is in the range `[2, 10⁴]`.
- `0 <= Node.val <= 10⁵`

**Note:** This question is the same as 783: [https://leetcode.com/problems/minimum-distance-between-bst-nodes/](https://leetcode.com/problems/minimum-distance-between-bst-nodes/)

# Starter

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def getMinimumDifference(self, root: Optional[TreeNode]) -> int:
        
```

# Hints

1. Inorder traversal of a BST visits values in sorted order. In a sorted list, where is the smallest difference?
2. Inorder traversal keeping the previous value; the answer is the minimum of (current − previous).

# Key points

- inorder = sorted, so only neighbours in that order matter
- track prev during the traversal, no extra list needed
- O(n) time, O(h) space

# Solution: inorder-traversal · Inorder Traversal · O(n) · O(n) · reference

The problem requires us to find the minimum difference between the values of any two nodes. Since the inorder traversal of a binary search tree is an increasing sequence, we only need to find the minimum difference between the values of two adjacent nodes in the inorder traversal.

We can use a recursive method to implement the inorder traversal. During the process, we use a variable pre to save the value of the previous node. This way, we can calculate the minimum difference between the values of two adjacent nodes during the traversal.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary search tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def getMinimumDifference(self, root: Optional[TreeNode]) -> int:
        def dfs(root: Optional[TreeNode]):
            if root is None:
                return
            dfs(root.left)
            nonlocal pre, ans
            ans = min(ans, root.val - pre)
            pre = root.val
            dfs(root.right)

        pre = -inf
        ans = inf
        dfs(root)
        return ans
```

# Tests

```python
def bst(vals):
    root = None
    def ins(node, v):
        if node is None:
            return [v, None, None]
        if v < node[0]:
            node[1] = ins(node[1], v)
        else:
            node[2] = ins(node[2], v)
        return node
    for v in vals:
        root = ins(root, v)
    out, q = [], [root]
    while q:
        n = q.pop(0)
        out.append(n[0] if n else None)
        if n:
            q += [n[1], n[2]]
    while out[-1] is None:
        out.pop()
    return out

def edge():
    return [[[4, 2, 6, 1, 3]], [[1, 0, 48, None, None, 12, 49]], [[0, None, 100000]], [[5, 3]]]

def random_case(rng):
    return [bst(rng.sample(range(0, 60), rng.randint(2, 10)))]

def perf(rng):
    vals = rng.sample(range(0, 10**5), 10000)
    return [[bst(vals)]]
```
