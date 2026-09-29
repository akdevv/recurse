---
lc: 208
title: "Implement Trie (Prefix Tree)"
difficulty: "Medium"
patterns: ["trie"]
lcTags: ["hash-table", "string", "design", "trie"]
entry: {"method": "Trie", "design": true, "params": [{"name": "operations", "type": "string[]"}, {"name": "arguments", "type": "list"}], "returns": "list", "voids": ["insert"]}
examples: ["[\"Trie\",\"insert\",\"search\",\"search\",\"startsWith\",\"insert\",\"search\"]\n[[],[\"apple\"],[\"apple\"],[\"app\"],[\"app\"],[\"app\"],[\"app\"]]"]
---

A [**trie**](https://en.wikipedia.org/wiki/Trie) (pronounced as "try") or **prefix tree** is a tree data structure used to efficiently store and retrieve keys in a dataset of strings. There are various applications of this data structure, such as autocomplete and spellchecker.

Implement the Trie class:

- `Trie()` Initializes the trie object.
- `void insert(String word)` Inserts the string `word` into the trie.
- `boolean search(String word)` Returns `true` if the string `word` is in the trie (i.e., was inserted before), and `false` otherwise.
- `boolean startsWith(String prefix)` Returns `true` if there is a previously inserted string `word` that has the prefix `prefix`, and `false` otherwise.

**Example 1:**

```
Input
["Trie", "insert", "search", "search", "startsWith", "insert", "search"]
[[], ["apple"], ["apple"], ["app"], ["app"], ["app"], ["app"]]
Output
[null, null, true, false, true, null, true]

Explanation
Trie trie = new Trie();
trie.insert("apple");
trie.search("apple");   // return True
trie.search("app");     // return False
trie.startsWith("app"); // return True
trie.insert("app");
trie.search("app");     // return True
```

**Constraints:**

- `1 <= word.length, prefix.length <= 2000`
- `word` and `prefix` consist only of lowercase English letters.
- At most `3 * 10⁴` calls **in total** will be made to `insert`, `search`, and `startsWith`.

# Starter

```python
class Trie:

    def __init__(self):
        

    def insert(self, word: str) -> None:
        

    def search(self, word: str) -> bool:
        

    def startsWith(self, prefix: str) -> bool:
        

# Your Trie object will be instantiated and called as such:
# obj = Trie()
# obj.insert(word)
# param_2 = obj.search(word)
# param_3 = obj.startsWith(prefix)
```

# Hints

1. Each node represents a prefix and has up to 26 children. How do you tell "a word ends here" apart from "a longer word passes through"?
2. Node = dict of children + an `end` flag. insert walks/creates nodes; search walks and checks `end`; startsWith just walks.

# Key points

- tree of characters; each path from the root spells a prefix
- `is_end` flag marks complete words
- insert/search/startsWith are O(L) for a word of length L

# Solution: trie-prefix-tree · Trie (Prefix Tree) · O(m × |\Sigma|) · O(q × m × |\Sigma|) · reference

Each node in the trie contains two parts:

1. An array of pointers to child nodes `children`. For this problem, the array length is 26, representing the number of lowercase English letters. `children[0]` corresponds to lowercase letter 'a', ..., and `children[25]` corresponds to lowercase letter 'z'.
2. A boolean field `isEnd` indicating whether the node is the end of a string.

### 1. Insert a String

We start from the root of the trie and insert the string. For the child node corresponding to the current character, there are two cases:

- The child node exists. Move along the pointer to the child node and continue processing the next character.
- The child node does not exist. Create a new child node, record it in the corresponding position of the `children` array, then move along the pointer to the child node and continue searching for the next character.

Repeat the above steps until the last character of the string is processed, then mark the current node as the end of the string.

### 2. Search for a Prefix

We start from the root of the trie and search for the prefix. For the child node corresponding to the current character, there are two cases:

- The child node exists. Move along the pointer to the child node and continue searching for the next character.
- The child node does not exist. This means the trie does not contain the prefix, so return a null pointer.

Repeat the above steps until a null pointer is returned or the last character of the prefix is searched.

If we search to the end of the prefix, it means the trie contains the prefix. Additionally, if the `isEnd` of the node corresponding to the end of the prefix is true, it means the trie contains the string.

The time complexity for inserting a string is O(m × |\Sigma|), and the time complexity for searching a prefix is O(m), where m is the length of the string and `|\Sigma|` is the size of the character set (26 in this problem). The space complexity is O(q × m × |\Sigma|), where q is the number of inserted strings.

```python
class Trie:
    def __init__(self):
        self.children = [None] * 26
        self.is_end = False

    def insert(self, word: str) -> None:
        node = self
        for c in word:
            idx = ord(c) - ord('a')
            if node.children[idx] is None:
                node.children[idx] = Trie()
            node = node.children[idx]
        node.is_end = True

    def search(self, word: str) -> bool:
        node = self._search_prefix(word)
        return node is not None and node.is_end

    def startsWith(self, prefix: str) -> bool:
        node = self._search_prefix(prefix)
        return node is not None

    def _search_prefix(self, prefix: str):
        node = self
        for c in prefix:
            idx = ord(c) - ord('a')
            if node.children[idx] is None:
                return None
            node = node.children[idx]
        return node

# Your Trie object will be instantiated and called as such:
# obj = Trie()
# obj.insert(word)
# param_2 = obj.search(word)
# param_3 = obj.startsWith(prefix)
```

# Tests

```python
def ops(rng, n, abc, L):
    o, a = ["Trie"], [[]]
    words = []
    for _ in range(n):
        op = rng.choice(["insert", "search", "startsWith"])
        w = rng.choice(words) if words and rng.random() < 0.5 else "".join(rng.choice(abc) for _ in range(rng.randint(1, L)))
        if op == "insert":
            words.append(w)
        elif op == "startsWith" and rng.random() < 0.5:
            w = w[: rng.randint(1, len(w))]
        o.append(op); a.append([w])
    return [o, a]

def edge():
    return [[["Trie", "insert", "search", "search", "startsWith", "insert", "search"], [[], ["apple"], ["apple"], ["app"], ["app"], ["app"], ["app"]]],
            [["Trie", "search", "startsWith"], [[], ["a"], ["a"]]]]

def random_case(rng):
    return ops(rng, rng.randint(1, 15), "ab", 4)

def perf(rng):
    return [ops(rng, 30000, "abcde", 30)]
```
