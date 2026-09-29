---
lc: 205
title: "Isomorphic Strings"
difficulty: "Easy"
patterns: ["hash-map"]
lcTags: ["hash-table", "string"]
entry: {"method": "isIsomorphic", "params": [{"name": "s", "type": "string"}, {"name": "t", "type": "string"}], "returns": "boolean"}
examples: ["\"egg\"\n\"add\"", "\"foo\"\n\"bar\"", "\"paper\"\n\"title\""]
---

Given two strings `s` and `t`, *determine if they are isomorphic*.

Two strings `s` and `t` are isomorphic if the characters in `s` can be replaced to get `t`.

All occurrences of a character must be replaced with another character while preserving the order of characters. No two characters may map to the same character, but a character may map to itself.

**Example 1:**

**Input:** s = "egg", t = "add"

**Output:** true

**Explanation:**

The strings `s` and `t` can be made identical by:

- Mapping `'e'` to `'a'`.
- Mapping `'g'` to `'d'`.

**Example 2:**

**Input:** s = "f11", t = "b23"

**Output:** false

**Explanation:**

The strings `s` and `t` can not be made identical as `'1'` needs to be mapped to both `'2'` and `'3'`.

**Example 3:**

**Input:** s = "paper", t = "title"

**Output:** true

**Constraints:**

- `1 <= s.length <= 5 * 10⁴`
- `t.length == s.length`
- `s` and `t` consist of any valid ascii character.

# Starter

```python
class Solution:
    def isIsomorphic(self, s: str, t: str) -> bool:
        
```

# Hints

1. Each character of s must always map to the same character of t, and no two characters of s may map to the same one.
2. Keep two dicts, s→t and t→s. At every position, if an existing mapping disagrees, return False.

# Key points

- the mapping must be consistent (a→x every time) and one-to-one (no two chars → same char)
- two dicts, one per direction; any conflict means False
- O(n) time, O(k) space for k distinct characters

# Solution: two-maps · Map both directions · O(n) · O(k) · reference

## Idea
`s_to_t` enforces "a always becomes the same letter". `t_to_s` enforces "no two letters become the same letter". One map alone misses cases like `s = "ab"`, `t = "aa"`.

`.get(a, b) != b` reads: "if `a` is already mapped, it must be to `b`".

## Complexity
- **Time: O(n)**.
- **Space: O(k)**, k distinct characters (at most 256 for ASCII).

```python
class Solution:
    def isIsomorphic(self, s: str, t: str) -> bool:
        s_to_t, t_to_s = {}, {}
        for a, b in zip(s, t):
            if s_to_t.get(a, b) != b or t_to_s.get(b, a) != a:
                return False
            s_to_t[a] = b
            t_to_s[b] = a
        return True
```

# Solution: first-seen · Compare first-occurrence patterns · O(n) · O(n)

## Idea
Replace every character by the index of its first occurrence. Two strings are isomorphic exactly when these patterns match: `"egg"` → `[0, 1, 1]`, `"add"` → `[0, 1, 1]`.

`str.index` scans, but only up to the first occurrence and there are at most 256 distinct characters, so it stays fast.

## Complexity
- **Time: O(n·k)** worst case with k distinct characters, effectively O(n) for ASCII.
- **Space: O(n)** for the two lists.

```python
class Solution:
    def isIsomorphic(self, s: str, t: str) -> bool:
        return [s.index(c) for c in s] == [t.index(c) for c in t]
```

# Tests

```python
def edge():
    return [["a", "b"], ["ab", "aa"], ["aa", "ab"], ["egg", "add"], ["foo", "bar"], ["paper", "title"], ["badc", "baba"]]

def random_case(rng):
    n = rng.randint(1, 8)
    s = "".join(rng.choice("abc") for _ in range(n))
    if rng.random() < 0.5:
        m = dict(zip("abc", rng.sample("xyz", 3)))
        t = "".join(m[c] for c in s)
    else:
        t = "".join(rng.choice("xyz") for _ in range(n))
    return [s, t]

def perf(rng):
    n = 50000
    s = "".join(chr(rng.randint(33, 126)) for _ in range(n))
    return [[s, s]]
```
