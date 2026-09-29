---
lc: 39
title: "Combination Sum"
difficulty: "Medium"
patterns: ["backtracking"]
lcTags: ["array", "backtracking"]
compare: "groups"
entry: {"method": "combinationSum", "params": [{"name": "candidates", "type": "integer[]"}, {"name": "target", "type": "integer"}], "returns": "list<list<integer>>"}
examples: ["[2,3,6,7]\n7", "[2,3,5]\n8", "[2]\n1"]
---

Given an array of **distinct** integers `candidates` and a target integer `target`, return *a list of all **unique combinations** of* `candidates` *where the chosen numbers sum to* `target`*.* You may return the combinations in **any order**.

The **same** number may be chosen from `candidates` an **unlimited number of times**. Two combinations are unique if the frequency of at least one of the chosen numbers is different.

The test cases are generated such that the number of unique combinations that sum up to `target` is less than `150` combinations for the given input.

**Example 1:**

```
Input: candidates = [2,3,6,7], target = 7
Output: [[2,2,3],[7]]
Explanation:
2 and 3 are candidates, and 2 + 2 + 3 = 7. Note that 2 can be used multiple times.
7 is a candidate, and 7 = 7.
These are the only two combinations.
```

**Example 2:**

```
Input: candidates = [2,3,5], target = 8
Output: [[2,2,2,2],[2,3,3],[3,5]]
```

**Example 3:**

```
Input: candidates = [2], target = 1
Output: []
```

**Constraints:**

- `1 <= candidates.length <= 30`
- `2 <= candidates[i] <= 40`
- All elements of `candidates` are **distinct**.
- `1 <= target <= 40`

# Starter

```python
class Solution:
    def combinationSum(self, candidates: list[int], target: int) -> list[list[int]]:
        
```

# Hints

1. Each candidate can be used unlimited times. How do you avoid producing [2, 3] and [3, 2] separately?
2. Backtrack(start, remaining): for i from start: if candidates[i] ≤ remaining, append it and recurse with i (not i + 1, so it can repeat). Sorting lets you break early.

# Key points

- recurse with the same index to allow reuse
- only move forward in the candidate list → no duplicate orderings
- sort and break when a candidate exceeds the remaining sum
- record when remaining == 0

# Solution: sorting-pruning-backtracking · Sorting + Pruning + Backtracking · O(2ⁿ × n) · O(n) · reference

We can first sort the array to facilitate pruning.

Next, we design a function `dfs(i, s)`, which means starting the search from index i with a remaining target value of s. Here, i and s are both non-negative integers, the current search path is t, and the answer is ans.

In the function `dfs(i, s)`, we first check whether s is 0. If it is, we add the current search path t to the answer ans, and then return. If `s < candidates[i]`, it means that the elements of the current index and the following indices are all greater than the remaining target value s, and the path is invalid, so we return directly. Otherwise, we start the search from index i, and the search index range is `j in [i, n)`, where n is the length of the array candidates. During the search, we add the element of the current index to the search path t, recursively call the function `dfs(j, s - candidates[j])`, and after the recursion ends, we remove the element of the current index from the search path t.

In the main function, we just need to call the function `dfs(0, target)` to get the answer.

The time complexity is O(2ⁿ × n), and the space complexity is O(n). Here, n is the length of the array candidates. Due to pruning, the actual time complexity is much less than O(2ⁿ × n).

Similar problems:

- [40. Combination Sum II](https://github.com/doocs/leetcode/blob/main/solution/0000-0099/0040.Combination%20Sum%20II/README_EN.md)
- [77. Combinations](https://github.com/doocs/leetcode/blob/main/solution/0000-0099/0077.Combinations/README_EN.md)
- [216. Combination Sum III](https://github.com/doocs/leetcode/blob/main/solution/0200-0299/0216.Combination%20Sum%20III/README_EN.md)

```python
class Solution:
    def combinationSum(self, candidates: List[int], target: int) -> List[List[int]]:
        def dfs(i: int, s: int):
            if s == 0:
                ans.append(t[:])
                return
            if s < candidates[i]:
                return
            for j in range(i, len(candidates)):
                t.append(candidates[j])
                dfs(j, s - candidates[j])
                t.pop()

        candidates.sort()
        t = []
        ans = []
        dfs(0, target)
        return ans
```

# Solution: sorting-pruning-backtracking-another-for · Sorting + Pruning + Backtracking(Another Form) · O(2ⁿ × n) · O(n)

We can also change the implementation logic of the function `dfs(i, s)` to another form. In the function `dfs(i, s)`, we first check whether s is 0. If it is, we add the current search path t to the answer ans, and then return. If `i >= n` or `s < candidates[i]`, the path is invalid, so we return directly. Otherwise, we consider two situations, one is not selecting the element of the current index, that is, recursively calling the function `dfs(i + 1, s)`, and the other is selecting the element of the current index, that is, recursively calling the function `dfs(i, s - candidates[i])`.

The time complexity is O(2ⁿ × n), and the space complexity is O(n). Here, n is the length of the array candidates. Due to pruning, the actual time complexity is much less than O(2ⁿ × n).

```python
class Solution:
    def combinationSum(self, candidates: List[int], target: int) -> List[List[int]]:
        def dfs(i: int, s: int):
            if s == 0:
                ans.append(t[:])
                return
            if i >= len(candidates) or s < candidates[i]:
                return
            dfs(i + 1, s)
            t.append(candidates[i])
            dfs(i, s - candidates[i])
            t.pop()

        candidates.sort()
        t = []
        ans = []
        dfs(0, target)
        return ans
```

# Tests

```python
def edge():
    return [[[2], 1], [[2], 2], [[2, 3, 6, 7], 7], [[2, 3, 5], 8], [[7, 3, 2], 18], [[40], 40]]

def random_case(rng):
    return [rng.sample(range(2, 15), rng.randint(1, 5)), rng.randint(1, 20)]

def perf(rng):
    return [[list(range(2, 32)), 40]]
```
