---
lc: 724
title: "Find Pivot Index"
difficulty: "Easy"
patterns: ["prefix-sum"]
lcTags: ["array", "prefix-sum"]
entry: {"method": "pivotIndex", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer"}
examples: ["[1,7,3,6,5,6]", "[1,2,3]", "[2,1,-1]"]
lcHints: ["Create an array sumLeft where sumLeft[i] is the sum of all the numbers to the left of index i.", "Create an array sumRight where sumRight[i] is the sum of all the numbers to the right of index i.", "For each index i, check if sumLeft[i] equals sumRight[i]. If so, return i. If no such i is found, return -1."]
---

Given an array of integers `nums`, calculate the **pivot index** of this array.

The **pivot index** is the index where the sum of all the numbers **strictly** to the left of the index is equal to the sum of all the numbers **strictly** to the index's right.

If the index is on the left edge of the array, then the left sum is `0` because there are no elements to the left. This also applies to the right edge of the array.

Return *the **leftmost pivot index***. If no such index exists, return `-1`.

**Example 1:**

```
Input: nums = [1,7,3,6,5,6]
Output: 3
Explanation:
The pivot index is 3.
Left sum = nums[0] + nums[1] + nums[2] = 1 + 7 + 3 = 11
Right sum = nums[4] + nums[5] = 5 + 6 = 11
```

**Example 2:**

```
Input: nums = [1,2,3]
Output: -1
Explanation:
There is no index that satisfies the conditions in the problem statement.
```

**Example 3:**

```
Input: nums = [2,1,-1]
Output: 0
Explanation:
The pivot index is 0.
Left sum = 0 (no elements to the left of index 0)
Right sum = nums[1] + nums[2] = 1 + -1 = 0
```

**Constraints:**

- `1 <= nums.length <= 10⁴`
- `-1000 <= nums[i] <= 1000`

**Note:** This question is the same as 1991: [https://leetcode.com/problems/find-the-middle-index-in-array/](https://leetcode.com/problems/find-the-middle-index-in-array/)

# Starter

```python
class Solution:
    def pivotIndex(self, nums: list[int]) -> int:
        
```

# Hints

1. At index i you need the sum to the left and the sum to the right. Recomputing both every time is O(n²).
2. Compute the total once. Walk left to right keeping `left`; the right sum is total − left − nums[i].

# Key points

- total once, then a running left sum
- right = total − left − nums[i]; pivot when left == right
- return the leftmost pivot, −1 if none
- O(n) time, O(1) space

# Solution: recount · Recompute both sides · O(n²) · O(1)

## Idea
For every index, sum both sides from scratch.

## Complexity
- **Time: O(n²)**.
- **Space: O(n)** for the slices.

```python
class Solution:
    def pivotIndex(self, nums: list[int]) -> int:
        for i in range(len(nums)):
            if sum(nums[:i]) == sum(nums[i + 1:]):
                return i
        return -1
```

# Solution: running · Total minus running left sum · O(n) · O(1) · reference

## Idea
Everything is either left of `i`, at `i`, or right of `i`. So once you know the total and the running left sum, the right sum is `total - left - x`. No second array needed.

Check before adding `x` to `left`, since the pivot itself belongs to neither side.

## Complexity
- **Time: O(n)**, two passes.
- **Space: O(1)**.

```python
class Solution:
    def pivotIndex(self, nums: list[int]) -> int:
        total, left = sum(nums), 0
        for i, x in enumerate(nums):
            if left == total - left - x:
                return i
            left += x
        return -1
```

# Tests

```python
def edge():
    return [[[1]], [[0]], [[1, 2, 3]], [[2, 1, -1]], [[0, 0, 0]], [[-1, -1, -1, -1, -1, 0]]]

def random_case(rng):
    return [[rng.randint(-3, 3) for _ in range(rng.randint(1, 10))]]

def perf(rng):
    return [[[1] * 10000]]
```
