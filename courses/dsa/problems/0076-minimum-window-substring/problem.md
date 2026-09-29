---
lc: 76
title: "Minimum Window Substring"
difficulty: "Hard"
patterns: ["sliding-window", "hash-map"]
lcTags: ["hash-table", "string", "sliding-window"]
entry: {"method": "minWindow", "params": [{"name": "s", "type": "string"}, {"name": "t", "type": "string"}], "returns": "string"}
examples: ["\"ADOBECODEBANC\"\n\"ABC\"", "\"a\"\n\"a\"", "\"a\"\n\"aa\""]
lcHints: ["Use two pointers to create a window of letters in s, which would have all the characters from t.", "Expand the right pointer until all the characters of t are covered.", "Once all the characters are covered, move the left pointer and ensure that all the characters are still covered to minimize the subarray size.", "Continue expanding the right and left pointers until you reach the end of s."]
---

Given two strings `s` and `t` of lengths `m` and `n` respectively, return *the **minimum window*** ***substring*** *of* `s` *such that every character in* `t` *(**including duplicates**) is included in the window*. If there is no such substring, return *the empty string* `""`.

The testcases will be generated such that the answer is **unique**.

**Example 1:**

```
Input: s = "ADOBECODEBANC", t = "ABC"
Output: "BANC"
Explanation: The minimum window substring "BANC" includes 'A', 'B', and 'C' from string t.
```

**Example 2:**

```
Input: s = "a", t = "a"
Output: "a"
Explanation: The entire string s is the minimum window.
```

**Example 3:**

```
Input: s = "a", t = "aa"
Output: ""
Explanation: Both 'a's from t must be included in the window.
Since the largest window of s only has one 'a', return empty string.
```

**Constraints:**

- `m == s.length`
- `n == t.length`
- `1 <= m, n <= 10⁵`
- `s` and `t` consist of uppercase and lowercase English letters.

**Follow up:** Could you find an algorithm that runs in `O(m + n)` time?

# Starter

```python
class Solution:
    def minWindow(self, s: str, t: str) -> str:
        
```

# Hints

1. Expand the window until it contains all of t's characters (with counts), then shrink from the left as long as it still does.
2. Keep need = Counter(t) and a counter `missing` of how many characters are still needed. A window is valid when missing == 0.

# Key points

- expand right until the window covers t, then shrink left while it still covers t
- track `missing` (total chars still needed) so validity is O(1) to check
- a char only reduces `missing` if its count in the window hasn't already met the need
- O(m + n) time, O(k) space

# Solution: sliding · Expand, then shrink · O(m + n) · O(k) · reference

## Idea
`need[c]` is how many more `c` the window needs (it can go negative for extras). `missing` is the total still needed.

- Move `r` right. If `need[c] > 0` the char was useful: `missing -= 1`. Always `need[c] -= 1`.
- While `missing == 0` the window is valid: record it, then drop `s[l]`. If that made `need[s[l]] > 0`, a required char left, so `missing += 1`.

## Complexity
- **Time: O(m + n)**: each pointer crosses `s` once.
- **Space: O(k)** for the counts.

```python
from collections import Counter

class Solution:
    def minWindow(self, s: str, t: str) -> str:
        need = Counter(t)
        missing = len(t)
        l, best = 0, (0, float("inf"))
        for r, c in enumerate(s):
            if need[c] > 0:
                missing -= 1
            need[c] -= 1
            while missing == 0:
                if r - l < best[1] - best[0]:
                    best = (l, r)
                need[s[l]] += 1
                if need[s[l]] > 0:
                    missing += 1
                l += 1
        return "" if best[1] == float("inf") else s[best[0]:best[1] + 1]
```

# Tests

```python
def edge():
    return [["a", "a"], ["a", "aa"], ["a", "b"], ["ab", "b"], ["ADOBECODEBANC", "ABC"], ["aa", "aa"], ["bba", "ab"], ["cabwefgewcwaefgcf", "cae"]]

from collections import Counter

def min_windows(s, t):
    need, found = Counter(t), []
    for i in range(len(s)):
        for j in range(i, len(s)):
            if not need - Counter(s[i:j + 1]):
                found.append(j - i + 1)
                break
    return found

def random_case(rng):
    while True:  # the answer must be unique (LeetCode guarantees it)
        s = "".join(rng.choice("abcA") for _ in range(rng.randint(1, 12)))
        t = "".join(rng.choice("abcA") for _ in range(rng.randint(1, 3)))
        w = min_windows(s, t)
        if not w or w.count(min(w)) == 1:
            return [s, t]

def perf(rng):
    s = "".join(rng.choice("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ") for _ in range(100000))
    return [[s, "abcXYZ"]]
```
