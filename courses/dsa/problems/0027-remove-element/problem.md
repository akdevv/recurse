---
lc: 27
title: "Remove Element"
difficulty: "Easy"
patterns: ["two-pointers"]
lcTags: ["array", "two-pointers"]
entry: {"method": "removeElement", "params": [{"name": "nums", "type": "integer[]"}, {"name": "val", "type": "integer"}], "returns": "integer", "outputParam": 0, "kPrefix": true}
examples: ["[3,2,2,3]\n3", "[0,1,2,2,3,0,4,2]\n2"]
lcHints: ["The problem statement clearly asks us to modify the array in-place and it also says that the element beyond the new length of the array can be anything. Given an element, we need to remove all the occurrences of it from the array. We don't technically need to <b>remove</b> that element per se, right?", "We can move all the occurrences of this element to the end of the array. Use two pointers!\r\n<br><img src=\"https://assets.leetcode.com/uploads/2019/10/20/hint_remove_element.png\" width=\"500\"/>", "Yet another direction of thought is to consider the elements to be removed as non-existent. In a single pass, if we keep copying the visible elements in-place, that should also solve this problem for us."]
---

Given an integer array `nums` and an integer `val`, remove all occurrences of `val` in `nums` [**in-place**](https://en.wikipedia.org/wiki/In-place_algorithm). The order of the elements may be changed. Then return *the number of elements in* `nums` *which are not equal to* `val`.

Consider the number of elements in `nums` which are not equal to `val` be `k`, to get accepted, you need to do the following things:

- Change the array `nums` such that the first `k` elements of `nums` contain the elements which are not equal to `val`. The remaining elements of `nums` are not important as well as the size of `nums`.
- Return `k`.

**Custom Judge:**

The judge will test your solution with the following code:

```
int[] nums = [...]; // Input array
int val = ...; // Value to remove
int[] expectedNums = [...]; // The expected answer with correct length.
                            // It is sorted with no values equaling val.

int k = removeElement(nums, val); // Calls your implementation

assert k == expectedNums.length;
sort(nums, 0, k); // Sort the first k elements of nums
for (int i = 0; i < actualLength; i++) {
    assert nums[i] == expectedNums[i];
}
```

If all assertions pass, then your solution will be **accepted**.

**Example 1:**

```
Input: nums = [3,2,2,3], val = 3
Output: 2, nums = [2,2,_,_]
Explanation: Your function should return k = 2, with the first two elements of nums being 2.
It does not matter what you leave beyond the returned k (hence they are underscores).
```

**Example 2:**

```
Input: nums = [0,1,2,2,3,0,4,2], val = 2
Output: 5, nums = [0,1,4,0,3,_,_,_]
Explanation: Your function should return k = 5, with the first five elements of nums containing 0, 0, 1, 3, and 4.
Note that the five elements can be returned in any order.
It does not matter what you leave beyond the returned k (hence they are underscores).
```

**Constraints:**

- `0 <= nums.length <= 100`
- `0 <= nums[i] <= 50`
- `0 <= val <= 100`

# Starter

```python
class Solution:
    def removeElement(self, nums: list[int], val: int) -> int:
        
```

# Hints

1. You don't have to delete anything. Only the first k slots are checked.
2. Keep a write pointer k. For every value that isn't val, write it to nums[k] and move k forward.

# Key points

- read pointer scans every element, write pointer marks where the next kept value goes
- deleting from a Python list in a loop is O(n) per delete, O(n²) total
- O(n) time, O(1) extra space, and the order of kept values is preserved

# Solution: filter-copy · Filter into a new list, copy back · O(n) · O(n)

## Idea
Build the list of values to keep, then copy it over the front of `nums`.

## Complexity
- **Time: O(n)**.
- **Space: O(n)** for the temporary list, which breaks the "in-place" spirit of the problem.

```python
class Solution:
    def removeElement(self, nums: list[int], val: int) -> int:
        kept = [x for x in nums if x != val]
        nums[: len(kept)] = kept
        return len(kept)
```

# Solution: write-pointer · Read pointer + write pointer · O(n) · O(1) extra · reference

## Idea
Two pointers moving the same direction: the loop **reads** every value, `k` marks where the next **kept** value goes. Values equal to `val` are simply skipped, and later kept values overwrite them.

## Why it's safe
`k` never passes the read position, so we only overwrite slots we've already read.

## Complexity
- **Time: O(n)**, one pass.
- **Space: O(1) extra**.

This read/write pattern shows up again in Remove Duplicates, Move Zeroes and many "compact the array" problems.

```python
class Solution:
    def removeElement(self, nums: list[int], val: int) -> int:
        k = 0
        for x in nums:
            if x != val:
                nums[k] = x
                k += 1
        return k
```

# Tests

```python
def edge():
    return [
        [[3, 2, 2, 3], 3],
        [[0, 1, 2, 2, 3, 0, 4, 2], 2],
        [[], 0],
        [[1], 1],
        [[2], 1],
        [[4, 4, 4], 4],
        [[1, 2, 3], 7],
    ]

def random_case(rng):
    return [[rng.randint(0, 4) for _ in range(rng.randint(0, 15))], rng.randint(0, 5)]

def perf(rng):
    return []
```
