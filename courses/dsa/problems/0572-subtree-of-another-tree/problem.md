---
lc: 572
title: "Subtree of Another Tree"
difficulty: "Easy"
patterns: ["tree-dfs"]
lcTags: ["tree", "depth-first-search", "string-matching", "binary-tree", "hash-function"]
entry: {"method": "isSubtree", "params": [{"name": "root", "type": "TreeNode"}, {"name": "subRoot", "type": "TreeNode"}], "returns": "boolean"}
examples: ["[3,4,5,1,2]\n[4,1,2]", "[3,4,5,1,2,null,null,null,null,0]\n[4,1,2]"]
lcHints: ["Which approach is better here- recursive or iterative?", "If recursive approach is better, can you write recursive function with its parameters?", "Two trees <b>s</b> and <b>t</b> are said to be identical if their root values are same and their left and right subtrees are identical. Can you write this in form of recursive formulae?", "Recursive formulae can be: \r\nisIdentical(s,t)= s.val==t.val AND isIdentical(s.left,t.left) AND isIdentical(s.right,t.right)"]
---

Given the roots of two binary trees `root` and `subRoot`, return `true` if there is a subtree of `root` with the same structure and node values of `subRoot` and `false` otherwise.

A subtree of a binary tree `tree` is a tree that consists of a node in `tree` and all of this node's descendants. The tree `tree` could also be considered as a subtree of itself.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/04/28/subtree1-tree.jpg)

```
Input: root = [3,4,5,1,2], subRoot = [4,1,2]
Output: true
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2021/04/28/subtree2-tree.jpg)

```
Input: root = [3,4,5,1,2,null,null,null,null,0], subRoot = [4,1,2]
Output: false
```

**Constraints:**

- The number of nodes in the `root` tree is in the range `[1, 2000]`.
- The number of nodes in the `subRoot` tree is in the range `[1, 1000]`.
- `-10⁴ <= root.val <= 10⁴`
- `-10⁴ <= subRoot.val <= 10⁴`

# Starter

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def isSubtree(self, root: TreeNode | None, subRoot: TreeNode | None) -> bool:
        
```

# Hints

1. subRoot is a subtree if it's the same tree as the tree rooted at some node of root.
2. For every node of root, check isSameTree(node, subRoot). Return True as soon as one matches.

# Key points

- reuse Same Tree at each node
- O(m·n) worst case; serialization + string search is the faster trick

# Solution: dfs · DFS · O(n × m) · O(n) · reference

We define a helper function `same(p, q)` to determine whether the tree rooted at p and the tree rooted at q are identical. If the root values of the two trees are equal, and their left and right subtrees are also respectively equal, then the two trees are identical.

In the `isSubtree(root, subRoot)` function, we first check if root is null. If it is, we return false. Otherwise, we check if root and subRoot are identical. If they are, we return true. Otherwise, we recursively check if the left or right subtree of root contains subRoot.

The time complexity is O(n × m), and the space complexity is O(n). Here, n and m are the number of nodes in the trees root and subRoot, respectively.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def isSubtree(self, root: Optional[TreeNode], subRoot: Optional[TreeNode]) -> bool:
        def same(p: Optional[TreeNode], q: Optional[TreeNode]) -> bool:
            if p is None or q is None:
                return p is q
            return p.val == q.val and same(p.left, q.left) and same(p.right, q.right)

        if root is None:
            return False
        return (
            same(root, subRoot)
            or self.isSubtree(root.left, subRoot)
            or self.isSubtree(root.right, subRoot)
        )
```

# Tests

```python
def tree(rng, n):
    vals = [rng.randint(1, 3) for _ in range(n)]
    out, slots, i = [vals[0]], 2, 1
    while i < n:
        if slots > 1 and rng.random() < 0.3:
            out.append(None); slots -= 1
        else:
            out.append(vals[i]); i += 1; slots += 1
    while out[-1] is None:
        out.pop()
    return out

def edge():
    return [[[1], [1]], [[1], [2]], [[3, 4, 5, 1, 2], [4, 1, 2]], [[3, 4, 5, 1, 2, None, None, None, None, 0], [4, 1, 2]], [[1, 1], [1]]]

def random_case(rng):
    return [tree(rng, rng.randint(1, 10)), tree(rng, rng.randint(1, 3))]

def perf(rng):
    return [[[1] * 2000, [1] * 999 + [2]]]
```
