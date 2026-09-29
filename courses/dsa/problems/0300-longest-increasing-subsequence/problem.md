---
lc: 300
title: "Longest Increasing Subsequence"
difficulty: "Medium"
patterns: ["dynamic-programming", "binary-search"]
lcTags: ["array", "binary-search", "dynamic-programming", "longest-increasing-subsequence"]
entry: {"method": "lengthOfLIS", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer"}
examples: ["[10,9,2,5,3,7,101,18]", "[0,1,0,3,2,3]", "[7,7,7,7,7,7,7]"]
---

Given an integer array `nums`, return *the length of the longest **strictly increasing*** ***subsequence***.

**Example 1:**

```
Input: nums = [10,9,2,5,3,7,101,18]
Output: 4
Explanation: The longest increasing subsequence is [2,3,7,101], therefore the length is 4.
```

**Example 2:**

```
Input: nums = [0,1,0,3,2,3]
Output: 4
```

**Example 3:**

```
Input: nums = [7,7,7,7,7,7,7]
Output: 1
```

**Constraints:**

- `1 <= nums.length <= 2500`
- `-10⁴ <= nums[i] <= 10⁴`

**Follow up:** Can you come up with an algorithm that runs in `O(n log(n))` time complexity?

# Starter

```python
class Solution:
    def lengthOfLIS(self, nums: list[int]) -> int:
        
```

# Hints

1. O(n²): dp[i] = length of the longest increasing subsequence ending at i = 1 + max dp[j] for j < i with nums[j] < nums[i].
2. O(n log n): keep tails[k] = smallest possible tail of an increasing subsequence of length k + 1. For each x, replace the first tail ≥ x (bisect_left) or append.

# Key points

- dp ending at each index: O(n²)
- patience sorting / tails array + binary search: O(n log n)
- tails isn't the subsequence itself, only its length is right
- strictly increasing → bisect_left

# Solution: solution-1 · DP · O(n²) · O(n) · reference

## Idea
`f[i]` is the length of the longest increasing subsequence ending at i: 1 plus the best `f[j]` for an earlier j with a smaller value.

## Complexity
- **Time: O(n²)**
- **Space: O(n)**

```python
class Solution:
    def lengthOfLIS(self, nums: List[int]) -> int:
        n = len(nums)
        f = [1] * n
        for i in range(1, n):
            for j in range(i):
                if nums[j] < nums[i]:
                    f[i] = max(f[i], f[j] + 1)
        return max(f)
```

# Solution: solution-2 · Binary indexed tree · O(n log n) · O(n)

## Idea
Compress the values to ranks, then process numbers left to right. A binary indexed tree stores, for each rank, the best length ending with that value. For x, query the best length among smaller ranks, add 1, and store it at x's rank.

## Complexity
- **Time: O(n log n)**
- **Space: O(n)**

```python
class BinaryIndexedTree:
    def __init__(self, n: int):
        self.n = n
        self.c = [0] * (n + 1)

    def update(self, x: int, v: int):
        while x <= self.n:
            self.c[x] = max(self.c[x], v)
            x += x & -x

    def query(self, x: int) -> int:
        mx = 0
        while x:
            mx = max(mx, self.c[x])
            x -= x & -x
        return mx

class Solution:
    def lengthOfLIS(self, nums: List[int]) -> int:
        s = sorted(set(nums))
        m = len(s)
        tree = BinaryIndexedTree(m)
        for x in nums:
            x = bisect_left(s, x) + 1
            t = tree.query(x - 1) + 1
            tree.update(x, t)
        return tree.query(m)
```

# Tests

```python
def edge():
    return [[[1]], [[10, 9, 2, 5, 3, 7, 101, 18]], [[0, 1, 0, 3, 2, 3]], [[7, 7, 7, 7]], [[5, 4, 3, 2, 1]], [[1, 2, 3, 4, 5]]]

def random_case(rng):
    return [[rng.randint(-10, 10) for _ in range(rng.randint(1, 12))]]

def perf(rng):
    return [[[rng.randint(-10**4, 10**4) for _ in range(2500)]], [list(range(2500))]]
```
