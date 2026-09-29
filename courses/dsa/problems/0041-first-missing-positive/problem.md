---
lc: 41
title: "First Missing Positive"
difficulty: "Hard"
patterns: ["cyclic-sort"]
lcTags: ["array", "hash-table"]
entry: {"method": "firstMissingPositive", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer"}
examples: ["[1,2,0]", "[3,4,-1,1]", "[7,8,9,11,12]"]
lcHints: ["Think about how you would solve the problem in non-constant space.  Can you apply that logic to the existing space?", "We don't care about duplicates or non-positive integers", "Remember that O(2n) = O(n)"]
---

Given an unsorted integer array `nums`. Return the *smallest positive integer* that is *not present* in `nums`.

You must implement an algorithm that runs in `O(n)` time and uses `O(1)` auxiliary space.

**Example 1:**

```
Input: nums = [1,2,0]
Output: 3
Explanation: The numbers in the range [1,2] are all in the array.
```

**Example 2:**

```
Input: nums = [3,4,-1,1]
Output: 2
Explanation: 1 is in the array but 2 is missing.
```

**Example 3:**

```
Input: nums = [7,8,9,11,12]
Output: 1
Explanation: The smallest positive integer 1 is missing.
```

**Constraints:**

- `1 <= nums.length <= 10⁵`
- `-2³¹ <= nums[i] <= 2³¹ - 1`

# Starter

```python
class Solution:
    def firstMissingPositive(self, nums: list[int]) -> int:
        
```

# Hints

1. The answer is always in 1..n + 1. Values outside that range can be ignored.
2. Cyclic sort: swap each value v in 1..n to index v − 1 until it's in place. Then the first index i with nums[i] != i + 1 gives i + 1.

# Key points

- the answer is between 1 and n + 1
- cyclic sort: put each v in 1..n at index v - 1 by swapping
- scan for the first slot that doesn't hold i + 1
- O(n) time (each swap fixes one value), O(1) space

# Solution: in-place-swap · In-place Swap · O(n) · O(1) · reference

We assume the length of the array nums is n, then the smallest positive integer must be in the range `[1, .., n + 1]`. We can traverse the array and swap each number x to its correct position, that is, the position `x - 1`. If x is not in the range `[1, n + 1]`, then we can ignore it.

After the traversal, we traverse the array again. If `i+1` is not equal to `nums[i]`, then `i+1` is the smallest positive integer we are looking for.

The time complexity is O(n), where n is the length of the array. The space complexity is O(1).

```python
class Solution:
    def firstMissingPositive(self, nums: List[int]) -> int:
        n = len(nums)
        for i in range(n):
            while 1 <= nums[i] <= n and nums[i] != nums[nums[i] - 1]:
                j = nums[i] - 1
                nums[i], nums[j] = nums[j], nums[i]
        for i in range(n):
            if nums[i] != i + 1:
                return i + 1
        return n + 1
```

# Tests

```python

```
