---
lc: 151
title: "Reverse Words in a String"
difficulty: "Medium"
patterns: ["two-pointers"]
lcTags: ["two-pointers", "string"]
entry: {"method": "reverseWords", "params": [{"name": "s", "type": "string"}], "returns": "string"}
examples: ["\"the sky is blue\"", "\"  hello world  \"", "\"a good   example\""]
---

Given an input string `s`, reverse the order of the **words**.

A **word** is defined as a sequence of non-space characters. The **words** in `s` will be separated by at least one space.

Return *a string of the words in reverse order concatenated by a single space.*

**Note** that `s` may contain leading or trailing spaces or multiple spaces between two words. The returned string should only have a single space separating the words. Do not include any extra spaces.

**Example 1:**

```
Input: s = "the sky is blue"
Output: "blue is sky the"
```

**Example 2:**

```
Input: s = "  hello world  "
Output: "world hello"
Explanation: Your reversed string should not contain leading or trailing spaces.
```

**Example 3:**

```
Input: s = "a good   example"
Output: "example good a"
Explanation: You need to reduce multiple spaces between two words to a single space in the reversed string.
```

**Constraints:**

- `1 <= s.length <= 10⁴`
- `s` contains English letters (upper-case and lower-case), digits, and spaces `' '`.
- There is **at least one** word in `s`.

**Follow-up:** If the string data type is mutable in your language, can you solve it **in-place** with `O(1)` extra space?

# Starter

```python
class Solution:
    def reverseWords(self, s: str) -> str:
        
```

# Hints

1. Watch the spaces: leading, trailing and repeated ones must all disappear.
2. Split into words (ignoring extra spaces), reverse the list, join with single spaces. In an interview, be ready to do it by scanning from the end too.

# Key points

- `split()` with no argument drops leading, trailing and repeated spaces
- reverse the list of words, not the characters, then join with one space
- O(n) time and space; strings are immutable in Python, so building a new one is unavoidable

# Solution: split-reverse · Split, reverse, join · O(n) · O(n) · reference

## Idea
`s.split()` gives the words with all the messy spacing removed. Reverse that list and glue it back with single spaces.

## Complexity
- **Time: O(n)**.
- **Space: O(n)** for the words and the result.

Interviewers often accept this, then ask you to do it without `split`. See the manual scan.

```python
class Solution:
    def reverseWords(self, s: str) -> str:
        return " ".join(reversed(s.split()))
```

# Solution: scan-back · Collect words scanning from the end · O(n) · O(n)

## Idea
Walk from the back. Skip spaces, then mark where a word ends and walk to where it starts. Words come out in reversed order naturally.

## Complexity
- **Time: O(n)**, each character is visited once.
- **Space: O(n)** for the result.

Using `"".join` on a list at the end avoids O(n²) repeated string concatenation.

```python
class Solution:
    def reverseWords(self, s: str) -> str:
        words, i = [], len(s) - 1
        while i >= 0:
            while i >= 0 and s[i] == " ":
                i -= 1
            if i < 0:
                break
            end = i
            while i >= 0 and s[i] != " ":
                i -= 1
            words.append(s[i + 1 : end + 1])
        return " ".join(words)
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
    return [["the sky is blue"], ["  hello world  "], ["a good   example"], ["a"], ["  a  "], ["x y"]]

def random_case(rng):
    return [sentence(rng, alnum=True)]

def perf(rng):
    return []
```
