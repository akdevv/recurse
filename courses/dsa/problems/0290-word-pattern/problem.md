---
lc: 290
title: "Word Pattern"
difficulty: "Easy"
patterns: ["hash-map"]
lcTags: ["hash-table", "string"]
entry: {"method": "wordPattern", "params": [{"name": "pattern", "type": "string"}, {"name": "s", "type": "string"}], "returns": "boolean"}
examples: ["\"abba\"\n\"dog cat cat dog\"", "\"abba\"\n\"dog cat cat fish\"", "\"aaaa\"\n\"dog cat cat dog\""]
---

Given a `pattern` and a string `s`, find if `s` follows the same pattern.

Here **follow** means a full match, such that there is a bijection between a letter in `pattern` and a **non-empty** word in `s`. Specifically:

- Each letter in `pattern` maps to **exactly** one unique word in `s`.
- Each unique word in `s` maps to **exactly** one letter in `pattern`.
- No two letters map to the same word, and no two words map to the same letter.

**Example 1:**

**Input:** pattern = "abba", s = "dog cat cat dog"

**Output:** true

**Explanation:**

The bijection can be established as:

- `'a'` maps to `"dog"`.
- `'b'` maps to `"cat"`.

**Example 2:**

**Input:** pattern = "abba", s = "dog cat cat fish"

**Output:** false

**Example 3:**

**Input:** pattern = "aaaa", s = "dog cat cat dog"

**Output:** false

**Constraints:**

- `1 <= pattern.length <= 300`
- `pattern` contains only lower-case English letters.
- `1 <= s.length <= 3000`
- `s` contains only lowercase English letters and spaces `' '`.
- `s` **does not contain** any leading or trailing spaces.
- All the words in `s` are separated by a **single space**.

# Starter

```python
class Solution:
    def wordPattern(self, pattern: str, s: str) -> bool:
        
```

# Hints

1. Split s into words first. If the counts don't match the pattern length, it's already False.
2. Same as Isomorphic Strings, but letters map to words: keep letter→word and word→letter dicts.

# Key points

- split into words, lengths must match
- bijection: letter→word and word→letter must both stay consistent
- O(n) time and space

# Solution: two-maps · Map both directions · O(n) · O(n) · reference

## Idea
A pattern letter must always stand for the same word, and two letters can't share a word. Two dicts check both directions, exactly like Isomorphic Strings.

Check the lengths first: `zip` would silently stop at the shorter one.

## Complexity
- **Time: O(n)** over the length of `s`.
- **Space: O(n)** for the words and maps.

```python
class Solution:
    def wordPattern(self, pattern: str, s: str) -> bool:
        words = s.split()
        if len(words) != len(pattern):
            return False
        to_word, to_char = {}, {}
        for c, w in zip(pattern, words):
            if to_word.get(c, w) != w or to_char.get(w, c) != c:
                return False
            to_word[c] = w
            to_char[w] = c
        return True
```

# Tests

```python
def edge():
    return [["abba", "dog cat cat dog"], ["abba", "dog cat cat fish"], ["aaaa", "dog cat cat dog"],
            ["abba", "dog dog dog dog"], ["a", "dog"], ["aaa", "dog dog"], ["ab", "dog dog"]]

def random_case(rng):
    n = rng.randint(1, 6)
    p = "".join(rng.choice("ab") for _ in range(n))
    words = {"a": "dog", "b": rng.choice(["cat", "dog"])}
    ws = [words[c] if rng.random() < 0.85 else rng.choice(["dog", "cat", "fish"]) for c in p]
    if rng.random() < 0.1:
        ws.append("cat")
    return [p, " ".join(ws)]
```
