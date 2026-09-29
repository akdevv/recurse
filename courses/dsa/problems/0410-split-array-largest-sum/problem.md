---
lc: 410
title: "Split Array Largest Sum"
difficulty: "Hard"
patterns: ["binary-search-answer"]
lcTags: ["array", "binary-search", "dynamic-programming", "greedy", "prefix-sum"]
entry: {"method": "splitArray", "params": [{"name": "nums", "type": "integer[]"}, {"name": "k", "type": "integer"}], "returns": "integer"}
examples: ["[7,2,5,10,8]\n2", "[1,2,3,4,5]\n2"]
---

Given an integer array `nums` and an integer `k`, split `nums` into `k` non-empty subarrays such that the largest sum of any subarray is **minimized**.

Return *the minimized largest sum of the split*.

A **subarray** is a contiguous part of the array.

**Example 1:**

```
Input: nums = [7,2,5,10,8], k = 2
Output: 18
Explanation: There are four ways to split nums into two subarrays.
The best way is to split it into [7,2,5] and [10,8], where the largest sum among the two subarrays is only 18.
```

**Example 2:**

```
Input: nums = [1,2,3,4,5], k = 2
Output: 9
Explanation: There are four ways to split nums into two subarrays.
The best way is to split it into [1,2,3] and [4,5], where the largest sum among the two subarrays is only 9.
```

**Constraints:**

- `1 <= nums.length <= 1000`
- `0 <= nums[i] <= 10⁶`
- `1 <= k <= min(50, nums.length)`

# Starter

```python
class Solution:
    def splitArray(self, nums: list[int], k: int) -> int:
        
```

# Hints

1. Guess the answer X: can you split into at most k parts where every part's sum is ≤ X?
2. That check is greedy (start a new part when the next number would exceed X). Binary search X in [max(nums), sum(nums)].

# Key points

- binary search on the answer (the largest allowed part sum)
- greedy check: count parts needed with limit X; feasible if parts <= k
- range [max(nums), sum(nums)], O(n log(sum)) time
- same shape as Capacity to Ship Packages

# Solution: binary-search · Binary Search · O(n × log m) · O(1) · reference

We notice that the larger the maximum sum of the subarrays, the fewer the number of subarrays. When there is a maximum sum of the subarrays that meets the condition, then a larger maximum sum of the subarrays will definitely meet the condition. This means that we can perform a binary search for the maximum sum of the subarrays to find the smallest value that meets the condition.

We define the left boundary of the binary search as `left = max(nums)`, and the right boundary as `right = sum(nums)`. Then for each step of the binary search, we take the middle value `mid =  (left + right) / (2)`, and then determine whether there is a way to split the array so that the maximum sum of the subarrays does not exceed mid. If there is, it means that mid might be the smallest value that meets the condition, so we adjust the right boundary to mid. Otherwise, we adjust the left boundary to `mid + 1`.

How do we determine whether there is a way to split the array so that the maximum sum of the subarrays does not exceed mid? We can use a greedy method, traverse the array from left to right, and add the elements of the array to the subarray one by one. If the current sum of the subarray is greater than mid, then we add the current element to the next subarray. If we can split the array into no more than k subarrays, and the maximum sum of each subarray does not exceed mid, then mid is the smallest value that meets the condition. Otherwise, mid does not meet the condition.

The time complexity is O(n × log m), and the space complexity is O(1). Here, n and m are the length of the array and the sum of all elements in the array, respectively.

```python
class Solution:
    def splitArray(self, nums: List[int], k: int) -> int:
        def check(mx):
            s, cnt = inf, 0
            for x in nums:
                s += x
                if s > mx:
                    s = x
                    cnt += 1
            return cnt <= k

        left, right = max(nums), sum(nums)
        return left + bisect_left(range(left, right + 1), True, key=check)
```

# Tests

```python

```
