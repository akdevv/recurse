---
lc: 704
title: "Binary Search"
difficulty: "Easy"
patterns: ["binary-search"]
lcTags: ["array", "binary-search"]
entry: {"method": "search", "params": [{"name": "nums", "type": "integer[]"}, {"name": "target", "type": "integer"}], "returns": "integer"}
examples: ["[-1,0,3,5,9,12]\n9", "[-1,0,3,5,9,12]\n2"]
---

Given an array of integers `nums` which is sorted in ascending order, and an integer `target`, write a function to search `target` in `nums`. If `target` exists, then return its index. Otherwise, return `-1`.

You must write an algorithm with `O(log n)` runtime complexity.

**Example 1:**

```
Input: nums = [-1,0,3,5,9,12], target = 9
Output: 4
Explanation: 9 exists in nums and its index is 4
```

**Example 2:**

```
Input: nums = [-1,0,3,5,9,12], target = 2
Output: -1
Explanation: 2 does not exist in nums so return -1
```

**Constraints:**

- `1 <= nums.length <= 10⁴`
- `-10⁴ < nums[i], target < 10⁴`
- All the integers in `nums` are **unique**.
- `nums` is sorted in ascending order.

# Starter

```python
class Solution:
    def search(self, nums: list[int], target: int) -> int:
        
```

# Hints

1. The array is sorted. Comparing target with the middle element tells you which half can't contain it.
2. lo = 0, hi = n − 1. While lo <= hi: mid = (lo + hi) // 2; equal → return mid; smaller → lo = mid + 1; bigger → hi = mid − 1.

# Key points

- each comparison with the middle discards half the range
- loop while lo <= hi, move lo = mid + 1 or hi = mid - 1
- O(log n) time, O(1) space
- return -1 when the range becomes empty

# Solution: binary-search · Binary Search · O(log n) · O(1) · reference

We define the left boundary `l=0` and the right boundary `r=n-1` for binary search.

In each iteration, we calculate the middle position `mid=(l+r)/2`, then compare the size of `nums[mid]` and target.

- If `nums[mid] >= target`, it means target is in the left half, so we move the right boundary r to mid;
- Otherwise, it means target is in the right half, so we move the left boundary l to `mid+1`.

The loop ends when `l<r`, at this point `nums[l]` is the target value we are looking for. If `nums[l]=target`, return l; otherwise, return -1.

The time complexity is O(log n), where n is the length of the array nums. The space complexity is O(1).

```python
class Solution:
    def search(self, nums: List[int], target: int) -> int:
        l, r = 0, len(nums) - 1
        while l < r:
            mid = (l + r) >> 1
            if nums[mid] >= target:
                r = mid
            else:
                l = mid + 1
        return l if nums[l] == target else -1
```

# Tests

```python
def edge():
    return [[[5], 5], [[5], -5], [[-1, 0, 3, 5, 9, 12], 9], [[-1, 0, 3, 5, 9, 12], 2], [[1, 2], 1], [[1, 2], 2], [[1, 2], 3]]

def random_case(rng):
    nums = sorted(rng.sample(range(-20, 20), rng.randint(1, 10)))
    return [nums, rng.choice(nums) if rng.random() < 0.6 else rng.randint(-21, 21)]
```
