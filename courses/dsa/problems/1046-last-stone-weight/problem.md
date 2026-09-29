---
lc: 1046
title: "Last Stone Weight"
difficulty: "Easy"
patterns: ["top-k-heap"]
lcTags: ["array", "heap-priority-queue"]
entry: {"method": "lastStoneWeight", "params": [{"name": "stones", "type": "integer[]"}], "returns": "integer"}
examples: ["[2,7,4,1,8,1]", "[1]"]
lcHints: ["Simulate the process.  We can do it with a heap, or by sorting some list of stones every time we take a turn."]
---

You are given an array of integers `stones` where `stones[i]` is the weight of the `iᵗʰ` stone.

We are playing a game with the stones. On each turn, we choose the **heaviest two stones** and smash them together. Suppose the heaviest two stones have weights `x` and `y` with `x <= y`. The result of this smash is:

- If `x == y`, both stones are destroyed, and
- If `x != y`, the stone of weight `x` is destroyed, and the stone of weight `y` has new weight `y - x`.

At the end of the game, there is **at most one** stone left.

Return *the weight of the last remaining stone*. If there are no stones left, return `0`.

**Example 1:**

```
Input: stones = [2,7,4,1,8,1]
Output: 1
Explanation:
We combine 7 and 8 to get 1 so the array converts to [2,4,1,1,1] then,
we combine 2 and 4 to get 2 so the array converts to [2,1,1,1] then,
we combine 2 and 1 to get 1 so the array converts to [1,1,1] then,
we combine 1 and 1 to get 0 so the array converts to [1] then that's the value of the last stone.
```

**Example 2:**

```
Input: stones = [1]
Output: 1
```

**Constraints:**

- `1 <= stones.length <= 30`
- `1 <= stones[i] <= 1000`

# Starter

```python
class Solution:
    def lastStoneWeight(self, stones: list[int]) -> int:
        
```

# Hints

1. Every turn you need the two heaviest stones. Which structure gives you the largest element quickly, over and over?
2. Use a max-heap (push negated values into heapq). Pop two, push back their difference if it's non-zero. Return the last stone or 0.

# Key points

- max-heap via negated values in heapq
- each turn: pop two, push the difference if > 0
- O(n log n) time

# Solution: solution-1 · Max-heap · O(n log n) · O(n) · reference

## Idea
Keep the stones in a max-heap (negated values in Python's min-heap). Pop the two heaviest; if they differ, push back the difference. The last stone left (or 0) is the answer.

## Complexity
- **Time: O(n log n)**
- **Space: O(n)**

```python
class Solution:
    def lastStoneWeight(self, stones: List[int]) -> int:
        h = [-x for x in stones]
        heapify(h)
        while len(h) > 1:
            y, x = -heappop(h), -heappop(h)
            if x != y:
                heappush(h, x - y)
        return 0 if not h else -h[0]
```

# Tests

```python

```
