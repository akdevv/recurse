---
lc: 84
title: "Largest Rectangle in Histogram"
difficulty: "Hard"
patterns: ["monotonic-stack"]
lcTags: ["array", "stack", "monotonic-stack", "range-minimum-maximum-query"]
entry: {"method": "largestRectangleArea", "params": [{"name": "heights", "type": "integer[]"}], "returns": "integer"}
examples: ["[2,1,5,6,2,3]", "[2,4]"]
---

Given an array of integers `heights` representing the histogram's bar height where the width of each bar is `1`, return *the area of the largest rectangle in the histogram*.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/01/04/histogram.jpg)

```
Input: heights = [2,1,5,6,2,3]
Output: 10
Explanation: The above is a histogram where width of each bar is 1.
The largest rectangle is shown in the red area, which has an area = 10 units.
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2021/01/04/histogram-1.jpg)

```
Input: heights = [2,4]
Output: 4
```

**Constraints:**

- `1 <= heights.length <= 10⁵`
- `0 <= heights[i] <= 10⁴`

# Starter

```python
class Solution:
    def largestRectangleArea(self, heights: list[int]) -> int:
        
```

# Hints

1. For each bar, the widest rectangle using its full height stretches until a shorter bar on each side.
2. Keep a stack of indices with increasing heights. When a shorter bar comes, pop: the popped bar's rectangle ends here, and starts right after the new stack top. Area = height × (i − top − 1).

# Key points

- each bar's rectangle is bounded by the nearest shorter bar on the left and right
- increasing stack: popping a bar means its right boundary was just found
- add a 0-height sentinel at the end to flush the stack
- O(n) time and space

# Solution: monotonic-stack · Monotonic Stack · O(n) · O(n) · reference

We can enumerate the height h of each bar as the height of the rectangle. Using a monotonic stack, we find the index left_i, right_i of the first bar with a height less than h to the left and right. The area of the rectangle at this time is `h × (right_i-left_i-1)`. We can find the maximum value.

The time complexity is O(n), and the space complexity is O(n). Here, n represents the length of heights.

Common model of monotonic stack: Find the **nearest** number to the left/right of each number that is **larger/smaller** than it. Template:

```python
stk = []
for i in range(n):
    while stk and check(stk[-1], i):
        stk.pop()
    stk.append(i)
```

```python
class Solution:
    def largestRectangleArea(self, heights: List[int]) -> int:
        n = len(heights)
        stk = []
        left = [-1] * n
        right = [n] * n
        for i, h in enumerate(heights):
            while stk and heights[stk[-1]] >= h:
                right[stk[-1]] = i
                stk.pop()
            if stk:
                left[i] = stk[-1]
            stk.append(i)
        return max(h * (right[i] - left[i] - 1) for i, h in enumerate(heights))
```

# Tests

```python

```
