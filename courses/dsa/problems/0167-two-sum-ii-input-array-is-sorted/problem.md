---
lc: 167
title: "Two Sum II - Input Array Is Sorted"
difficulty: "Medium"
patterns: ["two-pointers"]
lcTags: ["array", "two-pointers", "binary-search"]
entry: {"method": "twoSum", "params": [{"name": "numbers", "type": "integer[]"}, {"name": "target", "type": "integer"}], "returns": "integer[]"}
examples: ["[2,7,11,15]\n9", "[2,3,4]\n6", "[-1,0]\n-1"]
---

You are given a **1-indexed** array of integers `numbers` that is already **sorted in non-decreasing order**.

Find **two** numbers such that they add up to a specific `target` number. Let these two numbers be `numbers[index₁]` and `numbers[index₂]` where `1 <= index₁ < index₂ <= numbers.length`.

Return the indices of the two numbers `index₁` and `index₂` as an integer array `[index₁, index₂]` of length 2.

The tests are generated such that there is **exactly one solution**. You **may not** use the same element twice.

Your solution must use only constant extra space.

**Example 1:**

```
Input: numbers = [2,7,11,15], target = 9
Output: [1,2]
Explanation: The sum of 2 and 7 is 9. Therefore, index1 = 1, index2 = 2. We return [1, 2].
```

**Example 2:**

```
Input: numbers = [2,3,4], target = 6
Output: [1,3]
Explanation: The sum of 2 and 4 is 6. Therefore index1 = 1, index2 = 3. We return [1, 3].
```

**Example 3:**

```
Input: numbers = [-1,0], target = -1
Output: [1,2]
Explanation: The sum of -1 and 0 is -1. Therefore index1 = 1, index2 = 2. We return [1, 2].
```

**Constraints:**

- `2 <= numbers.length <= 3 * 10⁴`
- `-1000 <= numbers[i] <= 1000`
- `numbers` is sorted in **non-decreasing order**.
- `-1000 <= target <= 1000`
- The tests are generated such that there is **exactly one solution**.

# Starter

```python
class Solution:
    def twoSum(self, numbers: list[int], target: int) -> list[int]:
        
```

# Hints

1. The array is sorted. If the sum of two numbers is too small, which pointer should move to make it bigger?
2. Start with l = 0 and r = n − 1. Sum too small → l += 1. Too big → r −= 1. Equal → return [l + 1, r + 1].

# Key points

- sorted input: move left to increase the sum, right to decrease it
- each step discards one number that can't be part of the answer
- O(n) time, O(1) space (the hash map version needs O(n) space)
- answer is 1-indexed

# Solution: binary-search · Binary search the partner · O(n log n) · O(1)

## Idea
For each `i`, binary search for `target - numbers[i]` to the right of `i`.

## Complexity
- **Time: O(n log n)**.
- **Space: O(1)**.

```python
from bisect import bisect_left

class Solution:
    def twoSum(self, numbers: list[int], target: int) -> list[int]:
        for i, x in enumerate(numbers):
            j = bisect_left(numbers, target - x, i + 1)
            if j < len(numbers) and numbers[j] == target - x:
                return [i + 1, j + 1]
```

# Solution: two-pointers · Two pointers from the ends · O(n) · O(1) · reference

## Idea
Look at `numbers[l] + numbers[r]`.
- Too small: `numbers[l]` can't work even with the biggest partner left, so drop it (`l += 1`).
- Too big: `numbers[r]` can't work even with the smallest partner left, so drop it (`r -= 1`).

Each step safely throws one number away, so we find the pair in one pass.

## Complexity
- **Time: O(n)**.
- **Space: O(1)**.

```python
class Solution:
    def twoSum(self, numbers: list[int], target: int) -> list[int]:
        l, r = 0, len(numbers) - 1
        while l < r:
            s = numbers[l] + numbers[r]
            if s == target:
                return [l + 1, r + 1]
            if s < target:
                l += 1
            else:
                r -= 1
```

# Tests

```python
def unique(nums, target):
    return sum(nums[i] + nums[j] == target for i in range(len(nums)) for j in range(i + 1, len(nums))) == 1

def edge():
    return [[[2, 7, 11, 15], 9], [[2, 3, 4], 6], [[-1, 0], -1], [[0, 0, 3, 4], 0], [[1, 2], 3], [[-3, -1, 0, 5, 9], 8]]

def random_case(rng):
    while True:
        nums = sorted(rng.randint(-20, 20) for _ in range(rng.randint(2, 8)))
        i, j = sorted(rng.sample(range(len(nums)), 2))
        if unique(nums, nums[i] + nums[j]):
            return [nums, nums[i] + nums[j]]
```
