---
lc: 131
title: "Palindrome Partitioning"
difficulty: "Medium"
patterns: ["backtracking"]
lcTags: ["string", "dynamic-programming", "backtracking"]
compare: "unordered"
entry: {"method": "partition", "params": [{"name": "s", "type": "string"}], "returns": "list<list<string>>"}
examples: ["\"aab\"", "\"a\""]
---

Given a string `s`, partition `s` such that every substring of the partition is a **palindrome**. Return *all possible palindrome partitioning of* `s`.

**Example 1:**

```
Input: s = "aab"
Output: [["a","a","b"],["aa","b"]]
```

**Example 2:**

```
Input: s = "a"
Output: [["a"]]
```

**Constraints:**

- `1 <= s.length <= 16`
- `s` contains only lowercase English letters.

# Starter

```python
class Solution:
    def partition(self, s: str) -> list[list[str]]:
        
```

# Hints

1. Cut off a palindromic prefix, then partition the rest the same way.
2. Backtrack(start, path): for end in start..n − 1: if s[start:end + 1] is a palindrome, append it, recurse from end + 1, pop. Record when start == n.

# Key points

- choose a palindromic prefix, recurse on the suffix
- precomputing is_pal[i][j] with DP avoids re-checking substrings
- O(n·2ⁿ) worst case (e.g. "aaaa…")

# Solution: preprocessing-dfs-backtracking · Preprocessing + DFS (Backtracking) · O(n × 2ⁿ) · O(n²) · reference

We can use dynamic programming to preprocess whether any substring in the string is a palindrome, i.e., `f[i][j]` indicates whether the substring `s[i..j]` is a palindrome.

Next, we design a function `dfs(i)`, which represents starting from the i-th character of the string and partitioning it into several palindromic substrings, with the current partition scheme being t.

If `i = |s|`, it means the partitioning is complete, and we add t to the answer array and then return.

Otherwise, we can start from i and enumerate the end position j from small to large. If `s[i..j]` is a palindrome, we add `s[i..j]` to t, then continue to recursively call `dfs(j+1)`. When backtracking, we need to pop `s[i..j]`.

The time complexity is O(n × 2ⁿ), and the space complexity is O(n²). Here, n is the length of the string.

```python
class Solution:
    def partition(self, s: str) -> List[List[str]]:
        def dfs(i: int):
            if i == n:
                ans.append(t[:])
                return
            for j in range(i, n):
                if f[i][j]:
                    t.append(s[i : j + 1])
                    dfs(j + 1)
                    t.pop()

        n = len(s)
        f = [[True] * n for _ in range(n)]
        for i in range(n - 1, -1, -1):
            for j in range(i + 1, n):
                f[i][j] = s[i] == s[j] and f[i + 1][j - 1]
        ans = []
        t = []
        dfs(0)
        return ans
```

# Tests

```python

```
