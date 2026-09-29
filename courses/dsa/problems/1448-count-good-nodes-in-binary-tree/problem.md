---
lc: 1448
title: "Count Good Nodes in Binary Tree"
difficulty: "Medium"
patterns: ["tree-dfs"]
lcTags: ["tree", "depth-first-search", "breadth-first-search", "binary-tree"]
entry: {"method": "goodNodes", "params": [{"name": "root", "type": "TreeNode"}], "returns": "integer"}
examples: ["[3,1,4,3,null,1,5]", "[3,3,null,4,2]", "[1]"]
lcHints: ["Use DFS (Depth First Search) to traverse the tree, and constantly keep track of the current path maximum."]
---

Given a binary tree `root`, a node *X* in the tree is named **good** if in the path from root to *X* there are no nodes with a value *greater than* X.

Return the number of **good** nodes in the binary tree.

**Example 1:**

**![](https://assets.leetcode.com/uploads/2020/04/02/test_sample_1.png)**

```
Input: root = [3,1,4,3,null,1,5]
Output: 4
Explanation: Nodes in blue are good.
Root Node (3) is always a good node.
Node 4 -> (3,4) is the maximum value in the path starting from the root.
Node 5 -> (3,4,5) is the maximum value in the path
Node 3 -> (3,1,3) is the maximum value in the path.
```

**Example 2:**

**![](https://assets.leetcode.com/uploads/2020/04/02/test_sample_2.png)**

```
Input: root = [3,3,null,4,2]
Output: 3
Explanation: Node 2 -> (3, 3, 2) is not good, because "3" is higher than it.
```

**Example 3:**

```
Input: root = [1]
Output: 1
Explanation: Root is considered as good.
```

**Constraints:**

- The number of nodes in the binary tree is in the range `[1, 10^5]`.
- Each node's value is between `[-10^4, 10^4]`.

# Starter

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def goodNodes(self, root: TreeNode) -> int:
        
```

# Hints

1. A node is good if nothing on the path from the root to it is bigger. What should you pass down the recursion?
2. DFS(node, best): count 1 if node.val ≥ best, then recurse into both children with max(best, node.val).

# Key points

- pass the maximum seen so far down the path
- node is good when its value >= that maximum
- O(n) time, O(h) space

# Solution: solution-1 · DFS passing the max so far · O(n) · O(h) · reference

## Idea
DFS passing down the largest value on the path so far. A node is good if its value is at least that maximum; then the maximum is updated for its children.

## Complexity
- **Time: O(n)**
- **Space: O(h)**

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def goodNodes(self, root: TreeNode) -> int:
        def dfs(root: TreeNode, mx: int):
            if root is None:
                return
            nonlocal ans
            if mx <= root.val:
                ans += 1
                mx = root.val
            dfs(root.left, mx)
            dfs(root.right, mx)

        ans = 0
        dfs(root, -1000000)
        return ans
```

# Tests

```python
def tree(rng, n, lo, hi):
    vals = [rng.randint(lo, hi) for _ in range(n)]
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
    return [[[1]], [[3, 1, 4, 3, None, 1, 5]], [[3, 3, None, 4, 2]], [[-10000, 10000]], [[5, 4, 3, 2, 1]]]

def random_case(rng):
    return [tree(rng, rng.randint(1, 12), -5, 5)]

def perf(rng):
    return [[[rng.randint(-10**4, 10**4) for _ in range(100000)]]]
```
