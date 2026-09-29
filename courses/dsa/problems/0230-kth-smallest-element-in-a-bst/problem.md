---
lc: 230
title: "Kth Smallest Element in a BST"
difficulty: "Medium"
patterns: ["tree-dfs"]
lcTags: ["tree", "depth-first-search", "binary-search-tree", "binary-tree"]
entry: {"method": "kthSmallest", "params": [{"name": "root", "type": "TreeNode"}, {"name": "k", "type": "integer"}], "returns": "integer"}
examples: ["[3,1,4,null,2]\n1", "[5,3,6,2,4,null,null,1]\n3"]
lcHints: ["Try to utilize the property of a BST.", "Try in-order traversal. (Credits to @chan13)", "What if you could modify the BST node's structure?", "The optimal runtime complexity is O(height of BST)."]
---

Given the `root` of a binary search tree, and an integer `k`, return *the* `kᵗʰ` *smallest value (**1-indexed**) of all the values of the nodes in the tree*.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/01/28/kthtree1.jpg)

```
Input: root = [3,1,4,null,2], k = 1
Output: 1
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2021/01/28/kthtree2.jpg)

```
Input: root = [5,3,6,2,4,null,null,1], k = 3
Output: 3
```

**Constraints:**

- The number of nodes in the tree is `n`.
- `1 <= k <= n <= 10⁴`
- `0 <= Node.val <= 10⁴`

**Follow up:** If the BST is modified often (i.e., we can do insert and delete operations) and you need to find the kth smallest frequently, how would you optimize?

# Starter

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def kthSmallest(self, root: TreeNode | None, k: int) -> int:
        
```

# Hints

1. Inorder traversal of a BST gives values in sorted order.
2. Iterative inorder with a stack; count nodes as you pop them and return the k-th one. You can stop early.

# Key points

- inorder = ascending order
- stop after k pops: O(h + k) time
- follow-up: store subtree sizes in each node to answer in O(h)

# Solution: solution-1 · Iterative inorder traversal · O(h + k) · O(h) · reference

## Idea
Inorder traversal of a BST visits values in increasing order. Do it iteratively with a stack and count nodes as they're popped; the k-th popped node is the answer.

## Complexity
- **Time: O(h + k)**
- **Space: O(h)**

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def kthSmallest(self, root: Optional[TreeNode], k: int) -> int:
        stk = []
        while root or stk:
            if root:
                stk.append(root)
                root = root.left
            else:
                root = stk.pop()
                k -= 1
                if k == 0:
                    return root.val
                root = root.right
```

# Solution: solution-2 · Subtree sizes · O(n) build, O(h) query · O(n)

## Idea
Precompute the size of every subtree. At a node, if the left subtree has exactly k − 1 nodes, this node is the answer; if it has fewer, skip it and the node and go right with a smaller k; otherwise go left. This answers repeated queries in O(h).

## Complexity
- **Time: O(n) build, O(h) query**
- **Space: O(n)**

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right

class BST:
    def __init__(self, root):
        self.cnt = Counter()
        self.root = root
        self.count(root)

    def kthSmallest(self, k):
        node = self.root
        while node:
            if self.cnt[node.left] == k - 1:
                return node.val
            if self.cnt[node.left] < k - 1:
                k -= self.cnt[node.left] + 1
                node = node.right
            else:
                node = node.left
        return 0

    def count(self, root):
        if root is None:
            return 0
        n = 1 + self.count(root.left) + self.count(root.right)
        self.cnt[root] = n
        return n

class Solution:
    def kthSmallest(self, root: Optional[TreeNode], k: int) -> int:
        bst = BST(root)
        return bst.kthSmallest(k)
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
    return [[[3, 1, 4, None, 2], 1], [[5, 3, 6, 2, 4, None, None, 1], 3], [[1], 1], [[2, 1], 2]]

def random_case(rng):
    vals = rng.sample(range(0, 40), rng.randint(1, 10))
    return [bst(vals), rng.randint(1, len(vals))]

def perf(rng):
    vals = rng.sample(range(0, 10**4 + 1), 10000)
    return [[bst(vals), 9999]]
```
