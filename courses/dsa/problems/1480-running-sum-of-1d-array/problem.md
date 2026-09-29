---
lc: 1480
title: "Running Sum of 1d Array"
difficulty: "Easy"
patterns: ["prefix-sum"]
lcTags: ["array", "prefix-sum"]
entry: {"method": "runningSum", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer[]"}
examples: ["[1,2,3,4]", "[1,1,1,1,1]", "[3,1,2,10,1]"]
lcHints: ["Think about how we can calculate the i-th number in the running sum from the (i-1)-th number."]
---

Given an array `nums`. We define a running sum of an array as `runningSum[i] = sum(nums[0]…nums[i])`.

Return the running sum of `nums`.

**Example 1:**

```
Input: nums = [1,2,3,4]
Output: [1,3,6,10]
Explanation: Running sum is obtained as follows: [1, 1+2, 1+2+3, 1+2+3+4].
```

**Example 2:**

```
Input: nums = [1,1,1,1,1]
Output: [1,2,3,4,5]
Explanation: Running sum is obtained as follows: [1, 1+1, 1+1+1, 1+1+1+1, 1+1+1+1+1].
```

**Example 3:**

```
Input: nums = [3,1,2,10,1]
Output: [3,4,6,16,17]
```

**Constraints:**

- `1 <= nums.length <= 1000`
- `-10^6 <= nums[i] <= 10^6`

# Starter

```python
class Solution:
    def runningSum(self, nums: list[int]) -> list[int]:
        
```

# Hints

1. Do you need to re-add everything from the start for each index?
2. Keep one running total; out[i] = out[i-1] + nums[i].

# Key points

- prefix sum: each answer builds on the previous one
- recomputing each sum is O(n²), a running total is O(n)
- this array is the 'prefix sum' used later for O(1) range sums

# Solution: brute · Re-sum every prefix · O(n²) · O(1) extra

## Idea
For every index `i`, sum `nums[0..i]` from scratch.

## Complexity
- **Time: O(n²)**: index i does i+1 additions → 1 + 2 + … + n = n(n+1)/2.
- **Space: O(1) extra** (the slice copy is O(n) temporarily in Python).

Works within the constraints (n ≤ 1000), but it repeats work: the sum up to i already contains the sum up to i-1.

```python
class Solution:
    def runningSum(self, nums: List[int]) -> List[int]:
        return [sum(nums[: i + 1]) for i in range(len(nums))]
```

# Solution: running · Running total · O(n) · O(1) extra · reference

## Idea
Reuse the previous answer: `running[i] = running[i-1] + nums[i]`. Keep one variable `total` and append it after each step.

## Why it matters
This is the **prefix sum** array. Later (Module 2.3) it gives any range sum `nums[l..r]` in O(1): `prefix[r] - prefix[l-1]`.

## Complexity
- **Time: O(n)**, one addition per element.
- **Space: O(1) extra** besides the output.

```python
class Solution:
    def runningSum(self, nums: List[int]) -> List[int]:
        out, total = [], 0
        for x in nums:
            total += x
            out.append(total)
        return out
```

# Tests

```python
def edge():
    return [[[5]], [[-1, -2, -3]], [[0, 0, 0]], [[10**6] * 5]]

def random_case(rng):
    return [[rng.randint(-50, 50) for _ in range(rng.randint(1, 12))]]

def perf(rng):
    return [[[rng.randint(-10**6, 10**6) for _ in range(1000)]]]
```
