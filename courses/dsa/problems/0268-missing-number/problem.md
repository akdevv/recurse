---
lc: 268
title: "Missing Number"
difficulty: "Easy"
patterns: ["cyclic-sort", "bit-manipulation"]
lcTags: ["array", "hash-table", "math", "binary-search", "bit-manipulation", "sorting"]
entry: {"method": "missingNumber", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer"}
examples: ["[3,0,1]", "[0,1]", "[9,6,4,2,3,5,7,0,1]"]
---

Given an array `nums` containing `n` distinct numbers in the range `[0, n]`, return *the only number in the range that is missing from the array.*

**Example 1:**

**Input:** nums = [3,0,1]

**Output:** 2

**Explanation:**

`n = 3` since there are 3 numbers, so all numbers are in the range `[0,3]`. 2 is the missing number in the range since it does not appear in `nums`.

**Example 2:**

**Input:** nums = [0,1]

**Output:** 2

**Explanation:**

`n = 2` since there are 2 numbers, so all numbers are in the range `[0,2]`. 2 is the missing number in the range since it does not appear in `nums`.

**Example 3:**

**Input:** nums = [9,6,4,2,3,5,7,0,1]

**Output:** 8

**Explanation:**

`n = 9` since there are 9 numbers, so all numbers are in the range `[0,9]`. 8 is the missing number in the range since it does not appear in `nums`.

**Constraints:**

- `n == nums.length`
- `1 <= n <= 10⁴`
- `0 <= nums[i] <= n`
- All the numbers of `nums` are **unique**.

**Follow up:** Could you implement a solution using only `O(1)` extra space complexity and `O(n)` runtime complexity?

# Starter

```python
class Solution:
    def missingNumber(self, nums: list[int]) -> int:
        
```

# Hints

1. The numbers 0..n should add up to n(n + 1) / 2. What does the actual sum tell you?
2. Return n·(n + 1)/2 − sum(nums). (XOR of all indices and values works too.)

# Key points

- expected sum of 0..n is n(n + 1)/2; the difference is the missing number
- XOR alternative: x ^ x = 0, so XOR of 0..n and all values leaves the missing one
- O(n) time, O(1) space; a set works but uses O(n) space

# Solution: bitwise-operation · Bitwise Operation · O(n) · O(1) · reference

The XOR operation has the following properties:

- Any number XOR 0 is still the original number, i.e., `x XOR 0 = x`;
- Any number XOR itself is 0, i.e., `x XOR x = 0`;

Therefore, we can traverse the array, perform XOR operation between each element and the numbers `[0,..n]`, and the final result will be the missing number.

The time complexity is O(n), where n is the length of the array. The space complexity is O(1).

```python
class Solution:
    def missingNumber(self, nums: List[int]) -> int:
        return reduce(xor, (i ^ v for i, v in enumerate(nums, 1)))
```

# Solution: mathematics · Mathematics · O(n) · O(1)

We can also solve this problem using mathematics. By calculating the sum of `[0,..n]`, subtracting the sum of all numbers in the array, we can obtain the missing number.

The time complexity is O(n), where n is the length of the array. The space complexity is O(1).

```python
class Solution:
    def missingNumber(self, nums: List[int]) -> int:
        n = len(nums)
        return (1 + n) * n // 2 - sum(nums)
```

# Tests

```python
def edge():
    return [[[0]], [[1]], [[1, 0]], [[0, 1]], [[3, 0, 1]], [[9, 6, 4, 2, 3, 5, 7, 0, 1]]]

def random_case(rng):
    n = rng.randint(1, 12)
    nums = list(range(n + 1))
    nums.remove(rng.randint(0, n))
    rng.shuffle(nums)
    return [nums]

def perf(rng):
    nums = list(range(10001))
    nums.remove(rng.randint(0, 10000))
    rng.shuffle(nums)
    return [[nums]]
```
