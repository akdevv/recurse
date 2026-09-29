## Core idea

**A trie (prefix tree) stores strings character by character along paths from the root, so words that share a prefix share nodes.** Insert, search and "does any word start with this prefix?" all take O(L) for a word of length L, no matter how many words are stored.

## Intuition

A phone's autocomplete. Type "ap" and it instantly knows every word starting with "ap": they all live under the same two nodes. A hash set can tell you whether "apple" is a word, but it has no idea which words *start with* "ap" without checking every one.

Each node needs one extra bit: **is a word ending here?** Without it, you couldn't tell that "app" is a word on its own and not just the start of "apple".

## Visualization

Building a trie: shared prefixes share nodes, word ends are marked:

```viz
trie-build
```

`startsWith` only needs the path to exist; `search` also needs the end mark:

```viz
prefix-search
```

## Template code

```python
class TrieNode:
    def __init__(self):
        self.children = {}          # char -> TrieNode (or a list of 26)
        self.end = False

class Trie:
    def __init__(self):
        self.root = TrieNode()

    def insert(self, word):
        node = self.root
        for ch in word:
            node = node.children.setdefault(ch, TrieNode())
        node.end = True

    def _walk(self, s):
        node = self.root
        for ch in s:
            node = node.children.get(ch)
            if node is None:
                return None
        return node

    def search(self, word):
        node = self._walk(word)
        return node is not None and node.end

    def startsWith(self, prefix):
        return self._walk(prefix) is not None

# Wildcard '.' search: DFS into every child at a dot
def dfs(node, i):
    if i == len(word):
        return node.end
    if word[i] == ".":
        return any(dfs(child, i + 1) for child in node.children.values())
    child = node.children.get(word[i])
    return child is not None and dfs(child, i + 1)

# Replace words with the shortest root: walk until the first node with end = True
```

## Complexity

| Operation | Trie | Hash set of words |
|---|---|---|
| insert / search a word of length L | O(L) | O(L) average (hashing the string) |
| "any word with this prefix?" | **O(L)** | O(n · L): check every word |
| memory | up to O(total characters) nodes | O(total characters) |

## When to use it

- **Prefix queries: autocomplete, "starts with", shortest root** → trie
- **Many words searched on the same grid (Word Search II)** → trie + DFS, so all words share one walk and dead prefixes are pruned
- **Wildcard search ('.')** → trie with DFS at wildcards
- **Only exact lookups** → a hash set is simpler
- **Maximum XOR of two numbers** → a binary trie over the bits (advanced)

## Common traps

- Forgetting the end-of-word flag: "app" would wrongly be found after inserting "apple"
- `search` returning True just because the path exists (that's `startsWith`)
- Creating nodes while searching (use `.get`, not `setdefault`, when reading)
- Word Search II: not removing found words / pruning, so the same word is added twice or the search stays slow
- A list of 26 children assumes lowercase letters only; use a dict otherwise
