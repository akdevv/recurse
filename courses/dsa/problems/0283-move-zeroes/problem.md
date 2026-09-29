---
lc: 283
title: "Move Zeroes"
difficulty: "Easy"
patterns: ["two-pointers"]
lcTags: ["array", "two-pointers"]
entry: {"method": "moveZeroes", "params": [{"name": "nums", "type": "integer[]"}], "returns": "void", "outputParam": 0}
examples: ["[0,1,0,3,12]", "[0]"]
lcHints: ["<b>In-place</b> means we should not be allocating any space for extra array. But we are allowed to modify the existing array. However, as a first step, try coming up with a solution that makes use of additional space. For this problem as well, first apply the idea discussed using an additional array and the in-place solution will pop up eventually.", "A <b>two-pointer</b> approach could be helpful here. The idea would be to have one pointer for iterating the array and another pointer that just works on the non-zero elements of the array."]
---

Given an integer array `nums`, move all `0`'s to the end of it while maintaining the relative order of the non-zero elements.

**Note** that you must do this in-place without making a copy of the array.

**Example 1:**

```
Input: nums = [0,1,0,3,12]
Output: [1,3,12,0,0]
```

**Example 2:**

```
Input: nums = [0]
Output: [0]
```

**Constraints:**

- `1 <= nums.length <= 10⁴`
- `-2³¹ <= nums[i] <= 2³¹ - 1`

**Follow up:** Could you minimize the total number of operations done?

# Starter

```python
class Solution:
    def moveZeroes(self, nums: list[int]) -> None:
        """
        Do not return anything, modify nums in-place instead.
        """
        
```

# Hints

1. Think of it as "keep the non-zero values in order, packed to the front".
2. A write pointer k: for every non-zero value, swap it into position k and increase k. The zeros end up behind.

# Key points

- write pointer packs non-zeros to the front in order
- swapping (instead of copying then zero-filling) does it in one pass
- O(n) time, O(1) space, in place

# Solution: rebuild · Collect non-zeros, then pad · O(n) · O(n)

## Idea
Collect the non-zero values, pad with zeros, write back. Simple, but uses an extra list.

## Complexity
- **Time: O(n)**.
- **Space: O(n)**.

```python
class Solution:
    def moveZeroes(self, nums: list[int]) -> None:
        keep = [x for x in nums if x != 0]
        nums[:] = keep + [0] * (len(nums) - len(keep))
```

# Solution: swap · Swap non-zeros forward · O(n) · O(1) · reference

## Idea
`k` marks where the next non-zero value belongs. Each non-zero `nums[i]` is swapped with `nums[k]`. Everything before `k` is the non-zero values in their original order; zeros get swapped backwards.

## Complexity
- **Time: O(n)**, one pass.
- **Space: O(1)**.

```python
class Solution:
    def moveZeroes(self, nums: list[int]) -> None:
        k = 0
        for i in range(len(nums)):
            if nums[i] != 0:
                nums[k], nums[i] = nums[i], nums[k]
                k += 1
```

# Tests

```python
def edge():
    return [[[0]], [[1]], [[0, 0, 1]], [[1, 0, 0]], [[0, 1, 0, 3, 12]], [[-2**31, 0, 2**31 - 1]]]

def random_case(rng):
    return [[rng.choice([0, 0, rng.randint(-5, 5)]) for _ in range(rng.randint(1, 10))]]
```
