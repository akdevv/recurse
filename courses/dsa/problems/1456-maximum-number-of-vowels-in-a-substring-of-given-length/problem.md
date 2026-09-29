---
lc: 1456
title: "Maximum Number of Vowels in a Substring of Given Length"
difficulty: "Medium"
patterns: ["sliding-window"]
lcTags: ["string", "sliding-window"]
entry: {"method": "maxVowels", "params": [{"name": "s", "type": "string"}, {"name": "k", "type": "integer"}], "returns": "integer"}
examples: ["\"abciiidef\"\n3", "\"aeiou\"\n2", "\"leetcode\"\n3"]
lcHints: ["Keep a window of size k and maintain the number of vowels in it.", "Keep moving the window and update the number of vowels while moving. Answer is max number of vowels of any window."]
---

Given a string `s` and an integer `k`, return *the maximum number of vowel letters in any substring of* `s` *with length* `k`.

**Vowel letters** in English are `'a'`, `'e'`, `'i'`, `'o'`, and `'u'`.

**Example 1:**

```
Input: s = "abciiidef", k = 3
Output: 3
Explanation: The substring "iii" contains 3 vowel letters.
```

**Example 2:**

```
Input: s = "aeiou", k = 2
Output: 2
Explanation: Any substring of length 2 contains 2 vowels.
```

**Example 3:**

```
Input: s = "leetcode", k = 3
Output: 2
Explanation: "lee", "eet" and "ode" contain 2 vowels.
```

**Constraints:**

- `1 <= s.length <= 10⁵`
- `s` consists of lowercase English letters.
- `1 <= k <= s.length`

# Starter

```python
class Solution:
    def maxVowels(self, s: str, k: int) -> int:
        
```

# Hints

1. Every window has length k. When it slides right by one, only two characters change.
2. Count vowels in the first window, then add 1 if the entering char is a vowel and subtract 1 if the leaving one was.

# Key points

- fixed window of size k, update the count with the entering and leaving character
- O(n) time, O(1) space
- can stop early when the count reaches k

# Solution: recount · Count every window · O(n·k) · O(1) · slow

## Idea
Count vowels in each window from scratch.

## Complexity
- **Time: O(n·k)**.
- **Space: O(1)**.

```python
class Solution:
    def maxVowels(self, s: str, k: int) -> int:
        best = 0
        for i in range(len(s) - k + 1):
            cnt = 0
            for c in s[i:i + k]:
                if c in "aeiou":
                    cnt += 1
            best = max(best, cnt)
        return best
```

# Solution: sliding · Sliding count · O(n) · O(1) · reference

## Idea
Keep the vowel count of the current window. Slide by adding the new right character and removing `s[i - k]`.

## Complexity
- **Time: O(n)**.
- **Space: O(1)**.

```python
class Solution:
    def maxVowels(self, s: str, k: int) -> int:
        vowels = set("aeiou")
        cnt = sum(c in vowels for c in s[:k])
        best = cnt
        for i in range(k, len(s)):
            cnt += (s[i] in vowels) - (s[i - k] in vowels)
            best = max(best, cnt)
        return best
```

# Tests

```python
def edge():
    return [["a", 1], ["b", 1], ["aeiou", 2], ["leetcode", 3], ["tryhard", 4], ["abciiidef", 3]]

def random_case(rng):
    s = "".join(rng.choice("abeo") for _ in range(rng.randint(1, 12)))
    return [s, rng.randint(1, len(s))]

def perf(rng):
    s = "".join(rng.choice("abcdefghijklmnopqrstuvwxyz") for _ in range(100000))
    return [[s, 50000]]
```
