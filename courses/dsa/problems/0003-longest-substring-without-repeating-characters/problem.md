---
lc: 3
title: "Longest Substring Without Repeating Characters"
difficulty: "Medium"
patterns: ["sliding-window", "hash-map"]
lcTags: ["hash-table", "string", "sliding-window"]
entry: {"method": "lengthOfLongestSubstring", "params": [{"name": "s", "type": "string"}], "returns": "integer"}
examples: ["\"abcabcbb\"", "\"bbbbb\"", "\"pwwkew\""]
lcHints: ["There are less than 100 unique characters. We can check all substrings with length at most 100 for example. This is a good enough approximation."]
---

Given a string `s`, find the length of the **longest** **substring** without duplicate characters.

**Example 1:**

```
Input: s = "abcabcbb"
Output: 3
Explanation: The answer is "abc", with the length of 3. Note that "bca" and "cab" are also correct answers.
```

**Example 2:**

```
Input: s = "bbbbb"
Output: 1
Explanation: The answer is "b", with the length of 1.
```

**Example 3:**

```
Input: s = "pwwkew"
Output: 3
Explanation: The answer is "wke", with the length of 3.
Notice that the answer must be a substring, "pwke" is a subsequence and not a substring.
```

**Constraints:**

- `0 <= s.length <= 10⁵`
- `s` consists of English letters, digits, symbols and spaces.

# Starter

```python
class Solution:
    def lengthOfLongestSubstring(self, s: str) -> int:
        
```

# Hints

1. Grow a window to the right. When the new character is already in the window, the window must shrink from the left until it isn't.
2. Store each character's last index. On a repeat, jump the left edge to just after its previous position (never move it backwards).

# Key points

- window = substring with no repeats; expand right, shrink left on a repeat
- last-seen index lets the left edge jump in one step: left = max(left, last[c] + 1)
- max(...) because the old index may be left of the window already
- O(n) time, O(k) space for k distinct characters

# Solution: set-window · Window with a set · O(n) · O(k)

## Idea
The set holds the window's characters. When `c` is already there, remove characters from the left until it's gone, then add `c`.

## Complexity
- **Time: O(n)**: each character enters and leaves the set once.
- **Space: O(k)**, k = distinct characters.

```python
class Solution:
    def lengthOfLongestSubstring(self, s: str) -> int:
        window, l, best = set(), 0, 0
        for r, c in enumerate(s):
            while c in window:
                window.remove(s[l])
                l += 1
            window.add(c)
            best = max(best, r - l + 1)
        return best
```

# Solution: last-index · Jump with last-seen index · O(n) · O(k) · reference

## Idea
Remember where each character was last seen. If `c` was last seen inside the window, the window must start right after it. `max` keeps `l` from moving backwards when the old occurrence is already outside the window (e.g. `"abba"`).

## Complexity
- **Time: O(n)**, one pass.
- **Space: O(k)**.

```python
class Solution:
    def lengthOfLongestSubstring(self, s: str) -> int:
        last, l, best = {}, 0, 0
        for r, c in enumerate(s):
            if c in last:
                l = max(l, last[c] + 1)
            last[c] = r
            best = max(best, r - l + 1)
        return best
```

# Tests

```python
def edge():
    return [[""], [" "], ["a"], ["bbbbb"], ["abcabcbb"], ["pwwkew"], ["abba"], ["dvdf"]]

def random_case(rng):
    return ["".join(rng.choice("abc d") for _ in range(rng.randint(0, 12)))]

def perf(rng):
    return [["".join(chr(rng.randint(32, 126)) for _ in range(100000))]]
```
