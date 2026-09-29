---
lc: 567
title: "Permutation in String"
difficulty: "Medium"
patterns: ["sliding-window", "hash-map"]
lcTags: ["hash-table", "two-pointers", "string", "sliding-window"]
entry: {"method": "checkInclusion", "params": [{"name": "s1", "type": "string"}, {"name": "s2", "type": "string"}], "returns": "boolean"}
examples: ["\"ab\"\n\"eidbaooo\"", "\"ab\"\n\"eidboaoo\""]
lcHints: ["Obviously, brute force will result in TLE. Think of something else.", "How will you check whether one string is a permutation of another string?", "One way is to sort the string and then compare. But, Is there a better way?", "If one string is a permutation of another string then they must have one common metric. What is that?", "Both strings must have same character frequencies, if  one is permutation of another. Which data structure should be used to store frequencies?", "What about hash table?  An array of size 26?"]
---

Given two strings `s1` and `s2`, return `true` if `s2` contains a permutation of `s1`, or `false` otherwise.

In other words, return `true` if one of `s1`'s permutations is the substring of `s2`.

**Example 1:**

```
Input: s1 = "ab", s2 = "eidbaooo"
Output: true
Explanation: s2 contains one permutation of s1 ("ba").
```

**Example 2:**

```
Input: s1 = "ab", s2 = "eidboaoo"
Output: false
```

**Constraints:**

- `1 <= s1.length, s2.length <= 10⁴`
- `s1` and `s2` consist of lowercase English letters.

# Starter

```python
class Solution:
    def checkInclusion(self, s1: str, s2: str) -> bool:
        
```

# Hints

1. A permutation of s1 is any string with the same letter counts. Which substrings of s2 could be one?
2. Slide a window of length len(s1) over s2, keeping 26 letter counts. If the counts ever equal s1's counts, return True.

# Key points

- permutation = same letter counts
- fixed window of size len(s1) over s2, update counts on enter/leave
- comparing two 26-slot arrays is O(26) → O(26·n) overall, effectively O(n)
- if s1 is longer than s2, it's False

# Solution: sort-windows · Sort every window · O(n·m log m) · O(m)

## Idea
Compare the sorted letters of each window against sorted `s1`. Passes at these limits because sorting runs in C, but it redoes the work for every window.

## Complexity
- **Time: O(n·m log m)**, m = len(s1).
- **Space: O(m)**.

```python
class Solution:
    def checkInclusion(self, s1: str, s2: str) -> bool:
        target, m = sorted(s1), len(s1)
        return any(sorted(s2[i:i + m]) == target for i in range(len(s2) - m + 1))
```

# Solution: counts · Sliding letter counts · O(n) · O(1) · reference

## Idea
Keep counts for the current window of length `m`. When the window slides, add the entering letter and remove the leaving one. Each check compares two 26-slot lists.

## Complexity
- **Time: O(26·n)** = O(n).
- **Space: O(1)**.

```python
class Solution:
    def checkInclusion(self, s1: str, s2: str) -> bool:
        m = len(s1)
        if m > len(s2):
            return False
        need, have = [0] * 26, [0] * 26
        for c in s1:
            need[ord(c) - 97] += 1
        for i, c in enumerate(s2):
            have[ord(c) - 97] += 1
            if i >= m:
                have[ord(s2[i - m]) - 97] -= 1
            if have == need:
                return True
        return False
```

# Tests

```python
def edge():
    return [["a", "a"], ["a", "b"], ["ab", "a"], ["ab", "eidbaooo"], ["ab", "eidboaoo"], ["adc", "dcda"], ["hello", "ooolleoooleh"]]

def random_case(rng):
    return ["".join(rng.choice("abc") for _ in range(rng.randint(1, 3))),
            "".join(rng.choice("abc") for _ in range(rng.randint(1, 10)))]

def perf(rng):
    abc = "abcdefghijklmnopqrstuvwxyz"
    return [["".join(rng.choice(abc) for _ in range(5000)), "".join(rng.choice(abc) for _ in range(10000))]]
```
