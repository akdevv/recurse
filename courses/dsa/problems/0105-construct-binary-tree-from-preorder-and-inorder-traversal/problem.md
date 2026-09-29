---
lc: 105
title: "Construct Binary Tree from Preorder and Inorder Traversal"
difficulty: "Medium"
patterns: ["tree-dfs", "divide-and-conquer"]
lcTags: ["array", "hash-table", "divide-and-conquer", "tree", "binary-tree"]
entry: {"method": "buildTree", "params": [{"name": "preorder", "type": "integer[]"}, {"name": "inorder", "type": "integer[]"}], "returns": "TreeNode"}
examples: ["[3,9,20,15,7]\n[9,3,15,20,7]", "[-1]\n[-1]"]
---

Given two integer arrays `preorder` and `inorder` where `preorder` is the preorder traversal of a binary tree and `inorder` is the inorder traversal of the same tree, construct and return *the binary tree*.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/02/19/tree.jpg)

```
Input: preorder = [3,9,20,15,7], inorder = [9,3,15,20,7]
Output: [3,9,20,null,null,15,7]
```

**Example 2:**

```
Input: preorder = [-1], inorder = [-1]
Output: [-1]
```

**Constraints:**

- `1 <= preorder.length <= 3000`
- `inorder.length == preorder.length`
- `-3000 <= preorder[i], inorder[i] <= 3000`
- `preorder` and `inorder` consist of **unique** values.
- Each value of `inorder` also appears in `preorder`.
- `preorder` is **guaranteed** to be the preorder traversal of the tree.
- `inorder` is **guaranteed** to be the inorder traversal of the tree.

# Starter

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def buildTree(self, preorder: list[int], inorder: list[int]) -> TreeNode | None:
        
```

# Hints

1. preorder[0] is the root. Where does it sit in inorder, and what's on each side of it?
2. Map value → index in inorder. build(pre_start, in_lo, in_hi): root = preorder[pre_start]; left size = idx − in_lo; build left from pre_start + 1, right from pre_start + 1 + left size.

# Key points

- first preorder value is the root
- its position in inorder splits left and right subtrees
- a dict of inorder positions makes each split O(1) → O(n) total
- values are unique, which makes the split well-defined

# Solution: hash-table-recursion · Hash Table + Recursion · O(n) · O(n) · reference

The first node `preorder[0]` in the pre-order sequence is the root node. We find the position k of the root node in the in-order sequence, which can divide the in-order sequence into the left subtree `inorder[0..k]` and the right subtree `inorder[k+1..]`.

Through the intervals of the left and right subtrees, we can calculate the number of nodes in the left and right subtrees, assumed to be a and b. Then in the pre-order nodes, the a nodes after the root node are the left subtree, and the b nodes after that are the right subtree.

Therefore, we design a function `dfs(i, j, n)`, where i and j represent the starting positions of the pre-order sequence and the in-order sequence, respectively, and n represents the number of nodes. The return value of the function is the binary tree constructed with `preorder[i..i+n-1]` as the pre-order sequence and `inorder[j..j+n-1]` as the in-order sequence.

The execution process of the function `dfs(i, j, n)` is as follows:

- If `n <= 0`, it means there are no nodes, return a null node.
- Take out the first node `v = preorder[i]` of the pre-order sequence as the root node, and then use the hash table d to find the position k of the root node in the in-order sequence. Then the number of nodes in the left subtree is `k - j`, and the number of nodes in the right subtree is `n - k + j - 1`.
- Recursively construct the left subtree `l = dfs(i + 1, j, k - j)` and the right subtree `r = dfs(i + 1 + k - j, k + 1, n - k + j - 1)`.
- Finally, return the binary tree with v as the root node and l and r as the left and right subtrees, respectively.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def buildTree(self, preorder: List[int], inorder: List[int]) -> Optional[TreeNode]:
        def dfs(i: int, j: int, n: int) -> Optional[TreeNode]:
            if n <= 0:
                return None
            v = preorder[i]
            k = d[v]
            l = dfs(i + 1, j, k - j)
            r = dfs(i + 1 + k - j, k + 1, n - k + j - 1)
            return TreeNode(v, l, r)

        d = {v: i for i, v in enumerate(inorder)}
        return dfs(0, 0, len(preorder))
```

# Tests

```python
def tree_orders(rng, n):
    vals = rng.sample(range(-3000, 3001), n)
    root = None
    def insert_random(node, v):
        if node is None:
            return [v, None, None]
        side = 1 if rng.random() < 0.5 else 2
        node[side] = insert_random(node[side], v)
        return node
    for v in vals:
        root = insert_random(root, v)
    pre, ino = [], []
    def walk(node):
        if node:
            pre.append(node[0]); walk(node[1]); ino.append(node[0]); walk(node[2])
    walk(root)
    return [pre, ino]

def edge():
    return [[[-1], [-1]], [[3, 9, 20, 15, 7], [9, 3, 15, 20, 7]], [[1, 2], [2, 1]], [[1, 2], [1, 2]], [[1, 2, 3], [3, 2, 1]]]

def random_case(rng):
    return tree_orders(rng, rng.randint(1, 10))

def perf(rng):
    n = 3000
    return [[list(range(n)), list(range(n))[::-1]]]
```
