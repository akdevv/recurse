---
lc: 162
title: "Find Peak Element"
difficulty: "Medium"
patterns: ["binary-search"]
lcTags: ["array", "binary-search"]
compare: "check"
entry: {"method": "findPeakElement", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer"}
examples: ["[1,2,3,1]", "[1,2,1,3,5,6,4]"]
---

A peak element is an element that is strictly greater than its neighbors.

Given a **0-indexed** integer array `nums`, find a peak element, and return its index. If the array contains multiple peaks, return the index to **any of the peaks**.

You may imagine that `nums[-1] = nums[n] = -∞`. In other words, an element is always considered to be strictly greater than a neighbor that is outside the array.

You must write an algorithm that runs in `O(log n)` time.

**Example 1:**

```
Input: nums = [1,2,3,1]
Output: 2
Explanation: 3 is a peak element and your function should return the index number 2.
```

**Example 2:**

```
Input: nums = [1,2,1,3,5,6,4]
Output: 5
Explanation: Your function can return either index number 1 where the peak element is 2, or index number 5 where the peak element is 6.
```

**Constraints:**

- `1 <= nums.length <= 1000`
- `-2³¹ <= nums[i] <= 2³¹ - 1`
- `nums[i] != nums[i + 1]` for all valid `i`.

# Starter

```python
class Solution:
    def findPeakElement(self, nums: list[int]) -> int:
        
```

# Hints

1. If nums[mid] < nums[mid + 1], walking uphill to the right must reach a peak (the edge counts as −∞).
2. While lo < hi: if nums[mid] < nums[mid + 1]: lo = mid + 1 else hi = mid. Return lo.

# Key points

- neighbours are never equal and the ends count as -inf, so a peak always exists
- go toward the bigger neighbour: that side must contain a peak
- O(log n); any peak is accepted

# Solution: binary-search · Binary Search · O(log n) · O(1) · reference

We define the left boundary of binary search as `left=0` and the right boundary as `right=n-1`, where n is the length of the array. In each step of binary search, we find the middle element mid of the current interval, and compare the values of mid and its right neighbor `mid+1`:

- If the value of mid is greater than the value of `mid+1`, there exists a peak element on the left side, and we update the right boundary right to mid.
- Otherwise, there exists a peak element on the right side, and we update the left boundary left to `mid+1`.
- Finally, when the left boundary left is equal to the right boundary right, we have found the peak element of the array.

The time complexity is O(log n), where n is the length of the array nums. Each step of binary search can reduce the search interval by half, so the time complexity is O(log n). The space complexity is O(1).

```python
class Solution:
    def findPeakElement(self, nums: List[int]) -> int:
        left, right = 0, len(nums) - 1
        while left < right:
            mid = (left + right) >> 1
            if nums[mid] > nums[mid + 1]:
                right = mid
            else:
                left = mid + 1
        return left
```

# Tests

```python
def check(args, got, expected):
    nums = args[0]
    n = len(nums)
    return isinstance(got, int) and 0 <= got < n and (got == 0 or nums[got] > nums[got - 1]) \
        and (got == n - 1 or nums[got] > nums[got + 1])

def edge():
    return [[[1]], [[1, 2]], [[2, 1]], [[1, 2, 3, 1]], [[1, 2, 1, 3, 5, 6, 4]], [[-2**31, 2**31 - 1]]]

def random_case(rng):
    nums = [rng.randint(-10, 10)]
    for _ in range(rng.randint(0, 9)):
        v = rng.randint(-10, 10)
        while v == nums[-1]:
            v = rng.randint(-10, 10)
        nums.append(v)
    return [nums]
```
