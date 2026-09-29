---
lc: 72
title: "Edit Distance"
difficulty: "Medium"
patterns: ["dynamic-programming"]
lcTags: ["string", "dynamic-programming"]
entry: {"method": "minDistance", "params": [{"name": "word1", "type": "string"}, {"name": "word2", "type": "string"}], "returns": "integer"}
examples: ["\"horse\"\n\"ros\"", "\"intention\"\n\"execution\""]
---

Given two strings `word1` and `word2`, return *the minimum number of operations required to convert `word1` to `word2`*.

You have the following three operations permitted on a word:

- Insert a character
- Delete a character
- Replace a character

**Example 1:**

```
Input: word1 = "horse", word2 = "ros"
Output: 3
Explanation:
horse -> rorse (replace 'h' with 'r')
rorse -> rose (remove 'r')
rose -> ros (remove 'e')
```

**Example 2:**

```
Input: word1 = "intention", word2 = "execution"
Output: 5
Explanation:
intention -> inention (remove 't')
inention -> enention (replace 'i' with 'e')
enention -> exention (replace 'n' with 'x')
exention -> exection (replace 'n' with 'c')
exection -> execution (insert 'u')
```

**Constraints:**

- `0 <= word1.length, word2.length <= 500`
- `word1` and `word2` consist of lowercase English letters.

# Starter

```python
class Solution:
    def minDistance(self, word1: str, word2: str) -> int:
        
```

# Hints

1. Look at the last characters of both prefixes. Equal → no operation needed for them. Otherwise one of three operations happened last.
2. dp[i][j] = dp[i − 1][j − 1] if equal; else 1 + min(dp[i − 1][j] (delete), dp[i][j − 1] (insert), dp[i − 1][j − 1] (replace)). dp[i][0] = i, dp[0][j] = j.

# Key points

- 2D dp over prefixes
- base cases: turning a prefix into an empty string costs its length
- O(m·n) time, O(n) space with rolling rows

# Solution: dynamic-programming · Dynamic Programming · O(m × n) · O(m × n) · reference

We define `f[i][j]` as the minimum number of operations to convert word1 of length i to word2 of length j. `f[i][0] = i`, `f[0][j] = j`, `i in [1, m], j in [0, n]`.

We consider `f[i][j]`:

- If `word1[i - 1] = word2[j - 1]`, then we only need to consider the minimum number of operations to convert word1 of length `i - 1` to word2 of length `j - 1`, so `f[i][j] = f[i - 1][j - 1]`;
- Otherwise, we can consider insert, delete, and replace operations, then `f[i][j] = min(f[i - 1][j], f[i][j - 1], f[i - 1][j - 1]) + 1`.

Finally, we can get the state transition equation:

```
f[i][j] = \begin{cases}
i, & if  j = 0 \\
j, & if  i = 0 \\
f[i - 1][j - 1], & if  word1[i - 1] = word2[j - 1] \\
min(f[i - 1][j], f[i][j - 1], f[i - 1][j - 1]) + 1, & otherwise
\end{cases}
```

Finally, we return `f[m][n]`.

The time complexity is O(m × n), and the space complexity is O(m × n). m and n are the lengths of word1 and word2 respectively.

```python
class Solution:
    def minDistance(self, word1: str, word2: str) -> int:
        m, n = len(word1), len(word2)
        f = [[0] * (n + 1) for _ in range(m + 1)]
        for j in range(1, n + 1):
            f[0][j] = j
        for i, a in enumerate(word1, 1):
            f[i][0] = i
            for j, b in enumerate(word2, 1):
                if a == b:
                    f[i][j] = f[i - 1][j - 1]
                else:
                    f[i][j] = min(f[i - 1][j], f[i][j - 1], f[i - 1][j - 1]) + 1
        return f[m][n]
```

# Tests

```python

```
