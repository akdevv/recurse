---
lc: 118
title: "Pascal's Triangle"
difficulty: "Easy"
patterns: ["dynamic-programming"]
lcTags: ["array", "dynamic-programming"]
entry: {"method": "generate", "params": [{"name": "numRows", "type": "integer"}], "returns": "list<list<integer>>"}
examples: ["5", "1"]
---

Given an integer `numRows`, return the first numRows of **Pascal's triangle**.

In **Pascal's triangle**, each number is the sum of the two numbers directly above it as shown:

![](https://upload.wikimedia.org/wikipedia/commons/0/0d/PascalTriangleAnimated2.gif)

**Example 1:**

```
Input: numRows = 5
Output: [[1],[1,1],[1,2,1],[1,3,3,1],[1,4,6,4,1]]
```

**Example 2:**

```
Input: numRows = 1
Output: [[1]]
```

**Constraints:**

- `1 <= numRows <= 30`

# Starter

```python
class Solution:
    def generate(self, numRows: int) -> list[list[int]]:
        
```

# Hints

1. Each row starts and ends with 1; every inner number is the sum of the two numbers above it.
2. row = [1]; for each next row: [1] + [prev[j] + prev[j + 1] for j in range(len(prev) − 1)] + [1].

# Key points

- build row by row from the previous row
- inner value = sum of the two above
- O(n²) time for n rows (that's the output size)

# Solution: simulation · Simulation · O(n²) · O(1) · reference

We first create an answer array f, then set the first row of f to `[1]`. Next, starting from the second row, the first and last elements of each row are 1, and for other elements `f[i][j] = f[i - 1][j - 1] + f[i - 1][j]`.

The time complexity is O(n²), where n is the given number of rows. Ignoring the space consumption of the answer, the space complexity is O(1).

```python
class Solution:
    def generate(self, numRows: int) -> List[List[int]]:
        f = [[1]]
        for i in range(numRows - 1):
            g = [1] + [a + b for a, b in pairwise(f[-1])] + [1]
            f.append(g)
        return f
```

# Tests

```python

```
