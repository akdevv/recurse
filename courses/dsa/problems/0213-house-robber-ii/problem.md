---
lc: 213
title: "House Robber II"
difficulty: "Medium"
patterns: ["dynamic-programming"]
lcTags: ["array", "dynamic-programming"]
entry: {"method": "rob", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer"}
examples: ["[2,3,2]", "[1,2,3,1]", "[1,2,3]"]
lcHints: ["Since House[1] and House[n] are adjacent, they cannot be robbed together. Therefore, the problem becomes to rob either House[1]-House[n-1] or House[2]-House[n], depending on which choice offers more money. Now the problem has degenerated to the <a href =\"https://leetcode.com/problems/house-robber/description/\">House Robber</a>, which is already been solved."]
---

You are a professional robber planning to rob houses along a street. Each house has a certain amount of money stashed. All houses at this place are **arranged in a circle.** That means the first house is the neighbor of the last one. Meanwhile, adjacent houses have a security system connected, and **it will automatically contact the police if two adjacent houses were broken into on the same night**.

Given an integer array `nums` representing the amount of money of each house, return *the maximum amount of money you can rob tonight **without alerting the police***.

**Example 1:**

```
Input: nums = [2,3,2]
Output: 3
Explanation: You cannot rob house 1 (money = 2) and then rob house 3 (money = 2), because they are adjacent houses.
```

**Example 2:**

```
Input: nums = [1,2,3,1]
Output: 4
Explanation: Rob house 1 (money = 1) and then rob house 3 (money = 3).
Total amount you can rob = 1 + 3 = 4.
```

**Example 3:**

```
Input: nums = [1,2,3]
Output: 3
```

**Constraints:**

- `1 <= nums.length <= 100`
- `0 <= nums[i] <= 1000`

# Starter

```python
class Solution:
    def rob(self, nums: list[int]) -> int:
        
```

# Hints

1. The first and last houses are neighbours now, so you can't rob both. Split into two cases.
2. Answer = max(rob(nums[1:]), rob(nums[:-1])) using House Robber I. With one house, return it.

# Key points

- circle → either exclude the first house or exclude the last
- reuse the linear House Robber twice
- single-house edge case
- O(n) time, O(1) space

# Solution: dynamic-programming · Dynamic Programming · O(n) · O(1) · reference

The circular arrangement means that at most one of the first and last houses can be chosen for theft, so this circular arrangement problem can be reduced to two single-row house problems.

The time complexity is O(n), where n is the length of the array. The space complexity is O(1).

```python
class Solution:
    def rob(self, nums: List[int]) -> int:
        def _rob(nums):
            f = g = 0
            for x in nums:
                f, g = max(f, g), f + x
            return max(f, g)

        if len(nums) == 1:
            return nums[0]
        return max(_rob(nums[1:]), _rob(nums[:-1]))
```

# Tests

```python

```
