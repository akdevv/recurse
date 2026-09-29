---
lc: 20
title: "Valid Parentheses"
difficulty: "Easy"
patterns: ["stack"]
lcTags: ["string", "stack", "bracket-sequences"]
entry: {"method": "isValid", "params": [{"name": "s", "type": "string"}], "returns": "boolean"}
examples: ["\"()\"", "\"()[]{}\"", "\"(]\"", "\"([])\"", "\"([)]\""]
lcHints: ["Use a stack of characters.", "When you encounter an opening bracket, push it to the top of the stack.", "When you encounter a closing bracket, check if the top of the stack was the opening for it. If yes, pop it from the stack. Otherwise, return false."]
---

Given a string `s` containing just the characters `'('`, `')'`, `'{'`, `'}'`, `'['` and `']'`, determine if the input string is valid.

An input string is valid if:

1. Open brackets must be closed by the same type of brackets.
1. Open brackets must be closed in the correct order.
1. Every close bracket has a corresponding open bracket of the same type.

**Example 1:**

**Input:** s = "()"

**Output:** true

**Example 2:**

**Input:** s = "()[]{}"

**Output:** true

**Example 3:**

**Input:** s = "(]"

**Output:** false

**Example 4:**

**Input:** s = "([])"

**Output:** true

**Example 5:**

**Input:** s = "([)]"

**Output:** false

**Constraints:**

- `1 <= s.length <= 10⁴`
- `s` consists of parentheses only `'()[]{}'`.

# Starter

```python
class Solution:
    def isValid(self, s: str) -> bool:
        
```

# Hints

1. The most recent unmatched opening bracket is the one the next closing bracket must match. Which structure gives you "most recent"?
2. Push opening brackets. On a closing bracket, the stack must be non-empty and its top must be the matching opener; pop it. At the end the stack must be empty.

# Key points

- a stack of open brackets, top = most recent unmatched one
- closing bracket must match the top (use a map close → open)
- valid only if the stack ends empty
- O(n) time and space

# Solution: stack · Stack · O(n) · O(n) · reference

Traverse the bracket string s. When encountering a left bracket, push the current left bracket into the stack; when encountering a right bracket, pop the top element of the stack (if the stack is empty, directly return `false`), and judge whether it matches. If it does not match, directly return `false`.

Alternatively, when encountering a left bracket, you can push the corresponding right bracket into the stack; when encountering a right bracket, pop the top element of the stack (if the stack is empty, directly return `false`), and judge whether they are equal. If they do not match, directly return `false`.

> The difference between the two methods is only the timing of bracket conversion, one is when pushing into the stack, and the other is when popping out of the stack.

At the end of the traversal, if the stack is empty, it means the bracket string is valid, return `true`; otherwise, return `false`.

The time complexity is O(n), and the space complexity is O(n). Here, n is the length of the bracket string s.

```python
class Solution:
    def isValid(self, s: str) -> bool:
        stk = []
        d = {'()', '[]', '{}'}
        for c in s:
            if c in '({[':
                stk.append(c)
            elif not stk or stk.pop() + c not in d:
                return False
        return not stk
```

# Tests

```python
PAIRS = {"(": ")", "[": "]", "{": "}"}

def valid(rng, depth):
    if depth == 0 or rng.random() < 0.3:
        return ""
    o = rng.choice("([{")
    return o + valid(rng, depth - 1) + PAIRS[o] + valid(rng, depth - 1)

def edge():
    return [["("], [")"], ["()"], ["()[]{}"], ["(]"], ["([)]"], ["{[]}"], ["(("], ["]"]]

def random_case(rng):
    s = valid(rng, 4) or "()"
    if rng.random() < 0.4:
        i = rng.randrange(len(s))
        s = s[:i] + rng.choice("()[]{}") + s[i + 1:]
    return [s]

def perf(rng):
    return [["(" * 5000 + ")" * 5000], ["([{" * 3333 + "}])" * 3333]]
```
