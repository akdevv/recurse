---
lc: 1431
title: "Kids With the Greatest Number of Candies"
difficulty: "Easy"
patterns: ["simulation"]
lcTags: ["array"]
entry: {"method": "kidsWithCandies", "params": [{"name": "candies", "type": "integer[]"}, {"name": "extraCandies", "type": "integer"}], "returns": "list<boolean>"}
examples: ["[2,3,5,1,3]\n3", "[4,2,1,1,2]\n1", "[12,1,12]\n10"]
lcHints: ["For each kid check if candies[i] + extraCandies ≥ maximum in Candies[i]."]
---

There are `n` kids with candies. You are given an integer array `candies`, where each `candies[i]` represents the number of candies the `iᵗʰ` kid has, and an integer `extraCandies`, denoting the number of extra candies that you have.

Return *a boolean array* `result` *of length* `n`*, where* `result[i]` *is* `true` *if, after giving the* `iᵗʰ` *kid all the* `extraCandies`*, they will have the **greatest** number of candies among all the kids**, or* `false` *otherwise*.

Note that **multiple** kids can have the **greatest** number of candies.

**Example 1:**

```
Input: candies = [2,3,5,1,3], extraCandies = 3
Output: [true,true,true,false,true]
Explanation: If you give all extraCandies to:
- Kid 1, they will have 2 + 3 = 5 candies, which is the greatest among the kids.
- Kid 2, they will have 3 + 3 = 6 candies, which is the greatest among the kids.
- Kid 3, they will have 5 + 3 = 8 candies, which is the greatest among the kids.
- Kid 4, they will have 1 + 3 = 4 candies, which is not the greatest among the kids.
- Kid 5, they will have 3 + 3 = 6 candies, which is the greatest among the kids.
```

**Example 2:**

```
Input: candies = [4,2,1,1,2], extraCandies = 1
Output: [true,false,false,false,false]
Explanation: There is only 1 extra candy.
Kid 1 will always have the greatest number of candies, even if a different kid is given the extra candy.
```

**Example 3:**

```
Input: candies = [12,1,12], extraCandies = 10
Output: [true,false,true]
```

**Constraints:**

- `n == candies.length`
- `2 <= n <= 100`
- `1 <= candies[i] <= 100`
- `1 <= extraCandies <= 50`

# Starter

```python
class Solution:
    def kidsWithCandies(self, candies: list[int], extraCandies: int) -> list[bool]:
        
```

# Hints

1. Which single number does every kid get compared against?
2. Compute max(candies) once, then check candies[i] + extra >= max.

# Key points

- compute the max once, outside the loop
- calling max() inside the loop makes it O(n²)
- O(n) time

# Solution: brute · Recompute max per kid · O(n²) · O(1) extra

## Idea
For every kid, check whether their candies + extra reach the current maximum.

## The hidden cost
`max(candies)` is **inside** the loop, so it runs n times, and each call scans n elements → **O(n²)**. A classic "looks like O(n)" trap.

```python
class Solution:
    def kidsWithCandies(self, candies: List[int], extraCandies: int) -> List[bool]:
        return [c + extraCandies >= max(candies) for c in candies]
```

# Solution: max-once · Compute max once · O(n) · O(1) extra · reference

## Idea
The maximum doesn't change, so compute it once (O(n)), then one comparison per kid (O(n)).

## Complexity
- **Time: O(n)** (two passes).
- **Space: O(1) extra**

```python
class Solution:
    def kidsWithCandies(self, candies: List[int], extraCandies: int) -> List[bool]:
        most = max(candies)
        return [c + extraCandies >= most for c in candies]
```

# Tests

```python
def edge():
    return [[[1, 1], 0], [[5], 3], [[1, 100], 1]]

def random_case(rng):
    return [[rng.randint(1, 20) for _ in range(rng.randint(2, 10))], rng.randint(1, 10)]
```
