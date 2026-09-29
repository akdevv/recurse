---
lc: 94
title: "Binary Tree Inorder Traversal"
difficulty: "Easy"
patterns: ["tree-dfs"]
lcTags: ["stack", "tree", "depth-first-search", "binary-tree"]
entry: {"method": "inorderTraversal", "params": [{"name": "root", "type": "TreeNode"}], "returns": "list<integer>"}
examples: ["[1,null,2,3]", "[1,2,3,4,5,null,8,null,null,6,7,9]", "[]", "[1]"]
---

Given the `root` of a binary tree, return *the inorder traversal of its nodes' values*.

**Example 1:**

**Input:** root = [1,null,2,3]

**Output:** [1,3,2]

**Explanation:**

![](https://assets.leetcode.com/uploads/2024/08/29/screenshot-2024-08-29-202743.png)

**Example 2:**

**Input:** root = [1,2,3,4,5,null,8,null,null,6,7,9]

**Output:** [4,2,6,5,7,1,3,9,8]

**Explanation:**

![](https://assets.leetcode.com/uploads/2024/08/29/tree_2.png)

**Example 3:**

**Input:** root = []

**Output:** []

**Example 4:**

**Input:** root = [1]

**Output:** [1]

**Constraints:**

- The number of nodes in the tree is in the range `[0, 100]`.
- `-100 <= Node.val <= 100`

**Follow up:** Recursive solution is trivial, could you do it iteratively?

# Starter

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def inorderTraversal(self, root: TreeNode | None) -> list[int]:
        
```

# Hints

1. Inorder = left subtree, then node, then right subtree.
2. Iteratively: go left as far as possible pushing nodes; pop one, record it, then move to its right child and repeat.

# Key points

- order: left, root, right (sorted order for a BST)
- iterative: push the whole left chain, pop, go right
- O(n) time, O(h) space (Morris traversal gets O(1))

# Solution: recursive-traversal · Recursive Traversal · O(n) · O(n) · reference

We first recursively traverse the left subtree, then visit the root node, and finally recursively traverse the right subtree.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree, and the space complexity mainly depends on the stack space of the recursive call.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def inorderTraversal(self, root: Optional[TreeNode]) -> List[int]:
        def dfs(root):
            if root is None:
                return
            dfs(root.left)
            ans.append(root.val)
            dfs(root.right)

        ans = []
        dfs(root)
        return ans
```

# Solution: stack-implementation-for-non-recursive-t · Stack Implementation for Non-recursive Traversal · O(n) · O(n)

The non-recursive approach is as follows:

1. Define a stack `stk`.
2. Push the left nodes of the tree into the stack in sequence.
3. When the left node is null, pop and process the top element of the stack.
4. Repeat steps 2-3.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree, and the space complexity mainly depends on the stack space.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def inorderTraversal(self, root: Optional[TreeNode]) -> List[int]:
        ans, stk = [], []
        while root or stk:
            if root:
                stk.append(root)
                root = root.left
            else:
                root = stk.pop()
                ans.append(root.val)
                root = root.right
        return ans
```

# Solution: morris-implementation-for-in-order-trave · Morris Implementation for In-order Traversal · O(n) · O(1)

Morris traversal does not require a stack, so the space complexity is O(1). The core idea is:

Traverse the binary tree nodes,

1. If the left subtree of the current node `root` is null, **add the current node value to the result list `ans`**, and update the current node to `root.right`.
2. If the left subtree of the current node `root` is not null, find the rightmost node `prev` of the left subtree (which is the predecessor node of the `root` node in in-order traversal):
    - If the right subtree of the predecessor node `prev` is null, point the right subtree of the predecessor node to the current node `root`, and update the current node to `root.left`.
    - If the right subtree of the predecessor node `prev` is not null, **add the current node value to the result list `ans`**, then point the right subtree of the predecessor node to null (i.e., disconnect `prev` and `root`), and update the current node to `root.right`.
3. Repeat the above steps until the binary tree node is null, and the traversal ends.

The time complexity is O(n), and the space complexity is O(1). Here, n is the number of nodes in the binary tree.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def inorderTraversal(self, root: Optional[TreeNode]) -> List[int]:
        ans = []
        while root:
            if root.left is None:
                ans.append(root.val)
                root = root.right
            else:
                prev = root.left
                while prev.right and prev.right != root:
                    prev = prev.right
                if prev.right is None:
                    prev.right = root
                    root = root.left
                else:
                    ans.append(root.val)
                    prev.right = None
                    root = root.right
        return ans
```

# Tests

```python

```
