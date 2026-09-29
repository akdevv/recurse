---
lc: 34
title: "Find First and Last Position of Element in Sorted Array"
difficulty: "Medium"
patterns: ["binary-search"]
lcTags: ["array", "binary-search"]
entry: {"method": "searchRange", "params": [{"name": "nums", "type": "integer[]"}, {"name": "target", "type": "integer"}], "returns": "integer[]"}
examples: ["[5,7,7,8,8,10]\n8", "[5,7,7,8,8,10]\n6", "[]\n0"]
---

Given an array of integers `nums` sorted in non-decreasing order, find the starting and ending position of a given `target` value.

If `target` is not found in the array, return `[-1, -1]`.

You must write an algorithm with `O(log n)` runtime complexity.

**Example 1:**

```
Input: nums = [5,7,7,8,8,10], target = 8
Output: [3,4]
```

**Example 2:**

```
Input: nums = [5,7,7,8,8,10], target = 6
Output: [-1,-1]
```

**Example 3:**

```
Input: nums = [], target = 0
Output: [-1,-1]
```

**Constraints:**

- `0 <= nums.length <= 10⁵`
- `-10⁹ <= nums[i] <= 10⁹`
- `nums` is a non-decreasing array.
- `-10⁹ <= target <= 10⁹`

# Starter

```python
class Solution:
    def searchRange(self, nums: list[int], target: int) -> list[int]:
        
```

# Hints

1. Run two binary searches: one for the first position of target, one for the first position of target + 1.
2. lower_bound(target) gives the start. lower_bound(target + 1) − 1 gives the end. If start is out of range or nums[start] != target, return [-1, -1].

# Key points

- two lower-bound searches: first index >= target, first index >= target + 1
- end = second result - 1
- O(log n); a linear scan after finding one hit is O(n) in the worst case

# Solution: binary-search · Binary Search · O(log n) · O(1) · reference

We can perform two binary searches to find the left boundary and the right boundary.

The time complexity is O(log n), where n is the length of the array nums. The space complexity is O(1).

```python
class Solution:
    def searchRange(self, nums: List[int], target: int) -> List[int]:
        l = bisect_left(nums, target)
        r = bisect_left(nums, target + 1)
        return [-1, -1] if l == r else [l, r - 1]
```

# Tests

```python
def edge():
    return [[[], 0], [[1], 1], [[1], 0], [[2, 2], 2], [[5, 7, 7, 8, 8, 10], 8], [[5, 7, 7, 8, 8, 10], 6], [[1, 1, 1, 1], 1]]

def random_case(rng):
    nums = sorted(rng.randint(-5, 5) for _ in range(rng.randint(0, 10)))
    return [nums, rng.randint(-6, 6)]

def perf(rng):
    return [[[7] * 100000, 7], [sorted(rng.randint(-10**9, 10**9) for _ in range(100000)), 0]]
```
