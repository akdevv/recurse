---
lc: 496
title: "Next Greater Element I"
difficulty: "Easy"
patterns: ["monotonic-stack", "hash-map"]
lcTags: ["array", "hash-table", "stack", "monotonic-stack"]
entry: {"method": "nextGreaterElement", "params": [{"name": "nums1", "type": "integer[]"}, {"name": "nums2", "type": "integer[]"}], "returns": "integer[]"}
examples: ["[4,1,2]\n[1,3,4,2]", "[2,4]\n[1,2,3,4]"]
---

The **next greater element** of some element `x` in an array is the **first greater** element that is **to the right** of `x` in the same array.

You are given two **distinct 0-indexed** integer arrays `nums1` and `nums2`, where `nums1` is a subset of `nums2`.

For each `0 <= i < nums1.length`, find the index `j` such that `nums1[i] == nums2[j]` and determine the **next greater element** of `nums2[j]` in `nums2`. If there is no next greater element, then the answer for this query is `-1`.

Return *an array* `ans` *of length* `nums1.length` *such that* `ans[i]` *is the **next greater element** as described above.*

**Example 1:**

```
Input: nums1 = [4,1,2], nums2 = [1,3,4,2]
Output: [-1,3,-1]
Explanation: The next greater element for each value of nums1 is as follows:
- 4 is underlined in nums2 = [1,3,4,2]. There is no next greater element, so the answer is -1.
- 1 is underlined in nums2 = [1,3,4,2]. The next greater element is 3.
- 2 is underlined in nums2 = [1,3,4,2]. There is no next greater element, so the answer is -1.
```

**Example 2:**

```
Input: nums1 = [2,4], nums2 = [1,2,3,4]
Output: [3,-1]
Explanation: The next greater element for each value of nums1 is as follows:
- 2 is underlined in nums2 = [1,2,3,4]. The next greater element is 3.
- 4 is underlined in nums2 = [1,2,3,4]. There is no next greater element, so the answer is -1.
```

**Constraints:**

- `1 <= nums1.length <= nums2.length <= 1000`
- `0 <= nums1[i], nums2[i] <= 10⁴`
- All integers in `nums1` and `nums2` are **unique**.
- All the integers of `nums1` also appear in `nums2`.

**Follow up:** Could you find an `O(nums1.length + nums2.length)` solution?

# Starter

```python
class Solution:
    def nextGreaterElement(self, nums1: list[int], nums2: list[int]) -> list[int]:
        
```

# Hints

1. Compute the next greater element for every value of nums2 once, then answer nums1 with lookups.
2. Walk nums2 with a decreasing stack. When x is bigger than the top, x is the top's next greater: pop and record it. Store answers in a dict.

# Key points

- monotonic decreasing stack over nums2 finds "next greater" for all values in O(n)
- dict value → next greater, default -1
- answer nums1 by lookup: O(m + n) total

# Solution: monotonic-stack · Monotonic Stack · O(m + n) · O(n) · reference

We can traverse the array nums2 from right to left, maintaining a stack stk that is monotonically increasing from top to bottom. We use a hash table d to record the next greater element for each element.

When we encounter an element x, if the stack is not empty and the top element of the stack is less than x, we keep popping the top elements until the stack is empty or the top element is greater than or equal to x. At this point, if the stack is not empty, the top element of the stack is the next greater element for x. Otherwise, x has no next greater element.

Finally, we traverse the array nums1 and use the hash table d to get the answer.

The time complexity is O(m + n), and the space complexity is O(n). Here, m and n are the lengths of the arrays nums1 and nums2, respectively.

```python
class Solution:
    def nextGreaterElement(self, nums1: List[int], nums2: List[int]) -> List[int]:
        stk = []
        d = {}
        for x in nums2[::-1]:
            while stk and stk[-1] < x:
                stk.pop()
            if stk:
                d[x] = stk[-1]
            stk.append(x)
        return [d.get(x, -1) for x in nums1]
```

# Tests

```python
def edge():
    return [[[1], [1]], [[4, 1, 2], [1, 3, 4, 2]], [[2, 4], [1, 2, 3, 4]], [[3], [3, 2, 1]], [[1, 3], [3, 1]]]

def random_case(rng):
    nums2 = rng.sample(range(0, 20), rng.randint(1, 10))
    return [rng.sample(nums2, rng.randint(1, len(nums2))), nums2]

def perf(rng):
    nums2 = rng.sample(range(10**4 + 1), 1000)
    return [[nums2[:], nums2]]
```
