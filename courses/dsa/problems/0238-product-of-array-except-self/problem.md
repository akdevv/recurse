---
lc: 238
title: "Product of Array Except Self"
difficulty: "Medium"
patterns: ["prefix-sum"]
lcTags: ["array", "prefix-sum"]
entry: {"method": "productExceptSelf", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer[]"}
examples: ["[1,2,3,4]", "[-1,1,0,-3,3]"]
lcHints: ["Think how you can efficiently utilize prefix and suffix products to calculate the product of all elements except self for each index. Can you pre-compute the prefix and suffix products in linear time to avoid redundant calculations?", "Can you minimize additional space usage by reusing memory or modifying the input array to store intermediate results?"]
---

Given an integer array `nums`, return *an array* `answer` *such that* `answer[i]` *is equal to the product of all the elements of* `nums` *except* `nums[i]`.

The product of any prefix or suffix of `nums` is **guaranteed** to fit in a **32-bit** integer.

You must write an algorithm that runs in `O(n)` time and without using the division operation.

**Example 1:**

```
Input: nums = [1,2,3,4]
Output: [24,12,8,6]
```

**Example 2:**

```
Input: nums = [-1,1,0,-3,3]
Output: [0,0,9,0,0]
```

**Constraints:**

- `2 <= nums.length <= 10⁵`
- `-30 <= nums[i] <= 30`
- The input is generated such that `answer[i]` is **guaranteed** to fit in a **32-bit** integer.

**Follow up:** Can you solve the problem in `O(1)` extra space complexity? (The output array **does not** count as extra space for space complexity analysis.)

# Starter

```python
class Solution:
    def productExceptSelf(self, nums: list[int]) -> list[int]:
        
```

# Hints

1. answer[i] = (product of everything left of i) × (product of everything right of i). No division needed.
2. Fill answer with prefix products in one pass left→right, then multiply in suffix products with a running variable going right→left.

# Key points

- answer[i] = prefix product before i × suffix product after i
- no division, so zeros need no special handling
- two passes; the right-side product lives in one variable → O(1) extra space
- O(n) time

# Solution: brute · Multiply everything else · O(n²) · O(1) · slow

## Idea
For each index, multiply all other values.

## Complexity
- **Time: O(n²)**.
- **Space: O(1)** extra.

```python
class Solution:
    def productExceptSelf(self, nums: list[int]) -> list[int]:
        out = []
        for i in range(len(nums)):
            p = 1
            for j, x in enumerate(nums):
                if j != i:
                    p *= x
            out.append(p)
        return out
```

# Solution: prefix-suffix · Prefix × suffix products · O(n) · O(1) · reference

## Idea
Pass 1 stores in `out[i]` the product of everything **left** of i. Pass 2 walks from the right with a running `right` product and multiplies it in. Each `out[i]` ends up as left × right, skipping `nums[i]` itself.

Dividing the total product by `nums[i]` breaks on zeros; this approach never divides.

## Complexity
- **Time: O(n)**.
- **Space: O(1)** extra (the output doesn't count).

```python
class Solution:
    def productExceptSelf(self, nums: list[int]) -> list[int]:
        n = len(nums)
        out = [1] * n
        for i in range(1, n):
            out[i] = out[i - 1] * nums[i - 1]
        right = 1
        for i in range(n - 1, -1, -1):
            out[i] *= right
            right *= nums[i]
        return out
```

# Tests

```python
def edge():
    return [[[1, 2]], [[0, 0]], [[0, 4]], [[-1, 1, 0, -3, 3]], [[2, 3, 0, 4]], [[-1, -1, -1]]]

def random_case(rng):
    return [[rng.randint(-3, 3) for _ in range(rng.randint(2, 8))]]

def perf(rng):
    return [[[rng.choice([-1, 1]) for _ in range(100000)]]]
```
