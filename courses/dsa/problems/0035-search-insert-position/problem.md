---
lc: 35
title: "Search Insert Position"
difficulty: "Easy"
patterns: ["binary-search"]
lcTags: ["array", "binary-search"]
entry: {"method": "searchInsert", "params": [{"name": "nums", "type": "integer[]"}, {"name": "target", "type": "integer"}], "returns": "integer"}
examples: ["[1,3,5,6]\n5", "[1,3,5,6]\n2", "[1,3,5,6]\n7"]
---

Given a sorted array of distinct integers and a target value, return the index if the target is found. If not, return the index where it would be if it were inserted in order.

You must write an algorithm with `O(log n)` runtime complexity.

**Example 1:**

```
Input: nums = [1,3,5,6], target = 5
Output: 2
```

**Example 2:**

```
Input: nums = [1,3,5,6], target = 2
Output: 1
```

**Example 3:**

```
Input: nums = [1,3,5,6], target = 7
Output: 4
```

**Constraints:**

- `1 <= nums.length <= 10⁴`
- `-10⁴ <= nums[i] <= 10⁴`
- `nums` contains **distinct** values sorted in **ascending** order.
- `-10⁴ <= target <= 10⁴`

# Starter

```python
class Solution:
    def searchInsert(self, nums: list[int], target: int) -> int:
        
```

# Hints

1. You want the first index whose value is ≥ target. That's a "lower bound".
2. lo = 0, hi = n. While lo < hi: mid = (lo + hi) // 2; if nums[mid] < target: lo = mid + 1 else hi = mid. Return lo.

# Key points

- answer = first index with nums[i] >= target (lower bound)
- half-open range [lo, hi) with hi = n, so n is a possible answer
- O(log n); same as bisect_left

# Solution: binary-search · Binary Search · O(log n) · O(1) · reference

Since the array nums is already sorted, we can use the binary search method to find the insertion position of the target value target.

The time complexity is O(log n), and the space complexity is O(1). Here, n is the length of the array nums.

```python
class Solution:
    def searchInsert(self, nums: List[int], target: int) -> int:
        l, r = 0, len(nums)
        while l < r:
            mid = (l + r) >> 1
            if nums[mid] >= target:
                r = mid
            else:
                l = mid + 1
        return l
```

# Solution: binary-search-built-in-function · Binary Search (Built-in Function) · O(log n) · O(1)

We can also directly use the built-in function for binary search.

The time complexity is O(log n), where n is the length of the array nums. The space complexity is O(1).

```python
class Solution:
    def searchInsert(self, nums: List[int], target: int) -> int:
        return bisect_left(nums, target)
```

# Tests

```python
def edge():
    return [[[1], 0], [[1], 1], [[1], 2], [[1, 3, 5, 6], 5], [[1, 3, 5, 6], 2], [[1, 3, 5, 6], 7], [[1, 3, 5, 6], 0]]

def random_case(rng):
    nums = sorted(rng.sample(range(-20, 20), rng.randint(1, 10)))
    return [nums, rng.randint(-22, 22)]
```
