---
lc: 17
title: "Letter Combinations of a Phone Number"
difficulty: "Medium"
patterns: ["backtracking"]
lcTags: ["hash-table", "string", "backtracking"]
compare: "unordered"
entry: {"method": "letterCombinations", "params": [{"name": "digits", "type": "string"}], "returns": "list<string>"}
examples: ["\"23\"", "\"2\""]
---

Given a string containing digits from `2-9` inclusive, return all possible letter combinations that the number could represent. Return the answer in **any order**.

A mapping of digits to letters (just like on the telephone buttons) is given below. Note that 1 does not map to any letters.

![](https://assets.leetcode.com/uploads/2022/03/15/1200px-telephone-keypad2svg.png)

**Example 1:**

```
Input: digits = "23"
Output: ["ad","ae","af","bd","be","bf","cd","ce","cf"]
```

**Example 2:**

```
Input: digits = "2"
Output: ["a","b","c"]
```

**Constraints:**

- `1 <= digits.length <= 4`
- `digits[i]` is a digit in the range `['2', '9']`.

# Starter

```python
class Solution:
    def letterCombinations(self, digits: str) -> list[str]:
        
```

# Hints

1. Each digit adds one letter from its group. That's a tree with one level per digit.
2. Backtrack over the digits, appending each letter of the current digit. (Or iteratively: start with [""] and extend every string with every letter.)

# Key points

- map digits to letters
- one recursion level per digit; record when the string has len(digits) letters
- up to 4ⁿ results, O(n·4ⁿ) time

# Solution: traversal · Traversal · O(4ⁿ) · O(4ⁿ) · reference

First, we use an array or hash table to store the letters corresponding to each digit. Then we traverse each digit, combine its corresponding letters with the previous results to get the new results.

The time complexity is O(4ⁿ), and the space complexity is O(4ⁿ). Here, n is the length of the input digits.

```python
class Solution:
    def letterCombinations(self, digits: str) -> List[str]:
        if not digits:
            return []
        d = ["abc", "def", "ghi", "jkl", "mno", "pqrs", "tuv", "wxyz"]
        ans = [""]
        for i in digits:
            s = d[int(i) - 2]
            ans = [a + b for a in ans for b in s]
        return ans
```

# Solution: dfs · DFS · O(4ⁿ) · O(n)

We can use the method of depth-first search to enumerate all possible letter combinations. Suppose that a part of the letter combination has been generated, but some digits have not been exhausted. At this time, we take out the letters corresponding to the next digit, and then enumerate each letter corresponding to this digit one by one, add them to the letter combination that has been generated before, to form all possible combinations.

The time complexity is O(4ⁿ), and the space complexity is O(n). Here, n is the length of the input digits.

```python
class Solution:
    def letterCombinations(self, digits: str) -> List[str]:
        def dfs(i: int):
            if i >= len(digits):
                ans.append("".join(t))
                return
            for c in d[int(digits[i]) - 2]:
                t.append(c)
                dfs(i + 1)
                t.pop()

        if not digits:
            return []
        d = ["abc", "def", "ghi", "jkl", "mno", "pqrs", "tuv", "wxyz"]
        ans = []
        t = []
        dfs(0)
        return ans
```

# Tests

```python

```
