---
lc: 134
title: "Gas Station"
difficulty: "Medium"
patterns: ["greedy"]
lcTags: ["array", "greedy"]
entry: {"method": "canCompleteCircuit", "params": [{"name": "gas", "type": "integer[]"}, {"name": "cost", "type": "integer[]"}], "returns": "integer"}
examples: ["[1,2,3,4,5]\n[3,4,5,1,2]", "[2,3,4]\n[3,4,3]"]
---

There are `n` gas stations along a circular route, where the amount of gas at the `iᵗʰ` station is `gas[i]`.

You have a car with an unlimited gas tank and it costs `cost[i]` of gas to travel from the `iᵗʰ` station to its next `(i + 1)ᵗʰ` station. You begin the journey with an empty tank at one of the gas stations.

Given two integer arrays `gas` and `cost`, return *the starting gas station's index if you can travel around the circuit once in the clockwise direction, otherwise return* `-1`. If there exists a solution, it is **guaranteed** to be **unique**.

**Example 1:**

```
Input: gas = [1,2,3,4,5], cost = [3,4,5,1,2]
Output: 3
Explanation:
Start at station 3 (index 3) and fill up with 4 unit of gas. Your tank = 0 + 4 = 4
Travel to station 4. Your tank = 4 - 1 + 5 = 8
Travel to station 0. Your tank = 8 - 2 + 1 = 7
Travel to station 1. Your tank = 7 - 3 + 2 = 6
Travel to station 2. Your tank = 6 - 4 + 3 = 5
Travel to station 3. The cost is 5. Your gas is just enough to travel back to station 3.
Therefore, return 3 as the starting index.
```

**Example 2:**

```
Input: gas = [2,3,4], cost = [3,4,3]
Output: -1
Explanation:
You can't start at station 0 or 1, as there is not enough gas to travel to the next station.
Let's start at station 2 and fill up with 4 unit of gas. Your tank = 0 + 4 = 4
Travel to station 0. Your tank = 4 - 3 + 2 = 3
Travel to station 1. Your tank = 3 - 3 + 3 = 3
You cannot travel back to station 2, as it requires 4 unit of gas but you only have 3.
Therefore, you can't travel around the circuit once no matter where you start.
```

**Constraints:**

- `n == gas.length == cost.length`
- `1 <= n <= 10⁵`
- `0 <= gas[i], cost[i] <= 10⁴`
- The input is generated such that the answer is unique.

# Starter

```python
class Solution:
    def canCompleteCircuit(self, gas: list[int], cost: list[int]) -> int:
        
```

# Hints

1. If total gas < total cost, no start works. Otherwise exactly one does. Where?
2. Walk once with a running tank. When the tank goes negative at i, no station from the current start to i can be the start; restart at i + 1 with an empty tank.

# Key points

- total gas >= total cost ⇔ a solution exists
- a failed stretch rules out every start inside it → restart after it
- one pass, O(n) time, O(1) space

# Solution: solution-1 · Grow the circuit from both ends · O(n) · O(1) · reference

## Idea
Start at the last station and grow the covered stretch forward with j. Whenever the tank sum is negative, extend the start backwards with i (adding earlier stations) to pay for it. After covering all n stations, a non-negative sum means i is the answer.

## Complexity
- **Time: O(n)**
- **Space: O(1)**

```python
class Solution:
    def canCompleteCircuit(self, gas: List[int], cost: List[int]) -> int:
        n = len(gas)
        i = j = n - 1
        cnt = s = 0
        while cnt < n:
            s += gas[j] - cost[j]
            cnt += 1
            j = (j + 1) % n
            while s < 0 and cnt < n:
                i -= 1
                s += gas[i] - cost[i]
                cnt += 1
        return -1 if s < 0 else i
```

# Tests

```python
def solve(gas, cost):
    return [s for s in range(len(gas)) if all(sum(gas[(s + j) % len(gas)] - cost[(s + j) % len(gas)] for j in range(k + 1)) >= 0 for k in range(len(gas)))]

def edge():
    return [[[1, 2, 3, 4, 5], [3, 4, 5, 1, 2]], [[2, 3, 4], [3, 4, 3]], [[5], [4]], [[4], [5]], [[0, 0], [0, 1]]]

def random_case(rng):
    while True:
        n = rng.randint(1, 6)
        gas = [rng.randint(0, 5) for _ in range(n)]
        cost = [rng.randint(0, 5) for _ in range(n)]
        if len(solve(gas, cost)) <= 1:
            return [gas, cost]

def perf(rng):
    n = 100000
    return [[[1] * n, [1] * (n - 1) + [0]]]
```
