---
lc: 442
title: "Find All Duplicates in an Array"
difficulty: "Medium"
patterns: ["cyclic-sort"]
lcTags: ["array", "hash-table", "sorting"]
compare: "unordered"
entry: {"method": "findDuplicates", "params": [{"name": "nums", "type": "integer[]"}], "returns": "list<integer>"}
examples: ["[4,3,2,7,8,2,3,1]", "[1,1,2]", "[1]"]
---

Given an integer array `nums` of length `n` where all the integers of `nums` are in the range `[1, n]` and each integer appears **at most** **twice**, return *an array of all the integers that appears **twice***.

You must write an algorithm that runs in `O(n)` time and uses only *constant* auxiliary space, excluding the space needed to store the output

**Example 1:**

```
Input: nums = [4,3,2,7,8,2,3,1]
Output: [2,3]
```

**Example 2:**

```
Input: nums = [1,1,2]
Output: [1]
```

**Example 3:**

```
Input: nums = [1]
Output: []
```

**Constraints:**

- `n == nums.length`
- `1 <= n <= 10⁵`
- `1 <= nums[i] <= n`
- Each element in `nums` appears **once** or **twice**.

# Starter

```python
class Solution:
    def findDuplicates(self, nums: list[int]) -> list[int]:
        
```

# Hints

1. Like Disappeared Numbers: each value v points to index v − 1. What happens the second time you visit the same index?
2. For each v, look at nums[abs(v) − 1]. If it's already negative, v is a duplicate; otherwise negate it.

# Key points

- use the array as a seen-marker: negate nums[abs(v) - 1]
- finding it already negative means v was seen before
- O(n) time, O(1) extra space

# Solution: solution-1 · Cyclic sort · O(n) · O(1) · reference

## Idea
Cyclic sort: swap each value v into index v − 1 until every slot holds its own value or a duplicate blocks it. Afterwards, any index i whose value isn't i + 1 holds a duplicate.

## Complexity
- **Time: O(n)**
- **Space: O(1)**

```python
class Solution:
    def findDuplicates(self, nums: List[int]) -> List[int]:
        for i in range(len(nums)):
            while nums[i] != nums[nums[i] - 1]:
                nums[nums[i] - 1], nums[i] = nums[i], nums[nums[i] - 1]
        return [v for i, v in enumerate(nums) if v != i + 1]
```

# Tests

```python
def edge():
    return [[[1]], [[1, 1]], [[1, 1, 2]], [[2, 2, 1, 1]], [[4, 3, 2, 7, 8, 2, 3, 1]]]

def random_case(rng):
    n = rng.randint(1, 12)
    pool = list(range(1, n + 1))
    rng.shuffle(pool)
    nums = []
    for v in pool:
        if len(nums) < n:
            nums.append(v)
        if len(nums) < n and rng.random() < 0.3:
            nums.append(v)
    rng.shuffle(nums)
    return [nums]

def perf(rng):
    n = 100000
    half = list(range(1, n // 2 + 1))
    nums = half + half
    rng.shuffle(nums)
    return [[nums]]
```
