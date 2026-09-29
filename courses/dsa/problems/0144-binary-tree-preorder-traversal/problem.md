---
lc: 144
title: "Binary Tree Preorder Traversal"
difficulty: "Easy"
patterns: ["tree-dfs"]
lcTags: ["stack", "tree", "depth-first-search", "binary-tree"]
entry: {"method": "preorderTraversal", "params": [{"name": "root", "type": "TreeNode"}], "returns": "list<integer>"}
examples: ["[1,null,2,3]", "[1,2,3,4,5,null,8,null,null,6,7,9]", "[]", "[1]"]
---

Given the `root` of a binary tree, return *the preorder traversal of its nodes' values*.

**Example 1:**

**Input:** root = [1,null,2,3]

**Output:** [1,2,3]

**Explanation:**

![](https://assets.leetcode.com/uploads/2024/08/29/screenshot-2024-08-29-202743.png)

**Example 2:**

**Input:** root = [1,2,3,4,5,null,8,null,null,6,7,9]

**Output:** [1,2,4,5,6,7,3,8,9]

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
    def preorderTraversal(self, root: TreeNode | None) -> list[int]:
        
```

# Hints

1. Preorder = node, then left subtree, then right subtree.
2. Recursive is three lines. Iteratively: use a stack, pop a node, record it, push right then left (so left is processed first).

# Key points

- order: root, left, right
- iterative: stack, push right before left
- O(n) time, O(h) space

# Solution: recursive-traversal · Recursive Traversal · O(n) · O(n) · reference

We first visit the root node, then recursively traverse the left and right subtrees.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree. The space complexity mainly depends on the stack space used for recursive calls.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def preorderTraversal(self, root: Optional[TreeNode]) -> List[int]:
        def dfs(root):
            if root is None:
                return
            ans.append(root.val)
            dfs(root.left)
            dfs(root.right)

        ans = []
        dfs(root)
        return ans
```

# Solution: stack-implementation-for-non-recursive-t · Stack Implementation for Non-Recursive Traversal · O(n) · O(n)

The idea of using a stack to implement non-recursive traversal is as follows:

1. Define a stack stk, and first push the root node into the stack.
2. If the stack is not empty, pop a node from the stack each time.
3. Process the node.
4. First push the right child of the node into the stack, then push the left child of the node into the stack (if there are child nodes).
5. Repeat steps 2-4.
6. Return the result.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree. The space complexity mainly depends on the stack space.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def preorderTraversal(self, root: Optional[TreeNode]) -> List[int]:
        ans = []
        if root is None:
            return ans
        stk = [root]
        while stk:
            node = stk.pop()
            ans.append(node.val)
            if node.right:
                stk.append(node.right)
            if node.left:
                stk.append(node.left)
        return ans
```

# Solution: morris-preorder-traversal · Morris Preorder Traversal · O(n) · O(1)

Morris traversal does not require a stack, and its space complexity is O(1). The core idea is:

Traverse the binary tree nodes,

1. If the left subtree of the current node `root` is empty, add the current node value to the result list ans, and update the current node to `root.right`.
1. If the left subtree of the current node `root` is not empty, find the rightmost node `pre` of the left subtree (which is the predecessor of the `root` node in inorder traversal):
    - If the right subtree of the predecessor node `pre` is empty, add the current node value to the result list ans, then point the right subtree of the predecessor node to the current node `root`, and update the current node to `root.left`.
    - If the right subtree of the predecessor node `pre` is not empty, point the right subtree of the predecessor node to null (i.e., disconnect `pre` and `root`), and update the current node to `root.right`.
1. Repeat the above steps until the binary tree node is null, and the traversal ends.

The time complexity is O(n), where n is the number of nodes in the binary tree. The space complexity is O(1).

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def preorderTraversal(self, root: Optional[TreeNode]) -> List[int]:
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
                    ans.append(root.val)
                    prev.right = root
                    root = root.left
                else:
                    prev.right = None
                    root = root.right
        return ans
```

# Tests

```python

```
