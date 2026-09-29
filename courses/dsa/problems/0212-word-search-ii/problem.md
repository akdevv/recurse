---
lc: 212
title: "Word Search II"
difficulty: "Hard"
patterns: ["trie", "backtracking"]
lcTags: ["array", "string", "backtracking", "trie", "matrix"]
compare: "unordered"
entry: {"method": "findWords", "params": [{"name": "board", "type": "character[][]"}, {"name": "words", "type": "string[]"}], "returns": "list<string>"}
examples: ["[[\"o\",\"a\",\"a\",\"n\"],[\"e\",\"t\",\"a\",\"e\"],[\"i\",\"h\",\"k\",\"r\"],[\"i\",\"f\",\"l\",\"v\"]]\n[\"oath\",\"pea\",\"eat\",\"rain\"]", "[[\"a\",\"b\"],[\"c\",\"d\"]]\n[\"abcb\"]"]
lcHints: ["You would need to optimize your backtracking to pass the larger test. Could you stop backtracking earlier?", "If the current candidate does not exist in all words&#39; prefix, you could stop backtracking immediately. What kind of data structure could answer such query efficiently? Does a hash table work? Why or why not? How about a Trie? If you would like to learn how to implement a basic trie, please work on this problem: <a href=\"https://leetcode.com/problems/implement-trie-prefix-tree/\">Implement Trie (Prefix Tree)</a> first."]
---

Given an `m x n` `board` of characters and a list of strings `words`, return *all words on the board*.

Each word must be constructed from letters of sequentially adjacent cells, where **adjacent cells** are horizontally or vertically neighboring. The same letter cell may not be used more than once in a word.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/11/07/search1.jpg)

```
Input: board = [["o","a","a","n"],["e","t","a","e"],["i","h","k","r"],["i","f","l","v"]], words = ["oath","pea","eat","rain"]
Output: ["eat","oath"]
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2020/11/07/search2.jpg)

```
Input: board = [["a","b"],["c","d"]], words = ["abcb"]
Output: []
```

**Constraints:**

- `m == board.length`
- `n == board[i].length`
- `1 <= m, n <= 12`
- `board[i][j]` is a lowercase English letter.
- `1 <= words.length <= 3 * 10⁴`
- `1 <= words[i].length <= 10`
- `words[i]` consists of lowercase English letters.
- All the strings of `words` are unique.

# Starter

```python
class Solution:
    def findWords(self, board: list[list[str]], words: list[str]) -> list[str]:
        
```

# Hints

1. Running Word Search once per word repeats the same board walks. Search all words at once.
2. Put the words in a trie. DFS from every cell, following trie children only; when a node marks a word, record it (and clear the mark to avoid duplicates). Prune trie nodes that become empty.

# Key points

- trie of all words + one DFS per starting cell
- the trie prunes paths that can't lead to any word
- mark cells visited during the DFS and restore them
- remove found words from the trie to avoid duplicates and speed up

# Solution: solution-1 · Trie + DFS · O(m × n × 4 × 3^(L−1)) · O(total characters) · reference

## Idea
Insert all words into a trie (each word end remembers its index). DFS from every cell, only moving to letters that continue some word in the trie. When a word end is reached, record the word and clear its mark so it isn't added twice. Cells are marked while on the current path.

## Complexity
- **Time: O(m × n × 4 × 3^(L−1))**
- **Space: O(total characters)**

```python
class Trie:
    def __init__(self):
        self.children: List[Trie | None] = [None] * 26
        self.ref: int = -1

    def insert(self, w: str, ref: int):
        node = self
        for c in w:
            idx = ord(c) - ord('a')
            if node.children[idx] is None:
                node.children[idx] = Trie()
            node = node.children[idx]
        node.ref = ref

class Solution:
    def findWords(self, board: List[List[str]], words: List[str]) -> List[str]:
        def dfs(node: Trie, i: int, j: int):
            idx = ord(board[i][j]) - ord('a')
            if node.children[idx] is None:
                return
            node = node.children[idx]
            if node.ref >= 0:
                ans.append(words[node.ref])
                node.ref = -1
            c = board[i][j]
            board[i][j] = '#'
            for a, b in pairwise((-1, 0, 1, 0, -1)):
                x, y = i + a, j + b
                if 0 <= x < m and 0 <= y < n and board[x][y] != '#':
                    dfs(node, x, y)
            board[i][j] = c

        tree = Trie()
        for i, w in enumerate(words):
            tree.insert(w, i)
        m, n = len(board), len(board[0])
        ans = []
        for i in range(m):
            for j in range(n):
                dfs(tree, i, j)
        return ans
```

# Tests

```python
def edge():
    b = [["o", "a", "a", "n"], ["e", "t", "a", "e"], ["i", "h", "k", "r"], ["i", "f", "l", "v"]]
    return [[b, ["oath", "pea", "eat", "rain"]], [[["a", "b"], ["c", "d"]], ["abcb"]], [[["a"]], ["a", "b"]], [[["a", "a"]], ["aaa"]]]

def random_case(rng):
    m, n = rng.randint(1, 4), rng.randint(1, 4)
    board = [[rng.choice("ab") for _ in range(n)] for _ in range(m)]
    words = list({"".join(rng.choice("ab") for _ in range(rng.randint(1, 4))) for _ in range(rng.randint(1, 6))})
    return [board, words]

def perf(rng):
    abc = "abcde"
    board = [[rng.choice(abc) for _ in range(12)] for _ in range(12)]
    words = list({"".join(rng.choice(abc) for _ in range(rng.randint(1, 10))) for _ in range(30000)})
    return [[board, words]]
```
