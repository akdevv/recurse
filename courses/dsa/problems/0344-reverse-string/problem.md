---
lc: 344
title: "Reverse String"
difficulty: "Easy"
patterns: ["recursion", "two-pointers"]
lcTags: ["two-pointers", "string"]
entry: {"method": "reverseString", "params": [{"name": "s", "type": "character[]"}], "returns": "void", "outputParam": 0}
examples: ["[\"h\",\"e\",\"l\",\"l\",\"o\"]", "[\"H\",\"a\",\"n\",\"n\",\"a\",\"h\"]"]
lcHints: ["The entire logic for reversing a string is based on using the opposite directional two-pointer approach!"]
---

Write a function that reverses a string. The input string is given as an array of characters `s`.

You must do this by modifying the input array [in-place](https://en.wikipedia.org/wiki/In-place_algorithm) with `O(1)` extra memory.

**Example 1:**

```
Input: s = ["h","e","l","l","o"]
Output: ["o","l","l","e","h"]
```

**Example 2:**

```
Input: s = ["H","a","n","n","a","h"]
Output: ["h","a","n","n","a","H"]
```

**Constraints:**

- `1 <= s.length <= 10⁵`
- `s[i]` is a [printable ascii character](https://en.wikipedia.org/wiki/ASCII#Printable_characters).

# Starter

```python
class Solution:
    def reverseString(self, s: list[str]) -> None:
        """
        Do not return anything, modify s in-place instead.
        """
        
```

# Hints

1. Swap the first and last characters. What's left is a smaller version of the same problem.
2. Two indices l=0, r=len-1: swap, move both inward until they meet. Recursive version: helper(l, r) swaps then calls helper(l+1, r-1).

# Key points

- in-place: modify the list, return nothing
- swap the ends, shrink the problem: that's the recursive step
- recursion uses O(n) stack; deep inputs (10⁵) can hit Python's recursion limit
- iterative two-pointer: O(n) time, O(1) space

# Solution: recursive · Recursive swap · O(n) · O(n) stack · slow

## Idea
Reverse = swap the two ends, then reverse the middle. The middle is the **same problem, smaller**. Base case: `l >= r` (0 or 1 characters left).

## Complexity
- **Time: O(n)**
- **Space: O(n)**: n/2 stack frames.

## The catch
With n = 10⁵ this needs 50,000 nested calls. Python's recursion limit (1,000 by default, 10,000 in this judge) is exceeded → **RecursionError**. Recursion isn't free: every call costs stack memory. That's why the iterative version is preferred here.

```python
class Solution:
    def reverseString(self, s: List[str]) -> None:
        def helper(l, r):
            if l >= r:
                return
            s[l], s[r] = s[r], s[l]
            helper(l + 1, r - 1)

        helper(0, len(s) - 1)
```

# Solution: two-pointers · Two pointers, in place · O(n) · O(1) · reference

## Idea
The same swaps as the recursive version, as a loop: `l` from the left, `r` from the right, swap, move inward, stop when they meet.

Preview of the **two pointers** pattern (Module 3).

## Complexity
- **Time: O(n)**, **Space: O(1)**

```python
class Solution:
    def reverseString(self, s: List[str]) -> None:
        l, r = 0, len(s) - 1
        while l < r:
            s[l], s[r] = s[r], s[l]
            l += 1
            r -= 1
```

# Tests

```python
import string

def edge():
    return [[["a"]], [["a", "b"]], [list("racecar")], [list("A man")]]

def random_case(rng):
    return [[rng.choice(string.ascii_letters + string.digits) for _ in range(rng.randint(1, 15))]]

def perf(rng):
    return [[[rng.choice(string.ascii_letters) for _ in range(10**5)]]]
```
