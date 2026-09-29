---
lc: 150
title: "Evaluate Reverse Polish Notation"
difficulty: "Medium"
patterns: ["stack"]
lcTags: ["array", "math", "stack"]
entry: {"method": "evalRPN", "params": [{"name": "tokens", "type": "string[]"}], "returns": "integer"}
examples: ["[\"2\",\"1\",\"+\",\"3\",\"*\"]", "[\"4\",\"13\",\"5\",\"/\",\"+\"]", "[\"10\",\"6\",\"9\",\"3\",\"+\",\"-11\",\"*\",\"/\",\"*\",\"17\",\"+\",\"5\",\"+\"]"]
---

You are given an array of strings `tokens` that represents an arithmetic expression in a [Reverse Polish Notation](http://en.wikipedia.org/wiki/Reverse_Polish_notation).

Evaluate the expression. Return *an integer that represents the value of the expression*.

**Note** that:

- The valid operators are `'+'`, `'-'`, `'*'`, and `'/'`.
- Each operand may be an integer or another expression.
- The division between two integers always **truncates toward zero**.
- There will not be any division by zero.
- The input represents a valid arithmetic expression in a reverse polish notation.
- The answer and all the intermediate calculations can be represented in a **32-bit** integer.

**Example 1:**

```
Input: tokens = ["2","1","+","3","*"]
Output: 9
Explanation: ((2 + 1) * 3) = 9
```

**Example 2:**

```
Input: tokens = ["4","13","5","/","+"]
Output: 6
Explanation: (4 + (13 / 5)) = 6
```

**Example 3:**

```
Input: tokens = ["10","6","9","3","+","-11","*","/","*","17","+","5","+"]
Output: 22
Explanation: ((10 * (6 / ((9 + 3) * -11))) + 17) + 5
= ((10 * (6 / (12 * -11))) + 17) + 5
= ((10 * (6 / -132)) + 17) + 5
= ((10 * 0) + 17) + 5
= (0 + 17) + 5
= 17 + 5
= 22
```

**Constraints:**

- `1 <= tokens.length <= 10⁴`
- `tokens[i]` is either an operator: `"+"`, `"-"`, `"*"`, or `"/"`, or an integer in the range `[-200, 200]`.

# Starter

```python
class Solution:
    def evalRPN(self, tokens: list[str]) -> int:
        
```

# Hints

1. In RPN an operator applies to the two most recent values.
2. Push numbers. On an operator, pop b then a, push a op b. Division truncates toward zero: use int(a / b).

# Key points

- stack of operands; operators pop two and push one
- order matters: the second pop is the left operand
- division truncates toward zero: int(a / b), not a // b
- O(n) time and space

# Solution: solution-1 · Stack with an operator table · O(n) · O(n) · reference

## Idea
Push numbers on a stack. For an operator, pop the right and left operands (right comes off first), apply it through a small operator table, push the result. `int(a / b)` truncates toward zero as required.

## Complexity
- **Time: O(n)**
- **Space: O(n)**

```python
import operator

class Solution:
    def evalRPN(self, tokens: List[str]) -> int:
        opt = {
            "+": operator.add,
            "-": operator.sub,
            "*": operator.mul,
            "/": operator.truediv,
        }
        s = []
        for token in tokens:
            if token in opt:
                s.append(int(opt[token](s.pop(-2), s.pop(-1))))
            else:
                s.append(int(token))
        return s[0]
```

# Solution: solution-2 · Stack, operators applied in place · O(n) · O(n)

## Idea
Same stack, but the operator is applied directly to the second-from-top value and the top is popped. Division uses `int(a / b)` to truncate toward zero.

## Complexity
- **Time: O(n)**
- **Space: O(n)**

```python
class Solution:
    def evalRPN(self, tokens: List[str]) -> int:
        nums = []
        for t in tokens:
            if len(t) > 1 or t.isdigit():
                nums.append(int(t))
            else:
                if t == "+":
                    nums[-2] += nums[-1]
                elif t == "-":
                    nums[-2] -= nums[-1]
                elif t == "*":
                    nums[-2] *= nums[-1]
                else:
                    nums[-2] = int(nums[-2] / nums[-1])
                nums.pop()
        return nums[0]
```

# Tests

```python
def expr(rng, depth):
    if depth == 0 or rng.random() < 0.3:
        v = rng.randint(-20, 20)
        return [str(v)], v
    lt, lv = expr(rng, depth - 1)
    rt, rv = expr(rng, depth - 1)
    op = rng.choice("+-*/" if rv != 0 else "+-*")
    val = {"+": lv + rv, "-": lv - rv, "*": lv * rv}.get(op) if op != "/" else int(lv / rv)
    return lt + rt + [op], val

def edge():
    return [[["5"]], [["2", "1", "+", "3", "*"]], [["4", "13", "5", "/", "+"]], [["-7", "2", "/"]],
            [["10", "6", "9", "3", "+", "-11", "*", "/", "*", "17", "+", "5", "+"]]]

def random_case(rng):
    return [expr(rng, 3)[0]]

def perf(rng):
    t = ["1"]
    for _ in range(4999):
        t += ["1", "+"]
    return [[t[:10000]] if len(t) > 10000 else [t]]
```
