---
lc: 701
title: "Insert into a Binary Search Tree"
difficulty: "Medium"
patterns: ["tree-dfs", "binary-search"]
lcTags: ["tree", "binary-search-tree", "binary-tree"]
compare: "check"
entry: {"method": "insertIntoBST", "params": [{"name": "root", "type": "TreeNode"}, {"name": "val", "type": "integer"}], "returns": "TreeNode"}
examples: ["[4,2,7,1,3]\n5", "[40,20,60,10,30,50,70]\n25", "[4,2,7,1,3,null,null,null,null,null,null]\n5"]
---

You are given the `root` node of a binary search tree (BST) and a `value` to insert into the tree. Return *the root node of the BST after the insertion*. It is **guaranteed** that the new value does not exist in the original BST.

**Notice** that there may exist multiple valid ways for the insertion, as long as the tree remains a BST after insertion. You can return **any of them**.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/10/05/insertbst.jpg)

```
Input: root = [4,2,7,1,3], val = 5
Output: [4,2,7,1,3,5]
Explanation: Another accepted tree is:

![](https://assets.leetcode.com/uploads/2020/10/05/bst.jpg)
```

**Example 2:**

```
Input: root = [40,20,60,10,30,50,70], val = 25
Output: [40,20,60,10,30,50,70,null,null,25]
```

**Example 3:**

```
Input: root = [4,2,7,1,3,null,null,null,null,null,null], val = 5
Output: [4,2,7,1,3,5]
```

**Constraints:**

- The number of nodes in the tree will be in the range `[0, 10⁴]`.
- `-10⁸ <= Node.val <= 10⁸`
- All the values `Node.val` are **unique**.
- `-10⁸ <= val <= 10⁸`
- It's **guaranteed** that `val` does not exist in the original BST.

# Starter

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def insertIntoBST(self, root: TreeNode | None, val: int) -> TreeNode | None:
        
```

# Hints

1. Walk down as if searching for val. Where does the search fall off the tree?
2. If root is None return a new node. Go left if val < node.val else right, until the child you need is None; attach the new node there.

# Key points

- follow the BST path to an empty spot and attach a leaf
- no rebalancing needed; any valid BST is accepted
- O(h) time

# Solution: recursion · Recursion · O(n) · O(n) · reference

If the root node is null, we directly create a new node with the value val and return it.

If the root node's value is greater than val, we recursively insert val into the left subtree and update the root of the left subtree with the returned root node.

If the root node's value is less than val, we recursively insert val into the right subtree and update the root of the right subtree with the returned root node.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def insertIntoBST(self, root: Optional[TreeNode], val: int) -> Optional[TreeNode]:
        if root is None:
            return TreeNode(val)
        if root.val > val:
            root.left = self.insertIntoBST(root.left, val)
        else:
            root.right = self.insertIntoBST(root.right, val)
        return root
```

# Tests

```python
def check(args, got, expected):
    vals = []
    def walk(n):
        if n:
            walk(n.left); vals.append(n.val); walk(n.right)
    walk(to_tree(got))
    orig = [v for v in args[0] if v is not None]
    return vals == sorted(orig + [args[1]])

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
    while out and out[-1] is None:
        out.pop()
    return out

def edge():
    return [[[], 5], [[4, 2, 7, 1, 3], 5], [[40, 20, 60, 10, 30, 50, 70], 25], [[1], 0]]

def random_case(rng):
    vals = rng.sample(range(-30, 30), rng.randint(0, 10) + 1)
    return [bst(vals[1:]), vals[0]]

def perf(rng):
    vals = rng.sample(range(-10**8, 10**8), 10001)
    return [[bst(vals[1:]), vals[0]]]
```
