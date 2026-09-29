---
lc: 844
title: "Backspace String Compare"
difficulty: "Easy"
patterns: ["two-pointers", "stack"]
lcTags: ["two-pointers", "string", "stack", "simulation"]
entry: {"method": "backspaceCompare", "params": [{"name": "s", "type": "string"}, {"name": "t", "type": "string"}], "returns": "boolean"}
examples: ["\"ab#c\"\n\"ad#c\"", "\"ab##\"\n\"c#d#\"", "\"a#c\"\n\"b\""]
---

Given two strings `s` and `t`, return `true` *if they are equal when both are typed into empty text editors*. `'#'` means a backspace character.

Note that after backspacing an empty text, the text will continue empty.

**Example 1:**

```
Input: s = "ab#c", t = "ad#c"
Output: true
Explanation: Both s and t become "ac".
```

**Example 2:**

```
Input: s = "ab##", t = "c#d#"
Output: true
Explanation: Both s and t become "".
```

**Example 3:**

```
Input: s = "a#c", t = "b"
Output: false
Explanation: s becomes "c" while t becomes "b".
```

**Constraints:**

- `1 <= s.length, t.length <= 200`
- `s` and `t` only contain lowercase letters and `'#'` characters.

**Follow up:** Can you solve it in `O(n)` time and `O(1)` space?

# Starter

```python
class Solution:
    def backspaceCompare(self, s: str, t: str) -> bool:
        
```

# Hints

1. Build the final text of each string: a letter is typed, '#' deletes the last typed letter (if any).
2. Use a list as a stack: append letters, pop on '#'. Compare the two results. For O(1) space, walk both strings backwards counting pending backspaces.

# Key points

- a stack models typing: push letters, pop on '#'
- '#' on empty text does nothing
- O(n) time, O(n) space; walking backwards with skip counters gets O(1) space

# Solution: stack · Build both strings with a stack · O(n) · O(n) · reference

## Idea
Simulate the typing. A list works as a stack: append a letter, pop on `#` if there's something to delete.

## Complexity
- **Time: O(n + m)**.
- **Space: O(n + m)**.

```python
class Solution:
    def backspaceCompare(self, s: str, t: str) -> bool:
        def build(x):
            out = []
            for c in x:
                if c != "#":
                    out.append(c)
                elif out:
                    out.pop()
            return out
        return build(s) == build(t)
```

# Solution: backwards · Walk backwards with skip counters · O(n) · O(1)

## Idea
From the end, a `#` means "skip the next letter to the left". Each pointer jumps to the next letter that survives, then we compare those letters. Both run out at the same time → equal.

## Complexity
- **Time: O(n + m)**.
- **Space: O(1)**.

```python
class Solution:
    def backspaceCompare(self, s: str, t: str) -> bool:
        def next_kept(x, i):
            skip = 0
            while i >= 0:
                if x[i] == "#":
                    skip += 1
                elif skip:
                    skip -= 1
                else:
                    break
                i -= 1
            return i

        i, j = len(s) - 1, len(t) - 1
        while True:
            i, j = next_kept(s, i), next_kept(t, j)
            if i < 0 or j < 0:
                return i < 0 and j < 0
            if s[i] != t[j]:
                return False
            i -= 1
            j -= 1
```

# Tests

```python
def edge():
    return [["a", "a"], ["#", "a#"], ["ab##", "c#d#"], ["a#c", "b"], ["a##c", "#a#c"], ["xywrrmp", "xywrrmu#p"], ["bxj##tw", "bxo#j##tw"]]

def random_case(rng):
    return ["".join(rng.choice("ab##") for _ in range(rng.randint(1, 8))),
            "".join(rng.choice("ab##") for _ in range(rng.randint(1, 8)))]
```
