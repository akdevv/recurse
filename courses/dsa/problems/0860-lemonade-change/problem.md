---
lc: 860
title: "Lemonade Change"
difficulty: "Easy"
patterns: ["greedy"]
lcTags: ["array", "greedy"]
entry: {"method": "lemonadeChange", "params": [{"name": "bills", "type": "integer[]"}], "returns": "boolean"}
examples: ["[5,5,5,10,20]", "[5,5,10,10,20]"]
---

At a lemonade stand, each lemonade costs `$5`. Customers are standing in a queue to buy from you and order one at a time (in the order specified by bills). Each customer will only buy one lemonade and pay with either a `$5`, `$10`, or `$20` bill. You must provide the correct change to each customer so that the net transaction is that the customer pays `$5`.

Note that you do not have any change in hand at first.

Given an integer array `bills` where `bills[i]` is the bill the `iᵗʰ` customer pays, return `true` *if you can provide every customer with the correct change, or* `false` *otherwise*.

**Example 1:**

```
Input: bills = [5,5,5,10,20]
Output: true
Explanation:
From the first 3 customers, we collect three $5 bills in order.
From the fourth customer, we collect a $10 bill and give back a $5.
From the fifth customer, we give a $10 bill and a $5 bill.
Since all customers got correct change, we output true.
```

**Example 2:**

```
Input: bills = [5,5,10,10,20]
Output: false
Explanation:
From the first two customers in order, we collect two $5 bills.
For the next two customers in order, we collect a $10 bill and give back a $5 bill.
For the last customer, we can not give the change of $15 back because we only have two $10 bills.
Since not every customer received the correct change, the answer is false.
```

**Constraints:**

- `1 <= bills.length <= 10⁵`
- `bills[i]` is either `5`, `10`, or `20`.

# Starter

```python
class Solution:
    def lemonadeChange(self, bills: list[int]) -> bool:
        
```

# Hints

1. You only need to track how many $5 and $10 bills you have.
2. $5: keep it. $10: give back a $5. $20: prefer giving $10 + $5 (keep $5s, they're more useful), else three $5s. Fail if you can't.

# Key points

- count fives and tens
- for $20 prefer 10 + 5 over 5 + 5 + 5: fives are more flexible
- O(n) time, O(1) space

# Solution: solution-1 · Count $5 and $10 bills · O(n) · O(1) · reference

## Idea
Only $5 and $10 bills matter for change. A $10 needs a $5 back. A $20 needs $15: prefer one $10 and one $5, since $5 bills are more useful later. If a count goes negative, you couldn't give change.

## Complexity
- **Time: O(n)**
- **Space: O(1)**

```python
class Solution:
    def lemonadeChange(self, bills: List[int]) -> bool:
        five = ten = 0
        for v in bills:
            if v == 5:
                five += 1
            elif v == 10:
                ten += 1
                five -= 1
            else:
                if ten:
                    ten -= 1
                    five -= 1
                else:
                    five -= 3
            if five < 0:
                return False
        return True
```

# Tests

```python
def edge():
    return [[[5]], [[10]], [[5, 5, 5, 10, 20]], [[5, 5, 10, 10, 20]], [[5, 5, 5, 5, 20, 20]], [[5, 10, 5, 20]]]

def random_case(rng):
    return [[rng.choice([5, 5, 10, 20]) for _ in range(rng.randint(1, 10))]]

def perf(rng):
    return [[[5] * 50000 + [10, 20] * 25000]]
```
