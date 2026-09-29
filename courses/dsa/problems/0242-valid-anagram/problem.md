---
lc: 242
title: "Valid Anagram"
difficulty: "Easy"
patterns: ["hash-map"]
lcTags: ["hash-table", "string", "sorting"]
entry: {"method": "isAnagram", "params": [{"name": "s", "type": "string"}, {"name": "t", "type": "string"}], "returns": "boolean"}
examples: ["\"anagram\"\n\"nagaram\"", "\"rat\"\n\"car\""]
---

Given two strings `s` and `t`, return `true` if `t` is an anagram of `s`, and `false` otherwise.

**Example 1:**

**Input:** s = "anagram", t = "nagaram"

**Output:** true

**Example 2:**

**Input:** s = "rat", t = "car"

**Output:** false

**Constraints:**

- `1 <= s.length, t.length <= 5 * 10⁴`
- `s` and `t` consist of lowercase English letters.

**Follow up:** What if the inputs contain Unicode characters? How would you adapt your solution to such a case?

# Starter

```python
class Solution:
    def isAnagram(self, s: str, t: str) -> bool:
        
```

# Hints

1. Two strings are anagrams when every letter appears the same number of times in both.
2. Count letters of s (Counter or a 26-slot array), subtract the counts for t, and check everything is back to zero. Different lengths → False right away.

# Key points

- anagram = same letter counts
- compare Counter(s) == Counter(t), or a 26-slot count array for lowercase letters
- O(n) time; O(1) space with the 26-slot array (O(k) for k distinct chars with Unicode)
- sorting both strings also works in O(n log n)

# Solution: sort · Sort both strings · O(n log n) · O(n)

## Idea
Anagrams become the same string once their letters are sorted.

## Complexity
- **Time: O(n log n)**.
- **Space: O(n)** for the sorted lists.

```python
class Solution:
    def isAnagram(self, s: str, t: str) -> bool:
        return sorted(s) == sorted(t)
```

# Solution: count · Count letters · O(n) · O(1) · reference

## Idea
Add 1 for every letter of `s`, subtract 1 for every letter of `t`. They're anagrams exactly when every count ends at 0.

`Counter(s) == Counter(t)` is the same idea in one line, and it also handles the Unicode follow-up.

## Complexity
- **Time: O(n)**.
- **Space: O(1)**, 26 slots whatever the length.

```python
class Solution:
    def isAnagram(self, s: str, t: str) -> bool:
        if len(s) != len(t):
            return False
        counts = [0] * 26
        for a, b in zip(s, t):
            counts[ord(a) - ord("a")] += 1
            counts[ord(b) - ord("a")] -= 1
        return all(c == 0 for c in counts)
```

# Tests

```python
def edge():
    return [["a", "a"], ["a", "b"], ["ab", "a"], ["aa", "a"], ["abc", "cba"], ["aab", "abb"]]

def random_case(rng):
    n = rng.randint(1, 8)
    s = "".join(rng.choice("abc") for _ in range(n))
    if rng.random() < 0.5:
        t = list(s); rng.shuffle(t); t = "".join(t)
    else:
        t = "".join(rng.choice("abc") for _ in range(rng.randint(n - 1, n + 1) or 1))
    return [s, t]

def perf(rng):
    s = "".join(rng.choice("abcdefghijklmnopqrstuvwxyz") for _ in range(50000))
    return [[s, s[::-1]]]
```
