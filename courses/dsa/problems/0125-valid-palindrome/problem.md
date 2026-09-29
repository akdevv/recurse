---
lc: 125
title: "Valid Palindrome"
difficulty: "Easy"
patterns: ["two-pointers"]
lcTags: ["two-pointers", "string"]
entry: {"method": "isPalindrome", "params": [{"name": "s", "type": "string"}], "returns": "boolean"}
examples: ["\"A man, a plan, a canal: Panama\"", "\"race a car\"", "\" \""]
---

A phrase is a **palindrome** if, after converting all uppercase letters into lowercase letters and removing all non-alphanumeric characters, it reads the same forward and backward. Alphanumeric characters include letters and numbers.

Given a string `s`, return `true` *if it is a **palindrome**, or* `false` *otherwise*.

**Example 1:**

```
Input: s = "A man, a plan, a canal: Panama"
Output: true
Explanation: "amanaplanacanalpanama" is a palindrome.
```

**Example 2:**

```
Input: s = "race a car"
Output: false
Explanation: "raceacar" is not a palindrome.
```

**Example 3:**

```
Input: s = " "
Output: true
Explanation: s is an empty string "" after removing non-alphanumeric characters.
Since an empty string reads the same forward and backward, it is a palindrome.
```

**Constraints:**

- `1 <= s.length <= 2 * 10⁵`
- `s` consists only of printable ASCII characters.

# Starter

```python
class Solution:
    def isPalindrome(self, s: str) -> bool:
        
```

# Hints

1. Ignore everything that isn't a letter or digit, and compare case-insensitively.
2. Put one pointer at each end. Skip non-alphanumeric characters, compare lowercased characters, move both inward.

# Key points

- two pointers from both ends moving inward
- skip characters that aren't alphanumeric (`isalnum`), compare with `lower()`
- O(n) time, O(1) space; building a cleaned copy costs O(n) space

# Solution: clean-copy · Clean, then compare with the reverse · O(n) · O(n)

## Idea
Keep only letters and digits, lowercase them, and check the result reads the same backwards.

## Complexity
- **Time: O(n)**.
- **Space: O(n)** for the cleaned copy.

```python
class Solution:
    def isPalindrome(self, s: str) -> bool:
        t = [c.lower() for c in s if c.isalnum()]
        return t == t[::-1]
```

# Solution: two-pointers · Two pointers, skip in place · O(n) · O(1) · reference

## Idea
`l` starts at the front, `r` at the back. Move each past characters that don't count, then compare. Any mismatch → not a palindrome. When they meet, everything matched.

## Complexity
- **Time: O(n)**, each character is visited once.
- **Space: O(1)**.

```python
class Solution:
    def isPalindrome(self, s: str) -> bool:
        l, r = 0, len(s) - 1
        while l < r:
            if not s[l].isalnum():
                l += 1
            elif not s[r].isalnum():
                r -= 1
            elif s[l].lower() != s[r].lower():
                return False
            else:
                l += 1
                r -= 1
        return True
```

# Tests

```python
def edge():
    return [[" "], ["a"], [".,"], ["ab"], ["0P"], ["Aa"], ["race a car"], ["A man, a plan, a canal: Panama"]]

def random_case(rng):
    half = "".join(rng.choice("abAB1 ,") for _ in range(rng.randint(0, 5)))
    s = half + rng.choice(["", "x", ":"]) + half[::-1]
    if rng.random() < 0.4:
        s = "".join(rng.choice("abAB1 ,") for _ in range(rng.randint(1, 8)))
    return [s or "a"]

def perf(rng):
    half = "".join(rng.choice("abc, ") for _ in range(100000))
    return [[half + half[::-1]]]
```
