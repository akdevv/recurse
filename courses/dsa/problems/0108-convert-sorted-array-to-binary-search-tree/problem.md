---
lc: 108
title: "Convert Sorted Array to Binary Search Tree"
difficulty: "Easy"
patterns: ["divide-and-conquer"]
lcTags: ["array", "divide-and-conquer", "tree", "binary-search-tree", "binary-tree"]
compare: "check"
entry: {"method": "sortedArrayToBST", "params": [{"name": "nums", "type": "integer[]"}], "returns": "TreeNode"}
examples: ["[-10,-3,0,5,9]", "[1,3]"]
---

Given an integer array `nums` where the elements are sorted in **ascending order**, convert *it to a* ***height-balanced*** *binary search tree*.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/02/18/btree1.jpg)

```
Input: nums = [-10,-3,0,5,9]
Output: [0,-3,9,-10,null,5]
Explanation: [0,-10,5,null,-3,null,9] is also accepted:

![](https://assets.leetcode.com/uploads/2021/02/18/btree2.jpg)
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2021/02/18/btree.jpg)

```
Input: nums = [1,3]
Output: [3,1]
Explanation: [1,null,3] and [3,1] are both height-balanced BSTs.
```

**Constraints:**

- `1 <= nums.length <= 10⁴`
- `-10⁴ <= nums[i] <= 10⁴`
- `nums` is sorted in a **strictly increasing** order.

# Starter

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def sortedArrayToBST(self, nums: list[int]) -> TreeNode | None:
        
```

# Hints

1. To keep the tree balanced, the root should split the array into two halves of equal size.
2. build(lo, hi): mid = (lo + hi) // 2 is the root; build the left subtree from lo..mid − 1 and the right from mid + 1..hi.

# Key points

- middle element as root keeps both sides the same size
- recurse on each half
- O(n) time, O(log n) recursion depth
- many balanced answers are valid; the tests accept any of them

# Solution: binary-search-recursion · Binary Search + Recursion · O(n) · O(log n) · reference

We design a recursive function `dfs(l, r)`, which represents that the values of the nodes to be constructed in the current binary search tree are within the index range `[l, r]` of the array nums. This function returns the root node of the constructed binary search tree.

The execution process of the function `dfs(l, r)` is as follows:

1. If `l > r`, it means the current array is empty, so return `null`.
2. If `l <= r`, take the element at index `mid =  (l + r) / (2)` of the array as the root node of the current binary search tree, where x denotes the floor function of x.
3. Recursively construct the left subtree of the current binary search tree, with the root node's value being the element at index `mid - 1` of the array. The values of the nodes in the left subtree are within the index range `[l, mid - 1]` of the array.
4. Recursively construct the right subtree of the current binary search tree, with the root node's value being the element at index `mid + 1` of the array. The values of the nodes in the right subtree are within the index range `[mid + 1, r]` of the array.
5. Return the root node of the current binary search tree.

The answer is the return value of the function `dfs(0, n - 1)`.

The time complexity is O(n), and the space complexity is O(log n). Here, n is the length of the array nums.

```python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def sortedArrayToBST(self, nums: List[int]) -> Optional[TreeNode]:
        def dfs(l: int, r: int) -> Optional[TreeNode]:
            if l > r:
                return None
            mid = (l + r) >> 1
            return TreeNode(nums[mid], dfs(l, mid - 1), dfs(mid + 1, r))

        return dfs(0, len(nums) - 1)
```

# Tests

```python
def check(args, got, expected):
    root = to_tree(got)
    vals = []
    def walk(n):
        if not n:
            return 0
        l = walk(n.left)
        vals.append(n.val)
        r = walk(n.right)
        if l < 0 or r < 0 or abs(l - r) > 1:
            return -1
        return 1 + max(l, r)
    return walk(root) >= 0 and vals == args[0]

def edge():
    return [[[0]], [[1, 3]], [[-10, -3, 0, 5, 9]], [[1, 2, 3, 4, 5, 6, 7, 8]]]

def random_case(rng):
    return [sorted(rng.sample(range(-50, 50), rng.randint(1, 12)))]

def perf(rng):
    return [[list(range(-5000, 5000))]]
```
