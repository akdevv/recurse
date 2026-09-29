---
lc: 67
title: "Add Binary"
difficulty: "Easy"
patterns: ["bit-manipulation", "digit-math"]
lcTags: ["math", "string", "bit-manipulation", "simulation"]
entry: {"method": "addBinary", "params": [{"name": "a", "type": "string"}, {"name": "b", "type": "string"}], "returns": "string"}
examples: ["\"11\"\n\"1\"", "\"1010\"\n\"1011\""]
---

Given two binary strings `a` and `b`, return *their sum as a binary string*.

**Example 1:**

```
Input: a = "11", b = "1"
Output: "100"
```

**Example 2:**

```
Input: a = "1010", b = "1011"
Output: "10101"
```

**Constraints:**

- `1 <= a.length, b.length <= 10⁴`
- `a` and `b` consist only of `'0'` or `'1'` characters.
- Each string does not contain leading zeros except for the zero itself.

# Starter

```python
class Solution:
    def addBinary(self, a: str, b: str) -> str:
        
```

# Hints

1. Add from the right like on paper, carrying 1 when the column sum is 2 or 3.
2. i, j at the ends, carry = 0. While i ≥ 0 or j ≥ 0 or carry: total = carry + bits; append total % 2; carry = total // 2. Reverse at the end.

# Key points

- column addition from the least significant bit
- digit = total % 2, carry = total // 2
- build in a list and reverse/join once
- O(max(m, n)) time

# Solution: simulation · Simulation · O(max(m, n)) · O(1) · reference

We use a variable carry to record the current carry, and two pointers i and j to point to the end of a and b respectively, and add them bit by bit from the end to the beginning.

The time complexity is O(max(m, n)), where m and n are the lengths of strings a and b respectively. The space complexity is O(1).

```python
class Solution:
    def addBinary(self, a: str, b: str) -> str:
        ans = []
        i, j, carry = len(a) - 1, len(b) - 1, 0
        while i >= 0 or j >= 0 or carry:
            carry += (0 if i < 0 else int(a[i])) + (0 if j < 0 else int(b[j]))
            carry, v = divmod(carry, 2)
            ans.append(str(v))
            i, j = i - 1, j - 1
        return "".join(ans[::-1])
```

# Tests

```python
def num(rng, k):
    if k == 1:
        return rng.choice("01")
    return "1" + "".join(rng.choice("01") for _ in range(k - 1))

def edge():
    return [["0", "0"], ["11", "1"], ["1010", "1011"], ["1", "111"], ["0", "1"]]

def random_case(rng):
    return [num(rng, rng.randint(1, 8)), num(rng, rng.randint(1, 8))]

def perf(rng):
    return [[num(rng, 10000), num(rng, 10000)]]
```
