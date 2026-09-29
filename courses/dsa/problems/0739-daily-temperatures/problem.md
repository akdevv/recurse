---
lc: 739
title: "Daily Temperatures"
difficulty: "Medium"
patterns: ["monotonic-stack"]
lcTags: ["array", "stack", "monotonic-stack"]
entry: {"method": "dailyTemperatures", "params": [{"name": "temperatures", "type": "integer[]"}], "returns": "integer[]"}
examples: ["[73,74,75,71,69,72,76,73]", "[30,40,50,60]", "[30,60,90]"]
lcHints: ["If the temperature is say, 70 today, then in the future a warmer temperature must be either 71, 72, 73, ..., 99, or 100.  We could remember when all of them occur next."]
---

Given an array of integers `temperatures` represents the daily temperatures, return *an array* `answer` *such that* `answer[i]` *is the number of days you have to wait after the* `iᵗʰ` *day to get a warmer temperature*. If there is no future day for which this is possible, keep `answer[i] == 0` instead.

**Example 1:**

```
Input: temperatures = [73,74,75,71,69,72,76,73]
Output: [1,1,4,2,1,1,0,0]
```

**Example 2:**

```
Input: temperatures = [30,40,50,60]
Output: [1,1,1,0]
```

**Example 3:**

```
Input: temperatures = [30,60,90]
Output: [1,1,0]
```

**Constraints:**

- `1 <= temperatures.length <= 10⁵`
- `30 <= temperatures[i] <= 100`

# Starter

```python
class Solution:
    def dailyTemperatures(self, temperatures: list[int]) -> list[int]:
        
```

# Hints

1. For each day you want the next warmer day. Days still waiting for a warmer day form a stack with decreasing temperatures.
2. Stack of indices. For each i, while temps[i] > temps[stack top]: pop j and set answer[j] = i − j. Push i.

# Key points

- monotonic decreasing stack of indices still waiting for an answer
- a warmer day resolves every colder day on top of the stack
- each index pushed and popped once → O(n)
- days never resolved stay 0

# Solution: monotonic-stack · Monotonic Stack · O(n) · O(n) · reference

This problem requires us to find the position of the first element greater than each element to its right, which is a typical application scenario for a monotonic stack.

We traverse the array temperatures from right to left, maintaining a stack stk that is monotonically increasing from top to bottom in terms of temperature. The stack stores the indices of the array elements. For each element `temperatures[i]`, we continuously compare it with the top element of the stack. If the temperature corresponding to the top element of the stack is less than or equal to `temperatures[i]`, we pop the top element of the stack in a loop until the stack is empty or the temperature corresponding to the top element of the stack is greater than `temperatures[i]`. At this point, the top element of the stack is the first element greater than `temperatures[i]` to its right, and the distance is `stk.top() - i`. We update the answer array accordingly. Then we push `temperatures[i]` onto the stack and continue traversing.

After the traversal, we return the answer array.

The time complexity is O(n), and the space complexity is O(n). Here, n is the length of the array temperatures.

```python
class Solution:
    def dailyTemperatures(self, temperatures: List[int]) -> List[int]:
        stk = []
        n = len(temperatures)
        ans = [0] * n
        for i in range(n - 1, -1, -1):
            while stk and temperatures[stk[-1]] <= temperatures[i]:
                stk.pop()
            if stk:
                ans[i] = stk[-1] - i
            stk.append(i)
        return ans
```

# Tests

```python

```
