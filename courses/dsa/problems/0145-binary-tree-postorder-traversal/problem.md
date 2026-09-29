---
lc: 145
title: "Binary Tree Postorder Traversal"
difficulty: "Easy"
patterns: ["tree-dfs"]
lcTags: ["stack", "tree", "depth-first-search", "binary-tree"]
entry: {"method": "postorderTraversal", "params": [{"name": "root", "type": "TreeNode"}], "returns": "list<integer>"}
examples: ["[1,null,2,3]", "[1,2,3,4,5,null,8,null,null,6,7,9]", "[]", "[1]"]
---

Given the `root` of a binary tree, return *the postorder traversal of its nodes' values*.

**Example 1:**

**Input:** root = [1,null,2,3]

**Output:** [3,2,1]

**Explanation:**

![](https://assets.leetcode.com/uploads/2024/08/29/screenshot-2024-08-29-202743.png)

**Example 2:**

**Input:** root = [1,2,3,4,5,null,8,null,null,6,7,9]

**Output:** [4,6,7,5,2,9,8,3,1]

**Explanation:**

![](https://assets.leetcode.com/uploads/2024/08/29/tree_2.png)

**Example 3:**

**Input:** root = []

**Output:** []

**Example 4:**

**Input:** root = [1]

**Output:** [1]

**Constraints:**

- The number of the nodes in the tree is in the range `[0, 100]`.
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
    def postorderTraversal(self, root: TreeNode | None) -> list[int]:
        
```

# Hints

1. Postorder = left, right, then node. Children are finished before their parent.
2. Iterative trick: do a modified preorder (node, right, left) with a stack and reverse the result.

# Key points

- order: left, right, root
- reverse of root-right-left preorder gives postorder
- O(n) time, O(h) space

# Solution: recursion · Recursion · O(n) · O(n) · reference

We first recursively traverse the left and right subtrees, then visit the root node.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree. The space complexity mainly depends on the stack space used for recursive calls.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def postorderTraversal(self, root: Optional[TreeNode]) -> List[int]:
        def dfs(root):
            if root is None:
                return
            dfs(root.left)
            dfs(root.right)
            ans.append(root.val)

        ans = []
        dfs(root)
        return ans
```

# Solution: stack-implementation-for-postorder-trave · Stack Implementation for Postorder Traversal · O(n) · O(n)

The order of preorder traversal is: root, left, right. If we change the order of the left and right children, the order becomes: root, right, left. Finally, reversing the result gives us the postorder traversal result.

Therefore, the idea of using a stack to implement non-recursive traversal is as follows:

1. Define a stack stk, and first push the root node into the stack.
2. If the stack is not empty, pop a node from the stack each time.
3. Process the node.
4. First push the left child of the node into the stack, then push the right child of the node into the stack (if there are child nodes).
5. Repeat steps 2-4.
6. Reverse the result to get the postorder traversal result.

The time complexity is O(n), and the space complexity is O(n). Here, n is the number of nodes in the binary tree. The space complexity mainly depends on the stack space.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def postorderTraversal(self, root: Optional[TreeNode]) -> List[int]:
        ans = []
        if root is None:
            return ans
        stk = [root]
        while stk:
            node = stk.pop()
            ans.append(node.val)
            if node.left:
                stk.append(node.left)
            if node.right:
                stk.append(node.right)
        return ans[::-1]
```

# Solution: morris-implementation-for-postorder-trav · Morris Implementation for Postorder Traversal · O(n) · O(1)

Morris traversal does not require a stack, and its space complexity is O(1). The core idea is:

Traverse the binary tree nodes,

1. If the right subtree of the current node `root` is empty, add the current node value to the result list ans, and update the current node to `root.left`.
1. If the right subtree of the current node `root` is not empty, find the leftmost node `next` of the right subtree (which is the successor of the `root` node in inorder traversal):
    - If the left subtree of the successor node `next` is empty, add the current node value to the result list ans, then point the left subtree of the successor node to the current node `root`, and update the current node to `root.right`.
    - If the left subtree of the successor node `next` is not empty, point the left subtree of the successor node to null (i.e., disconnect `next` and `root`), and update the current node to `root.left`.
1. Repeat the above steps until the binary tree node is null, and the traversal ends.
1. Finally, return the reverse of the result list.

> The idea of Morris postorder traversal is consistent with Morris preorder traversal, just change the "root-left-right" of preorder to "root-right-left", and finally reverse the result to become "left-right-root".

The time complexity is O(n), where n is the number of nodes in the binary tree. The space complexity is O(1).

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def postorderTraversal(self, root: Optional[TreeNode]) -> List[int]:
        ans = []
        while root:
            if root.right is None:
                ans.append(root.val)
                root = root.left
            else:
                next = root.right
                while next.left and next.left != root:
                    next = next.left
                if next.left != root:
                    ans.append(root.val)
                    next.left = root
                    root = root.right
                else:
                    next.left = None
                    root = root.left
        return ans[::-1]
```

# Tests

```python

```
