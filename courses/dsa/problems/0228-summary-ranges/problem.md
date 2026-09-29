---
lc: 228
title: "Summary Ranges"
difficulty: "Easy"
patterns: ["two-pointers"]
lcTags: ["array"]
entry: {"method": "summaryRanges", "params": [{"name": "nums", "type": "integer[]"}], "returns": "list<string>"}
examples: ["[0,1,2,4,5,7]", "[0,2,3,4,6,8,9]"]
---

You are given a **sorted unique** integer array `nums`.

A **range** `[a,b]` is the set of all integers from `a` to `b` (inclusive).

Return *the **smallest sorted** list of ranges that **cover all the numbers in the array exactly***. That is, each element of `nums` is covered by exactly one of the ranges, and there is no integer `x` such that `x` is in one of the ranges but not in `nums`.

Each range `[a,b]` in the list should be output as:

- `"a->b"` if `a != b`
- `"a"` if `a == b`

**Example 1:**

```
Input: nums = [0,1,2,4,5,7]
Output: ["0->2","4->5","7"]
Explanation: The ranges are:
[0,2] --> "0->2"
[4,5] --> "4->5"
[7,7] --> "7"
```

**Example 2:**

```
Input: nums = [0,2,3,4,6,8,9]
Output: ["0","2->4","6","8->9"]
Explanation: The ranges are:
[0,0] --> "0"
[2,4] --> "2->4"
[6,6] --> "6"
[8,9] --> "8->9"
```

**Constraints:**

- `0 <= nums.length <= 20`
- `-2³¹ <= nums[i] <= 2³¹ - 1`
- All the values of `nums` are **unique**.
- `nums` is sorted in ascending order.

# Starter

```python
class Solution:
    def summaryRanges(self, nums: list[int]) -> list[str]:
        
```

# Hints

1. Walk the sorted array and extend a range while each number is the previous + 1.
2. Keep the start of the current range; when the next number breaks the run (or the array ends), output "a" or "a->b".

# Key points

- one pass, two pointers: range start and current index
- single-number range prints just the number
- O(n) time

# Solution: two-pointers · Two Pointers · O(n) · O(1) · reference

We can use two pointers i and j to find the left and right endpoints of each interval.

Traverse the array, when `j + 1 < n` and `nums[j + 1] = nums[j] + 1`, move j to the right, otherwise the interval `[i, j]` has been found, add it to the answer, then move i to the position of `j + 1`, and continue to find the next interval.

Time complexity O(n), where n is the length of the array. Space complexity O(1).

```python
class Solution:
    def summaryRanges(self, nums: List[int]) -> List[str]:
        def f(i: int, j: int) -> str:
            return str(nums[i]) if i == j else f'{nums[i]}->{nums[j]}'

        i = 0
        n = len(nums)
        ans = []
        while i < n:
            j = i
            while j + 1 < n and nums[j + 1] == nums[j] + 1:
                j += 1
            ans.append(f(i, j))
            i = j + 1
        return ans
```

# Tests

```python
def edge():
    return [[[]], [[1]], [[0, 1, 2, 4, 5, 7]], [[0, 2, 3, 4, 6, 8, 9]], [[-2**31, 2**31 - 1]], [[-1, 0, 1]]]

def random_case(rng):
    return [sorted(rng.sample(range(-10, 15), rng.randint(0, 12)))]
```
