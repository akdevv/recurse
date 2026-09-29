---
lc: 394
title: "Decode String"
difficulty: "Medium"
patterns: ["stack"]
lcTags: ["string", "stack", "recursion"]
entry: {"method": "decodeString", "params": [{"name": "s", "type": "string"}], "returns": "string"}
examples: ["\"3[a]2[bc]\"", "\"3[a2[c]]\"", "\"2[abc]3[cd]ef\""]
---

Given an encoded string, return its decoded string.

The encoding rule is: `k[encoded_string]`, where the `encoded_string` inside the square brackets is being repeated exactly `k` times. Note that `k` is guaranteed to be a positive integer.

You may assume that the input string is always valid; there are no extra white spaces, square brackets are well-formed, etc. Furthermore, you may assume that the original data does not contain any digits and that digits are only for those repeat numbers, `k`. For example, there will not be input like `3a` or `2[4]`.

The test cases are generated so that the length of the output will never exceed `10⁵`.

**Example 1:**

```
Input: s = "3[a]2[bc]"
Output: "aaabcbc"
```

**Example 2:**

```
Input: s = "3[a2[c]]"
Output: "accaccacc"
```

**Example 3:**

```
Input: s = "2[abc]3[cd]ef"
Output: "abcabccdcdcdef"
```

**Constraints:**

- `1 <= s.length <= 30`
- `s` consists of lowercase English letters, digits, and square brackets `'[]'`.
- `s` is guaranteed to be **a valid** input.
- All the integers in `s` are in the range `[1, 300]`.

# Starter

```python
class Solution:
    def decodeString(self, s: str) -> str:
        
```

# Hints

1. Brackets can nest. When you hit ']', you need the string and the repeat count that were active before the matching '['.
2. Stack of (previous string, count). On '[' push and reset; on ']' pop and set cur = prev + count · cur. Digits can be multi-digit.

# Key points

- stack saves the outer context at each '['
- on ']' repeat the inner string and append it to the outer one
- numbers can have several digits: num = num * 10 + d
- recursion is an equally good way to write it

# Solution: solution-1 · Two stacks (counts and strings) · O(output length) · O(n) · reference

## Idea
One stack keeps repeat counts, the other keeps the string built before each `[`. On `[` push both and start fresh; on `]` pop them and set `res = previous + res × count`. Digits build multi-digit counts.

## Complexity
- **Time: O(output length)**
- **Space: O(n)**

```python
class Solution:
    def decodeString(self, s: str) -> str:
        s1, s2 = [], []
        num, res = 0, ''
        for c in s:
            if c.isdigit():
                num = num * 10 + int(c)
            elif c == '[':
                s1.append(num)
                s2.append(res)
                num, res = 0, ''
            elif c == ']':
                res = s2.pop() + res * s1.pop()
            else:
                res += c
        return res
```

# Tests

```python
def enc(rng, depth):
    parts = []
    for _ in range(rng.randint(1, 2)):
        if depth and rng.random() < 0.5:
            parts.append(f"{rng.randint(1, 4)}[{enc(rng, depth - 1)}]")
        else:
            parts.append("".join(rng.choice("abc") for _ in range(rng.randint(1, 3))))
    return "".join(parts)

def edge():
    return [["a"], ["3[a]"], ["3[a]2[bc]"], ["3[a2[c]]"], ["2[abc]3[cd]ef"], ["10[a]"], ["abc3[cd]xyz"]]

def random_case(rng):
    while True:
        s = enc(rng, 2)
        if len(s) <= 30:
            return [s]
```
