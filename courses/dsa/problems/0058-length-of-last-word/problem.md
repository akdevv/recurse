---
lc: 58
title: "Length of Last Word"
difficulty: "Easy"
patterns: ["simulation"]
lcTags: ["string"]
entry: {"method": "lengthOfLastWord", "params": [{"name": "s", "type": "string"}], "returns": "integer"}
examples: ["\"Hello World\"", "\"   fly me   to   the moon  \"", "\"luffy is still joyboy\""]
---

Given a string `s` consisting of words and spaces, return *the length of the **last** word in the string.*

A **word** is a maximal substring consisting of non-space characters only.

**Example 1:**

```
Input: s = "Hello World"
Output: 5
Explanation: The last word is "World" with length 5.
```

**Example 2:**

```
Input: s = "   fly me   to   the moon  "
Output: 4
Explanation: The last word is "moon" with length 4.
```

**Example 3:**

```
Input: s = "luffy is still joyboy"
Output: 6
Explanation: The last word is "joyboy" with length 6.
```

**Constraints:**

- `1 <= s.length <= 10⁴`
- `s` consists of only English letters and spaces `' '`.
- There will be at least one word in `s`.

# Starter

```python
class Solution:
    def lengthOfLastWord(self, s: str) -> int:
        
```

# Hints

1. Trailing spaces are the trap. Where does the last word actually end?
2. Walk from the end: skip spaces, then count letters until the next space or the start.

# Key points

- skip trailing spaces first, then count until the next space
- scanning from the back touches only the last word, O(1) extra space
- `s.split()` also works and handles repeated spaces, but builds every word: O(n) space

# Solution: split · Split into words · O(n) · O(n)

## Idea
`s.split()` with no argument splits on any run of whitespace and drops empty pieces, so leading, trailing and repeated spaces all vanish.

## Complexity
- **Time: O(n)**.
- **Space: O(n)**, it builds a list of every word.

Note `s.split(" ")` would behave differently: it keeps empty strings between repeated spaces.

```python
class Solution:
    def lengthOfLastWord(self, s: str) -> int:
        return len(s.split()[-1])
```

# Solution: scan-back · Scan from the end · O(n) · O(1) · reference

## Idea
1. Skip the trailing spaces.
2. Count characters until the next space or the start of the string.

The first loop can't run off the start because the string is guaranteed to contain a word.

## Complexity
- **Time: O(n)** worst case, but it only reads the tail of the string.
- **Space: O(1)**.

```python
class Solution:
    def lengthOfLastWord(self, s: str) -> int:
        i = len(s) - 1
        while s[i] == " ":
            i -= 1
        n = 0
        while i >= 0 and s[i] != " ":
            n += 1
            i -= 1
        return n
```

# Tests

```python
LETTERS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

def sentence(rng, alnum=False):
    chars = LETTERS + ("0123456789" if alnum else "")
    words = ["".join(rng.choice(chars) for _ in range(rng.randint(1, 6))) for _ in range(rng.randint(1, 5))]
    gap = lambda lo: " " * rng.randint(lo, 3)
    return gap(0) + "".join(w + gap(1) for w in words[:-1]) + words[-1] + gap(0)

def edge():
    return [["Hello World"], ["   fly me   to   the moon  "], ["luffy is still joyboy"], ["a"], ["a "], ["  ab"], ["day"]]

def random_case(rng):
    return [sentence(rng)]

def perf(rng):
    return []
```
