---
lc: 139
title: "Word Break"
difficulty: "Medium"
patterns: ["dynamic-programming"]
lcTags: ["array", "hash-table", "string", "dynamic-programming", "trie", "memoization", "brute-force-search"]
entry: {"method": "wordBreak", "params": [{"name": "s", "type": "string"}, {"name": "wordDict", "type": "list<string>"}], "returns": "boolean"}
examples: ["\"leetcode\"\n[\"leet\",\"code\"]", "\"applepenapple\"\n[\"apple\",\"pen\"]", "\"catsandog\"\n[\"cats\",\"dog\",\"sand\",\"and\",\"cat\"]"]
---

Given a string `s` and a dictionary of strings `wordDict`, return `true` if `s` can be segmented into a space-separated sequence of one or more dictionary words.

**Note** that the same word in the dictionary may be reused multiple times in the segmentation.

**Example 1:**

```
Input: s = "leetcode", wordDict = ["leet","code"]
Output: true
Explanation: Return true because "leetcode" can be segmented as "leet code".
```

**Example 2:**

```
Input: s = "applepenapple", wordDict = ["apple","pen"]
Output: true
Explanation: Return true because "applepenapple" can be segmented as "apple pen apple".
Note that you are allowed to reuse a dictionary word.
```

**Example 3:**

```
Input: s = "catsandog", wordDict = ["cats","dog","sand","and","cat"]
Output: false
```

**Constraints:**

- `1 <= s.length <= 300`
- `1 <= wordDict.length <= 1000`
- `1 <= wordDict[i].length <= 20`
- `s` and `wordDict[i]` consist of only lowercase English letters.
- All the strings of `wordDict` are **unique**.

# Starter

```python
class Solution:
    def wordBreak(self, s: str, wordDict: list[str]) -> bool:
        
```

# Hints

1. s[:i] can be segmented if some earlier split point j is segmentable and s[j:i] is a word.
2. dp[0] = True; dp[i] = any(dp[j] and s[j:i] in words) for j < i. Only check j down to i − (max word length).

# Key points

- dp[i] = can the prefix of length i be split into words
- put the dictionary in a set for O(1) lookups
- limit inner loop by the longest word length
- O(n × L) checks

# Solution: solution-1 · DP over prefixes · O(n³) · O(n + total word length) · reference

## Idea
`f[i]` says whether the first i characters can be split into words. The prefix of length i works if some shorter prefix `f[j]` works and `s[j:i]` is a word.

## Complexity
- **Time: O(n³)**
- **Space: O(n + total word length)**

```python
class Solution:
    def wordBreak(self, s: str, wordDict: List[str]) -> bool:
        words = set(wordDict)
        n = len(s)
        f = [True] + [False] * n
        for i in range(1, n + 1):
            f[i] = any(f[j] and s[j:i] in words for j in range(i))
        return f[n]
```

# Solution: solution-2 · Trie + DP · O(n² + total word length) · O(n + total word length)

## Idea
Put the words in a trie. Fill `f[i]` = "the suffix starting at i can be split" from the right: walk the trie from position i, and whenever a word ends at position j, `f[i]` is true if `f[j + 1]` is. The trie stops early when no word continues.

## Complexity
- **Time: O(n² + total word length)**
- **Space: O(n + total word length)**

```python
class Trie:
    def __init__(self):
        self.children: List[Trie | None] = [None] * 26
        self.isEnd = False

    def insert(self, w: str):
        node = self
        for c in w:
            idx = ord(c) - ord('a')
            if not node.children[idx]:
                node.children[idx] = Trie()
            node = node.children[idx]
        node.isEnd = True

class Solution:
    def wordBreak(self, s: str, wordDict: List[str]) -> bool:
        trie = Trie()
        for w in wordDict:
            trie.insert(w)
        n = len(s)
        f = [False] * (n + 1)
        f[n] = True
        for i in range(n - 1, -1, -1):
            node = trie
            for j in range(i, n):
                idx = ord(s[j]) - ord('a')
                if not node.children[idx]:
                    break
                node = node.children[idx]
                if node.isEnd and f[j + 1]:
                    f[i] = True
                    break
        return f[0]
```

# Tests

```python
def edge():
    return [["leetcode", ["leet", "code"]], ["applepenapple", ["apple", "pen"]], ["catsandog", ["cats", "dog", "sand", "and", "cat"]],
            ["a", ["a"]], ["a", ["b"]], ["aaaaaaaaaaab", ["a", "aa", "aaa"]]]

def random_case(rng):
    words = list({"".join(rng.choice("ab") for _ in range(rng.randint(1, 3))) for _ in range(rng.randint(1, 4))})
    parts = [rng.choice(words) for _ in range(rng.randint(1, 4))]
    s = "".join(parts)
    if rng.random() < 0.4:
        s += rng.choice("abc")
    return [s, words]

def perf(rng):
    return [["a" * 299 + "b", ["a" * i for i in range(1, 21)]]]
```
