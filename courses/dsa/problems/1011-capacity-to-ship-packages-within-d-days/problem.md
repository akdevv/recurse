---
lc: 1011
title: "Capacity To Ship Packages Within D Days"
difficulty: "Medium"
patterns: ["binary-search-answer"]
lcTags: ["array", "binary-search"]
entry: {"method": "shipWithinDays", "params": [{"name": "weights", "type": "integer[]"}, {"name": "days", "type": "integer"}], "returns": "integer"}
examples: ["[1,2,3,4,5,6,7,8,9,10]\n5", "[3,2,2,4,1,4]\n3", "[1,2,3,1,1]\n4"]
lcHints: ["Binary search on the answer.  We need a function possible(capacity) which returns true if and only if we can do the task in D days."]
---

A conveyor belt has packages that must be shipped from one port to another within `days` days.

The `iᵗʰ` package on the conveyor belt has a weight of `weights[i]`. Each day, we load the ship with packages on the conveyor belt (in the order given by `weights`). We may not load more weight than the maximum weight capacity of the ship.

Return the least weight capacity of the ship that will result in all the packages on the conveyor belt being shipped within `days` days.

**Example 1:**

```
Input: weights = [1,2,3,4,5,6,7,8,9,10], days = 5
Output: 15
Explanation: A ship capacity of 15 is the minimum to ship all the packages in 5 days like this:
1st day: 1, 2, 3, 4, 5
2nd day: 6, 7
3rd day: 8
4th day: 9
5th day: 10

Note that the cargo must be shipped in the order given, so using a ship of capacity 14 and splitting the packages into parts like (2, 3, 4, 5), (1, 6, 7), (8), (9), (10) is not allowed.
```

**Example 2:**

```
Input: weights = [3,2,2,4,1,4], days = 3
Output: 6
Explanation: A ship capacity of 6 is the minimum to ship all the packages in 3 days like this:
1st day: 3, 2
2nd day: 2, 4
3rd day: 1, 4
```

**Example 3:**

```
Input: weights = [1,2,3,1,1], days = 4
Output: 3
Explanation:
1st day: 1
2nd day: 2
3rd day: 3
4th day: 1, 1
```

**Constraints:**

- `1 <= days <= weights.length <= 5 * 10⁴`
- `1 <= weights[i] <= 500`

# Starter

```python
class Solution:
    def shipWithinDays(self, weights: list[int], days: int) -> int:
        
```

# Hints

1. The capacity is at least the heaviest package and at most the total weight. More capacity never needs more days.
2. Binary search capacity in [max(w), sum(w)]. For a capacity, greedily fill each day in order and count days; feasible if days ≤ D.

# Key points

- search range: [max weight, total weight]
- feasibility check: greedy fill in order, start a new day when the next package doesn't fit
- find the smallest capacity that works
- O(n log(sum)) time

# Solution: solution-1 · Binary search on the capacity · O(n log(sum)) · O(1) · reference

## Idea
Binary search the capacity between the heaviest package and the total weight. `check(cap)` fills days greedily in order and counts them; the smallest capacity where the count fits within `days` is the answer.

## Complexity
- **Time: O(n log(sum))**
- **Space: O(1)**

```python
class Solution:
    def shipWithinDays(self, weights: List[int], days: int) -> int:
        def check(mx):
            ws, cnt = 0, 1
            for w in weights:
                ws += w
                if ws > mx:
                    cnt += 1
                    ws = w
            return cnt <= days

        left, right = max(weights), sum(weights) + 1
        return left + bisect_left(range(left, right), True, key=check)
```

# Tests

```python

```
