---
lc: 136
title: "Single Number"
difficulty: "Easy"
patterns: ["bit-manipulation"]
lcTags: ["array", "bit-manipulation"]
entry: {"method": "singleNumber", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer"}
examples: ["[2,2,1]", "[4,1,2,1,2]", "[1]"]
lcHints: ["Think about the XOR (^) operator's property."]
---

Given a **non-empty** array of integers `nums`, every element appears *twice* except for one. Find that single one.

You must implement a solution with a linear runtime complexity and use only constant extra space.

**Example 1:**

**Input:** nums = [2,2,1]

**Output:** 1

**Example 2:**

**Input:** nums = [4,1,2,1,2]

**Output:** 4

**Example 3:**

**Input:** nums = [1]

**Output:** 1

**Constraints:**

- `1 <= nums.length <= 3 * 10⁴`
- `-3 * 10⁴ <= nums[i] <= 3 * 10⁴`
- Each element in the array appears twice except for one element which appears only once.

# Starter

```python
class Solution:
    def singleNumber(self, nums: list[int]) -> int:
        
```

# Hints

1. x ^ x = 0 and x ^ 0 = x, and XOR doesn't care about order.
2. XOR all the numbers together: every pair cancels out, leaving the single one.

# Key points

- XOR is its own inverse: pairs cancel
- one pass, O(n) time, O(1) space
- a set or Counter works but uses O(n) space

# Solution: bitwise-operation · Bitwise Operation · O(n) · O(1) · reference

The XOR operation has the following properties:

- Any number XOR 0 is still the original number, i.e., `x XOR 0 = x`;
- Any number XOR itself is 0, i.e., `x XOR x = 0`;

Performing XOR operation on all elements in the array will result in the number that only appears once.

The time complexity is O(n), where n is the length of the array. The space complexity is O(1).

```python
class Solution:
    def singleNumber(self, nums: List[int]) -> int:
        return reduce(xor, nums)
```

# Tests

```python
def make(rng, pairs, lo, hi):
    vals = rng.sample(range(lo, hi + 1), pairs + 1)
    nums = vals[:-1] * 2 + [vals[-1]]
    rng.shuffle(nums)
    return [nums]

def edge():
    return [[[1]], [[2, 2, 1]], [[4, 1, 2, 1, 2]], [[-30000, 5, 5]], [[0, 1, 0]]]

def random_case(rng):
    return make(rng, rng.randint(0, 5), -10, 10)

def perf(rng):
    return [make(rng, 14999, -3 * 10**4, 3 * 10**4)]
```
