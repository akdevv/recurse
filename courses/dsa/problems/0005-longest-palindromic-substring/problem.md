---
lc: 5
title: "Longest Palindromic Substring"
difficulty: "Medium"
patterns: ["two-pointers", "dynamic-programming"]
lcTags: ["two-pointers", "string", "dynamic-programming", "manacher"]
compare: "check"
entry: {"method": "longestPalindrome", "params": [{"name": "s", "type": "string"}], "returns": "string"}
examples: ["\"babad\"", "\"cbbd\""]
lcHints: ["How can we reuse a previously computed palindrome to compute a larger palindrome?", "If “aba” is a palindrome, is “xabax” a palindrome? Similarly is “xabay” a palindrome?", "Complexity based hint:</br>\r\nIf we use brute-force and check whether for every start and end position a substring is a palindrome we have O(n^2) start - end pairs and O(n) palindromic checks. Can we reduce the time for palindromic checks to O(1) by reusing some previous computation."]
---

Given a string `s`, return *the longest* *palindromic* *substring* in `s`.

**Example 1:**

```
Input: s = "babad"
Output: "bab"
Explanation: "aba" is also a valid answer.
```

**Example 2:**

```
Input: s = "cbbd"
Output: "bb"
```

**Constraints:**

- `1 <= s.length <= 1000`
- `s` consist of only digits and English letters.

# Starter

```python
class Solution:
    def longestPalindrome(self, s: str) -> str:
        
```

# Hints

1. Every palindrome has a center: a character (odd length) or a gap between two characters (even length).
2. For each of the 2n − 1 centers, expand outward while the ends match. Keep the longest.

# Key points

- expand around each center: O(n²) time, O(1) space
- remember both odd and even centers
- DP table is also O(n²) but uses O(n²) space
- several answers can be valid; any palindrome of the maximum length is accepted

# Solution: dynamic-programming · Dynamic Programming · O(n²) · O(n²) · reference

We define `f[i][j]` to represent whether the string `s[i..j]` is a palindrome, initially `f[i][j] = true`.

Next, we define variables k and mx, where k represents the starting position of the longest palindrome, and mx represents the length of the longest palindrome. Initially, `k = 0`, `mx = 1`.

Considering `f[i][j]`, if `s[i] = s[j]`, then `f[i][j] = f[i + 1][j - 1]`; otherwise, `f[i][j] = false`. If `f[i][j] = true` and `mx < j - i + 1`, then we update `k = i`, `mx = j - i + 1`.

Since `f[i][j]` depends on `f[i + 1][j - 1]`, we need to ensure that `i + 1` is before `j - 1`, so we need to enumerate i from large to small, and enumerate j from small to large.

The time complexity is O(n²), and the space complexity is O(n²). Here, n is the length of the string s.

```python
class Solution:
    def longestPalindrome(self, s: str) -> str:
        n = len(s)
        f = [[True] * n for _ in range(n)]
        k, mx = 0, 1
        for i in range(n - 2, -1, -1):
            for j in range(i + 1, n):
                f[i][j] = False
                if s[i] == s[j]:
                    f[i][j] = f[i + 1][j - 1]
                    if f[i][j] and mx < j - i + 1:
                        k, mx = i, j - i + 1
        return s[k : k + mx]
```

# Solution: enumerate-palindrome-midpoint · Enumerate Palindrome Midpoint · O(n²) · O(1)

We can enumerate the midpoint of the palindrome, spread to both sides, and find the longest palindrome.

The time complexity is O(n²), and the space complexity is O(1). Here, n is the length of the string s.

```python
class Solution:
    def longestPalindrome(self, s: str) -> str:
        def f(l, r):
            while l >= 0 and r < n and s[l] == s[r]:
                l, r = l - 1, r + 1
            return r - l - 1

        n = len(s)
        start, mx = 0, 1
        for i in range(n):
            a = f(i, i)
            b = f(i, i + 1)
            t = max(a, b)
            if mx < t:
                mx = t
                start = i - ((t - 1) >> 1)
        return s[start : start + mx]
```

# Tests

```python
def check(args, got, expected):
    s = args[0]
    return isinstance(got, str) and got == got[::-1] and got in s and len(got) == len(expected)

def edge():
    return [["a"], ["bb"], ["babad"], ["cbbd"], ["ac"], ["aaaa"], ["abacdfgdcaba"]]

def random_case(rng):
    return ["".join(rng.choice("ab1") for _ in range(rng.randint(1, 12)))]

def perf(rng):
    return [["".join(rng.choice("ab") for _ in range(1000))], ["a" * 1000]]
```
