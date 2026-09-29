---
lc: 682
title: "Baseball Game"
difficulty: "Easy"
patterns: ["stack"]
lcTags: ["array", "stack", "simulation"]
entry: {"method": "calPoints", "params": [{"name": "operations", "type": "string[]"}], "returns": "integer"}
examples: ["[\"5\",\"2\",\"C\",\"D\",\"+\"]", "[\"5\",\"-2\",\"4\",\"C\",\"D\",\"9\",\"+\",\"+\"]", "[\"1\",\"C\"]"]
---

You are keeping the scores for a baseball game with strange rules. At the beginning of the game, you start with an empty record.

You are given a list of strings `operations`, where `operations[i]` is the `iᵗʰ` operation you must apply to the record and is one of the following:

- An integer `x`.

  - Record a new score of `x`.

- `'+'`.

  - Record a new score that is the sum of the previous two scores.

- `'D'`.

  - Record a new score that is the double of the previous score.

- `'C'`.

  - Invalidate the previous score, removing it from the record.

Return *the sum of all the scores on the record after applying all the operations*.

The test cases are generated such that the answer and all intermediate calculations fit in a **32-bit** integer and that all operations are valid.

**Example 1:**

```
Input: ops = ["5","2","C","D","+"]
Output: 30
Explanation:
"5" - Add 5 to the record, record is now [5].
"2" - Add 2 to the record, record is now [5, 2].
"C" - Invalidate and remove the previous score, record is now [5].
"D" - Add 2 * 5 = 10 to the record, record is now [5, 10].
"+" - Add 5 + 10 = 15 to the record, record is now [5, 10, 15].
The total sum is 5 + 10 + 15 = 30.
```

**Example 2:**

```
Input: ops = ["5","-2","4","C","D","9","+","+"]
Output: 27
Explanation:
"5" - Add 5 to the record, record is now [5].
"-2" - Add -2 to the record, record is now [5, -2].
"4" - Add 4 to the record, record is now [5, -2, 4].
"C" - Invalidate and remove the previous score, record is now [5, -2].
"D" - Add 2 * -2 = -4 to the record, record is now [5, -2, -4].
"9" - Add 9 to the record, record is now [5, -2, -4, 9].
"+" - Add -4 + 9 = 5 to the record, record is now [5, -2, -4, 9, 5].
"+" - Add 9 + 5 = 14 to the record, record is now [5, -2, -4, 9, 5, 14].
The total sum is 5 + -2 + -4 + 9 + 5 + 14 = 27.
```

**Example 3:**

```
Input: ops = ["1","C"]
Output: 0
Explanation:
"1" - Add 1 to the record, record is now [1].
"C" - Invalidate and remove the previous score, record is now [].
Since the record is empty, the total sum is 0.
```

**Constraints:**

- `1 <= operations.length <= 1000`
- `operations[i]` is `"C"`, `"D"`, `"+"`, or a string representing an integer in the range `[-3 * 10⁴, 3 * 10⁴]`.
- For operation `"+"`, there will always be at least two previous scores on the record.
- For operations `"C"` and `"D"`, there will always be at least one previous score on the record.

# Starter

```python
class Solution:
    def calPoints(self, operations: list[str]) -> int:
        
```

# Hints

1. Each operation only looks at the most recent valid scores.
2. Use a list as a stack: number → push, "+" → push sum of last two, "D" → push double the last, "C" → pop. Return the sum.

# Key points

- stack of valid scores; every op touches only the top one or two
- O(n) time and space

# Solution: stack-simulation · Stack + Simulation · O(n) · O(n) · reference

We can use a stack to simulate this process.

Traverse operations, for each operation:

- If it is `+`, add the top two elements of the stack and push the result onto the stack;
- If it is `D`, multiply the top element of the stack by 2 and push the result onto the stack;
- If it is `C`, pop the top element of the stack;
- If it is a number, push the number onto the stack.

Finally, sum all the elements in the stack to get the answer.

The time complexity is O(n), and the space complexity is O(n). Here, n is the length of operations.

```python
class Solution:
    def calPoints(self, operations: List[str]) -> int:
        stk = []
        for op in operations:
            if op == "+":
                stk.append(stk[-1] + stk[-2])
            elif op == "D":
                stk.append(stk[-1] << 1)
            elif op == "C":
                stk.pop()
            else:
                stk.append(int(op))
        return sum(stk)
```

# Tests

```python
def edge():
    return [[["1"]], [["5", "2", "C", "D", "+"]], [["5", "-2", "4", "C", "D", "9", "+", "+"]], [["1", "C"]]]

def random_case(rng):
    ops, size = [], 0
    for _ in range(rng.randint(1, 12)):
        choices = ["num"] + (["C", "D"] if size >= 1 else []) + (["+"] if size >= 2 else [])
        op = rng.choice(choices)
        if op == "num":
            ops.append(str(rng.randint(-30, 30))); size += 1
        else:
            ops.append(op); size += -1 if op == "C" else 1
    return [ops]
```
