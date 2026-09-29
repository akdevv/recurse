---
lc: 33
title: "Search in Rotated Sorted Array"
difficulty: "Medium"
patterns: ["binary-search"]
lcTags: ["array", "binary-search"]
entry: {"method": "search", "params": [{"name": "nums", "type": "integer[]"}, {"name": "target", "type": "integer"}], "returns": "integer"}
examples: ["[4,5,6,7,0,1,2]\n0", "[4,5,6,7,0,1,2]\n3", "[1]\n0"]
---

There is an integer array `nums` sorted in ascending order (with **distinct** values).

Prior to being passed to your function, `nums` is **possibly left rotated** at an unknown index `k` (`1 <= k < nums.length`) such that the resulting array is `[nums[k], nums[k+1], ..., nums[n-1], nums[0], nums[1], ..., nums[k-1]]` (**0-indexed**). For example, `[0,1,2,4,5,6,7]` might be left rotated by `3` indices and become `[4,5,6,7,0,1,2]`.

Given the array `nums` **after** the possible rotation and an integer `target`, return *the index of* `target` *if it is in* `nums`*, or* `-1` *if it is not in* `nums`.

You must write an algorithm with `O(log n)` runtime complexity.

**Example 1:**

```
Input: nums = [4,5,6,7,0,1,2], target = 0
Output: 4
```

**Example 2:**

```
Input: nums = [4,5,6,7,0,1,2], target = 3
Output: -1
```

**Example 3:**

```
Input: nums = [1], target = 0
Output: -1
```

**Constraints:**

- `1 <= nums.length <= 5000`
- `-10⁴ <= nums[i] <= 10⁴`
- All values of `nums` are **unique**.
- `nums` is an ascending array that is possibly rotated.
- `-10⁴ <= target <= 10⁴`

# Starter

```python
class Solution:
    def search(self, nums: list[int], target: int) -> int:
        
```

# Hints

1. After picking mid, at least one of the two halves [lo, mid] or [mid, hi] is sorted normally. Which one?
2. If nums[lo] <= nums[mid], the left half is sorted: go left if nums[lo] <= target < nums[mid], else right. Otherwise the right half is sorted: go right if nums[mid] < target <= nums[hi], else left.

# Key points

- one half around mid is always sorted
- check whether target lies inside the sorted half's range; if yes search there, else the other half
- O(log n); values are unique

# Solution: binary-search · Binary Search · O(log n) · O(1) · reference

We use binary search to divide the array into two parts, `[left,.. mid]` and `[mid + 1,.. right]`. At this point, we can find that one part must be sorted.

Therefore, we can determine whether target is in this part based on the sorted part:

- If the elements in the range `[0,.. mid]` form a sorted array:
    - If `nums[0] <= target <= nums[mid]`, then our search range can be narrowed down to `[left,.. mid]`;
    - Otherwise, search in `[mid + 1,.. right]`;
- If the elements in the range `[mid + 1, n - 1]` form a sorted array:
    - If `nums[mid] < target <= nums[n - 1]`, then our search range can be narrowed down to `[mid + 1,.. right]`;
    - Otherwise, search in `[left,.. mid]`.

The termination condition for binary search is `left >= right`. If at the end we find that `nums[left]` is not equal to target, it means that there is no element with a value of target in the array, and we return -1. Otherwise, we return the index left.

The time complexity is O(log n), where n is the length of the array nums. The space complexity is O(1).

```python
class Solution:
    def search(self, nums: List[int], target: int) -> int:
        n = len(nums)
        left, right = 0, n - 1
        while left < right:
            mid = (left + right) >> 1
            if nums[0] <= nums[mid]:
                if nums[0] <= target <= nums[mid]:
                    right = mid
                else:
                    left = mid + 1
            else:
                if nums[mid] < target <= nums[n - 1]:
                    left = mid + 1
                else:
                    right = mid
        return left if nums[left] == target else -1
```

# Tests

```python
def rotated(rng, n):
    nums = sorted(rng.sample(range(-30, 30), n))
    k = rng.randrange(n)
    return nums[k:] + nums[:k]

def edge():
    return [[[1], 0], [[1], 1], [[3, 1], 1], [[3, 1], 3], [[4, 5, 6, 7, 0, 1, 2], 0], [[4, 5, 6, 7, 0, 1, 2], 3], [[1, 3], 3]]

def random_case(rng):
    nums = rotated(rng, rng.randint(1, 10))
    return [nums, rng.choice(nums) if rng.random() < 0.6 else rng.randint(-31, 31)]

def perf(rng):
    nums = list(range(5000))
    return [[nums[1234:] + nums[:1234], 1233]]
```
