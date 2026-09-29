---
lc: 1
title: "Two Sum"
difficulty: "Easy"
patterns: ["hash-map"]
lcTags: ["array", "hash-table"]
compare: "unordered"
entry: {"method": "twoSum", "params": [{"name": "nums", "type": "integer[]"}, {"name": "target", "type": "integer"}], "returns": "integer[]"}
examples: ["[2,7,11,15]\n9", "[3,2,4]\n6", "[3,3]\n6"]
lcHints: ["A really brute force way would be to search for all possible pairs of numbers but that would be too slow. Again, it's best to try out brute force solutions just for completeness. It is from these brute force solutions that you can come up with optimizations.", "So, if we fix one of the numbers, say <code>x</code>, we have to scan the entire array to find the next number <code>y</code> which is <code>value - x</code> where value is the input parameter. Can we change our array somehow so that this search becomes faster?", "The second train of thought is, without changing the array, can we use additional space somehow? Like maybe a hash map to speed up the search?"]
---

You are given an array of integers `nums` and an integer `target`, return *indices of the two numbers such that they add up to `target`*.

You may assume that each input would have ***exactly* one solution**, and you may not use the *same* element twice.

You can return the answer in any order.

**Example 1:**

```
Input: nums = [2,7,11,15], target = 9
Output: [0,1]
Explanation: Because nums[0] + nums[1] == 9, we return [0, 1].
```

**Example 2:**

```
Input: nums = [3,2,4], target = 6
Output: [1,2]
```

**Example 3:**

```
Input: nums = [3,3], target = 6
Output: [0,1]
```

**Constraints:**

- `2 <= nums.length <= 10⁴`
- `-10⁹ <= nums[i] <= 10⁹`
- `-10⁹ <= target <= 10⁹`
- **Only one valid answer exists.**

**Follow-up:** Can you come up with an algorithm that is less than `O(n²)` time complexity?

# Starter

```python
class Solution:
    def twoSum(self, nums: list[int], target: int) -> list[int]:
        
```

# Hints

1. For each number x you need to find target − x somewhere else in the array. How can you find it without scanning again?
2. Keep a dict value → index of numbers seen so far. For each x, check if target − x is in it before storing x.

# Key points

- for each x, the partner is target − x
- store value → index in a dict as you go; look up the partner before inserting x
- checking before inserting stops x from pairing with itself
- O(n) time, O(n) space vs O(n²) for checking all pairs

# Solution: pairs · Check every pair · O(n²) · O(1)

## Idea
Try every pair i < j. With n ≤ 10⁴ this still passes, but it's the answer the interviewer wants you to improve.

## Complexity
- **Time: O(n²)**.
- **Space: O(1)**.

```python
class Solution:
    def twoSum(self, nums: list[int], target: int) -> list[int]:
        for i in range(len(nums)):
            for j in range(i + 1, len(nums)):
                if nums[i] + nums[j] == target:
                    return [i, j]
```

# Solution: one-pass · One-pass hash map · O(n) · O(n) · reference

## Idea
Walk left to right. For `x` the partner must be `target - x`. If we've already seen it, the dict gives its index. If not, store `x` so a later number can find it.

Looking up **before** inserting means `x` never pairs with itself (e.g. `[3, 2, 4]`, target 6 must not return `[0, 0]`).

## Complexity
- **Time: O(n)**, one pass with O(1) dict lookups.
- **Space: O(n)** for the dict.

```python
class Solution:
    def twoSum(self, nums: list[int], target: int) -> list[int]:
        index = {}
        for i, x in enumerate(nums):
            if target - x in index:
                return [index[target - x], i]
            index[x] = i
```

# Tests

```python
def edge():
    return [[[3, 3], 6], [[3, 2, 4], 6], [[-1, -2, -3, -4, -5], -8], [[0, 4, 3, 0], 0], [[10**9, -10**9], 0]]

def random_case(rng):
    n = rng.randint(2, 10)
    vals = rng.sample(range(-50, 50), n)
    i, j = rng.sample(range(n), 2)
    target = vals[i] + vals[j]
    # keep the answer unique: drop other pairs that hit target
    seen = set()
    for k in range(n):
        if k in (i, j):
            continue
        while any(vals[k] + vals[m] == target for m in range(n) if m != k) or vals[k] in seen:
            vals[k] = rng.randint(1000, 10**6)
        seen.add(vals[k])
    return [vals, target]

def perf(rng):
    n = 10000
    nums = list(range(1, n + 1))
    return [[nums, 2 * n - 1]]
```
