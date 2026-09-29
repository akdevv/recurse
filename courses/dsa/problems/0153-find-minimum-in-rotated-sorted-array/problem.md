---
lc: 153
title: "Find Minimum in Rotated Sorted Array"
difficulty: "Medium"
patterns: ["binary-search"]
lcTags: ["array", "binary-search"]
entry: {"method": "findMin", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer"}
examples: ["[3,4,5,1,2]", "[4,5,6,7,0,1,2]", "[11,13,15,17]"]
lcHints: ["Array was originally in ascending order. Now that the array is rotated, there would be a point in the array where there is a small deflection from the increasing sequence. eg. The array would be something like [4, 5, 6, 7, 0, 1, 2].", "You can divide the search space into two and see which direction to go.\r\nCan you think of an algorithm which has O(logN) search complexity?", "<ol>\r\n<li>All the elements to the left of inflection point > first element of the array.</li>\r\n<li>All the elements to the right of inflection point < first element of the array.</li>\r\n<ol>"]
---

Suppose an array of length `n` sorted in ascending order is **rotated** between `1` and `n` times. For example, the array `nums = [0,1,2,4,5,6,7]` might become:

- `[4,5,6,7,0,1,2]` if it was rotated `4` times.
- `[0,1,2,4,5,6,7]` if it was rotated `7` times.

Notice that **rotating** an array `[a[0], a[1], a[2], ..., a[n-1]]` 1 time results in the array `[a[n-1], a[0], a[1], a[2], ..., a[n-2]]`.

Given the sorted rotated array `nums` of **unique** elements, return *the minimum element of this array*.

You must write an algorithm that runs in `O(log n) time`.

**Example 1:**

```
Input: nums = [3,4,5,1,2]
Output: 1
Explanation: The original array was [1,2,3,4,5] rotated 3 times.
```

**Example 2:**

```
Input: nums = [4,5,6,7,0,1,2]
Output: 0
Explanation: The original array was [0,1,2,4,5,6,7] and it was rotated 4 times.
```

**Example 3:**

```
Input: nums = [11,13,15,17]
Output: 11
Explanation: The original array was [11,13,15,17] and it was rotated 4 times.
```

**Constraints:**

- `n == nums.length`
- `1 <= n <= 5000`
- `-5000 <= nums[i] <= 5000`
- All the integers of `nums` are **unique**.
- `nums` is sorted and rotated between `1` and `n` times.

# Starter

```python
class Solution:
    def findMin(self, nums: list[int]) -> int:
        
```

# Hints

1. Compare nums[mid] with nums[hi]. If nums[mid] > nums[hi], the drop (and the minimum) is to the right of mid.
2. While lo < hi: if nums[mid] > nums[hi]: lo = mid + 1 else hi = mid. Return nums[lo].

# Key points

- compare mid with the right end to know which side holds the rotation point
- nums[mid] > nums[hi] → minimum is right of mid; else it's mid or left
- O(log n), works when not rotated at all

# Solution: binary-search · Binary Search · O(log n) · O(1) · reference

We can use binary search to solve this problem.

First, we define two pointers l and r pointing to the start and end of the array respectively. Then we enter a loop until l is no longer less than r.

In each iteration, we calculate the middle position mid and compare `nums[mid]` with `nums[n-1]`. If `nums[mid]` is greater than `nums[n-1]`, the minimum value is to the right of mid, so we update l to `mid + 1`. Otherwise, the minimum value is at mid or to its left, so we update r to mid. When the loop ends, pointer l will point to the minimum value, and we return `nums[l]`.

The time complexity is O(log n), where n is the length of array nums. The space complexity is O(1).

```python
class Solution:
    def findMin(self, nums: List[int]) -> int:
        l, r = 0, len(nums) - 1
        while l < r:
            mid = (l + r) >> 1
            if nums[mid] > nums[-1]:
                l = mid + 1
            else:
                r = mid
        return nums[l]
```

# Tests

```python
def edge():
    return [[[1]], [[2, 1]], [[1, 2]], [[3, 4, 5, 1, 2]], [[4, 5, 6, 7, 0, 1, 2]], [[11, 13, 15, 17]]]

def random_case(rng):
    nums = sorted(rng.sample(range(-30, 30), rng.randint(1, 10)))
    k = rng.randrange(len(nums))
    return [nums[k:] + nums[:k]]
```
