---
lc: 392
title: "Is Subsequence"
difficulty: "Easy"
patterns: ["two-pointers"]
lcTags: ["two-pointers", "string", "dynamic-programming"]
entry: {"method": "isSubsequence", "params": [{"name": "s", "type": "string"}, {"name": "t", "type": "string"}], "returns": "boolean"}
examples: ["\"abc\"\n\"ahbgdc\"", "\"axc\"\n\"ahbgdc\""]
---

Given two strings `s` and `t`, return `true` *if* `s` *is a **subsequence** of* `t`*, or* `false` *otherwise*.

A **subsequence** of a string is a new string that is formed from the original string by deleting some (can be none) of the characters without disturbing the relative positions of the remaining characters. (i.e., `"ace"` is a subsequence of `"<u>a</u>b<u>c</u>d<u>e</u>"` while `"aec"` is not).

**Example 1:**

```
Input: s = "abc", t = "ahbgdc"
Output: true
```

**Example 2:**

```
Input: s = "axc", t = "ahbgdc"
Output: false
```

**Constraints:**

- `0 <= s.length <= 100`
- `0 <= t.length <= 10⁴`
- `s` and `t` consist only of lowercase English letters.

**Follow up:** Suppose there are lots of incoming `s`, say `s₁, s₂, ..., sₖ` where `k >= 10⁹`, and you want to check one by one to see if `t` has its subsequence. In this scenario, how would you change your code?

# Starter

```python
class Solution:
    def isSubsequence(self, s: str, t: str) -> bool:
        
```

# Hints

1. Walk through t once. Whenever the current character matches the next needed character of s, move on in s.
2. Pointer i in s; for each character of t, if it equals s[i], do i += 1. Answer: i == len(s).

# Key points

- greedy: match each character of s at its earliest possible spot in t
- one pointer per string, O(n) time, O(1) space
- empty s is always a subsequence
- follow-up (many s): precompute, for each char, the sorted positions in t and binary search

# Solution: two-pointers · Greedy matching · O(n) · O(1) · reference

## Idea
Take characters of `s` in order and match each at the earliest place in `t`. Matching early never hurts: it leaves the most of `t` for the rest.

## Complexity
- **Time: O(len(t))**.
- **Space: O(1)**.

```python
class Solution:
    def isSubsequence(self, s: str, t: str) -> bool:
        i = 0
        for c in t:
            if i < len(s) and c == s[i]:
                i += 1
        return i == len(s)
```

# Tests

```python
def edge():
    return [["", ""], ["", "abc"], ["a", ""], ["abc", "abc"], ["axc", "ahbgdc"], ["aaa", "aa"], ["ace", "abcde"]]

def random_case(rng):
    return ["".join(rng.choice("ab") for _ in range(rng.randint(0, 4))),
            "".join(rng.choice("abc") for _ in range(rng.randint(0, 10)))]
```
