---
lc: 49
title: "Group Anagrams"
difficulty: "Medium"
patterns: ["hash-map"]
lcTags: ["array", "hash-table", "string", "sorting"]
compare: "groups"
entry: {"method": "groupAnagrams", "params": [{"name": "strs", "type": "string[]"}], "returns": "list<list<string>>"}
examples: ["[\"eat\",\"tea\",\"tan\",\"ate\",\"nat\",\"bat\"]", "[\"\"]", "[\"a\"]"]
---

Given an array of strings `strs`, group the anagrams together. You can return the answer in **any order**.

**Example 1:**

**Input:** strs = ["eat","tea","tan","ate","nat","bat"]

**Output:** [["bat"],["nat","tan"],["ate","eat","tea"]]

**Explanation:**

- There is no string in strs that can be rearranged to form `"bat"`.
- The strings `"nat"` and `"tan"` are anagrams as they can be rearranged to form each other.
- The strings `"ate"`, `"eat"`, and `"tea"` are anagrams as they can be rearranged to form each other.

**Example 2:**

**Input:** strs = [""]

**Output:** [[""]]

**Example 3:**

**Input:** strs = ["a"]

**Output:** [["a"]]

**Constraints:**

- `1 <= strs.length <= 10⁴`
- `0 <= strs[i].length <= 100`
- `strs[i]` consists of lowercase English letters.

# Starter

```python
class Solution:
    def groupAnagrams(self, strs: list[str]) -> list[list[str]]:
        
```

# Hints

1. Two words are anagrams when they have the same letters. What could you compute from a word so that all its anagrams produce the same value?
2. Use a dict from key → list of words. The key can be the sorted word ("aet") or a tuple of 26 letter counts.

# Key points

- anagrams share a canonical key: sorted letters or a 26-count tuple
- defaultdict(list): append each word under its key, return the values
- sorted key: O(n·k log k); count key: O(n·k), k = word length
- keys must be hashable: use a string or tuple, not a list

# Solution: sorted-key · Sorted word as key · O(n·k log k) · O(n·k) · reference

## Idea
All anagrams sort to the same string: `"eat"`, `"tea"`, `"ate"` → `"aet"`. Use that as the dict key and collect the words.

## Complexity
- **Time: O(n·k log k)**, sorting each of n words of length k.
- **Space: O(n·k)** for the groups.

```python
from collections import defaultdict

class Solution:
    def groupAnagrams(self, strs: list[str]) -> list[list[str]]:
        groups = defaultdict(list)
        for w in strs:
            groups["".join(sorted(w))].append(w)
        return list(groups.values())
```

# Solution: count-key · Letter counts as key · O(n·k) · O(n·k)

## Idea
Same grouping, but the key is the 26 letter counts. That avoids sorting each word. The list has to become a `tuple` because dict keys must be hashable.

## Complexity
- **Time: O(n·k)**, plus 26 per word to build the tuple.
- **Space: O(n·k)**.

```python
from collections import defaultdict

class Solution:
    def groupAnagrams(self, strs: list[str]) -> list[list[str]]:
        groups = defaultdict(list)
        for w in strs:
            counts = [0] * 26
            for c in w:
                counts[ord(c) - ord("a")] += 1
            groups[tuple(counts)].append(w)
        return list(groups.values())
```

# Tests

```python
def edge():
    return [[[""]], [["a"]], [["", ""]], [["ab", "ba", "abc"]], [["aa", "a"]]]

def random_case(rng):
    return [["".join(rng.choice("abc") for _ in range(rng.randint(0, 3))) for _ in range(rng.randint(1, 8))]]

def perf(rng):
    return [[["".join(rng.choice("abcde") for _ in range(rng.randint(1, 20))) for _ in range(10000)]]]
```
