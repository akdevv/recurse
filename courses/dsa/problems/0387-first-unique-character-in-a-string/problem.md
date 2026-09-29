---
lc: 387
title: "First Unique Character in a String"
difficulty: "Easy"
patterns: ["hash-map"]
lcTags: ["hash-table", "string", "queue", "counting"]
entry: {"method": "firstUniqChar", "params": [{"name": "s", "type": "string"}], "returns": "integer"}
examples: ["\"leetcode\"", "\"loveleetcode\"", "\"aabb\""]
---

Given a string `s`, find the **first** non-repeating character in it and return its index. If it **does not** exist, return `-1`.

**Example 1:**

**Input:** s = "leetcode"

**Output:** 0

**Explanation:**

The character `'l'` at index 0 is the first character that does not occur at any other index.

**Example 2:**

**Input:** s = "loveleetcode"

**Output:** 2

**Example 3:**

**Input:** s = "aabb"

**Output:** -1

**Constraints:**

- `1 <= s.length <= 10⁵`
- `s` consists of only lowercase English letters.

# Starter

```python
class Solution:
    def firstUniqChar(self, s: str) -> int:
        
```

# Hints

1. You need to know each character's total count before you can say it's unique. That suggests two passes.
2. First pass: count every character. Second pass: return the first index whose character has count 1.

# Key points

- two passes: count everything, then scan for the first count of 1
- the scan must go over the string (not the dict) to keep the original order
- O(n) time, O(1) space for 26 lowercase letters

# Solution: count-each · Count each character separately · O(n²) · O(1) · slow

## Idea
For each position, count how often its character appears. `s.count` is O(n), so this is quadratic.

## Complexity
- **Time: O(n²)** in the worst case.
- **Space: O(1)**.

```python
class Solution:
    def firstUniqChar(self, s: str) -> int:
        for i, c in enumerate(s):
            if s.count(c) == 1:
                return i
        return -1
```

# Solution: two-pass · Count, then scan · O(n) · O(1) · reference

## Idea
Pass 1 counts every character. Pass 2 walks the string in order and returns the first index whose character appeared once.

## Complexity
- **Time: O(n)**, two passes.
- **Space: O(1)**: at most 26 keys.

```python
from collections import Counter

class Solution:
    def firstUniqChar(self, s: str) -> int:
        counts = Counter(s)
        for i, c in enumerate(s):
            if counts[c] == 1:
                return i
        return -1
```

# Tests

```python
def edge():
    return [["a"], ["aa"], ["aabb"], ["leetcode"], ["loveleetcode"], ["abcabcd"]]

def random_case(rng):
    return ["".join(rng.choice("abcd") for _ in range(rng.randint(1, 10)))]

def perf(rng):
    n = 100000
    s = "".join(rng.choice("abcdefghijklmnopqrstuvwxy") for _ in range(n)) * 1
    return [[("ab" * (n // 2)) + "z"], [s + "z"]]
```
