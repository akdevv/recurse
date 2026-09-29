---
lc: 55
title: "Jump Game"
difficulty: "Medium"
patterns: ["greedy"]
lcTags: ["array", "dynamic-programming", "greedy"]
entry: {"method": "canJump", "params": [{"name": "nums", "type": "integer[]"}], "returns": "boolean"}
examples: ["[2,3,1,1,4]", "[3,2,1,0,4]"]
---

You are given an integer array `nums`. You are initially positioned at the array's **first index**, and each element in the array represents your maximum jump length at that position.

Return `true` *if you can reach the last index, or* `false` *otherwise*.

**Example 1:**

```
Input: nums = [2,3,1,1,4]
Output: true
Explanation: Jump 1 step from index 0 to 1, then 3 steps to the last index.
```

**Example 2:**

```
Input: nums = [3,2,1,0,4]
Output: false
Explanation: You will always arrive at index 3 no matter what. Its maximum jump length is 0, which makes it impossible to reach the last index.
```

**Constraints:**

- `1 <= nums.length <= 10⁴`
- `0 <= nums[i] <= 10⁵`

# Starter

```python
class Solution:
    def canJump(self, nums: list[int]) -> bool:
        
```

# Hints

1. Track the farthest index you can reach so far.
2. Walk i from 0; if i > farthest, you're stuck (False). Otherwise farthest = max(farthest, i + nums[i]).

# Key points

- greedy: maintain the farthest reachable index
- stuck if the current index is beyond it
- O(n) time, O(1) space

# Solution: greedy · Greedy · O(n) · O(1) · reference

We use a variable mx to maintain the farthest index that can currently be reached, initially `mx = 0`.

We traverse the array from left to right. For each position i we traverse, if `mx < i`, it means that the current position cannot be reached, so we directly return `false`. Otherwise, the farthest position that we can reach by jumping from position i is `i+nums[i]`, we use `i+nums[i]` to update the value of mx, that is, `mx = max(mx, i + nums[i])`.

At the end of the traversal, we directly return `true`.

The time complexity is O(n), where n is the length of the array. The space complexity is O(1).

Similar problems:

- [45. Jump Game II](https://github.com/doocs/leetcode/blob/main/solution/0000-0099/0045.Jump%20Game%20II/README_EN.md)
- [1024. Video Stitching](https://github.com/doocs/leetcode/blob/main/solution/1000-1099/1024.Video%20Stitching/README_EN.md)
- [1326. Minimum Number of Taps to Open to Water a Garden](https://github.com/doocs/leetcode/blob/main/solution/1300-1399/1326.Minimum%20Number%20of%20Taps%20to%20Open%20to%20Water%20a%20Garden/README_EN.md)

```python
class Solution:
    def canJump(self, nums: List[int]) -> bool:
        mx = 0
        for i, x in enumerate(nums):
            if mx < i:
                return False
            mx = max(mx, i + x)
        return True
```

# Tests

```python

```
