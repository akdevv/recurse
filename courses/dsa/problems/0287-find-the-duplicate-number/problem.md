---
lc: 287
title: "Find the Duplicate Number"
difficulty: "Medium"
patterns: ["fast-slow-pointers", "binary-search"]
lcTags: ["array", "two-pointers", "binary-search", "bit-manipulation", "pigeonhole-principle", "floyds-cycle-finding-algorithm"]
entry: {"method": "findDuplicate", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer"}
examples: ["[1,3,4,2,2]", "[3,1,3,4,2]", "[3,3,3,3,3]"]
---

Given an array of integers `nums` containing `n + 1` integers where each integer is in the range `[1, n]` inclusive.

There is only **one repeated number** in `nums`, return *this repeated number*.

You must solve the problem **without** modifying the array `nums` and using only constant extra space.

**Example 1:**

```
Input: nums = [1,3,4,2,2]
Output: 2
```

**Example 2:**

```
Input: nums = [3,1,3,4,2]
Output: 3
```

**Example 3:**

```
Input: nums = [3,3,3,3,3]
Output: 3
```

**Constraints:**

- `1 <= n <= 10⁵`
- `nums.length == n + 1`
- `1 <= nums[i] <= n`
- All the integers in `nums` appear only **once** except for **precisely one integer** which appears **two or more** times.

**Follow up:**

- How can we prove that at least one duplicate number must exist in `nums`?
- Can you solve the problem in linear runtime complexity?

# Starter

```python
class Solution:
    def findDuplicate(self, nums: list[int]) -> int:
        
```

# Hints

1. Values are in 1..n and there are n + 1 of them. Treat i → nums[i] as a "next" pointer: the duplicate is where two arrows point to the same place.
2. Floyd's cycle detection on that implicit list: find the meeting point, then restart one pointer at 0 and step both until they meet. That value is the duplicate.

# Key points

- index → value links form a linked list with a cycle; the duplicate is the cycle entrance
- Floyd phase 1 + phase 2, like Linked List Cycle II
- O(n) time, O(1) space, array not modified
- alternative: binary search on the value range, counting how many are <= mid

# Solution: binary-search · Binary Search · O(n × log n) · O(1) · reference

We can observe that if the number of elements in `[1,..x]` is greater than x, then the duplicate number must be in `[1,..x]`, otherwise the duplicate number must be in `[x+1,..n]`.

Therefore, we can use binary search to find x, and check whether the number of elements in `[1,..x]` is greater than x at each iteration. This way, we can determine which interval the duplicate number is in, and narrow down the search range until we find the duplicate number.

The time complexity is O(n × log n), where n is the length of the array nums. The space complexity is O(1).

```python
class Solution:
    def findDuplicate(self, nums: List[int]) -> int:
        def f(x: int) -> bool:
            return sum(v <= x for v in nums) > x

        return bisect_left(range(len(nums)), True, key=f)
```

# Tests

```python
def edge():
    return [[[1, 1]], [[1, 1, 1]], [[1, 3, 4, 2, 2]], [[3, 1, 3, 4, 2]], [[3, 3, 3, 3, 3]], [[2, 2, 2]]]

def random_case(rng):
    n = rng.randint(1, 10)
    dup = rng.randint(1, n)
    others = [v for v in range(1, n + 1) if v != dup]
    rng.shuffle(others)
    keep = others[: rng.randint(0, len(others))]
    nums = keep + [dup] * (n + 1 - len(keep))
    rng.shuffle(nums)
    return [nums]

def perf(rng):
    n = 100000
    nums = list(range(1, n + 1)) + [rng.randint(1, n)]
    rng.shuffle(nums)
    return [[nums]]
```
