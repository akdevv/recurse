---
lc: 424
title: "Longest Repeating Character Replacement"
difficulty: "Medium"
patterns: ["sliding-window", "hash-map"]
lcTags: ["hash-table", "string", "sliding-window"]
entry: {"method": "characterReplacement", "params": [{"name": "s", "type": "string"}, {"name": "k", "type": "integer"}], "returns": "integer"}
examples: ["\"ABAB\"\n2", "\"AABABBA\"\n1"]
---

You are given a string `s` and an integer `k`. You can choose any character of the string and change it to any other uppercase English character. You can perform this operation at most `k` times.

Return *the length of the longest substring containing the same letter you can get after performing the above operations*.

**Example 1:**

```
Input: s = "ABAB", k = 2
Output: 4
Explanation: Replace the two 'A's with two 'B's or vice versa.
```

**Example 2:**

```
Input: s = "AABABBA", k = 1
Output: 4
Explanation: Replace the one 'A' in the middle with 'B' and form "AABBBBA".
The substring "BBBB" has the longest repeating letters, which is 4.
There may exists other ways to achieve this answer too.
```

**Constraints:**

- `1 <= s.length <= 10⁵`
- `s` consists of only uppercase English letters.
- `0 <= k <= s.length`

# Starter

```python
class Solution:
    def characterReplacement(self, s: str, k: int) -> int:
        
```

# Hints

1. A window can become all one letter if (window length − count of its most frequent letter) ≤ k.
2. Expand right and update counts. If the window becomes invalid, move left by one. Track the max frequency seen; it never needs to decrease.

# Key points

- window is fixable when length − max_count ≤ k
- expand right; if invalid, shrink left by one (window size never decreases)
- max_count can stay stale: the answer only grows when a bigger max_count appears
- O(n) time (26 letters), O(1) space

# Solution: all-starts · Every start, extend with counts · O(26·n²) · O(1) · slow

## Idea
For each start, extend the end while keeping letter counts, and check length − max count ≤ k.

## Complexity
- **Time: O(26·n²)**.
- **Space: O(1)**.

```python
class Solution:
    def characterReplacement(self, s: str, k: int) -> int:
        best = 0
        for i in range(len(s)):
            counts = [0] * 26
            for j in range(i, len(s)):
                counts[ord(s[j]) - 65] += 1
                if j - i + 1 - max(counts) <= k:
                    best = max(best, j - i + 1)
        return best
```

# Solution: sliding · Sliding window with max frequency · O(n) · O(1) · reference

## Idea
Inside a window, keep the most frequent letter and replace the rest. That works when `length - maxf <= k`.

Expand `r`. If the window breaks the rule, slide `l` forward by one, so the window keeps its size and moves right. The window never shrinks, so its size is the best answer so far.

`maxf` is never decreased when `l` moves. A stale `maxf` can only keep an invalid window at the old best size, never make the answer bigger than it should be; the answer grows only when a real, bigger `maxf` appears.

## Complexity
- **Time: O(n)**.
- **Space: O(1)**, 26 counts.

```python
from collections import defaultdict

class Solution:
    def characterReplacement(self, s: str, k: int) -> int:
        counts = defaultdict(int)
        l = maxf = 0
        for r, c in enumerate(s):
            counts[c] += 1
            maxf = max(maxf, counts[c])
            if r - l + 1 - maxf > k:
                counts[s[l]] -= 1
                l += 1
        return len(s) - l
```

# Tests

```python
def edge():
    return [["A", 0], ["A", 1], ["AB", 0], ["ABAB", 2], ["AABABBA", 1], ["ABCDE", 1], ["AAAA", 0]]

def random_case(rng):
    s = "".join(rng.choice("ABC") for _ in range(rng.randint(1, 10)))
    return [s, rng.randint(0, len(s))]

def perf(rng):
    return [["".join(rng.choice("ABCDEFGHIJKLMNOPQRSTUVWXYZ") for _ in range(100000)), 50]]
```
