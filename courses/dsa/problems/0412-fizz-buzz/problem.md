---
lc: 412
title: "Fizz Buzz"
difficulty: "Easy"
patterns: ["simulation"]
lcTags: ["math", "string", "simulation"]
entry: {"method": "fizzBuzz", "params": [{"name": "n", "type": "integer"}], "returns": "list<string>"}
examples: ["3", "5", "15"]
---

Given an integer `n`, return *a string array* `answer` *(**1-indexed**) where*:

- `answer[i] == "FizzBuzz"` if `i` is divisible by `3` and `5`.
- `answer[i] == "Fizz"` if `i` is divisible by `3`.
- `answer[i] == "Buzz"` if `i` is divisible by `5`.
- `answer[i] == i` (as a string) if none of the above conditions are true.

**Example 1:**

```
Input: n = 3
Output: ["1","2","Fizz"]
```

**Example 2:**

```
Input: n = 5
Output: ["1","2","Fizz","4","Buzz"]
```

**Example 3:**

```
Input: n = 15
Output: ["1","2","Fizz","4","Buzz","Fizz","7","8","Fizz","Buzz","11","Fizz","13","14","FizzBuzz"]
```

**Constraints:**

- `1 <= n <= 10⁴`

# Starter

```python
class Solution:
    def fizzBuzz(self, n: int) -> list[str]:
        
```

# Hints

1. Check the 'both' case before the single cases. What number is divisible by both 3 and 5?
2. Order matters: test i % 15 (or both conditions) first, then % 3, then % 5, else str(i).

# Key points

- loop 1..n and build a list
- check divisible-by-both first (15), otherwise it gets swallowed by the 3 or 5 case
- O(n) time, O(n) output space

# Solution: conditions · If / elif chain · O(n) · O(1) extra · reference

## Idea
Walk 1..n and decide each value with modulo checks. The **most specific case goes first**: a multiple of 15 is also a multiple of 3, so if `% 3` came first, "FizzBuzz" would never print.

## Complexity
- **Time: O(n)**, one constant-time decision per number.
- **Space: O(1) extra**; the output list itself is O(n) but that's required.

```python
class Solution:
    def fizzBuzz(self, n: int) -> List[str]:
        out = []
        for i in range(1, n + 1):
            if i % 15 == 0:
                out.append("FizzBuzz")
            elif i % 3 == 0:
                out.append("Fizz")
            elif i % 5 == 0:
                out.append("Buzz")
            else:
                out.append(str(i))
        return out
```

# Solution: concat · Build the word by concatenation · O(n) · O(1) extra

## Idea
Instead of a special "both" case, build the word piece by piece: add "Fizz" if divisible by 3, add "Buzz" if divisible by 5. Empty word → the number itself.

## Why interviewers like this one
It **scales**: adding "Jazz for 7" is one more `if`, whereas the if/elif chain needs every combination (15, 21, 35, 105…).

## Complexity
- **Time: O(n)**
- **Space: O(1) extra**

```python
class Solution:
    def fizzBuzz(self, n: int) -> List[str]:
        out = []
        for i in range(1, n + 1):
            word = ""
            if i % 3 == 0:
                word += "Fizz"
            if i % 5 == 0:
                word += "Buzz"
            out.append(word or str(i))
        return out
```

# Tests

```python
def edge():
    return [[1], [2], [15], [30]]

def random_case(rng):
    return [rng.randint(1, 200)]

def perf(rng):
    return [[10_000]]
```
