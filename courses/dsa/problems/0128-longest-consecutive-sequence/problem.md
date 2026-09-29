---
lc: 128
title: "Longest Consecutive Sequence"
difficulty: "Medium"
patterns: ["hash-map"]
lcTags: ["array", "hash-table", "union-find"]
entry: {"method": "longestConsecutive", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer"}
examples: ["[100,4,200,1,3,2]", "[0,3,7,2,5,8,4,6,0,1]", "[1,0,1,2]"]
---

Given an unsorted array of integers `nums`, return *the length of the longest consecutive elements sequence.*

You must write an algorithm that runs in `O(n)` time.

**Example 1:**

```
Input: nums = [100,4,200,1,3,2]
Output: 4
Explanation: The longest consecutive elements sequence is [1, 2, 3, 4]. Therefore its length is 4.
```

**Example 2:**

```
Input: nums = [0,3,7,2,5,8,4,6,0,1]
Output: 9
```

**Example 3:**

```
Input: nums = [1,0,1,2]
Output: 3
```

**Constraints:**

- `0 <= nums.length <= 10⁵`
- `-10⁹ <= nums[i] <= 10⁹`

# Starter

```python
class Solution:
    def longestConsecutive(self, nums: list[int]) -> int:
        
```

# Hints

1. Sorting gives O(n log n). For O(n), put everything in a set so "is x + 1 present?" is O(1).
2. Only start counting from a number x where x − 1 is NOT in the set (the start of a run). Then walk x + 1, x + 2, … while they exist.

# Key points

- put all numbers in a set
- only start from run beginnings (x − 1 not in set) so each number is walked once
- O(n) total even though there's a nested while loop
- empty input → 0; duplicates don't matter thanks to the set

# Solution: sort · Sort and scan · O(n log n) · O(n)

## Idea
Remove duplicates, sort, and count runs of +1 steps.

## Complexity
- **Time: O(n log n)**.
- **Space: O(n)**.

```python
class Solution:
    def longestConsecutive(self, nums: list[int]) -> int:
        nums = sorted(set(nums))
        best = run = 0
        for i, x in enumerate(nums):
            run = run + 1 if i and x == nums[i - 1] + 1 else 1
            best = max(best, run)
        return best
```

# Solution: run-starts · Grow runs from their start · O(n) · O(n) · reference

## Idea
A run like 1, 2, 3, 4 should be counted once, from 1. So only start walking at `x` when `x - 1` isn't in the set. From there, step up while `y + 1` exists.

Every number is stepped over by at most one walk, so the inner `while` adds O(n) in total, not per element.

## Complexity
- **Time: O(n)**.
- **Space: O(n)** for the set.

```python
class Solution:
    def longestConsecutive(self, nums: list[int]) -> int:
        s = set(nums)
        best = 0
        for x in s:
            if x - 1 not in s:
                y = x
                while y + 1 in s:
                    y += 1
                best = max(best, y - x + 1)
        return best
```

# Tests

```python
def edge():
    return [[[]], [[5]], [[1, 1, 1]], [[1, 3, 5]], [[-1, 0, 1]], [[9, 1, 4, 7, 3, -1, 0, 5, 8, -1, 6]]]

def random_case(rng):
    return [[rng.randint(-10, 10) for _ in range(rng.randint(0, 12))]]

def perf(rng):
    return [[list(range(100000, 0, -1))], [rng.sample(range(-10**9, 10**9), 100000)]]
```
