---
lc: 53
title: "Maximum Subarray"
difficulty: "Medium"
patterns: ["dynamic-programming", "greedy"]
lcTags: ["array", "divide-and-conquer", "dynamic-programming"]
entry: {"method": "maxSubArray", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer"}
examples: ["[-2,1,-3,4,-1,2,1,-5,4]", "[1]", "[5,4,-1,7,8]"]
---

Given an integer array `nums`, find the subarray with the largest sum, and return *its sum*.

**Example 1:**

```
Input: nums = [-2,1,-3,4,-1,2,1,-5,4]
Output: 6
Explanation: The subarray [4,-1,2,1] has the largest sum 6.
```

**Example 2:**

```
Input: nums = [1]
Output: 1
Explanation: The subarray [1] has the largest sum 1.
```

**Example 3:**

```
Input: nums = [5,4,-1,7,8]
Output: 23
Explanation: The subarray [5,4,-1,7,8] has the largest sum 23.
```

**Constraints:**

- `1 <= nums.length <= 10⁵`
- `-10⁴ <= nums[i] <= 10⁴`

**Follow up:** If you have figured out the `O(n)` solution, try coding another solution using the **divide and conquer** approach, which is more subtle.

# Starter

```python
class Solution:
    def maxSubArray(self, nums: list[int]) -> int:
        
```

# Hints

1. For each position, the best subarray ending here either extends the previous best or starts fresh.
2. Kadane: cur = max(x, cur + x); best = max(best, cur).

# Key points

- Kadane's algorithm: drop the running sum when it becomes worse than starting over
- best subarray ending at i = max(nums[i], best ending at i - 1 + nums[i])
- O(n) time, O(1) space
- all-negative input returns the largest single element

# Solution: dynamic-programming · Dynamic Programming · O(n) · O(1) · reference

We define `f[i]` to represent the maximum sum of a contiguous subarray ending at element `nums[i]`. Initially, `f[0] = nums[0]`. The final answer we seek is `\max_{0 <= i < n} f[i]`.

Consider `f[i]` for `i >= 1`. Its state transition equation is:

```
f[i] = max(f[i - 1] + nums[i], nums[i])
```

That is:

```
f[i] = max(f[i - 1], 0) + nums[i]
```

Since `f[i]` is only related to `f[i - 1]`, we can use a single variable f to maintain the current value of `f[i]` and perform the state transition. The answer is `\max_{0 <= i < n} f`.

The time complexity is O(n), where n is the length of the array nums. The space complexity is O(1).

```python
class Solution:
    def maxSubArray(self, nums: List[int]) -> int:
        ans = f = nums[0]
        for x in nums[1:]:
            f = max(f, 0) + x
            ans = max(ans, f)
        return ans
```

# Solution: divide-and-conquer · Divide and Conquer · O(n log n) · O(log n)

Split the array at the midpoint. The answer is the max of the left half, the right half, and the best subarray that crosses the midpoint (max suffix of the left plus max prefix of the right).

The time complexity is O(n log n) and the space complexity is O(log n), where n is the length of the array.

```python
class Solution:
    def maxSubArray(self, nums: List[int]) -> int:
        def crossMaxSub(nums, left, mid, right):
            lsum = rsum = 0
            lmx = rmx = -inf
            for i in range(mid, left - 1, -1):
                lsum += nums[i]
                lmx = max(lmx, lsum)
            for i in range(mid + 1, right + 1):
                rsum += nums[i]
                rmx = max(rmx, rsum)
            return lmx + rmx

        def maxSub(nums, left, right):
            if left == right:
                return nums[left]
            mid = (left + right) >> 1
            lsum = maxSub(nums, left, mid)
            rsum = maxSub(nums, mid + 1, right)
            csum = crossMaxSub(nums, left, mid, right)
            return max(lsum, rsum, csum)

        left, right = 0, len(nums) - 1
        return maxSub(nums, left, right)
```

# Tests

```python

```
