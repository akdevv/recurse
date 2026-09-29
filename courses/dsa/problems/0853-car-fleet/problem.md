---
lc: 853
title: "Car Fleet"
difficulty: "Medium"
patterns: ["monotonic-stack"]
lcTags: ["array", "stack", "sorting", "monotonic-stack"]
entry: {"method": "carFleet", "params": [{"name": "target", "type": "integer"}, {"name": "position", "type": "integer[]"}, {"name": "speed", "type": "integer[]"}], "returns": "integer"}
examples: ["12\n[10,8,0,5,3]\n[2,4,1,1,3]", "10\n[3]\n[3]", "100\n[0,2,4]\n[4,2,1]"]
---

There are `n` cars at given miles away from the starting mile 0, traveling to reach the mile `target`.

You are given two integer arrays `position` and `speed`, both of length `n`, where `position[i]` is the starting mile of the `iᵗʰ` car and `speed[i]` is the speed of the `iᵗʰ` car in miles per hour.

A car cannot pass another car, but it can catch up and then travel next to it at the speed of the slower car.

A **car fleet** is a single car or a group of cars driving next to each other. The speed of the car fleet is the **minimum** speed of any car in the fleet.

If a car catches up to a car fleet at the mile `target`, it will still be considered as part of the car fleet.

Return the number of car fleets that will arrive at the destination.

**Example 1:**

**Input:** target = 12, position = [10,8,0,5,3], speed = [2,4,1,1,3]

**Output:** 3

**Explanation:**

- The cars starting at 10 (speed 2) and 8 (speed 4) become a fleet, meeting each other at 12. The fleet forms at `target`.
- The car starting at 0 (speed 1) does not catch up to any other car, so it is a fleet by itself.
- The cars starting at 5 (speed 1) and 3 (speed 3) become a fleet, meeting each other at 6. The fleet moves at speed 1 until it reaches `target`.

**Example 2:**

**Input:** target = 10, position = [3], speed = [3]

**Output:** 1

**Explanation:**

There is only one car, hence there is only one fleet.

**Example 3:**

**Input:** target = 100, position = [0,2,4], speed = [4,2,1]

**Output:** 1

**Explanation:**

- The cars starting at 0 (speed 4) and 2 (speed 2) become a fleet, meeting each other at 4. The car starting at 4 (speed 1) travels to 5.
- Then, the fleet at 4 (speed 2) and the car at position 5 (speed 1) become one fleet, meeting each other at 6. The fleet moves at speed 1 until it reaches `target`.

**Constraints:**

- `n == position.length == speed.length`
- `1 <= n <= 10⁵`
- `0 < target <= 10⁶`
- `0 <= position[i] < target`
- All the values of `position` are **unique**.
- `0 < speed[i] <= 10⁶`

# Starter

```python
class Solution:
    def carFleet(self, target: int, position: list[int], speed: list[int]) -> int:
        
```

# Hints

1. Sort cars by position, closest to the target first. For each car compute the time it needs to reach the target alone.
2. Walk from the car nearest the target backwards. A car that would arrive no later than the fleet ahead joins it; a car that would arrive later starts a new fleet.

# Key points

- sort by position descending, time = (target - pos) / speed
- a car can't pass the fleet ahead: if its time <= that fleet's time, it merges
- count how many times a strictly slower (later) time appears
- O(n log n) for the sort

# Solution: solution-1 · Sort by position, compare arrival times · O(n log n) · O(n) · reference

## Idea
Sort cars by position and walk from the one closest to the target. Compute each car's arrival time alone. A car that arrives later than the fleet in front can't catch it, so it starts a new fleet; otherwise it merges into that fleet.

## Complexity
- **Time: O(n log n)**
- **Space: O(n)**

```python
class Solution:
    def carFleet(self, target: int, position: List[int], speed: List[int]) -> int:
        idx = sorted(range(len(position)), key=lambda i: position[i])
        ans = pre = 0
        for i in idx[::-1]:
            t = (target - position[i]) / speed[i]
            if t > pre:
                ans += 1
                pre = t
        return ans
```

# Tests

```python
def edge():
    return [[10, [3], [3]], [12, [10, 8, 0, 5, 3], [2, 4, 1, 1, 3]], [100, [0, 2, 4], [4, 2, 1]], [10, [0, 4, 2], [2, 1, 3]], [10, [6, 8], [3, 2]]]

def random_case(rng):
    target = rng.randint(2, 30)
    n = rng.randint(1, min(8, target))
    return [target, rng.sample(range(target), n), [rng.randint(1, 5) for _ in range(n)]]

def perf(rng):
    return [[10**6, rng.sample(range(10**6), 100000), [rng.randint(1, 10**6) for _ in range(100000)]]]
```
