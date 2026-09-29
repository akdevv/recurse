---
lc: 977
title: "Squares of a Sorted Array"
difficulty: "Easy"
patterns: ["two-pointers"]
lcTags: ["array", "two-pointers", "sorting"]
entry: {"method": "sortedSquares", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer[]"}
examples: ["[-4,-1,0,3,10]", "[-7,-3,2,3,11]"]
---

Given an integer array `nums` sorted in **non-decreasing** order, return *an array of **the squares of each number** sorted in non-decreasing order*.

**Example 1:**

```
Input: nums = [-4,-1,0,3,10]
Output: [0,1,9,16,100]
Explanation: After squaring, the array becomes [16,1,0,9,100].
After sorting, it becomes [0,1,9,16,100].
```

**Example 2:**

```
Input: nums = [-7,-3,2,3,11]
Output: [4,9,9,49,121]
```

**Constraints:**

- `1 <= nums.length <= 10⁴`
- `-10⁴ <= nums[i] <= 10⁴`
- `nums` is sorted in **non-decreasing** order.

**Follow up:** Squaring each element and sorting the new array is very trivial, could you find an `O(n)` solution using a different approach?

# Starter

```python
class Solution:
    def sortedSquares(self, nums: list[int]) -> list[int]:
        
```

# Hints

1. The largest square comes from one of the two ends: the most negative number or the most positive one.
2. Two pointers at the ends. Compare the absolute values, write the bigger square at the back of the result, move that pointer inward.

# Key points

- the biggest square is always at one of the two ends
- fill the result from the back, taking the larger |value| each time
- O(n) time vs O(n log n) for square-then-sort

# Solution: square-sort · Square, then sort · O(n log n) · O(n)

## Idea
Square everything and sort. Correct, but ignores that the input is already sorted.

## Complexity
- **Time: O(n log n)**.
- **Space: O(n)**.

```python
class Solution:
    def sortedSquares(self, nums: list[int]) -> list[int]:
        return sorted(x * x for x in nums)
```

# Solution: two-pointers · Two pointers from the ends · O(n) · O(n) · reference

## Idea
Negative numbers get bigger when squared, so the sorted input has its largest squares at **both ends** and its smallest in the middle. Compare the two ends, place the larger square at the last free slot of the result, move that pointer in.

## Complexity
- **Time: O(n)**.
- **Space: O(n)** for the output.

```python
class Solution:
    def sortedSquares(self, nums: list[int]) -> list[int]:
        n = len(nums)
        out = [0] * n
        l, r = 0, n - 1
        for i in range(n - 1, -1, -1):
            if abs(nums[l]) > abs(nums[r]):
                out[i] = nums[l] * nums[l]
                l += 1
            else:
                out[i] = nums[r] * nums[r]
                r -= 1
        return out
```

# Tests

```python
def edge():
    return [[[0]], [[-5]], [[-3, -2, -1]], [[1, 2, 3]], [[-2, 0, 2]], [[-10000, 10000]]]

def random_case(rng):
    return [sorted(rng.randint(-10, 10) for _ in range(rng.randint(1, 10)))]
```
