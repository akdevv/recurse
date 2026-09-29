---
lc: 383
title: "Ransom Note"
difficulty: "Easy"
patterns: ["hash-map"]
lcTags: ["hash-table", "string", "counting"]
entry: {"method": "canConstruct", "params": [{"name": "ransomNote", "type": "string"}, {"name": "magazine", "type": "string"}], "returns": "boolean"}
examples: ["\"a\"\n\"b\"", "\"aa\"\n\"ab\"", "\"aa\"\n\"aab\""]
---

Given two strings `ransomNote` and `magazine`, return `true` *if* `ransomNote` *can be constructed by using the letters from* `magazine` *and* `false` *otherwise*.

Each letter in `magazine` can only be used once in `ransomNote`.

**Example 1:**

```
Input: ransomNote = "a", magazine = "b"
Output: false
```

**Example 2:**

```
Input: ransomNote = "aa", magazine = "ab"
Output: false
```

**Example 3:**

```
Input: ransomNote = "aa", magazine = "aab"
Output: true
```

**Constraints:**

- `1 <= ransomNote.length, magazine.length <= 10⁵`
- `ransomNote` and `magazine` consist of lowercase English letters.

# Starter

```python
class Solution:
    def canConstruct(self, ransomNote: str, magazine: str) -> bool:
        
```

# Hints

1. Each letter of the magazine can be used once. Count what the magazine offers.
2. Count the magazine's letters, then walk the note and decrement; if any count would go below zero, return False.

# Key points

- count the magazine's letters with Counter or a 26-slot array
- every note letter consumes one count; a missing letter means False
- O(m + n) time, O(1) space for 26 letters

# Solution: remove · Remove letters from a list · O(m·n) · O(n) · slow

## Idea
Cut each needed letter out of the magazine. `in` and `remove` both scan the list.

## Complexity
- **Time: O(m·n)**.
- **Space: O(n)**.

```python
class Solution:
    def canConstruct(self, ransomNote: str, magazine: str) -> bool:
        letters = list(magazine)
        for c in ransomNote:
            if c not in letters:
                return False
            letters.remove(c)
        return True
```

# Solution: count · Count the magazine · O(m + n) · O(1) · reference

## Idea
Count what the magazine offers, then spend one count per note letter. Running out of a letter means we can't build the note.

One-liner: `return not Counter(ransomNote) - Counter(magazine)` (Counter subtraction drops non-positive counts).

## Complexity
- **Time: O(m + n)**.
- **Space: O(1)**, 26 counts.

```python
class Solution:
    def canConstruct(self, ransomNote: str, magazine: str) -> bool:
        counts = [0] * 26
        for c in magazine:
            counts[ord(c) - ord("a")] += 1
        for c in ransomNote:
            i = ord(c) - ord("a")
            if counts[i] == 0:
                return False
            counts[i] -= 1
        return True
```

# Tests

```python
def edge():
    return [["a", "b"], ["aa", "ab"], ["aa", "aab"], ["abc", "cba"], ["z", "z"]]

def random_case(rng):
    return ["".join(rng.choice("abc") for _ in range(rng.randint(1, 6))),
            "".join(rng.choice("abc") for _ in range(rng.randint(1, 8)))]

def perf(rng):
    n = 100000
    return [["b" * (n // 2), "a" * (n // 2) + "b" * (n // 2)]]
```
