---
lc: 90
title: "Subsets II"
difficulty: "Medium"
patterns: ["backtracking"]
lcTags: ["array", "backtracking", "bit-manipulation"]
compare: "groups"
entry: {"method": "subsetsWithDup", "params": [{"name": "nums", "type": "integer[]"}], "returns": "list<list<integer>>"}
examples: ["[1,2,2]", "[0]"]
---

Given an integer array `nums` that may contain duplicates, return *all possible* *subsets* *(the power set)*.

The solution set **must not** contain duplicate subsets. Return the solution in **any order**.

**Example 1:**

```
Input: nums = [1,2,2]
Output: [[],[1],[1,2],[1,2,2],[2],[2,2]]
```

**Example 2:**

```
Input: nums = [0]
Output: [[],[0]]
```

**Constraints:**

- `1 <= nums.length <= 10`
- `-10 <= nums[i] <= 10`

# Starter

```python
class Solution:
    def subsetsWithDup(self, nums: list[int]) -> list[list[int]]:
        
```

# Hints

1. Duplicates in the input create duplicate subsets. Sorting puts equal values together; how can you skip repeats?
2. Sort. In the loop `for j in range(i, n)`, skip j if j > i and nums[j] == nums[j − 1]: at a given depth, only the first copy starts a branch.

# Key points

- sort so duplicates are adjacent
- at each recursion level, use each distinct value only once as the next pick
- same template as Subsets otherwise
- O(n·2ⁿ) time

# Solution: sorting-dfs · Sorting + DFS · O(n × 2ⁿ) · O(n) · reference

We can first sort the array nums to facilitate deduplication.

Then, we design a function `dfs(i)`, which represents the current search for subsets starting from the i-th element. The execution logic of the function `dfs(i)` is as follows:

If `i >= n`, it means all elements have been searched, add the current subset to the answer array, and end the recursion.

If `i < n`, add the i-th element to the subset, execute `dfs(i + 1)`, then remove the i-th element from the subset. Next, we check if the i-th element is the same as the next element. If they are the same, skip the element in a loop until we find the first element different from the i-th element, then execute `dfs(i + 1)`.

Finally, we only need to call `dfs(0)` and return the answer array.

The time complexity is O(n × 2ⁿ), and the space complexity is O(n). Here, n is the length of the array nums.

```python
class Solution:
    def subsetsWithDup(self, nums: List[int]) -> List[List[int]]:
        def dfs(i: int):
            if i == len(nums):
                ans.append(t[:])
                return
            t.append(nums[i])
            dfs(i + 1)
            x = t.pop()
            while i + 1 < len(nums) and nums[i + 1] == x:
                i += 1
            dfs(i + 1)

        nums.sort()
        ans = []
        t = []
        dfs(0)
        return ans
```

# Solution: sorting-binary-enumeration · Sorting + Binary Enumeration · O(n × 2ⁿ) · O(n)

Similar to Solution 1, we first sort the array nums to facilitate deduplication.

Next, we enumerate a binary number mask in the range `[0, 2ⁿ)`, where the binary representation of mask is an n-bit bit string. If the i-th bit of mask is 1, it means selecting `nums[i]`, and 0 means not selecting `nums[i]`. Note that if the `(i - 1)`-th bit of mask is 0 and `nums[i] = nums[i - 1]`, it means that the i-th element is the same as the `(i - 1)`-th element in the current enumeration scheme. To avoid duplication, we skip this case. Otherwise, we add the subset corresponding to mask to the answer array.

After the enumeration, we return the answer array.

The time complexity is O(n × 2ⁿ), and the space complexity is O(n). Here, n is the length of the array nums.

```python
class Solution:
    def subsetsWithDup(self, nums: List[int]) -> List[List[int]]:
        nums.sort()
        n = len(nums)
        ans = []
        for mask in range(1 << n):
            ok = True
            t = []
            for i in range(n):
                if mask >> i & 1:
                    if i and (mask >> (i - 1) & 1) == 0 and nums[i] == nums[i - 1]:
                        ok = False
                        break
                    t.append(nums[i])
            if ok:
                ans.append(t)
        return ans
```

# Tests

```python

```
