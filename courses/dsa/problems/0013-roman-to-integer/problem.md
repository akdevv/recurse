---
lc: 13
title: "Roman to Integer"
difficulty: "Easy"
patterns: ["hash-map"]
lcTags: ["hash-table", "math", "string"]
entry: {"method": "romanToInt", "params": [{"name": "s", "type": "string"}], "returns": "integer"}
examples: ["\"III\"", "\"LVIII\"", "\"MCMXCIV\""]
lcHints: ["Problem is simpler to solve by working the string from back to front and using a map."]
---

Roman numerals are represented by seven different symbols: `I`, `V`, `X`, `L`, `C`, `D` and `M`.

```
Symbol       Value
I             1
V             5
X             10
L             50
C             100
D             500
M             1000
```

For example, `2` is written as `II` in Roman numeral, just two ones added together. `12` is written as `XII`, which is simply `X + II`. The number `27` is written as `XXVII`, which is `XX + V + II`.

Roman numerals are usually written largest to smallest from left to right. However, the numeral for four is not `IIII`. Instead, the number four is written as `IV`. Because the one is before the five we subtract it making four. The same principle applies to the number nine, which is written as `IX`. There are six instances where subtraction is used:

- `I` can be placed before `V` (5) and `X` (10) to make 4 and 9.
- `X` can be placed before `L` (50) and `C` (100) to make 40 and 90.
- `C` can be placed before `D` (500) and `M` (1000) to make 400 and 900.

Given a roman numeral, convert it to an integer.

**Example 1:**

```
Input: s = "III"
Output: 3
Explanation: III = 3.
```

**Example 2:**

```
Input: s = "LVIII"
Output: 58
Explanation: L = 50, V= 5, III = 3.
```

**Example 3:**

```
Input: s = "MCMXCIV"
Output: 1994
Explanation: M = 1000, CM = 900, XC = 90 and IV = 4.
```

**Constraints:**

- `1 <= s.length <= 15`
- `s` contains only the characters `('I', 'V', 'X', 'L', 'C', 'D', 'M')`.
- It is **guaranteed** that `s` is a valid roman numeral in the range `[1, 3999]`.

# Starter

```python
class Solution:
    def romanToInt(self, s: str) -> int:
        
```

# Hints

1. Map each symbol to its value. When is a symbol subtracted instead of added?
2. If a symbol is smaller than the one right after it (IV, XC, CM), subtract it; otherwise add it.

# Key points

- a dict maps each symbol to its value in O(1)
- a symbol smaller than its right neighbour is subtracted, otherwise added
- one pass, O(n) time and O(1) space (the map has 7 fixed entries)

# Solution: replace-pairs · Expand the subtractive pairs first · O(n) · O(n)

## Idea
There are only six subtractive pairs. Rewrite each one in the long additive form (`IV` → `IIII`), then just add up the symbols.

## Complexity
- **Time: O(n)**, six replaces plus one sum.
- **Space: O(n)** for the rewritten strings.

Clever, but it only works because Roman numerals have a tiny fixed set of special cases.

```python
class Solution:
    def romanToInt(self, s: str) -> int:
        for pair, spelled in (("IV", "IIII"), ("IX", "VIIII"), ("XL", "XXXX"),
                              ("XC", "LXXXX"), ("CD", "CCCC"), ("CM", "DCCCC")):
            s = s.replace(pair, spelled)
        value = {"I": 1, "V": 5, "X": 10, "L": 50, "C": 100, "D": 500, "M": 1000}
        return sum(value[c] for c in s)
```

# Solution: subtract-rule · Add, or subtract when smaller than the next · O(n) · O(1) · reference

## Idea
Roman numerals are written largest to smallest. A symbol that's **smaller than the one after it** breaks that order, and that's exactly when it counts negatively.

`MCMXCIV` → M(+1000) C(−100, C < M) M(+1000) X(−10) C(+100) I(−1) V(+5) = 1994

## Complexity
- **Time: O(n)**.
- **Space: O(1)**: the dict has 7 fixed entries.

```python
class Solution:
    def romanToInt(self, s: str) -> int:
        value = {"I": 1, "V": 5, "X": 10, "L": 50, "C": 100, "D": 500, "M": 1000}
        total = 0
        for i, c in enumerate(s):
            v = value[c]
            if i + 1 < len(s) and v < value[s[i + 1]]:
                total -= v
            else:
                total += v
        return total
```

# Tests

```python
VALS = [(1000, "M"), (900, "CM"), (500, "D"), (400, "CD"), (100, "C"), (90, "XC"),
        (50, "L"), (40, "XL"), (10, "X"), (9, "IX"), (5, "V"), (4, "IV"), (1, "I")]

def roman(n):
    out = []
    for v, sym in VALS:
        while n >= v:
            out.append(sym)
            n -= v
    return "".join(out)

def edge():
    return [["III"], ["LVIII"], ["MCMXCIV"], ["I"], ["IV"], ["IX"], ["XL"], ["CD"], ["MMMCMXCIX"], ["DCCCXC"]]

def random_case(rng):
    return [roman(rng.randint(1, 3999))]

def perf(rng):
    return []
```
