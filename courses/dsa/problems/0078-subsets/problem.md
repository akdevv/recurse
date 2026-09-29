---
lc: 78
title: "Subsets"
difficulty: "Medium"
patterns: ["backtracking"]
lcTags: ["array", "backtracking", "bit-manipulation"]
compare: "groups"
entry: {"method": "subsets", "params": [{"name": "nums", "type": "integer[]"}], "returns": "list<list<integer>>"}
examples: ["[1,2,3]", "[0]"]
---

Given an integer array `nums` of **unique** elements, return *all possible* *subsets* *(the power set)*.

The solution set **must not** contain duplicate subsets. Return the solution in **any order**.

**Example 1:**

```
Input: nums = [1,2,3]
Output: [[],[1],[2],[1,2],[3],[1,3],[2,3],[1,2,3]]
```

**Example 2:**

```
Input: nums = [0]
Output: [[],[0]]
```

**Constraints:**

- `1 <= nums.length <= 10`
- `-10 <= nums[i] <= 10`
- All the numbers of `nums` are **unique**.

# Starter

```python
class Solution:
    def subsets(self, nums: list[int]) -> list[list[int]]:
        
```

# Hints

1. Every element is either in a subset or not: 2ⁿ subsets. Can you build them by making that choice one element at a time?
2. Backtrack(i, path): record path, then for j from i to n − 1: add nums[j], recurse with j + 1, remove it. (Or iterate: start with [[]] and for each x add x to every existing subset.)

# Key points

- decision tree: include or skip each element → 2ⁿ subsets
- backtracking: choose, explore, un-choose; record the path at every node
- O(n·2ⁿ) time (copying each subset), O(n) recursion depth
- bitmask alternative: each number 0..2ⁿ-1 is one subset

# Solution: dfs-backtracking · DFS (Backtracking) · O(n × 2ⁿ) · O(n) · reference

We design a function `dfs(i)`, which represents starting the search from the ith element of the array for all subsets. The execution logic of the function `dfs(i)` is as follows:

- If `i = n`, it means the current search has ended. Add the current subset t to the answer array ans, and then return.
- Otherwise, we can choose not to select the current element and directly execute `dfs(i + 1)`; or we can choose the current element, i.e., add the current element `nums[i]` to the subset t, and then execute `dfs(i + 1)`. Note that we need to remove `nums[i]` from the subset t after executing `dfs(i + 1)` (backtracking).

In the main function, we call `dfs(0)`, i.e., start searching all subsets from the first element of the array. Finally, return the answer array ans.

The time complexity is O(n × 2ⁿ), and the space complexity is O(n). Here, n is the length of the array. There are a total of 2ⁿ subsets, and each subset takes O(n) time to construct.

```python
class Solution:
    def subsets(self, nums: List[int]) -> List[List[int]]:
        def dfs(i: int):
            if i == len(nums):
                ans.append(t[:])
                return
            dfs(i + 1)
            t.append(nums[i])
            dfs(i + 1)
            t.pop()

        ans = []
        t = []
        dfs(0)
        return ans
```

# Solution: binary-enumeration · Binary Enumeration · O(n × 2ⁿ) · O(n)

We can also use the method of binary enumeration to get all subsets.

We can use 2ⁿ binary numbers to represent all subsets of n elements. For the current binary number mask, if the ith bit is 1, it means that the ith element is selected, otherwise it means that the ith element is not selected.

The time complexity is O(n × 2ⁿ), and the space complexity is O(n). Here, n is the length of the array. There are a total of 2ⁿ subsets, and each subset takes O(n) time to construct.

```python
class Solution:
    def subsets(self, nums: List[int]) -> List[List[int]]:
        ans = []
        for mask in range(1 << len(nums)):
            t = [x for i, x in enumerate(nums) if mask >> i & 1]
            ans.append(t)
        return ans
```

# Tests

```python
def edge():
    return [[[0]], [[1, 2]], [[1, 2, 3]], [[-10, 10]], [list(range(10))]]

def random_case(rng):
    return [rng.sample(range(-10, 11), rng.randint(1, 6))]
```
