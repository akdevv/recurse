---
lc: 15
title: "3Sum"
difficulty: "Medium"
patterns: ["two-pointers"]
lcTags: ["array", "two-pointers", "sorting"]
compare: "groups"
entry: {"method": "threeSum", "params": [{"name": "nums", "type": "integer[]"}], "returns": "list<list<integer>>"}
examples: ["[-1,0,1,2,-1,-4]", "[0,1,1]", "[0,0,0]"]
lcHints: ["So, we essentially need to find three numbers x, y, and z such that they add up to the given value. If we fix one of the numbers say x, we are left with the two-sum problem at hand!", "For the two-sum problem, if we fix one of the numbers, say x, we have to scan the entire array to find the next number y, which is value - x where value is the input parameter. Can we change our array somehow so that this search becomes faster?", "The second train of thought for two-sum is, without changing the array, can we use additional space somehow? Like maybe a hash map to speed up the search?"]
---

Given an integer array nums, return all the triplets `[nums[i], nums[j], nums[k]]` such that `i != j`, `i != k`, and `j != k`, and `nums[i] + nums[j] + nums[k] == 0`.

Notice that the solution set must not contain duplicate triplets.

**Example 1:**

```
Input: nums = [-1,0,1,2,-1,-4]
Output: [[-1,-1,2],[-1,0,1]]
Explanation:
nums[0] + nums[1] + nums[2] = (-1) + 0 + 1 = 0.
nums[1] + nums[2] + nums[4] = 0 + 1 + (-1) = 0.
nums[0] + nums[3] + nums[4] = (-1) + 2 + (-1) = 0.
The distinct triplets are [-1,0,1] and [-1,-1,2].
Notice that the order of the output and the order of the triplets does not matter.
```

**Example 2:**

```
Input: nums = [0,1,1]
Output: []
Explanation: The only possible triplet does not sum up to 0.
```

**Example 3:**

```
Input: nums = [0,0,0]
Output: [[0,0,0]]
Explanation: The only possible triplet sums up to 0.
```

**Constraints:**

- `3 <= nums.length <= 3000`
- `-10⁵ <= nums[i] <= 10⁵`

# Starter

```python
class Solution:
    def threeSum(self, nums: list[int]) -> list[list[int]]:
        
```

# Hints

1. Sort the array. Fix the first number, then you need two numbers after it that sum to −first: that's Two Sum II.
2. To avoid duplicate triplets, skip a fixed number equal to the previous one, and after finding a triplet move both pointers past equal values.

# Key points

- sort, then for each i run two pointers on the rest for sum −nums[i]
- skip equal values for i and after each hit, so no duplicate triplets
- O(n²) time, O(1) extra space besides the output (sorting aside)
- early exit: once nums[i] > 0 no triplet can sum to 0

# Solution: hash-set · Fix two, look up the third · O(n²) · O(n)

## Idea
Sort, fix `i`, then run the "Two Sum with a set" idea on the rest. Collect triplets as sorted tuples in a set to remove duplicates.

## Complexity
- **Time: O(n²)**.
- **Space: O(n)** for the set (plus the output).

```python
class Solution:
    def threeSum(self, nums: list[int]) -> list[list[int]]:
        nums = sorted(nums)
        found = set()
        for i in range(len(nums)):
            seen = set()
            for j in range(i + 1, len(nums)):
                need = -nums[i] - nums[j]
                if need in seen:
                    found.add((nums[i], need, nums[j]))
                seen.add(nums[j])
        return [list(t) for t in found]
```

# Solution: two-pointers · Sort + two pointers · O(n²) · O(1) · reference

## Idea
Sort. For each `i`, look for two numbers after it summing to `-nums[i]` with the Two Sum II pointers.

Duplicates are handled by skipping, not by a set:
- skip `i` if `nums[i] == nums[i - 1]` (same first number, same triplets);
- after a hit, move `l` and `r` past values equal to the ones just used.

## Complexity
- **Time: O(n²)**: n choices of `i`, O(n) pointer walk each.
- **Space: O(1)** extra (ignoring sort and output).

```python
class Solution:
    def threeSum(self, nums: list[int]) -> list[list[int]]:
        nums.sort()
        out = []
        for i in range(len(nums) - 2):
            if nums[i] > 0:
                break
            if i and nums[i] == nums[i - 1]:
                continue
            l, r = i + 1, len(nums) - 1
            while l < r:
                s = nums[i] + nums[l] + nums[r]
                if s < 0:
                    l += 1
                elif s > 0:
                    r -= 1
                else:
                    out.append([nums[i], nums[l], nums[r]])
                    l += 1
                    r -= 1
                    while l < r and nums[l] == nums[l - 1]:
                        l += 1
                    while l < r and nums[r] == nums[r + 1]:
                        r -= 1
        return out
```

# Solution: brute · Try every triple · O(n³) · O(1) · slow

## Idea
Three nested loops, dedupe with a set of sorted triples.

## Complexity
- **Time: O(n³)**, far too slow for n = 3000.
- **Space: O(1)** extra besides the answer set.

```python
class Solution:
    def threeSum(self, nums: list[int]) -> list[list[int]]:
        n, found = len(nums), set()
        for i in range(n):
            for j in range(i + 1, n):
                for k in range(j + 1, n):
                    if nums[i] + nums[j] + nums[k] == 0:
                        found.add(tuple(sorted((nums[i], nums[j], nums[k]))))
        return [list(t) for t in found]
```

# Tests

```python
def edge():
    return [[[0, 0, 0]], [[0, 1, 1]], [[0, 0, 0, 0]], [[-1, 0, 1, 0]], [[-2, 0, 1, 1, 2]], [[1, 2, -3, -1, -1, 2]]]

def random_case(rng):
    return [[rng.randint(-5, 5) for _ in range(rng.randint(3, 10))]]

def perf(rng):
    return [[[rng.randint(-10**5, 10**5) for _ in range(3000)]], [[rng.randint(-50, 50) for _ in range(3000)]]]
```
