---
lc: 22
title: "Generate Parentheses"
difficulty: "Medium"
patterns: ["backtracking"]
lcTags: ["string", "dynamic-programming", "backtracking", "bracket-sequences"]
compare: "unordered"
entry: {"method": "generateParenthesis", "params": [{"name": "n", "type": "integer"}], "returns": "list<string>"}
examples: ["3", "1"]
---

Given `n` pairs of parentheses, write a function to *generate all combinations of well-formed parentheses*.

**Example 1:**

```
Input: n = 3
Output: ["((()))","(()())","(())()","()(())","()()()"]
```

**Example 2:**

```
Input: n = 1
Output: ["()"]
```

**Constraints:**

- `1 <= n <= 8`

# Starter

```python
class Solution:
    def generateParenthesis(self, n: int) -> list[str]:
        
```

# Hints

1. Build the string one character at a time. When is adding '(' allowed? When is ')' allowed?
2. Backtrack(open, close): add '(' if open < n; add ')' if close < open. Record when the length is 2n.

# Key points

- '(' allowed while fewer than n opened
- ')' allowed only if it closes something (close < open)
- these rules only produce valid strings, no filtering needed
- number of results is the Catalan number

# Solution: dfs-pruning · DFS + Pruning · O(2^{n× 2} × n) · O(n) · reference

The range of n in the problem is `[1, 8]`, so we can directly solve this problem through "brute force search + pruning".

We design a function `dfs(l, r, t)`, where l and r represent the number of left and right brackets respectively, and t represents the current bracket sequence. Then we can get the following recursive structure:

- If `l > n` or `r > n` or `l < r`, then the current bracket combination t is invalid, return directly;
- If `l = n` and `r = n`, then the current bracket combination t is valid, add it to the answer array `ans`, and return directly;
- We can choose to add a left bracket, and recursively execute `dfs(l + 1, r, t + "(")`;
- We can also choose to add a right bracket, and recursively execute `dfs(l, r + 1, t + ")")`.

The time complexity is O(2^{n× 2} × n), and the space complexity is O(n).

```python
class Solution:
    def generateParenthesis(self, n: int) -> List[str]:
        def dfs(l: int, r: int, t: str):
            if l > n or r > n or l < r:
                return
            if l == n and r == n:
                ans.append(t)
                return
            dfs(l + 1, r, t + "(")
            dfs(l, r + 1, t + ")")

        ans = []
        dfs(0, 0, "")
        return ans
```

# Tests

```python

```
