---
lc: 450
title: "Delete Node in a BST"
difficulty: "Medium"
patterns: ["tree-dfs"]
lcTags: ["tree", "binary-search-tree", "binary-tree"]
compare: "check"
entry: {"method": "deleteNode", "params": [{"name": "root", "type": "TreeNode"}, {"name": "key", "type": "integer"}], "returns": "TreeNode"}
examples: ["[5,3,6,2,4,null,7]\n3", "[5,3,6,2,4,null,7]\n0", "[]\n0"]
---

Given a root node reference of a BST and a key, delete the node with the given key in the BST. Return *the **root node reference** (possibly updated) of the BST*.

Basically, the deletion can be divided into two stages:

1. Search for a node to remove.
1. If the node is found, delete the node.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/09/04/del_node_1.jpg)

```
Input: root = [5,3,6,2,4,null,7], key = 3
Output: [5,4,6,2,null,null,7]
Explanation: Given key to delete is 3. So we find the node with value 3 and delete it.
One valid answer is [5,4,6,2,null,null,7], shown in the above BST.
Please notice that another valid answer is [5,2,6,null,4,null,7] and it's also accepted.

![](https://assets.leetcode.com/uploads/2020/09/04/del_node_supp.jpg)
```

**Example 2:**

```
Input: root = [5,3,6,2,4,null,7], key = 0
Output: [5,3,6,2,4,null,7]
Explanation: The tree does not contain a node with value = 0.
```

**Example 3:**

```
Input: root = [], key = 0
Output: []
```

**Constraints:**

- The number of nodes in the tree is in the range `[0, 10⁴]`.
- `-10⁵ <= Node.val <= 10⁵`
- Each node has a **unique** value.
- `root` is a valid binary search tree.
- `-10⁵ <= key <= 10⁵`

**Follow up:** Could you solve it with time complexity `O(height of tree)`?

# Starter

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def deleteNode(self, root: TreeNode | None, key: int) -> TreeNode | None:
        
```

# Hints

1. First find the node. Deleting a leaf or a node with one child is easy. What about two children?
2. Two children: replace the node's value with its inorder successor (leftmost node of the right subtree), then delete that successor from the right subtree.

# Key points

- search by BST property, then handle 0, 1 or 2 children
- two children: copy the successor (or predecessor) value and delete it below
- O(h) time; many valid result trees, the tests accept any valid BST

# Solution: solution-1 · Recursive delete · O(h) · O(h) · reference

## Idea
Search down using the BST property. At the node: if a child is missing, return the other child. With two children, find the leftmost node of the right subtree (the successor), hang the left subtree under it, and return the right subtree.

## Complexity
- **Time: O(h)**
- **Space: O(h)**

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def deleteNode(self, root: Optional[TreeNode], key: int) -> Optional[TreeNode]:
        if root is None:
            return None
        if root.val > key:
            root.left = self.deleteNode(root.left, key)
            return root
        if root.val < key:
            root.right = self.deleteNode(root.right, key)
            return root
        if root.left is None:
            return root.right
        if root.right is None:
            return root.left
        node = root.right
        while node.left:
            node = node.left
        node.left = root.left
        root = root.right
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
    return vals == sorted(v for v in orig if v != args[1])

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
    return [[[5, 3, 6, 2, 4, None, 7], 3], [[5, 3, 6, 2, 4, None, 7], 0], [[], 0], [[5], 5], [[5, 3, 6, 2, 4, None, 7], 5]]

def random_case(rng):
    vals = rng.sample(range(-30, 30), rng.randint(0, 10))
    key = rng.choice(vals) if vals and rng.random() < 0.7 else rng.randint(-31, 31)
    return [bst(vals), key]

def perf(rng):
    vals = rng.sample(range(-10**5, 10**5), 10000)
    return [[bst(vals), vals[0]]]
```
