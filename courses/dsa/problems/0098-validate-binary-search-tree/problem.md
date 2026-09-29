---
lc: 98
title: "Validate Binary Search Tree"
difficulty: "Medium"
patterns: ["tree-dfs"]
lcTags: ["tree", "depth-first-search", "binary-search-tree", "binary-tree"]
entry: {"method": "isValidBST", "params": [{"name": "root", "type": "TreeNode"}], "returns": "boolean"}
examples: ["[2,1,3]", "[5,1,4,null,null,3,6]"]
---

Given the `root` of a binary tree, *determine if it is a valid binary search tree (BST)*.

A **valid BST** is defined as follows:

- The left subtree of a node contains only nodes with keys **strictly less than** the node's key.
- The right subtree of a node contains only nodes with keys **strictly greater than** the node's key.
- Both the left and right subtrees must also be binary search trees.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/12/01/tree1.jpg)

```
Input: root = [2,1,3]
Output: true
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2020/12/01/tree2.jpg)

```
Input: root = [5,1,4,null,null,3,6]
Output: false
Explanation: The root node's value is 5 but its right child's value is 4.
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
    def isValidBST(self, root: TreeNode | None) -> bool:
        
```

# Hints

1. Checking only a node against its children isn't enough: every node in the left subtree must be smaller than the root.
2. Pass bounds down: valid(node, lo, hi) requires lo < node.val < hi; recurse left with (lo, node.val) and right with (node.val, hi). (Or check that inorder is strictly increasing.)

# Key points

- each node must be inside an allowed (low, high) range from its ancestors
- trap: comparing only with direct children misses deeper violations
- equal values are not allowed
- O(n) time

# Solution: recursion · Recursion · O(n) · O(n) · reference

We can perform a recursive in-order traversal on the binary tree. If the result of the traversal is strictly ascending, then this tree is a binary search tree.

Therefore, we use a variable `prev` to save the last node we traversed. Initially, `prev = -∞`. Then we recursively traverse the left subtree. If the left subtree is not a binary search tree, we directly return `False`. Otherwise, we check whether the value of the current node is greater than `prev`. If not, we return `False`. Otherwise, we update `prev` to the value of the current node, and then recursively traverse the right subtree.

The time complexity is O(n), and the space complexity is O(n). Where n is the number of nodes in the binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def isValidBST(self, root: Optional[TreeNode]) -> bool:
        def dfs(root: Optional[TreeNode]) -> bool:
            if root is None:
                return True
            if not dfs(root.left):
                return False
            nonlocal prev
            if prev >= root.val:
                return False
            prev = root.val
            return dfs(root.right)

        prev = -inf
        return dfs(root)
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
    return [[[2, 1, 3]], [[5, 1, 4, None, None, 3, 6]], [[1]], [[1, 1]], [[5, 4, 6, None, None, 3, 7]], [[-2**31, None, 2**31 - 1]], [[2, 2, 2]]]

def random_case(rng):
    t = bst(rng.sample(range(-20, 20), rng.randint(1, 10)))
    if rng.random() < 0.5:
        idx = [i for i, v in enumerate(t) if v is not None]
        t[rng.choice(idx)] = rng.randint(-20, 20)
    return [t]

def perf(rng):
    return [[bst(rng.sample(range(-10**6, 10**6), 10000))]]
```
