---
lc: 75
title: "Sort Colors"
difficulty: "Medium"
patterns: ["two-pointers"]
lcTags: ["array", "two-pointers", "sorting", "quicksort", "bubble-sort"]
entry: {"method": "sortColors", "params": [{"name": "nums", "type": "integer[]"}], "returns": "void", "outputParam": 0}
examples: ["[2,0,2,1,1,0]", "[2,0,1]"]
lcHints: ["A rather straight forward solution is a two-pass algorithm using counting sort.", "Iterate the array counting number of 0's, 1's, and 2's.", "Overwrite array with the total number of 0's, then 1's and followed by 2's."]
---

You are given an array `nums` with `n` objects colored red, white, or blue, sort them **[in-place](https://en.wikipedia.org/wiki/In-place_algorithm)** so that objects of the same color are adjacent, with the colors in the order red, white, and blue.

We will use the integers 0, 1, and 2 to represent the color red, white, and blue, respectively.

You must solve this problem without using the library's sort function.

**Example 1:**

**Input:** nums = [2,0,2,1,1,0]

**Output:** [0,0,1,1,2,2]

**Explanation:**

The array has two 0s, two 1s, and two 2s. Sorting them in-place places all 0s first, then all 1s, then all 2s.

**Example 2:**

**Input:** nums = [2,0,1]

**Output:** [0,1,2]

**Explanation:**

The array has one each of 0, 1, and 2, arranged in-place in the order 0, 1, 2.

**Constraints:**

- `n == nums.length`
- `1 <= n <= 300`
- `nums[i]` is either 0, 1, or 2.

**Follow up:** Could you come up with a one-pass algorithm using only constant extra space?

# Starter

```python
class Solution:
    def sortColors(self, nums: list[int]) -> None:
        """
        Do not return anything, modify nums in-place instead.
        """
        
```

# Hints

1. Only three values. Counting how many 0s, 1s, 2s and rewriting works in two passes.
2. One pass (Dutch flag): lo, mid, hi pointers. 0 → swap to lo, 1 → skip, 2 → swap to hi (and don't advance mid, the swapped-in value is unchecked).

# Key points

- counting sort works in two passes
- Dutch national flag: everything before lo is 0, lo..mid-1 is 1, after hi is 2
- after swapping a 2 to the back, don't advance mid: the new value hasn't been checked
- one pass, O(n) time, O(1) space

# Solution: count · Count, then rewrite · O(n) · O(1)

## Idea
Count each color, then overwrite the array with that many 0s, 1s and 2s.

## Complexity
- **Time: O(n)**, two passes.
- **Space: O(1)**.

```python
class Solution:
    def sortColors(self, nums: list[int]) -> None:
        c = [nums.count(0), nums.count(1), nums.count(2)]
        nums[:] = [0] * c[0] + [1] * c[1] + [2] * c[2]
```

# Solution: dutch-flag · Dutch national flag · O(n) · O(1) · reference

## Idea
Three regions: `[0, lo)` are 0s, `[lo, mid)` are 1s, `(hi, n)` are 2s, and `[mid, hi]` is still unknown. Look at `nums[mid]`:
- 0: swap it to `lo`, advance both.
- 1: already in place, advance `mid`.
- 2: swap it to `hi`, shrink `hi`. Don't advance `mid`: the value that came back hasn't been looked at.

## Complexity
- **Time: O(n)**, one pass.
- **Space: O(1)**.

```python
class Solution:
    def sortColors(self, nums: list[int]) -> None:
        lo, mid, hi = 0, 0, len(nums) - 1
        while mid <= hi:
            if nums[mid] == 0:
                nums[lo], nums[mid] = nums[mid], nums[lo]
                lo += 1
                mid += 1
            elif nums[mid] == 1:
                mid += 1
            else:
                nums[mid], nums[hi] = nums[hi], nums[mid]
                hi -= 1
```

# Tests

```python
def edge():
    return [[[0]], [[2]], [[2, 0]], [[2, 0, 1]], [[1, 1, 1]], [[2, 2, 0, 0]], [[2, 0, 2, 1, 1, 0]]]

def random_case(rng):
    return [[rng.randint(0, 2) for _ in range(rng.randint(1, 12))]]
```
