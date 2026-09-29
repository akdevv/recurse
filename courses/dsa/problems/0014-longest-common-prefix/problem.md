---
lc: 14
title: "Longest Common Prefix"
difficulty: "Easy"
patterns: ["simulation"]
lcTags: ["array", "string", "trie"]
entry: {"method": "longestCommonPrefix", "params": [{"name": "strs", "type": "string[]"}], "returns": "string"}
examples: ["[\"flower\",\"flow\",\"flight\"]", "[\"dog\",\"racecar\",\"car\"]"]
---

Write a function to find the longest common prefix string amongst an array of strings.

If there is no common prefix, return an empty string `""`.

**Example 1:**

```
Input: strs = ["flower","flow","flight"]
Output: "fl"
```

**Example 2:**

```
Input: strs = ["dog","racecar","car"]
Output: ""
Explanation: There is no common prefix among the input strings.
```

**Constraints:**

- `1 <= strs.length <= 200`
- `0 <= strs[i].length <= 200`
- `strs[i]` consists of only lowercase English letters if it is non-empty.

# Starter

```python
class Solution:
    def longestCommonPrefix(self, strs: list[str]) -> str:
        
```

# Hints

1. Compare column by column: is character i the same in every string?
2. Stop at the first column where a string is too short or has a different character. The prefix is everything before it.

# Key points

- vertical scan: check character i across all strings, stop at the first mismatch
- the prefix can't be longer than the shortest string
- O(S) time where S is the total number of characters, O(1) extra space

# Solution: vertical-scan · Vertical scan · O(S) · O(1) extra · reference

## Idea
Line the strings up and read down each column. Column `i` is part of the prefix only if every string has the same character there. The first column that fails ends the prefix.

```
f l o w e r
f l o w
f l i g h t
    ^ mismatch at i = 2 → "fl"
```

## Complexity
- **Time: O(S)**, S = total characters; we stop at the first mismatch, so often much less.
- **Space: O(1) extra** (the returned slice is the output).

```python
class Solution:
    def longestCommonPrefix(self, strs: list[str]) -> str:
        first = strs[0]
        for i, ch in enumerate(first):
            for s in strs[1:]:
                if i == len(s) or s[i] != ch:
                    return first[:i]
        return first
```

# Solution: sort-ends · Sort, compare first and last · O(m·n log n) · O(n)

## Idea
After sorting, the first and last strings are the two that differ the most. Any prefix they share, every string in between shares too.

## Complexity
- **Time: O(n log n · m)**: sorting compares strings of length up to m.
- **Space: O(n)** for the sorted copy.

A neat trick, but the vertical scan is simpler and faster.

```python
class Solution:
    def longestCommonPrefix(self, strs: list[str]) -> str:
        s = sorted(strs)
        a, b = s[0], s[-1]
        i = 0
        while i < min(len(a), len(b)) and a[i] == b[i]:
            i += 1
        return a[:i]
```

# Tests

```python
import string

def edge():
    return [
        [["flower", "flow", "flight"]],
        [["dog", "racecar", "car"]],
        [["a"]],
        [[""]],
        [["", "b"]],
        [["ab", "a"]],
        [["abc", "abc", "abc"]],
    ]

def random_case(rng):
    pre = "".join(rng.choice("ab") for _ in range(rng.randint(0, 4)))
    return [[pre + "".join(rng.choice("abc") for _ in range(rng.randint(0, 3))) for _ in range(rng.randint(1, 5))]]

def perf(rng):
    return []
```
