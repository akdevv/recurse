---
lc: 88
title: "Merge Sorted Array"
difficulty: "Easy"
patterns: ["two-pointers"]
lcTags: ["array", "two-pointers", "sorting"]
entry: {"method": "merge", "params": [{"name": "nums1", "type": "integer[]"}, {"name": "m", "type": "integer"}, {"name": "nums2", "type": "integer[]"}, {"name": "n", "type": "integer"}], "returns": "void", "outputParam": 0}
examples: ["[1,2,3,0,0,0]\n3\n[2,5,6]\n3", "[1]\n1\n[]\n0", "[0]\n0\n[1]\n1"]
lcHints: ["You can easily solve this problem if you simply think about two elements at a time rather than two arrays. We know that each of the individual arrays is sorted. What we don't know is how they will intertwine. Can we take a local decision and arrive at an optimal solution?", "If you simply consider one element each at a time from the two arrays and make a decision and proceed accordingly, you will arrive at the optimal solution."]
---

You are given two integer arrays `nums1` and `nums2`, sorted in **non-decreasing order**, and two integers `m` and `n`, representing the number of elements in `nums1` and `nums2` respectively.

**Merge** `nums1` and `nums2` into a single array sorted in **non-decreasing order**.

The final sorted array should not be returned by the function, but instead be *stored inside the array* `nums1`. To accommodate this, `nums1` has a length of `m + n`, where the first `m` elements denote the elements that should be merged, and the last `n` elements are set to `0` and should be ignored. `nums2` has a length of `n`.

**Example 1:**

```
Input: nums1 = [1,2,3,0,0,0], m = 3, nums2 = [2,5,6], n = 3
Output: [1,2,2,3,5,6]
Explanation: The arrays we are merging are [1,2,3] and [2,5,6].
The result of the merge is [1,2,2,3,5,6] with the underlined elements coming from nums1.
```

**Example 2:**

```
Input: nums1 = [1], m = 1, nums2 = [], n = 0
Output: [1]
Explanation: The arrays we are merging are [1] and [].
The result of the merge is [1].
```

**Example 3:**

```
Input: nums1 = [0], m = 0, nums2 = [1], n = 1
Output: [1]
Explanation: The arrays we are merging are [] and [1].
The result of the merge is [1].
Note that because m = 0, there are no elements in nums1. The 0 is only there to ensure the merge result can fit in nums1.
```

**Constraints:**

- `nums1.length == m + n`
- `nums2.length == n`
- `0 <= m, n <= 200`
- `1 <= m + n <= 200`
- `-10⁹ <= nums1[i], nums2[j] <= 10⁹`

**Follow up:** Can you come up with an algorithm that runs in `O(m + n)` time?

# Starter

```python
class Solution:
    def merge(self, nums1: list[int], m: int, nums2: list[int], n: int) -> None:
        """
        Do not return anything, modify nums1 in-place instead.
        """
        
```

# Hints

1. Filling nums1 from the front would overwrite values you still need. Where is there free space?
2. Start at the back: compare the largest remaining of each array and write the bigger one into the last free slot of nums1.

# Key points

- both inputs are sorted, so the largest remaining value is always at one of two ends
- writing from the back uses nums1's empty tail, so nothing unread gets overwritten
- O(m + n) time, O(1) extra space; concat + sort would be O((m + n) log(m + n))

# Solution: concat-sort · Copy in, then sort · O((m+n) log(m+n)) · O(1) extra

## Idea
Drop nums2 into the empty tail of nums1, then sort the whole thing.

## Complexity
- **Time: O((m+n) log(m+n))** for the sort.
- **Space: O(1) extra** (Python's sort needs a little scratch space, fine for interviews).

It works, but it ignores the best clue in the problem: both halves are already sorted.

```python
class Solution:
    def merge(self, nums1: list[int], m: int, nums2: list[int], n: int) -> None:
        nums1[m:] = nums2
        nums1.sort()
```

# Solution: back-pointers · Three pointers from the back · O(m+n) · O(1) extra · reference

## Idea
The biggest remaining value is always the last unread one of nums1 or nums2. Write it into the last free slot `w` and step that pointer left.

## Why from the back
The free space in nums1 is at the **end**. Writing there never overwrites a value of nums1 we haven't read yet: `w` is always at or ahead of `i`.

## Why `while j >= 0`
Once nums2 is used up, whatever is left of nums1 is already in place. If nums1 runs out first (`i < 0`), we keep copying from nums2.

## Complexity
- **Time: O(m + n)**, each value is written once.
- **Space: O(1) extra**.

```python
class Solution:
    def merge(self, nums1: list[int], m: int, nums2: list[int], n: int) -> None:
        i, j, w = m - 1, n - 1, m + n - 1
        while j >= 0:
            if i >= 0 and nums1[i] > nums2[j]:
                nums1[w] = nums1[i]
                i -= 1
            else:
                nums1[w] = nums2[j]
                j -= 1
            w -= 1
```

# Tests

```python
def edge():
    return [
        [[1, 2, 3, 0, 0, 0], 3, [2, 5, 6], 3],
        [[1], 1, [], 0],
        [[0], 0, [1], 1],
        [[4, 5, 6, 0, 0, 0], 3, [1, 2, 3], 3],
        [[2, 0], 1, [1], 1],
        [[-1, 0, 0, 0], 1, [-3, -2, 5], 3],
    ]

def random_case(rng):
    m, n = rng.randint(0, 6), rng.randint(0, 6)
    if m + n == 0:
        n = 1
    a = sorted(rng.randint(-20, 20) for _ in range(m)) + [0] * n
    b = sorted(rng.randint(-20, 20) for _ in range(n))
    return [a, m, b, n]

def perf(rng):
    return []
```
