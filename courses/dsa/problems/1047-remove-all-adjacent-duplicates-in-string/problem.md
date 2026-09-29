---
lc: 1047
title: "Remove All Adjacent Duplicates In String"
difficulty: "Easy"
patterns: ["stack"]
lcTags: ["string", "stack"]
entry: {"method": "removeDuplicates", "params": [{"name": "s", "type": "string"}], "returns": "string"}
examples: ["\"abbaca\"", "\"azxxzy\""]
lcHints: ["Use a stack to process everything greedily."]
---

You are given a string `s` consisting of lowercase English letters. A **duplicate removal** consists of choosing two **adjacent** and **equal** letters and removing them.

We repeatedly make **duplicate removals** on `s` until we no longer can.

Return *the final string after all such duplicate removals have been made*. It can be proven that the answer is **unique**.

**Example 1:**

```
Input: s = "abbaca"
Output: "ca"
Explanation:
For example, in "abbaca" we could remove "bb" since the letters are adjacent and equal, and this is the only possible move.  The result of this move is that the string is "aaca", of which only "aa" is possible, so the final string is "ca".
```

**Example 2:**

```
Input: s = "azxxzy"
Output: "ay"
```

**Constraints:**

- `1 <= s.length <= 10⁵`
- `s` consists of lowercase English letters.

# Starter

```python
class Solution:
    def removeDuplicates(self, s: str) -> str:
        
```

# Hints

1. Removing a pair can create a new pair, like "abba" → "aa" → "". Which structure lets you compare with the last kept character?
2. Stack of characters: if c equals the top, pop; otherwise push. Join the stack at the end.

# Key points

- stack holds the result so far; new char cancels an equal top
- handles chain reactions automatically
- O(n) time and space

# Solution: solution-1 · Stack · O(n) · O(n) · reference

## Idea
Use a stack of characters. If the next character equals the top, they cancel: pop. Otherwise push it. The stack handles chain reactions automatically.

## Complexity
- **Time: O(n)**
- **Space: O(n)**

```python
class Solution:
    def removeDuplicates(self, s: str) -> str:
        stk = []
        for c in s:
            if stk and stk[-1] == c:
                stk.pop()
            else:
                stk.append(c)
        return ''.join(stk)
```

# Tests

```python

```
