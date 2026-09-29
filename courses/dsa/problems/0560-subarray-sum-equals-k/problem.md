---
lc: 560
title: "Subarray Sum Equals K"
difficulty: "Medium"
patterns: ["prefix-sum", "hash-map"]
lcTags: ["array", "hash-table", "prefix-sum"]
entry: {"method": "subarraySum", "params": [{"name": "nums", "type": "integer[]"}, {"name": "k", "type": "integer"}], "returns": "integer"}
examples: ["[1,1,1]\n2", "[1,2,3]\n3"]
lcHints: ["Will Brute force work here? Try to optimize it.", "Can we optimize it by using some extra space?", "What about storing sum frequencies in a hash table? Will it be useful?", "sum(i,j)=sum(0,j)-sum(0,i), where sum(i,j) represents the sum of all the elements from index i to j-1.\r\n\r\nCan we use this property to optimize it."]
---

Given an array of integers `nums` and an integer `k`, return *the total number of subarrays whose sum equals to* `k`.

A subarray is a contiguous **non-empty** sequence of elements within an array.

**Example 1:**

```
Input: nums = [1,1,1], k = 2
Output: 2
```

**Example 2:**

```
Input: nums = [1,2,3], k = 3
Output: 2
```

**Constraints:**

- `1 <= nums.length <= 2 * 10⁴`
- `-1000 <= nums[i] <= 1000`
- `-10⁷ <= k <= 10⁷`

# Starter

```python
class Solution:
    def subarraySum(self, nums: List[int], k: int) -> int:
        
```

# Hints

1. Sum of nums[i..j] = prefix[j + 1] − prefix[i]. You want pairs of prefix sums that differ by exactly k.
2. Walk once with a running sum s. Keep a dict count[prefix value]. At each step add count[s − k] to the answer, then record s. Start with count[0] = 1.

# Key points

- subarray sum = difference of two prefix sums
- at each position count earlier prefixes equal to s − k (like Two Sum on prefix sums)
- seed count[0] = 1 for subarrays that start at index 0
- sliding window doesn't work because values can be negative
- O(n) time, O(n) space

# Solution: all-starts · Every start, running sum · O(n²) · O(1) · slow

## Idea
Fix a start `i`, extend the end `j` while keeping a running sum.

## Complexity
- **Time: O(n²)**.
- **Space: O(1)**.

```python
class Solution:
    def subarraySum(self, nums: list[int], k: int) -> int:
        count = 0
        for i in range(len(nums)):
            s = 0
            for j in range(i, len(nums)):
                s += nums[j]
                if s == k:
                    count += 1
        return count
```

# Solution: prefix-map · Prefix sums + hash map · O(n) · O(n) · reference

## Idea
If the running sum is `s` now and was `s - k` at some earlier point, the numbers in between add up to `k`. So at every step, the number of subarrays ending here is how many earlier prefixes equal `s - k`.

`seen[0] = 1` stands for the empty prefix, so a subarray starting at index 0 is counted too.

Sliding window fails here: with negative numbers, shrinking the window doesn't always lower the sum.

## Complexity
- **Time: O(n)**.
- **Space: O(n)** for the prefix counts.

```python
from collections import defaultdict

class Solution:
    def subarraySum(self, nums: list[int], k: int) -> int:
        seen = defaultdict(int)
        seen[0] = 1
        s = count = 0
        for x in nums:
            s += x
            count += seen[s - k]
            seen[s] += 1
        return count
```

# Tests

```python
def edge():
    return [[[1], 1], [[1], 0], [[0, 0, 0], 0], [[1, -1, 1, -1], 0], [[-1, -1, 1], 0], [[3, 4, 7, 2, -3, 1, 4, 2], 7]]

def random_case(rng):
    return [[rng.randint(-3, 3) for _ in range(rng.randint(1, 10))], rng.randint(-4, 4)]

def perf(rng):
    return [[[rng.randint(-1000, 1000) for _ in range(20000)], 100]]
```
