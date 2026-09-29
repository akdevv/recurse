---
lc: 1672
title: "Richest Customer Wealth"
difficulty: "Easy"
patterns: ["simulation"]
lcTags: ["array", "matrix"]
entry: {"method": "maximumWealth", "params": [{"name": "accounts", "type": "integer[][]"}], "returns": "integer"}
examples: ["[[1,2,3],[3,2,1]]", "[[1,5],[7,3],[3,5]]", "[[2,8,7],[7,1,3],[1,9,5]]"]
lcHints: ["Calculate the wealth of each customer", "Find the maximum element in array."]
---

You are given an `m x n` integer grid `accounts` where `accounts[i][j]` is the amount of money the `i​​​​​^(​​​​​​th)​​​​` customer has in the `j​​​​​^(​​​​​​th)`​​​​ bank. Return *the **wealth** that the richest customer has.*

A customer's **wealth** is the amount of money they have in all their bank accounts. The richest customer is the customer that has the maximum **wealth**.

**Example 1:**

```
Input: accounts = [[1,2,3],[3,2,1]]
Output: 6
Explanation:
1st customer has wealth = 1 + 2 + 3 = 6
2nd customer has wealth = 3 + 2 + 1 = 6
Both customers are considered the richest with a wealth of 6 each, so return 6.
```

**Example 2:**

```
Input: accounts = [[1,5],[7,3],[3,5]]
Output: 10
Explanation:
1st customer has wealth = 6
2nd customer has wealth = 10
3rd customer has wealth = 8
The 2nd customer is the richest with a wealth of 10.
```

**Example 3:**

```
Input: accounts = [[2,8,7],[7,1,3],[1,9,5]]
Output: 17
```

**Constraints:**

- `m == accounts.length`
- `n == accounts[i].length`
- `1 <= m, n <= 50`
- `1 <= accounts[i][j] <= 100`

# Starter

```python
class Solution:
    def maximumWealth(self, accounts: list[list[int]]) -> int:
        
```

# Hints

1. Each row is one customer. What's one customer's wealth?
2. Sum each row, keep the max. `max(sum(row) for row in accounts)`.

# Key points

- row = customer, sum a row = wealth
- track the maximum while iterating
- O(m·n) time: every cell is read once

# Solution: loops · Nested loops · O(m·n) · O(1) · reference

## Idea
Each row is a customer. Add up the row, compare with the best so far.

## Complexity
- **Time: O(m·n)**: m customers × n banks, each cell read once. You can't do better: every cell could change the answer.
- **Space: O(1)**

```python
class Solution:
    def maximumWealth(self, accounts: List[List[int]]) -> int:
        best = 0
        for customer in accounts:
            wealth = 0
            for money in customer:
                wealth += money
            best = max(best, wealth)
        return best
```

# Solution: pythonic · One-liner with built-ins · O(m·n) · O(1)

## Idea
Same algorithm, Python built-ins. `sum` and `max` over a **generator** (no brackets) don't build an intermediate list.

## Interview note
Fine to write, but be ready to say what it costs: it's still O(m·n).

```python
class Solution:
    def maximumWealth(self, accounts: List[List[int]]) -> int:
        return max(sum(row) for row in accounts)
```

# Tests

```python
def edge():
    return [[[[1]]], [[[100] * 50] * 50], [[[1, 1], [2]]]]

def random_case(rng):
    m, n = rng.randint(1, 6), rng.randint(1, 6)
    return [[[rng.randint(1, 100) for _ in range(n)] for _ in range(m)]]
```
