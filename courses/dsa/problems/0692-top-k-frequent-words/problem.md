---
lc: 692
title: "Top K Frequent Words"
difficulty: "Medium"
patterns: ["top-k-heap", "hash-map"]
lcTags: ["array", "hash-table", "string", "trie", "sorting", "heap-priority-queue", "bucket-sort", "counting"]
entry: {"method": "topKFrequent", "params": [{"name": "words", "type": "string[]"}, {"name": "k", "type": "integer"}], "returns": "list<string>"}
examples: ["[\"i\",\"love\",\"leetcode\",\"i\",\"love\",\"coding\"]\n2", "[\"the\",\"day\",\"is\",\"sunny\",\"the\",\"the\",\"the\",\"sunny\",\"is\",\"is\"]\n4"]
---

Given an array of strings `words` and an integer `k`, return *the* `k` *most frequent strings*.

Return the answer **sorted** by **the frequency** from highest to lowest. Sort the words with the same frequency by their **lexicographical order**.

**Example 1:**

```
Input: words = ["i","love","leetcode","i","love","coding"], k = 2
Output: ["i","love"]
Explanation: "i" and "love" are the two most frequent words.
Note that "i" comes before "love" due to a lower alphabetical order.
```

**Example 2:**

```
Input: words = ["the","day","is","sunny","the","the","the","sunny","is","is"], k = 4
Output: ["the","is","sunny","day"]
Explanation: "the", "is", "sunny" and "day" are the four most frequent words, with the number of occurrence being 4, 3, 2 and 1 respectively.
```

**Constraints:**

- `1 <= words.length <= 500`
- `1 <= words[i].length <= 10`
- `words[i]` consists of lowercase English letters.
- `k` is in the range `[1, The number of **unique** words[i]]`

**Follow-up:** Could you solve it in `O(n log(k))` time and `O(n)` extra space?

# Starter

```python
class Solution:
    def topKFrequent(self, words: list[str], k: int) -> list[str]:
        
```

# Hints

1. Count the words, then order by (−count, word): higher count first, ties alphabetical.
2. sorted(counts, key=lambda w: (−counts[w], w))[:k]. For O(n log k), use a heap of size k with the same ordering.

# Key points

- Counter for frequencies
- sort key (-count, word) handles the tie-break
- heap alternative: O(n log k)

# Solution: hash-table-sorting · Hash Table + Sorting · O(n × log n) · O(n) · reference

We can use a hash table cnt to record the frequency of each word. Then, we sort the key-value pairs in the hash table by value, and if the values are the same, we sort by key.

Finally, we take the first k keys.

The time complexity is O(n × log n), and the space complexity is O(n). Here, n is the number of words.

```python
class Solution:
    def topKFrequent(self, words: List[str], k: int) -> List[str]:
        cnt = Counter(words)
        return sorted(cnt, key=lambda x: (-cnt[x], x))[:k]
```

# Tests

```python
def edge():
    return [[["i", "love", "leetcode", "i", "love", "coding"], 2], [["the", "day", "is", "sunny", "the", "the", "the", "sunny", "is", "is"], 4], [["a"], 1], [["b", "a"], 2]]

def random_case(rng):
    words = ["".join(rng.choice("abc") for _ in range(rng.randint(1, 2))) for _ in range(rng.randint(1, 12))]
    return [words, rng.randint(1, len(set(words)))]

def perf(rng):
    words = ["".join(rng.choice("abcdefghij") for _ in range(rng.randint(1, 3))) for _ in range(500)]
    return [[words, len(set(words))]]
```
