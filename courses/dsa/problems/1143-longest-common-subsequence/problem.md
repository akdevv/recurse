---
lc: 1143
title: "Longest Common Subsequence"
difficulty: "Medium"
patterns: ["dynamic-programming"]
lcTags: ["string", "dynamic-programming", "longest-common-subsequence"]
entry: {"method": "longestCommonSubsequence", "params": [{"name": "text1", "type": "string"}, {"name": "text2", "type": "string"}], "returns": "integer"}
examples: ["\"abcde\"\n\"ace\"", "\"abc\"\n\"abc\"", "\"abc\"\n\"def\""]
lcHints: ["Try dynamic programming. \r\nDP[i][j] represents the longest common subsequence of text1[0 ... i] & text2[0 ... j].", "DP[i][j] = DP[i - 1][j - 1] + 1 , if text1[i] == text2[j]\r\nDP[i][j] = max(DP[i - 1][j], DP[i][j - 1]) , otherwise"]
---

Given two strings `text1` and `text2`, return *the length of their longest **common subsequence**.* If there is no **common subsequence**, return `0`.

A **subsequence** of a string is a new string generated from the original string with some characters (can be none) deleted without changing the relative order of the remaining characters.

- For example, `"ace"` is a subsequence of `"abcde"`.

A **common subsequence** of two strings is a subsequence that is common to both strings.

**Example 1:**

```
Input: text1 = "abcde", text2 = "ace"
Output: 3
Explanation: The longest common subsequence is "ace" and its length is 3.
```

**Example 2:**

```
Input: text1 = "abc", text2 = "abc"
Output: 3
Explanation: The longest common subsequence is "abc" and its length is 3.
```

**Example 3:**

```
Input: text1 = "abc", text2 = "def"
Output: 0
Explanation: There is no such common subsequence, so the result is 0.
```

**Constraints:**

- `1 <= text1.length, text2.length <= 1000`
- `text1` and `text2` consist of only lowercase English characters.

# Starter

```python
class Solution:
    def longestCommonSubsequence(self, text1: str, text2: str) -> int:
        
```

# Hints

1. Compare the last characters. If they match, they can end the common subsequence. If not, drop one of them.
2. dp[i][j] = dp[i − 1][j − 1] + 1 if a[i − 1] == b[j − 1], else max(dp[i − 1][j], dp[i][j − 1]).

# Key points

- 2D dp over prefixes of both strings
- match → diagonal + 1; mismatch → best of dropping a char from either string
- O(m·n) time, O(min(m, n)) space with a rolling row

# Solution: dynamic-programming · Dynamic Programming · O(m × n) · O(m × n) · reference

We define `f[i][j]` as the length of the longest common subsequence of the first i characters of text1 and the first j characters of text2. Therefore, the answer is `f[m][n]`, where m and n are the lengths of text1 and text2, respectively.

If the ith character of text1 and the jth character of text2 are the same, then `f[i][j] = f[i - 1][j - 1] + 1`; if the ith character of text1 and the jth character of text2 are different, then `f[i][j] = max(f[i - 1][j], f[i][j - 1])`. The state transition equation is:

```
f[i][j] =
\begin{cases}
f[i - 1][j - 1] + 1, & if  text1[i - 1] = text2[j - 1] \\
max(f[i - 1][j], f[i][j - 1]), & if  text1[i - 1] != text2[j - 1]
\end{cases}
```

The time complexity is O(m × n), and the space complexity is O(m × n). Here, m and n are the lengths of text1 and text2, respectively.

```python
class Solution:
    def longestCommonSubsequence(self, text1: str, text2: str) -> int:
        m, n = len(text1), len(text2)
        f = [[0] * (n + 1) for _ in range(m + 1)]
        for i in range(1, m + 1):
            for j in range(1, n + 1):
                if text1[i - 1] == text2[j - 1]:
                    f[i][j] = f[i - 1][j - 1] + 1
                else:
                    f[i][j] = max(f[i - 1][j], f[i][j - 1])
        return f[m][n]
```

# Tests

```python
def edge():
    return [["abcde", "ace"], ["abc", "abc"], ["abc", "def"], ["a", "a"], ["a", "b"], ["bl", "yby"]]

def random_case(rng):
    return ["".join(rng.choice("abc") for _ in range(rng.randint(1, 8))), "".join(rng.choice("abc") for _ in range(rng.randint(1, 8)))]

def perf(rng):
    abc = "abcdefghijklmnopqrstuvwxyz"
    return [["".join(rng.choice(abc) for _ in range(1000)), "".join(rng.choice(abc) for _ in range(1000))]]
```
