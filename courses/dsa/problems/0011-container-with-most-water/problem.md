---
lc: 11
title: "Container With Most Water"
difficulty: "Medium"
patterns: ["two-pointers"]
lcTags: ["array", "two-pointers", "greedy"]
entry: {"method": "maxArea", "params": [{"name": "height", "type": "integer[]"}], "returns": "integer"}
examples: ["[1,8,6,2,5,4,8,3,7]", "[1,1]"]
lcHints: ["If you simulate the problem, it will be O(n^2) which is not efficient.", "Try to use two-pointers. Set one pointer to the left and one to the right of the array. Always move the pointer that points to the lower line.", "How can you calculate the amount of water at each step?"]
---

You are given an integer array `height` of length `n`. There are `n` vertical lines drawn such that the two endpoints of the `iᵗʰ` line are `(i, 0)` and `(i, height[i])`.

Find two lines that together with the x-axis form a container, such that the container contains the most water.

Return *the maximum amount of water a container can store*.

**Notice** that you may not slant the container.

**Example 1:**

![](https://s3-lc-upload.s3.amazonaws.com/uploads/2018/07/17/question_11.jpg)

```
Input: height = [1,8,6,2,5,4,8,3,7]
Output: 49
Explanation: The above vertical lines are represented by array [1,8,6,2,5,4,8,3,7]. In this case, the max area of water (blue section) the container can contain is 49.
```

**Example 2:**

```
Input: height = [1,1]
Output: 1
```

**Constraints:**

- `n == height.length`
- `2 <= n <= 10⁵`
- `0 <= height[i] <= 10⁴`

# Starter

```python
class Solution:
    def maxArea(self, height: list[int]) -> int:
        
```

# Hints

1. Area = width × the shorter of the two lines. Start with the widest container, both ends.
2. Moving the taller line inward can never help (width shrinks, height is still capped by the shorter one). So always move the shorter line.

# Key points

- area = (r − l) × min(height[l], height[r])
- start at both ends; always move the pointer at the shorter line
- moving the taller line can only lose: width drops and the height cap stays
- O(n) time, O(1) space

# Solution: pairs · Try every pair · O(n²) · O(1) · slow

## Idea
Compute the area for every pair of lines.

## Complexity
- **Time: O(n²)**, too slow for n = 10⁵.
- **Space: O(1)**.

```python
class Solution:
    def maxArea(self, height: list[int]) -> int:
        best = 0
        for i in range(len(height)):
            for j in range(i + 1, len(height)):
                best = max(best, (j - i) * min(height[i], height[j]))
        return best
```

# Solution: two-pointers · Move the shorter line · O(n) · O(1) · reference

## Idea
Start with the widest container. The shorter line limits the area. Any container that keeps that short line and moves the other end inward is narrower and still capped by it, so it's never better. We can drop the shorter line and move its pointer in.

## Complexity
- **Time: O(n)**.
- **Space: O(1)**.

```python
class Solution:
    def maxArea(self, height: list[int]) -> int:
        l, r, best = 0, len(height) - 1, 0
        while l < r:
            best = max(best, (r - l) * min(height[l], height[r]))
            if height[l] < height[r]:
                l += 1
            else:
                r -= 1
        return best
```

# Tests

```python
def edge():
    return [[[1, 1]], [[0, 0]], [[1, 2, 1]], [[4, 3, 2, 1, 4]], [[1, 8, 6, 2, 5, 4, 8, 3, 7]]]

def random_case(rng):
    return [[rng.randint(0, 10) for _ in range(rng.randint(2, 10))]]

def perf(rng):
    return [[[rng.randint(0, 10**4) for _ in range(100000)]]]
```
