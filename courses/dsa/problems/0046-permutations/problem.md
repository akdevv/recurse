---
lc: 46
title: "Permutations"
difficulty: "Medium"
patterns: ["backtracking"]
lcTags: ["array", "backtracking"]
compare: "unordered"
entry: {"method": "permute", "params": [{"name": "nums", "type": "integer[]"}], "returns": "list<list<integer>>"}
examples: ["[1,2,3]", "[0,1]", "[1]"]
---

Given an array `nums` of distinct integers, return all the possible permutations. You can return the answer in **any order**.

**Example 1:**

```
Input: nums = [1,2,3]
Output: [[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]
```

**Example 2:**

```
Input: nums = [0,1]
Output: [[0,1],[1,0]]
```

**Example 3:**

```
Input: nums = [1]
Output: [[1]]
```

**Constraints:**

- `1 <= nums.length <= 6`
- `-10 <= nums[i] <= 10`
- All the integers of `nums` are **unique**.

# Starter

```python
class Solution:
    def permute(self, nums: list[int]) -> list[list[int]]:
        
```

# Hints

1. A permutation picks the first element (n choices), then the next from what's left, and so on.
2. Backtrack with a `used` array: for each unused number, mark it, append, recurse, then unmark and pop. Record when the path has n numbers.

# Key points

- n! permutations; at each level try every unused element
- track used elements with a boolean array (or swap in place)
- choose / explore / un-choose
- O(n·n!) time, O(n) extra space besides the output

# Solution: dfs-backtracking · DFS (Backtracking) · O(n × n!) · O(n) · reference

We design a function `dfs(i)` to represent that the first i positions have been filled, and now we need to fill the `i+1` position. We enumerate all possible numbers, if this number has not been filled, we fill in this number, and then continue to fill the next position, until all positions are filled.

The time complexity is O(n × n!), where n is the length of the array. There are `n!` permutations in total, and each permutation takes O(n) time to construct.

Similar problems:

- [47. Permutations II](https://github.com/doocs/leetcode/blob/main/solution/0000-0099/0047.Permutations%20II/README_EN.md)

```python
class Solution:
    def permute(self, nums: List[int]) -> List[List[int]]:
        def dfs(i: int):
            if i >= n:
                ans.append(t[:])
                return
            for j, x in enumerate(nums):
                if not vis[j]:
                    vis[j] = True
                    t[i] = x
                    dfs(i + 1)
                    vis[j] = False

        n = len(nums)
        vis = [False] * n
        t = [0] * n
        ans = []
        dfs(0)
        return ans
```

# Tests

```python
def edge():
    return [[[1]], [[0, 1]], [[1, 2, 3]], [[-10, 0, 10]], [[1, 2, 3, 4, 5, 6]]]

def random_case(rng):
    return [rng.sample(range(-10, 11), rng.randint(1, 5))]
```
