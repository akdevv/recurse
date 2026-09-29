---
lc: 485
title: "Max Consecutive Ones"
difficulty: "Easy"
patterns: ["simulation"]
lcTags: ["array"]
entry: {"method": "findMaxConsecutiveOnes", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer"}
examples: ["[1,1,0,1,1,1]", "[1,0,1,1,0,1]"]
lcHints: ["You need to think about two things as far as any window is concerned. One is the starting point for the window. How do you detect that a new window of 1s has started? The next part is detecting the ending point for this window.\r\n\r\nHow do you detect the ending point for an existing window? If you figure these two things out, you will be able to detect the windows of consecutive ones. All that remains afterward is to find the longest such window and return the size."]
---

Given a binary array `nums`, return *the maximum number of consecutive* `1`*'s in the array*.

**Example 1:**

```
Input: nums = [1,1,0,1,1,1]
Output: 3
Explanation: The first two digits or the last three digits are consecutive 1s. The maximum number of consecutive 1s is 3.
```

**Example 2:**

```
Input: nums = [1,0,1,1,0,1]
Output: 2
```

**Constraints:**

- `1 <= nums.length <= 10⁵`
- `nums[i]` is either `0` or `1`.

# Starter

```python
class Solution:
    def findMaxConsecutiveOnes(self, nums: list[int]) -> int:
        
```

# Hints

1. Do you need to restart counting from every index, or can one pass carry the current streak?
2. Keep `cur` (length of the streak ending here) and `best`. A 1 extends the streak, a 0 resets it to 0.

# Key points

- track the current streak and the best streak in one pass
- a 0 resets the current streak; update best as you go
- O(n) time, O(1) space; restarting at every index is O(n²)

# Solution: every-start · Count from every start · O(n²) · O(1) · slow

## Idea
From every index, walk right while you see 1s and record the longest run.

## Complexity
- **Time: O(n²)** in the worst case (all ones: n + (n−1) + … + 1 steps).
- **Space: O(1)**.

With n up to 10⁵ that's billions of steps. The walk from index i+1 repeats almost all the work of the walk from i.

```python
class Solution:
    def findMaxConsecutiveOnes(self, nums: list[int]) -> int:
        best = 0
        for i in range(len(nums)):
            j = i
            while j < len(nums) and nums[j] == 1:
                j += 1
            best = max(best, j - i)
        return best
```

# Solution: streak · One pass with a running streak · O(n) · O(1) · reference

## Idea
`cur` is the length of the run of 1s ending at the current index. A 1 extends it, a 0 resets it. The answer is the largest `cur` ever seen.

## Complexity
- **Time: O(n)**, one pass.
- **Space: O(1)**.

Same shape as a running sum: one variable carries the work forward so nothing is recounted.

```python
class Solution:
    def findMaxConsecutiveOnes(self, nums: list[int]) -> int:
        best = cur = 0
        for x in nums:
            cur = cur + 1 if x == 1 else 0
            best = max(best, cur)
        return best
```

# Tests

```python
def edge():
    return [[[1]], [[0]], [[1, 1, 1]], [[0, 0, 0]], [[1, 1, 0, 1, 1, 1]], [[1, 0, 1, 1, 0, 1]], [[0, 1]]]

def random_case(rng):
    return [[rng.choice([0, 1, 1]) for _ in range(rng.randint(1, 20))]]

def perf(rng):
    return [[[1] * 100000], [[rng.choice([1, 1, 1, 1, 0]) for _ in range(100000)]]]
```
