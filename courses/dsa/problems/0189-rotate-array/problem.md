---
lc: 189
title: "Rotate Array"
difficulty: "Medium"
patterns: ["two-pointers"]
lcTags: ["array", "math", "two-pointers"]
entry: {"method": "rotate", "params": [{"name": "nums", "type": "integer[]"}, {"name": "k", "type": "integer"}], "returns": "void", "outputParam": 0}
examples: ["[1,2,3,4,5,6,7]\n3", "[-1,-100,3,99]\n2"]
lcHints: ["The easiest solution would use additional memory and that is perfectly fine.", "The actual trick comes when trying to solve this problem without using any additional memory. This means you need to use the original array somehow to move the elements around. Now, we can place each element in its original location and shift all the elements around it to adjust as that would be too costly and most likely will time out on larger input arrays.", "One line of thought is based on reversing the array (or parts of it) to obtain the desired result. Think about how reversal might potentially help us out by using an example.", "The other line of thought is a tad bit complicated but essentially it builds on the idea of placing each element in its original position while keeping track of the element originally in that position. Basically, at every step, we place an element in its rightful position and keep track of the element already there or the one being overwritten in an additional variable. We can't do this in one linear pass and the idea here is based on <b>cyclic-dependencies</b> between elements."]
---

Given an integer array `nums`, rotate the array to the right by `k` steps, where `k` is non-negative.

**Example 1:**

```
Input: nums = [1,2,3,4,5,6,7], k = 3
Output: [5,6,7,1,2,3,4]
Explanation:
rotate 1 steps to the right: [7,1,2,3,4,5,6]
rotate 2 steps to the right: [6,7,1,2,3,4,5]
rotate 3 steps to the right: [5,6,7,1,2,3,4]
```

**Example 2:**

```
Input: nums = [-1,-100,3,99], k = 2
Output: [3,99,-1,-100]
Explanation:
rotate 1 steps to the right: [99,-1,-100,3]
rotate 2 steps to the right: [3,99,-1,-100]
```

**Constraints:**

- `1 <= nums.length <= 10⁵`
- `-2³¹ <= nums[i] <= 2³¹ - 1`
- `0 <= k <= 10⁵`

**Follow up:**

- Try to come up with as many solutions as you can. There are at least **three** different ways to solve this problem.
- Could you do it in-place with `O(1)` extra space?

# Starter

```python
class Solution:
    def rotate(self, nums: list[int], k: int) -> None:
        """
        Do not return anything, modify nums in-place instead.
        """
        
```

# Hints

1. Rotating by n is the same as not rotating at all, so first take k %= n. Then: can an extra array make this easy?
2. For O(1) space: reverse the whole array, then reverse the first k values, then reverse the rest.

# Key points

- k can be bigger than n, so reduce it with k %= n first
- value at index i moves to (i + k) % n; an extra array makes that direct
- three reversals do it in place: O(n) time, O(1) extra space

# Solution: one-step · Rotate by one, k times · O(n·k) · O(1) · slow

## Idea
Move the last element to the front, k times.

## Complexity
- **Time: O(n·k)**: `insert(0, …)` shifts every element, and we do it up to n−1 times.
- **Space: O(1)**.

Correct, but n and k can both be 10⁵.

```python
class Solution:
    def rotate(self, nums: list[int], k: int) -> None:
        for _ in range(k % len(nums)):
            nums.insert(0, nums.pop())
```

# Solution: extra-array · Place each value at (i + k) % n · O(n) · O(n)

## Idea
Every value moves k steps right, wrapping around: index `i` goes to `(i + k) % n`. Build the result in a new array and copy it back.

## Complexity
- **Time: O(n)**.
- **Space: O(n)** for the copy.

Note `nums[:] = out`: assigning to the slice changes the list the caller holds. `nums = out` would only rebind the local name.

```python
class Solution:
    def rotate(self, nums: list[int], k: int) -> None:
        n = len(nums)
        out = [0] * n
        for i, x in enumerate(nums):
            out[(i + k) % n] = x
        nums[:] = out
```

# Solution: reverse-thrice · Three reversals · O(n) · O(1) · reference

## Idea
Rotating right by k moves the last k values to the front, keeping each group's order.

`[1 2 3 4 5 6 7]`, k = 3
1. Reverse everything: `[7 6 5 | 4 3 2 1]`. The last 3 are now in front, but backwards.
2. Reverse the first k: `[5 6 7 | 4 3 2 1]`.
3. Reverse the rest: `[5 6 7 | 1 2 3 4]`. Done.

Each reversal is two pointers swapping toward the middle.

## Complexity
- **Time: O(n)**, every value is swapped at most twice.
- **Space: O(1) extra**.

```python
class Solution:
    def rotate(self, nums: list[int], k: int) -> None:
        n = len(nums)
        k %= n

        def rev(lo: int, hi: int) -> None:
            while lo < hi:
                nums[lo], nums[hi] = nums[hi], nums[lo]
                lo, hi = lo + 1, hi - 1

        rev(0, n - 1)
        rev(0, k - 1)
        rev(k, n - 1)
```

# Tests

```python
def edge():
    return [
        [[1, 2, 3, 4, 5, 6, 7], 3],
        [[-1, -100, 3, 99], 2],
        [[1], 0],
        [[1], 5],
        [[1, 2], 3],
        [[1, 2, 3], 3],
        [[1, 2, 3, 4], 0],
    ]

def random_case(rng):
    n = rng.randint(1, 10)
    return [[rng.randint(-50, 50) for _ in range(n)], rng.randint(0, 25)]

def perf(rng):
    n = 100000
    return [[[rng.randint(-10**9, 10**9) for _ in range(n)], n - 1]]
```
