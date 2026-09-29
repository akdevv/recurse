---
lc: 152
title: "Maximum Product Subarray"
difficulty: "Medium"
patterns: ["dynamic-programming"]
lcTags: ["array", "dynamic-programming"]
entry: {"method": "maxProduct", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer"}
examples: ["[2,3,-2,4]", "[-2,0,-1]"]
---

Given an integer array `nums`, find a subarray that has the largest product, and return *the product*.

The test cases are generated so that the answer will fit in a **32-bit** integer.

**Note** that the product of an array with a single element is the value of that element.

**Example 1:**

```
Input: nums = [2,3,-2,4]
Output: 6
Explanation: [2,3] has the largest product 6.
```

**Example 2:**

```
Input: nums = [-2,0,-1]
Output: 0
Explanation: The result cannot be 2, because [-2,-1] is not a subarray.
```

**Constraints:**

- `1 <= nums.length <= 2 * 10⁴`
- `-10 <= nums[i] <= 10`
- The product of any subarray of `nums` is **guaranteed** to fit in a **32-bit** integer.

# Starter

```python
class Solution:
    def maxProduct(self, nums: list[int]) -> int:
        
```

# Hints

1. A negative number flips the biggest product into the smallest and vice versa. Track both.
2. For each x: new_max = max(x, x·max, x·min), new_min = min(x, x·max, x·min). The answer is the best max seen.

# Key points

- keep the max and min product ending at each index
- a negative x swaps their roles
- zero resets both (x itself is a candidate)
- O(n) time, O(1) space

# Solution: solution-1 · Track max and min product · O(n) · O(1) · reference

## Idea
`f` is the largest product of a subarray ending here, `g` the smallest. A negative number turns the smallest into the largest, so both are needed: the new values are the best of `x`, `f·x` and `g·x`.

## Complexity
- **Time: O(n)**
- **Space: O(1)**

```python
class Solution:
    def maxProduct(self, nums: List[int]) -> int:
        ans = f = g = nums[0]
        for x in nums[1:]:
            ff, gg = f, g
            f = max(x, ff * x, gg * x)
            g = min(x, ff * x, gg * x)
            ans = max(ans, f)
        return ans
```

# Tests

```python
def edge():
    return [[[2, 3, -2, 4]], [[-2, 0, -1]], [[-2]], [[0]], [[-2, 3, -4]], [[-1, -1]], [[2, -5, -2, -4, 3]]]

def random_case(rng):
    return [[rng.randint(-4, 4) for _ in range(rng.randint(1, 10))]]

def perf(rng):
    return [[[rng.choice([-1, 1, 2, 0]) if i % 20 else 0 for i in range(20000)]]]
```
