---
lc: 91
title: "Decode Ways"
difficulty: "Medium"
patterns: ["dynamic-programming"]
lcTags: ["string", "dynamic-programming"]
entry: {"method": "numDecodings", "params": [{"name": "s", "type": "string"}], "returns": "integer"}
examples: ["\"12\"", "\"226\"", "\"06\""]
---

You have intercepted a secret message encoded as a string of numbers. The message is **decoded** via the following mapping:

`"1" -> 'A'<br> "2" -> 'B'<br> ...<br> "25" -> 'Y'<br> "26" -> 'Z'`

However, while decoding the message, you realize that there are many different ways you can decode the message because some codes are contained in other codes (`"2"` and `"5"` vs `"25"`).

For example, `"11106"` can be decoded into:

- `"AAJF"` with the grouping `(1, 1, 10, 6)`
- `"KJF"` with the grouping `(11, 10, 6)`
- The grouping `(1, 11, 06)` is invalid because `"06"` is not a valid code (only `"6"` is valid).

Note: there may be strings that are impossible to decode.<br> <br> Given a string s containing only digits, return the **number of ways** to **decode** it. If the entire string cannot be decoded in any valid way, return `0`.

The test cases are generated so that the answer fits in a **32-bit** integer.

**Example 1:**

**Input:** s = "12"

**Output:** 2

**Explanation:**

"12" could be decoded as "AB" (1 2) or "L" (12).

**Example 2:**

**Input:** s = "226"

**Output:** 3

**Explanation:**

"226" could be decoded as "BZ" (2 26), "VF" (22 6), or "BBF" (2 2 6).

**Example 3:**

**Input:** s = "06"

**Output:** 0

**Explanation:**

"06" cannot be mapped to "F" because of the leading zero ("6" is different from "06"). In this case, the string is not a valid encoding, so return 0.

**Constraints:**

- `1 <= s.length <= 100`
- `s` contains only digits and may contain leading zero(s).

# Starter

```python
class Solution:
    def numDecodings(self, s: str) -> int:
        
```

# Hints

1. The last step decodes either one digit (1–9) or two digits (10–26). A '0' alone can't be decoded.
2. dp[i] = (dp[i − 1] if s[i − 1] != '0') + (dp[i − 2] if 10 ≤ int(s[i − 2:i]) ≤ 26). dp[0] = 1.

# Key points

- like Climbing Stairs with validity checks
- one digit valid if it isn't '0'; two digits valid if between 10 and 26
- leading or isolated zeros make the count 0
- O(n) time, O(1) space with rolling variables

# Solution: dynamic-programming · Dynamic Programming · O(n) · O(n) · reference

We define `f[i]` to represent the number of decoding methods for the first i characters of the string. Initially, `f[0]=1`, and the rest `f[i]=0`.

Consider how `f[i]` transitions.

- If the ith character (i.e., `s[i-1]`) forms a code on its own, it corresponds to one decoding method, i.e., `f[i]=f[i-1]`. The premise is `s[i-1] != 0`.
- If the string formed by the `i-1`th character and the ith character is within the range `[1,26]`, then they can be treated as a whole, corresponding to one decoding method, i.e., `f[i] = f[i] + f[i-2]`. The premise is `s[i-2] != 0`, and `s[i-2]s[i-1]` is within the range `[1,26]`.

The time complexity is O(n), and the space complexity is O(n). Here, n is the length of the string.

```python
class Solution:
    def numDecodings(self, s: str) -> int:
        n = len(s)
        f = [1] + [0] * n
        for i, c in enumerate(s, 1):
            if c != "0":
                f[i] = f[i - 1]
            if i > 1 and s[i - 2] != "0" and int(s[i - 2 : i]) <= 26:
                f[i] += f[i - 2]
        return f[n]
```

# Solution: optimized-dynamic-programming · Optimized Dynamic Programming · O(n) · O(n)

We notice that the state `f[i]` is only related to `f[i-1]` and `f[i-2]`. Therefore, we can use two variables to replace these states, reducing the space complexity from O(n) to O(1). The time complexity remains O(n).

```python
class Solution:
    def numDecodings(self, s: str) -> int:
        f, g = 0, 1
        for i, c in enumerate(s, 1):
            h = g if c != "0" else 0
            if i > 1 and s[i - 2] != "0" and int(s[i - 2 : i]) <= 26:
                h += f
            f, g = g, h
        return g
```

# Tests

```python

```
