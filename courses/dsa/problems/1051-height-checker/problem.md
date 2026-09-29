---
lc: 1051
title: "Height Checker"
difficulty: "Easy"
patterns: ["simulation"]
lcTags: ["array", "sorting", "counting-sort", "bubble-sort"]
entry: {"method": "heightChecker", "params": [{"name": "heights", "type": "integer[]"}], "returns": "integer"}
examples: ["[1,1,4,2,1,3]", "[5,1,2,3,4]", "[1,2,3,4,5]"]
lcHints: ["Build the correct order of heights by sorting another array, then compare the two arrays."]
---

A school is trying to take an annual photo of all the students. The students are asked to stand in a single file line in **non-decreasing order** by height. Let this ordering be represented by the integer array `expected` where `expected[i]` is the expected height of the `iᵗʰ` student in line.

You are given an integer array `heights` representing the **current order** that the students are standing in. Each `heights[i]` is the height of the `iᵗʰ` student in line (**0-indexed**).

Return *the **number of indices** where* `heights[i] != expected[i]`.

**Example 1:**

```
Input: heights = [1,1,4,2,1,3]
Output: 3
Explanation:
heights:  [1,1,4,2,1,3]
expected: [1,1,1,2,3,4]
Indices 2, 4, and 5 do not match.
```

**Example 2:**

```
Input: heights = [5,1,2,3,4]
Output: 5
Explanation:
heights:  [5,1,2,3,4]
expected: [1,2,3,4,5]
All indices do not match.
```

**Example 3:**

```
Input: heights = [1,2,3,4,5]
Output: 0
Explanation:
heights:  [1,2,3,4,5]
expected: [1,2,3,4,5]
All indices match.
```

**Constraints:**

- `1 <= heights.length <= 100`
- `1 <= heights[i] <= 100`

# Starter

```python
class Solution:
    def heightChecker(self, heights: list[int]) -> int:
        
```

# Hints

1. What would the line look like if everyone stood in the right order?
2. Sort a copy and count positions where the two lists differ. Heights are ≤ 100, so counting sort also works.

# Key points

- expected order = sorted copy
- count indices where heights[i] != expected[i]
- O(n log n) with sort, O(n + 100) with counting sort

# Solution: sorting · Sorting · O(n × log n) · O(n) · reference

We can first sort the heights of the students, then compare the sorted heights with the original heights, and count the positions that are different.

The time complexity is O(n × log n), and the space complexity is O(n). Where n is the number of students.

```python
class Solution:
    def heightChecker(self, heights: List[int]) -> int:
        expected = sorted(heights)
        return sum(a != b for a, b in zip(heights, expected))
```

# Solution: counting-sort · Counting Sort · O(n + M) · O(M)

Since the height of the students in the problem does not exceed 100, we can use counting sort. Here we use an array cnt of length 101 to count the number of times each height h_i appears.

The time complexity is O(n + M), and the space complexity is O(M). Where n is the number of students, and M is the maximum height of the students. In this problem, `M = 101`.

```python
class Solution:
    def heightChecker(self, heights: List[int]) -> int:
        cnt = [0] * 101
        for h in heights:
            cnt[h] += 1
        ans = i = 0
        for j in range(1, 101):
            while cnt[j]:
                cnt[j] -= 1
                if heights[i] != j:
                    ans += 1
                i += 1
        return ans
```

# Tests

```python
def edge():
    return [[[1]], [[1, 1, 1]], [[5, 1, 2, 3, 4]], [[1, 2, 3, 4, 5]], [[1, 1, 4, 2, 1, 3]]]

def random_case(rng):
    return [[rng.randint(1, 6) for _ in range(rng.randint(1, 10))]]
```
