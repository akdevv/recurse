---
lc: 648
title: "Replace Words"
difficulty: "Medium"
patterns: ["trie"]
lcTags: ["array", "hash-table", "string", "trie"]
entry: {"method": "replaceWords", "params": [{"name": "dictionary", "type": "list<string>"}, {"name": "sentence", "type": "string"}], "returns": "string"}
examples: ["[\"cat\",\"bat\",\"rat\"]\n\"the cattle was rattled by the battery\"", "[\"a\",\"b\",\"c\"]\n\"aadsfasf absbs bbab cadsfafs\""]
---

In English, we have a concept called **root**, which can be followed by some other word to form another longer word - let's call this word **derivative**. For example, when the **root** `"help"` is followed by the word `"ful"`, we can form a derivative `"helpful"`.

Given a `dictionary` consisting of many **roots** and a `sentence` consisting of words separated by spaces, replace all the derivatives in the sentence with the **root** forming it. If a derivative can be replaced by more than one **root**, replace it with the **root** that has **the shortest length**.

Return *the `sentence`* after the replacement.

**Example 1:**

```
Input: dictionary = ["cat","bat","rat"], sentence = "the cattle was rattled by the battery"
Output: "the cat was rat by the bat"
```

**Example 2:**

```
Input: dictionary = ["a","b","c"], sentence = "aadsfasf absbs bbab cadsfafs"
Output: "a a b c"
```

**Constraints:**

- `1 <= dictionary.length <= 1000`
- `1 <= dictionary[i].length <= 100`
- `dictionary[i]` consists of only lower-case letters.
- `1 <= sentence.length <= 10⁶`
- `sentence` consists of only lower-case letters and spaces.
- The number of words in `sentence` is in the range `[1, 1000]`
- The length of each word in `sentence` is in the range `[1, 1000]`
- Every two consecutive words in `sentence` will be separated by exactly one space.
- `sentence` does not have leading or trailing spaces.

# Starter

```python
class Solution:
    def replaceWords(self, dictionary: list[str], sentence: str) -> str:
        
```

# Hints

1. For each word you want the shortest root that is a prefix of it.
2. Insert all roots into a trie. For each word, walk the trie letter by letter and stop at the first node that ends a root; replace the word with that prefix (or keep it if none).

# Key points

- trie of roots; walk each word until the first complete root
- shortest root wins automatically (first one hit)
- O(total characters) time

# Solution: trie · Trie · O(n × |w| + L) · O(n × |w|) · reference

We can use a trie to store all the roots in the dictionary. Define the trie node class Trie, which contains an array children of length 26 to store child nodes, and a boolean variable is_end to mark whether it is a complete root.

For each root, we insert it into the trie. For each word in the sentence, we search for its shortest root in the trie. If found, we replace the word; otherwise, we keep it unchanged.

The time complexity is O(n × |w| + L), and the space complexity is O(n × |w|), where n and `|w|` are the number of roots in the dictionary and the average length, respectively, and L is the total length of words in the sentence.

```python
class Trie:
    def __init__(self):
        self.children = [None] * 26
        self.is_end = False

    def insert(self, w: str) -> None:
        node = self
        for c in w:
            idx = ord(c) - ord("a")
            if node.children[idx] is None:
                node.children[idx] = Trie()
            node = node.children[idx]
        node.is_end = True

    def search(self, w: str) -> str:
        node = self
        for i, c in enumerate(w, 1):
            idx = ord(c) - ord("a")
            if node.children[idx] is None:
                return w
            node = node.children[idx]
            if node.is_end:
                return w[:i]
        return w

class Solution:
    def replaceWords(self, dictionary: List[str], sentence: str) -> str:
        trie = Trie()
        for w in dictionary:
            trie.insert(w)
        return " ".join(trie.search(w) for w in sentence.split())
```

# Tests

```python
def edge():
    return [[["cat", "bat", "rat"], "the cattle was rattled by the battery"], [["a", "b", "c"], "aadsfasf absbs bbab cadsfafs"],
            [["a", "aa"], "aaaa"], [["xyz"], "abc"]]

def random_case(rng):
    roots = list({"".join(rng.choice("ab") for _ in range(rng.randint(1, 3))) for _ in range(rng.randint(1, 4))})
    words = ["".join(rng.choice("abc") for _ in range(rng.randint(1, 5))) for _ in range(rng.randint(1, 6))]
    return [roots, " ".join(words)]

def perf(rng):
    abc = "abcdefghijklmnopqrstuvwxyz"
    roots = list({"".join(rng.choice(abc) for _ in range(rng.randint(1, 5))) for _ in range(1000)})
    return [[roots, " ".join("".join(rng.choice(abc) for _ in range(1000)) for _ in range(1000))]]
```
