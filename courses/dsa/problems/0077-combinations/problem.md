---
lc: 77
title: "Combinations"
difficulty: "Medium"
patterns: ["backtracking"]
lcTags: ["backtracking"]
compare: "groups"
entry: {"method": "combine", "params": [{"name": "n", "type": "integer"}, {"name": "k", "type": "integer"}], "returns": "list<list<integer>>"}
examples: ["4\n2", "1\n1"]
---

Given two integers `n` and `k`, return *all possible combinations of* `k` *numbers chosen from the range* `[1, n]`.

You may return the answer in **any order**.

**Example 1:**

```
Input: n = 4, k = 2
Output: [[1,2],[1,3],[1,4],[2,3],[2,4],[3,4]]
Explanation: There are 4 choose 2 = 6 total combinations.
Note that combinations are unordered, i.e., [1,2] and [2,1] are considered to be the same combination.
```

**Example 2:**

```
Input: n = 1, k = 1
Output: [[1]]
Explanation: There is 1 choose 1 = 1 total combination.
```

**Constraints:**

- `1 <= n <= 20`
- `1 <= k <= n`

# Starter

```python
class Solution:
    def combine(self, n: int, k: int) -> list[list[int]]:
        
```

# Hints

1. Choose k numbers from 1..n. Build them in increasing order so each combination is produced once.
2. Backtrack(start, path): if len(path) == k record it; else for x in start..n: append x, recurse with x + 1, pop. Prune when not enough numbers remain.

# Key points

- pick numbers in increasing order to avoid duplicates
- stop when the path has k numbers
- prune: skip starts that leave fewer than k - len(path) numbers
- C(n, k) results, O(k·C(n, k)) time

# Solution: backtracking-two-ways · Backtracking (Two Ways) · (C_n^k × k) · O(k) · reference

We design a function `dfs(i)`, which represents starting the search from number i, with the current search path as t, and the answer as ans.

The execution logic of the function `dfs(i)` is as follows:

- If the length of the current search path t equals k, then add the current search path to the answer and return.
- If `i > n`, it means the search has ended, return.
- Otherwise, we can choose to add the number i to the search path t, and then continue the search, i.e., execute `dfs(i + 1)`, and then remove the number i from the search path t; or we do not add the number i to the search path t, and directly execute `dfs(i + 1)`.

The above method is actually enumerating whether to select the current number or not, and then recursively searching the next number. We can also enumerate the next number j to be selected, where `i <= j <= n`. If the next number to be selected is j, then we add the number j to the search path t, and then continue the search, i.e., execute `dfs(j + 1)`, and then remove the number j from the search path t.

In the main function, we start the search from number 1, i.e., execute `dfs(1)`.

The time complexity is `(C_n^k × k)`, and the space complexity is O(k). Here, `C_n^k` represents the combination number.

Similar problems:

- [39. Combination Sum](https://github.com/doocs/leetcode/blob/main/solution/0000-0099/0039.Combination%20Sum/README_EN.md)
- [40. Combination Sum II](https://github.com/doocs/leetcode/blob/main/solution/0000-0099/0040.Combination%20Sum%20II/README_EN.md)
- [216. Combination Sum III](https://github.com/doocs/leetcode/blob/main/solution/0200-0299/0216.Combination%20Sum%20III/README_EN.md)

```python
class Solution:
    def combine(self, n: int, k: int) -> List[List[int]]:
        def dfs(i: int):
            if len(t) == k:
                ans.append(t[:])
                return
            if i > n:
                return
            t.append(i)
            dfs(i + 1)
            t.pop()
            dfs(i + 1)

        ans = []
        t = []
        dfs(1)
        return ans
```

# Solution: solution-2 · Backtracking with a for-loop · O(k × C(n, k)) · O(k)

## Idea
Same backtracking, written with a loop: at each level choose the next number j from i..n, recurse from j + 1, then undo. Stop when the path has k numbers.

## Complexity
- **Time: O(k × C(n, k))**
- **Space: O(k)**

```python
class Solution:
    def combine(self, n: int, k: int) -> List[List[int]]:
        def dfs(i: int):
            if len(t) == k:
                ans.append(t[:])
                return
            if i > n:
                return
            for j in range(i, n + 1):
                t.append(j)
                dfs(j + 1)
                t.pop()

        ans = []
        t = []
        dfs(1)
        return ans
```

# Tests

```python

```
