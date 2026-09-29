---
lc: 217
title: "Contains Duplicate"
difficulty: "Easy"
patterns: ["hash-map"]
lcTags: ["array", "hash-table", "sorting"]
entry: {"method": "containsDuplicate", "params": [{"name": "nums", "type": "integer[]"}], "returns": "boolean"}
examples: ["[1,2,3,1]", "[1,2,3,4]", "[1,1,1,3,3,4,3,2,4,2]"]
---

Given an integer array `nums`, return `true` if any value appears **at least twice** in the array, and return `false` if every element is distinct.

**Example 1:**

**Input:** nums = [1,2,3,1]

**Output:** true

**Explanation:**

The element 1 occurs at the indices 0 and 3.

**Example 2:**

**Input:** nums = [1,2,3,4]

**Output:** false

**Explanation:**

All elements are distinct.

**Example 3:**

**Input:** nums = [1,1,1,3,3,4,3,2,4,2]

**Output:** true

**Constraints:**

- `1 <= nums.length <= 10⁵`
- `-10⁹ <= nums[i] <= 10⁹`

# Starter

```python
class Solution:
    def containsDuplicate(self, nums: list[int]) -> bool:
        
```

# Hints

1. Comparing every pair is O(n²). What data structure answers "have I seen this before?" in O(1)?
2. Walk the array with a set. If the value is already in the set, you found a duplicate; otherwise add it.

# Key points

- a set gives O(1) average membership checks
- one pass: check before adding, return True on the first repeat
- O(n) time, O(n) space; sorting instead is O(n log n) time, O(1) extra space

# Solution: pairs · Compare every pair · O(n²) · O(1) · slow

## Idea
Check every pair (i, j) with i < j.

## Complexity
- **Time: O(n²)**, too slow for n = 10⁵.
- **Space: O(1)**.

```python
class Solution:
    def containsDuplicate(self, nums: list[int]) -> bool:
        for i in range(len(nums)):
            for j in range(i + 1, len(nums)):
                if nums[i] == nums[j]:
                    return True
        return False
```

# Solution: sort · Sort, then compare neighbours · O(n log n) · O(n)

## Idea
After sorting, equal values sit next to each other, so one scan over neighbours is enough.

## Complexity
- **Time: O(n log n)** for the sort.
- **Space: O(n)** for the sorted copy (O(1) extra if you may sort in place).

```python
class Solution:
    def containsDuplicate(self, nums: list[int]) -> bool:
        nums = sorted(nums)
        for i in range(1, len(nums)):
            if nums[i] == nums[i - 1]:
                return True
        return False
```

# Solution: seen-set · Seen set · O(n) · O(n) · reference

## Idea
Remember every value in a set. The first value that's already there is a duplicate.

`return len(set(nums)) < len(nums)` is the one-line version, but it always builds the full set; the loop can stop early.

## Complexity
- **Time: O(n)**, O(1) average per set operation.
- **Space: O(n)** for the set.

```python
class Solution:
    def containsDuplicate(self, nums: list[int]) -> bool:
        seen = set()
        for x in nums:
            if x in seen:
                return True
            seen.add(x)
        return False
```

# Tests

```python
def edge():
    return [[[1]], [[1, 1]], [[1, 2]], [[-10**9, 10**9]], [[5, 4, 3, 2, 1, 5]]]

def random_case(rng):
    n = rng.randint(1, 12)
    return [[rng.randint(-8, 8) for _ in range(n)]]

def perf(rng):
    n = 100000
    return [[list(range(n))], [rng.sample(range(-10**9, 10**9), n)]]
```
