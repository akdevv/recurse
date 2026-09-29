---
lc: 40
title: "Combination Sum II"
difficulty: "Medium"
patterns: ["backtracking"]
lcTags: ["array", "backtracking"]
compare: "groups"
entry: {"method": "combinationSum2", "params": [{"name": "candidates", "type": "integer[]"}, {"name": "target", "type": "integer"}], "returns": "list<list<integer>>"}
examples: ["[10,1,2,7,6,1,5]\n8", "[2,5,2,1,2]\n5"]
---

Given a collection of candidate numbers (`candidates`) and a target number (`target`), find all unique combinations in `candidates` where the candidate numbers sum to `target`.

Each number in `candidates` may only be used **once** in the combination.

**Note:** The solution set must not contain duplicate combinations.

**Example 1:**

```
Input: candidates = [10,1,2,7,6,1,5], target = 8
Output:
[
[1,1,6],
[1,2,5],
[1,7],
[2,6]
]
```

**Example 2:**

```
Input: candidates = [2,5,2,1,2], target = 5
Output:
[
[1,2,2],
[5]
]
```

**Constraints:**

- `1 <= candidates.length <= 100`
- `1 <= candidates[i] <= 50`
- `1 <= target <= 30`

# Starter

```python
class Solution:
    def combinationSum2(self, candidates: list[int], target: int) -> list[list[int]]:
        
```

# Hints

1. Each number can be used once, but the input has duplicates. Combine "move to i + 1" with Subsets II's skip rule.
2. Sort. For i from start: skip if i > start and c[i] == c[i − 1]; break if c[i] > remaining; otherwise take it and recurse with i + 1.

# Key points

- sort, recurse with i + 1 (each element used at most once)
- skip equal values at the same depth to avoid duplicate combinations
- break early once candidates exceed the remaining target

# Solution: sorting-pruning-backtracking · Sorting + Pruning + Backtracking · O(2ⁿ × n) · O(n) · reference

We can first sort the array to facilitate pruning and skipping duplicate numbers.

Next, we design a function `dfs(i, s)`, which means starting the search from index i with a remaining target value of s. Here, i and s are both non-negative integers, the current search path is t, and the answer is ans.

In the function `dfs(i, s)`, we first check whether s is 0. If it is, we add the current search path t to the answer ans, and then return. If `i >= n` or `s < candidates[i]`, the path is invalid, so we return directly. Otherwise, we start the search from index i, and the search index range is `j in [i, n)`, where n is the length of the array candidates. During the search, if `j > i` and `candidates[j] = candidates[j - 1]`, it means that the current number is the same as the previous number, we can skip the current number because the previous number has been searched. Otherwise, we add the current number to the search path t, recursively call the function `dfs(j + 1, s - candidates[j])`, and after the recursion ends, we remove the current number from the search path t.

We can also change the implementation logic of the function `dfs(i, s)` to another form. If we choose the current number, we add the current number to the search path t, then recursively call the function `dfs(i + 1, s - candidates[i])`, and after the recursion ends, we remove the current number from the search path t. If we do not choose the current number, we can skip all numbers that are the same as the current number, then recursively call the function `dfs(j, s)`, where j is the index of the first number that is different from the current number.

In the main function, we just need to call the function `dfs(0, target)` to get the answer.

The time complexity is O(2ⁿ × n), and the space complexity is O(n). Here, n is the length of the array candidates. Due to pruning, the actual time complexity is much less than O(2ⁿ × n).

Similar problems:

- [39. Combination Sum](https://github.com/doocs/leetcode/blob/main/solution/0000-0099/0039.Combination%20Sum/README_EN.md)
- [77. Combinations](https://github.com/doocs/leetcode/blob/main/solution/0000-0099/0077.Combinations/README_EN.md)
- [216. Combination Sum III](https://github.com/doocs/leetcode/blob/main/solution/0200-0299/0216.Combination%20Sum%20III/README_EN.md)

```python
class Solution:
    def combinationSum2(self, candidates: List[int], target: int) -> List[List[int]]:
        def dfs(i: int, s: int):
            if s == 0:
                ans.append(t[:])
                return
            if i >= len(candidates) or s < candidates[i]:
                return
            for j in range(i, len(candidates)):
                if j > i and candidates[j] == candidates[j - 1]:
                    continue
                t.append(candidates[j])
                dfs(j + 1, s - candidates[j])
                t.pop()

        candidates.sort()
        ans = []
        t = []
        dfs(0, target)
        return ans
```

# Solution: sorting-pruning-backtracking-another-for · Sorting + Pruning + Backtracking(Another Form) · O(2ⁿ × n) · O(n)

We can also change the implementation logic of the function `dfs(i, s)` to another form. If we choose the current number, we add the current number to the search path t, then recursively call the function `dfs(i + 1, s - candidates[i])`, and after the recursion ends, we remove the current number from the search path t. If we do not choose the current number, we can skip all numbers that are the same as the current number, then recursively call the function `dfs(j, s)`, where j is the index of the first number that is different from the current number.

The time complexity is O(2ⁿ × n), and the space complexity is O(n). Here, n is the length of the array candidates. Due to pruning, the actual time complexity is much less than O(2ⁿ × n).

```python
class Solution:
    def combinationSum2(self, candidates: List[int], target: int) -> List[List[int]]:
        def dfs(i: int, s: int):
            if s == 0:
                ans.append(t[:])
                return
            if i >= len(candidates) or s < candidates[i]:
                return
            x = candidates[i]
            t.append(x)
            dfs(i + 1, s - x)
            t.pop()
            while i < len(candidates) and candidates[i] == x:
                i += 1
            dfs(i, s)

        candidates.sort()
        ans = []
        t = []
        dfs(0, target)
        return ans
```

# Tests

```python

```
