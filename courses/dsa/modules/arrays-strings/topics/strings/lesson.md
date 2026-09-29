## Core idea

**A string is an array of characters that you can't change.** Reading `s[i]` is O(1) like any array, but every "change" builds a brand-new string. Good string code collects pieces in a list and joins once.

## Intuition

A Python string is like a printed page. You can read any letter instantly, but you can't erase one: to "edit" it you reprint the whole page. Reprinting once at the end is fine. Reprinting after every single edit (`s += c` in a loop) is how an O(n) idea quietly becomes O(n²).

The other half of string problems is **parsing**: walking through characters one at a time and deciding what each one means, like a tiny state machine.

## Visualization

Parsing a number character by character: skip spaces, read an optional sign, then build the value with `num = num × 10 + digit`.

```viz
atoi
```

## Template code

```python
# Build strings with a list + join, never += in a loop
parts = []
for word in words:
    parts.append(word.upper())
result = " ".join(parts)          # O(total length), once

# Characters ↔ numbers
ord("a")                          # 97
chr(97)                           # "a"
ord(c) - ord("0")                 # digit value of c
ord(c) - ord("a")                 # 0..25, index for a 26-slot count array

# Counting characters
from collections import Counter
Counter("banana")                 # {'a': 3, 'n': 2, 'b': 1}
counts = [0] * 26
for c in s:
    counts[ord(c) - ord("a")] += 1

# Splitting / cleaning
s.split()                         # splits on ANY whitespace, drops empties
s.split(" ")                      # splits on single spaces, KEEPS empties
s.strip()                         # remove leading/trailing whitespace
s[::-1]                           # reversed copy
c.isdigit(), c.isalpha(), c.isalnum(), c.lower()

# Scan with an index when you need to look ahead
i = 0
while i < len(s) and s[i] == " ":
    i += 1
```

## Complexity

| Operation | Cost |
|---|---|
| `s[i]`, `len(s)` | O(1) |
| `s + t`, slicing `s[a:b]` | O(len of result), a new string |
| `s += c` inside a loop of n | **O(n²)** total |
| `"".join(parts)` | O(total length), once |
| `c in s`, `s.find(t)` | O(n) (roughly O(n·m) for substrings) |
| `s.split()`, `s[::-1]`, `sorted(s)` | O(n), O(n), O(n log n) |

For lowercase letters, a **26-slot count array** is O(1) space: the size doesn't grow with n.

## When to use it

- **Building output piece by piece** → list + `"".join`
- **"Parse", "convert", "validate"** → scan with an index, one phase at a time
- **Symbol → value lookups** (Roman numerals, keypads) → a small dict
- **"Anagram", "count letters"** → `Counter` or a 26-slot array
- **Word-level work** → `split()` first, then handle the words
- **Comparing strings position by position** → a vertical scan (Longest Common Prefix)

## Common traps

- `s += c` in a loop: hidden O(n²)
- `split(" ")` vs `split()`: repeated spaces produce empty strings with the first one
- Forgetting the empty string, a single character, or all spaces
- Index out of range when looking ahead (`s[i + 1]`): check `i + 1 < len(s)` first
- Uppercase vs lowercase: `'A' != 'a'`; normalise with `.lower()` if the problem says case doesn't matter
- In other languages, parsing numbers can overflow; say out loud where you'd clamp
