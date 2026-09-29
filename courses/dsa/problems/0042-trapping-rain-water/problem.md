---
lc: 42
title: "Trapping Rain Water"
difficulty: "Hard"
patterns: ["two-pointers"]
lcTags: ["array", "two-pointers", "dynamic-programming", "stack", "monotonic-stack"]
entry: {"method": "trap", "params": [{"name": "height", "type": "integer[]"}], "returns": "integer"}
examples: ["[0,1,0,2,1,0,1,3,2,1,2,1]", "[4,2,0,3,2,5]"]
---

Given `n` non-negative integers representing an elevation map where the width of each bar is `1`, compute how much water it can trap after raining.

**Example 1:**

![](https://assets.leetcode.com/uploads/2018/10/22/rainwatertrap.png)

```
Input: height = [0,1,0,2,1,0,1,3,2,1,2,1]
Output: 6
Explanation: The above elevation map (black section) is represented by array [0,1,0,2,1,0,1,3,2,1,2,1]. In this case, 6 units of rain water (blue section) are being trapped.
```

**Example 2:**

```
Input: height = [4,2,0,3,2,5]
Output: 9
```

**Constraints:**

- `n == height.length`
- `1 <= n <= 2 * 10⁴`
- `0 <= height[i] <= 10⁵`

# Starter

```python
class Solution:
    def trap(self, height: list[int]) -> int:
        
```

# Hints

1. Water above bar i = min(tallest bar to its left, tallest bar to its right) − height[i], if positive.
2. Two pointers: keep left_max and right_max. Whichever side has the smaller max is settled: add its water and move that pointer inward.

# Key points

- water at i = min(max left, max right) − height[i]
- prefix/suffix max arrays give O(n) time, O(n) space
- two pointers: the side with the smaller max is bounded by it, so it can be settled now → O(1) space

# Solution: brute · Scan both sides for every bar · O(n²) · O(1) · slow

## Idea
For each bar, find the tallest bar on each side and add the water above it.

## Complexity
- **Time: O(n²)**.
- **Space: O(1)**.

```python
class Solution:
    def trap(self, height: list[int]) -> int:
        total = 0
        for i in range(len(height)):
            total += min(max(height[: i + 1]), max(height[i:])) - height[i]
        return total
```

# Solution: prefix-max · Prefix and suffix maxima · O(n) · O(n)

## Idea
Precompute `left[i]` = tallest bar in `0..i` and `right[i]` = tallest in `i..n-1`. Then each bar holds `min(left[i], right[i]) - height[i]`.

## Complexity
- **Time: O(n)**, three passes.
- **Space: O(n)** for the two arrays.

```python
class Solution:
    def trap(self, height: list[int]) -> int:
        n = len(height)
        left, right = height[:], height[:]
        for i in range(1, n):
            left[i] = max(left[i - 1], height[i])
        for i in range(n - 2, -1, -1):
            right[i] = max(right[i + 1], height[i])
        return sum(min(left[i], right[i]) - height[i] for i in range(n))
```

# Solution: two-pointers · Two pointers · O(n) · O(1) · reference

## Idea
Keep `lmax` (tallest seen from the left) and `rmax` (from the right). If `lmax < rmax`, the water at `l` is decided by `lmax`: there's something at least as tall as `rmax` on the right, so the right side can't be the limit. Add `lmax - height[l]` and move `l`. Otherwise do the same on the right.

## Complexity
- **Time: O(n)**.
- **Space: O(1)**.

```python
class Solution:
    def trap(self, height: list[int]) -> int:
        l, r = 0, len(height) - 1
        lmax = rmax = total = 0
        while l < r:
            lmax = max(lmax, height[l])
            rmax = max(rmax, height[r])
            if lmax < rmax:
                total += lmax - height[l]
                l += 1
            else:
                total += rmax - height[r]
                r -= 1
        return total
```

# Tests

```python
def edge():
    return [[[0]], [[5]], [[1, 2, 3]], [[3, 2, 1]], [[2, 0, 2]], [[4, 2, 0, 3, 2, 5]], [[5, 4, 1, 2]]]

def random_case(rng):
    return [[rng.randint(0, 6) for _ in range(rng.randint(1, 12))]]

def perf(rng):
    return [[[rng.randint(0, 10**5) for _ in range(20000)]]]
```
