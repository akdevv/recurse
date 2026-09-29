---
lc: 211
title: "Design Add and Search Words Data Structure"
difficulty: "Medium"
patterns: ["trie", "backtracking"]
lcTags: ["string", "depth-first-search", "design", "trie"]
entry: {"method": "WordDictionary", "design": true, "params": [{"name": "operations", "type": "string[]"}, {"name": "arguments", "type": "list"}], "returns": "list", "voids": ["addWord"]}
examples: ["[\"WordDictionary\",\"addWord\",\"addWord\",\"addWord\",\"search\",\"search\",\"search\",\"search\"]\n[[],[\"bad\"],[\"dad\"],[\"mad\"],[\"pad\"],[\"bad\"],[\".ad\"],[\"b..\"]]"]
lcHints: ["You should be familiar with how a Trie works. If not, please work on this problem: <a href=\"https://leetcode.com/problems/implement-trie-prefix-tree/\">Implement Trie (Prefix Tree)</a> first."]
---

Design a data structure that supports adding new words and finding if a string matches any previously added string.

Implement the `WordDictionary` class:

- `WordDictionary()` Initializes the object.
- `void addWord(word)` Adds `word` to the data structure, it can be matched later.
- `bool search(word)` Returns `true` if there is any string in the data structure that matches `word` or `false` otherwise. `word` may contain dots `'.'` where dots can be matched with any letter.

**Example:**

```
Input
["WordDictionary","addWord","addWord","addWord","search","search","search","search"]
[[],["bad"],["dad"],["mad"],["pad"],["bad"],[".ad"],["b.."]]
Output
[null,null,null,null,false,true,true,true]

Explanation
WordDictionary wordDictionary = new WordDictionary();
wordDictionary.addWord("bad");
wordDictionary.addWord("dad");
wordDictionary.addWord("mad");
wordDictionary.search("pad"); // return False
wordDictionary.search("bad"); // return True
wordDictionary.search(".ad"); // return True
wordDictionary.search("b.."); // return True
```

**Constraints:**

- `1 <= word.length <= 25`
- `word` in `addWord` consists of lowercase English letters.
- `word` in `search` consist of `'.'` or lowercase English letters.
- There will be at most `2` dots in `word` for `search` queries.
- At most `10⁴` calls will be made to `addWord` and `search`.

# Starter

```python
class WordDictionary:

    def __init__(self):
        

    def addWord(self, word: str) -> None:
        

    def search(self, word: str) -> bool:
        

# Your WordDictionary object will be instantiated and called as such:
# obj = WordDictionary()
# obj.addWord(word)
# param_2 = obj.search(word)
```

# Hints

1. Store words in a trie. A '.' can match any child, so search may need to try several branches.
2. search(i, node): at '.', recurse into every child; otherwise follow the one child. Succeed at the end only if the node marks a word.

# Key points

- trie for storage
- DFS during search to handle '.' wildcards
- at most 2 dots keeps the branching small
- O(L) per addWord, up to O(26² · L) per search with 2 dots

# Solution: solution-1 · Trie + DFS for wildcards · O(L) add, O(26² × L) search · O(total characters) · reference

## Idea
Store words in a trie. Search walks the trie; a letter follows one child, a `.` tries every child recursively. A match needs the walk to end on a node that marks the end of a word.

## Complexity
- **Time: O(L) add, O(26² × L) search**
- **Space: O(total characters)**

```python
class Trie:
    def __init__(self):
        self.children = [None] * 26
        self.is_end = False

class WordDictionary:
    def __init__(self):
        self.trie = Trie()

    def addWord(self, word: str) -> None:
        node = self.trie
        for c in word:
            idx = ord(c) - ord('a')
            if node.children[idx] is None:
                node.children[idx] = Trie()
            node = node.children[idx]
        node.is_end = True

    def search(self, word: str) -> bool:
        def search(word, node):
            for i in range(len(word)):
                c = word[i]
                idx = ord(c) - ord('a')
                if c != '.' and node.children[idx] is None:
                    return False
                if c == '.':
                    for child in node.children:
                        if child is not None and search(word[i + 1 :], child):
                            return True
                    return False
                node = node.children[idx]
            return node.is_end

        return search(word, self.trie)

# Your WordDictionary object will be instantiated and called as such:
# obj = WordDictionary()
# obj.addWord(word)
# param_2 = obj.search(word)
```

# Tests

```python
def ops(rng, n, abc, L):
    o, a, words = ["WordDictionary"], [[]], []
    for _ in range(n):
        if rng.random() < 0.5:
            w = "".join(rng.choice(abc) for _ in range(rng.randint(1, L)))
            words.append(w); o.append("addWord"); a.append([w])
        else:
            w = list(rng.choice(words) if words and rng.random() < 0.6 else "".join(rng.choice(abc) for _ in range(rng.randint(1, L))))
            for _ in range(rng.randint(0, 2)):
                w[rng.randrange(len(w))] = "."
            o.append("search"); a.append(["".join(w)])
    return [o, a]

def edge():
    return [[["WordDictionary", "addWord", "addWord", "addWord", "search", "search", "search", "search"],
             [[], ["bad"], ["dad"], ["mad"], ["pad"], ["bad"], [".ad"], ["b.."]]],
            [["WordDictionary", "search", "addWord", "search", "search"], [[], ["."], ["a"], ["."], [".."]]]]

def random_case(rng):
    return ops(rng, rng.randint(1, 15), "ab", 3)

def perf(rng):
    return [ops(rng, 10000, "abcdefghijklmnopqrstuvwxyz", 25)]
```
