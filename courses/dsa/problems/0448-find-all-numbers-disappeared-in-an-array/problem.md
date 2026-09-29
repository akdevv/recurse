---
lc: 448
title: "Find All Numbers Disappeared in an Array"
difficulty: "Easy"
patterns: ["cyclic-sort"]
lcTags: ["array", "hash-table"]
compare: "unordered"
entry: {"method": "findDisappearedNumbers", "params": [{"name": "nums", "type": "integer[]"}], "returns": "list<integer>"}
examples: ["[4,3,2,7,8,2,3,1]", "[1,1]"]
lcHints: ["This is a really easy problem if you decide to use additional memory. For those trying to write an initial solution using additional memory, think <b>counters!</b>", "However, the trick really is to not use any additional space than what is already available to use. Sometimes, multiple passes over the input array help find the solution. However, there's an interesting piece of information in this problem that makes it easy to re-use the input array itself for the solution.", "The problem specifies that the numbers in the array will be in the range [1, n] where n is the number of elements in the array. Can we use this information and modify the array in-place somehow to find what we need?"]
---

Given an array `nums` of `n` integers where `nums[i]` is in the range `[1, n]`, return *an array of all the integers in the range* `[1, n]` *that do not appear in* `nums`.

**Example 1:**

```
Input: nums = [4,3,2,7,8,2,3,1]
Output: [5,6]
```

**Example 2:**

```
Input: nums = [1,1]
Output: [2]
```

**Constraints:**

- `n == nums.length`
- `1 <= n <= 10⁵`
- `1 <= nums[i] <= n`

**Follow up:** Could you do it without extra space and in `O(n)` runtime? You may assume the returned list does not count as extra space.

# Starter

```python
class Solution:
    def findDisappearedNumbers(self, nums: list[int]) -> list[int]:
        
```

# Hints

1. Values are in 1..n, so each value can be used as an index into the array itself.
2. For every value v, mark index v − 1 by making nums[v − 1] negative. Indices still positive at the end were never visited: i + 1 is missing.

# Key points

- values 1..n map to indices 0..n-1
- mark "seen" in place by negating nums[abs(v) - 1]
- positive slots at the end = missing numbers
- O(n) time, O(1) extra space (a set would be O(n))

# Solution: solution-1 · Set of seen values · O(n) · O(n) · reference

## Idea
Put the values in a set and list every number from 1 to n that isn't in it.

## Complexity
- **Time: O(n)**
- **Space: O(n)**

```python
class Solution:
    def findDisappearedNumbers(self, nums: List[int]) -> List[int]:
        s = set(nums)
        return [x for x in range(1, len(nums) + 1) if x not in s]
```

# Solution: solution-2 · Mark by negating in place · O(n) · O(1)

## Idea
Use the array itself as the "seen" set: for every value v, make `nums[v − 1]` negative. Indices that stay positive were never pointed to, so i + 1 is missing.

## Complexity
- **Time: O(n)**
- **Space: O(1)**

```python
class Solution:
    def findDisappearedNumbers(self, nums: List[int]) -> List[int]:
        for x in nums:
            i = abs(x) - 1
            if nums[i] > 0:
                nums[i] *= -1
        return [i + 1 for i in range(len(nums)) if nums[i] > 0]
```

# Tests

```python

```
