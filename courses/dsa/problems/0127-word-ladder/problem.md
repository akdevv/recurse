---
lc: 127
title: "Word Ladder"
difficulty: "Hard"
patterns: ["bfs"]
lcTags: ["hash-table", "string", "breadth-first-search", "bidirectional-search"]
entry: {"method": "ladderLength", "params": [{"name": "beginWord", "type": "string"}, {"name": "endWord", "type": "string"}, {"name": "wordList", "type": "list<string>"}], "returns": "integer"}
examples: ["\"hit\"\n\"cog\"\n[\"hot\",\"dot\",\"dog\",\"lot\",\"log\",\"cog\"]", "\"hit\"\n\"cog\"\n[\"hot\",\"dot\",\"dog\",\"lot\",\"log\"]"]
---

A **transformation sequence** from word `beginWord` to word `endWord` using a dictionary `wordList` is a sequence of words `beginWord -> s₁ -> s₂ -> ... -> sₖ` such that:

- Every adjacent pair of words differs by a single letter.
- Every `sᵢ` for `1 <= i <= k` is in `wordList`. Note that `beginWord` does not need to be in `wordList`.
- `sₖ == endWord`

Given two words, `beginWord` and `endWord`, and a dictionary `wordList`, return *the **number of words** in the **shortest transformation sequence** from* `beginWord` *to* `endWord`*, or* `0` *if no such sequence exists.*

**Example 1:**

```
Input: beginWord = "hit", endWord = "cog", wordList = ["hot","dot","dog","lot","log","cog"]
Output: 5
Explanation: One shortest transformation sequence is "hit" -> "hot" -> "dot" -> "dog" -> cog", which is 5 words long.
```

**Example 2:**

```
Input: beginWord = "hit", endWord = "cog", wordList = ["hot","dot","dog","lot","log"]
Output: 0
Explanation: The endWord "cog" is not in wordList, therefore there is no valid transformation sequence.
```

**Constraints:**

- `1 <= beginWord.length <= 10`
- `endWord.length == beginWord.length`
- `1 <= wordList.length <= 5000`
- `wordList[i].length == beginWord.length`
- `beginWord`, `endWord`, and `wordList[i]` consist of lowercase English letters.
- `beginWord != endWord`
- All the words in `wordList` are **unique**.

# Starter

```python
class Solution:
    def ladderLength(self, beginWord: str, endWord: str, wordList: list[str]) -> int:
        
```

# Hints

1. Words are nodes; two words are connected if they differ in one letter. You want the shortest path length.
2. BFS from beginWord. For each word, try changing every position to a..z and check the word set; remove words from the set once visited.

# Key points

- BFS gives the shortest transformation
- generate neighbours by changing one letter at a time (L·26 per word)
- remove visited words from the set
- return 0 if endWord isn't reachable (or not in the list)

# Solution: bfs · BFS · O(n × L × 26) · O(n × L) · reference

BFS minimum step model. This problem can be solved with naive BFS, or it can be optimized with bidirectional BFS to reduce the search space and improve efficiency.

Bidirectional BFS is a common optimization method for BFS, with the main implementation ideas as follows:

1. Create two queues, q1 and q2, for "start -> end" and "end -> start" search directions, respectively.
2. Create two hash maps, m1 and m2, to record the visited nodes and their corresponding expansion times (steps).
3. During each search, prioritize the queue with fewer elements for search expansion. If a node visited from the other direction is found during the expansion, it means the shortest path has been found.
4. If one of the queues is empty, it means that the search in the current direction cannot continue, indicating that the start and end points are not connected, and there is no need to continue the search.

```python
while q1 and q2:
    if len(q1) <= len(q2):
        # Prioritize the queue with fewer elements for expansion
        extend(m1, m2, q1)
    else:
        extend(m2, m1, q2)

def extend(m1, m2, q):
    # New round of expansion
    for _ in range(len(q)):
        p = q.popleft()
        step = m1[p]
        for t in next(p):
            if t in m1:
                # Already visited before
                continue
            if t in m2:
                # The other direction has been searched, indicating that a shortest path has been found
                return step + 1 + m2[t]
            q.append(t)
            m1[t] = step + 1
```

```python
class Solution:
    def ladderLength(self, beginWord: str, endWord: str, wordList: List[str]) -> int:
        words = set(wordList)
        q = deque([beginWord])
        ans = 1
        while q:
            ans += 1
            for _ in range(len(q)):
                s = q.popleft()
                s = list(s)
                for i in range(len(s)):
                    ch = s[i]
                    for j in range(26):
                        s[i] = chr(ord('a') + j)
                        t = ''.join(s)
                        if t not in words:
                            continue
                        if t == endWord:
                            return ans
                        q.append(t)
                        words.remove(t)
                    s[i] = ch
        return 0
```

# Solution: bidirectional-bfs · Bidirectional BFS · O(n × L × 26) · O(n × L)

Search from both ends until the two sides meet.

```python
class Solution:
    def ladderLength(self, beginWord: str, endWord: str, wordList: List[str]) -> int:
        def extend(m1, m2, q):
            for _ in range(len(q)):
                s = q.popleft()
                step = m1[s]
                s = list(s)
                for i in range(len(s)):
                    ch = s[i]
                    for j in range(26):
                        s[i] = chr(ord('a') + j)
                        t = ''.join(s)
                        if t in m1 or t not in words:
                            continue
                        if t in m2:
                            return step + 1 + m2[t]
                        m1[t] = step + 1
                        q.append(t)
                    s[i] = ch
            return -1

        words = set(wordList)
        if endWord not in words:
            return 0
        q1, q2 = deque([beginWord]), deque([endWord])
        m1, m2 = {beginWord: 0}, {endWord: 0}
        while q1 and q2:
            t = extend(m1, m2, q1) if len(q1) <= len(q2) else extend(m2, m1, q2)
            if t != -1:
                return t + 1
        return 0
```

# Tests

```python
def edge():
    return [["hit", "cog", ["hot", "dot", "dog", "lot", "log", "cog"]], ["hit", "cog", ["hot", "dot", "dog", "lot", "log"]],
            ["a", "c", ["a", "b", "c"]], ["ab", "cd", ["ad", "cd"]]]

def random_case(rng):
    L = rng.randint(1, 3)
    w = lambda: "".join(rng.choice("abc") for _ in range(L))
    while True:
        b, e = w(), w()
        if b != e:
            break
    words = list({w() for _ in range(rng.randint(1, 10))} | ({e} if rng.random() < 0.7 else set()))
    rng.shuffle(words)
    return [b, e, words]

def perf(rng):
    words = list({"".join(rng.choice("abcdefghij") for _ in range(5)) for _ in range(5000)})
    return [["aaaaa", words[0], words]]
```
