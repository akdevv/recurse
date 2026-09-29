---
lc: 8
title: "String to Integer (atoi)"
difficulty: "Medium"
patterns: ["simulation"]
lcTags: ["string"]
entry: {"method": "myAtoi", "params": [{"name": "s", "type": "string"}], "returns": "integer"}
examples: ["\"42\"", "\"   -042\"", "\"1337c0d3\"", "\"0-1\"", "\"words and 987\""]
---

Implement the `myAtoi(string s)` function, which converts a string to a 32-bit signed integer.

The algorithm for `myAtoi(string s)` is as follows:

1. **Whitespace**: Ignore any leading whitespace (`" "`).
1. **Signedness**: Determine the sign by checking if the next character is `'-'` or `'+'`, assuming positivity if neither present.
1. **Conversion**: Read the integer by skipping leading zeros until a non-digit character is encountered or the end of the string is reached. If no digits were read, then the result is 0.
1. **Rounding**: If the integer is out of the 32-bit signed integer range `[-2³¹, 2³¹ - 1]`, then round the integer to remain in the range. Specifically, integers less than `-2³¹` should be rounded to `-2³¹`, and integers greater than `2³¹ - 1` should be rounded to `2³¹ - 1`.

Return the integer as the final result.

**Example 1:**

**Input:** s = "42"

**Output:** 42

**Explanation:**

```
The underlined characters are what is read in and the caret is the current reader position.
Step 1: "42" (no characters read because there is no leading whitespace)
         ^
Step 2: "42" (no characters read because there is neither a '-' nor '+')
         ^
Step 3: "42" ("42" is read in)
           ^
```

**Example 2:**

**Input:** s = " -042"

**Output:** -42

**Explanation:**

```
Step 1: "   -042" (leading whitespace is read and ignored)
            ^
Step 2: "   -042" ('-' is read, so the result should be negative)
             ^
Step 3: "   -042" ("042" is read in, leading zeros ignored in the result)
               ^
```

**Example 3:**

**Input:** s = "1337c0d3"

**Output:** 1337

**Explanation:**

```
Step 1: "1337c0d3" (no characters read because there is no leading whitespace)
         ^
Step 2: "1337c0d3" (no characters read because there is neither a '-' nor '+')
         ^
Step 3: "1337c0d3" ("1337" is read in; reading stops because the next character is a non-digit)
             ^
```

**Example 4:**

**Input:** s = "0-1"

**Output:** 0

**Explanation:**

```
Step 1: "0-1" (no characters read because there is no leading whitespace)
         ^
Step 2: "0-1" (no characters read because there is neither a '-' nor '+')
         ^
Step 3: "0-1" ("0" is read in; reading stops because the next character is a non-digit)
          ^
```

**Example 5:**

**Input:** s = "words and 987"

**Output:** 0

**Explanation:**

Reading stops at the first non-digit character 'w'.

**Constraints:**

- `0 <= s.length <= 200`
- `s` consists of English letters (lower-case and upper-case), digits (`0-9`), `' '`, `'+'`, `'-'`, and `'.'`.

# Starter

```python
class Solution:
    def myAtoi(self, s: str) -> int:
        
```

# Hints

1. Go step by step exactly as the statement says: spaces, then an optional sign, then digits. Stop at the first non-digit.
2. Build the number digit by digit (n = n * 10 + d), then clamp to [−2³¹, 2³¹ − 1] at the end.

# Key points

- follow the phases in order: skip spaces, read one optional sign, read digits, stop at anything else
- build the value with n = n * 10 + digit; `ord(c) - ord('0')` turns a char into a digit
- clamp to the 32-bit range; no digits means 0

# Solution: scan · Parse in phases · O(n) · O(1) · reference

## Idea
A tiny state machine, in the exact order the statement lists:
1. Skip leading spaces.
2. Read at most one `+` or `-`.
3. Read digits, building `num = num * 10 + digit`.
4. Stop at the first non-digit and clamp.

## Complexity
- **Time: O(n)**.
- **Space: O(1)**.

Python ints never overflow, so clamping at the end is fine. In Java or C++ you'd check before each `num * 10 + d` step.

```python
class Solution:
    def myAtoi(self, s: str) -> int:
        i, n = 0, len(s)
        while i < n and s[i] == " ":
            i += 1
        sign = 1
        if i < n and s[i] in "+-":
            sign = -1 if s[i] == "-" else 1
            i += 1
        num = 0
        while i < n and s[i].isdigit():
            num = num * 10 + (ord(s[i]) - ord("0"))
            i += 1
        return max(-(2**31), min(2**31 - 1, sign * num))
```

# Solution: regex · One regular expression · O(n) · O(n)

## Idea
`" *([+-]?\d+)"`: any spaces, then an optional sign and at least one digit. `re.match` anchors at the start, so junk before the number means no match (0).

## Complexity
- **Time: O(n)**.
- **Space: O(n)** for the matched text.

Short, but interviewers usually want to see the manual parse.

```python
import re

class Solution:
    def myAtoi(self, s: str) -> int:
        m = re.match(r" *([+-]?\d+)", s)
        if not m:
            return 0
        return max(-(2**31), min(2**31 - 1, int(m.group(1))))
```

# Tests

```python
def edge():
    return [
        ["42"], ["   -042"], ["1337c0d3"], ["0-1"], ["words and 987"], [""], [" "], ["-"], ["+"],
        ["+-12"], ["-91283472332"], ["2147483647"], ["2147483648"], ["-2147483648"], ["-2147483649"],
        ["   +0 123"], ["00000-42a1234"], [".1"], ["  0000000000012345678"],
    ]

def random_case(rng):
    if rng.random() < 0.3:
        return ["".join(rng.choice("0123456789 +-.a") for _ in range(rng.randint(0, 12)))]
    s = " " * rng.randint(0, 3) + rng.choice(["", "+", "-", "+-"])
    s += "".join(rng.choice("0123456789") for _ in range(rng.randint(0, 12)))
    return [s + rng.choice(["", " 12", "abc", ".5", "-3"])]

def perf(rng):
    return []
```
