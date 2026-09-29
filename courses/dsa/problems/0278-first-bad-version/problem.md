---
lc: 278
title: "First Bad Version"
difficulty: "Easy"
patterns: ["binary-search"]
lcTags: ["binary-search", "interactive"]
entry: {"method": "firstBadVersion", "params": [{"name": "n", "type": "integer"}, {"name": "bad", "type": "integer"}], "returns": "integer", "interactive": true}
examples: ["5\n4", "1\n1"]
---

You are a product manager and currently leading a team to develop a new product. Unfortunately, the latest version of your product fails the quality check. Since each version is developed based on the previous version, all the versions after a bad version are also bad.

Suppose you have `n` versions `[1, 2, ..., n]` and you want to find out the first bad one, which causes all the following ones to be bad.

You are given an API `bool isBadVersion(version)` which returns whether `version` is bad. Implement a function to find the first bad version. You should minimize the number of calls to the API.

**Example 1:**

```
Input: n = 5, bad = 4
Output: 4
Explanation:
call isBadVersion(3) -> false
call isBadVersion(5) -> true
call isBadVersion(4) -> true
Then 4 is the first bad version.
```

**Example 2:**

```
Input: n = 1, bad = 1
Output: 1
```

**Constraints:**

- `1 <= bad <= n <= 2³¹ - 1`

# Starter

```python
# The isBadVersion API is already defined for you.
# def isBadVersion(version: int) -> bool:

class Solution:
    def firstBadVersion(self, n: int) -> int:
        
```

# Hints

1. Versions look like good, good, …, good, bad, bad, …. You want the first bad one, with as few API calls as possible.
2. Binary search: if isBadVersion(mid), the answer is mid or earlier (hi = mid); otherwise it's after mid (lo = mid + 1).

# Key points

- the predicate is monotonic: false…false true…true
- binary search for the first true: hi = mid on bad, lo = mid + 1 on good
- O(log n) API calls; linear search times out for n up to 2³¹ − 1
- in other languages use lo + (hi - lo) // 2 to avoid overflow

# Solution: binary-search · Binary Search · O(log n) · O(1) · reference

We define the left boundary of the binary search as `l = 1` and the right boundary as `r = n`.

While `l < r`, we calculate the middle position `mid =  (l + r) / (2)`, then call the `isBadVersion(mid)` API. If it returns true, it means the first bad version is between `[l, mid]`, so we set `r = mid`; otherwise, the first bad version is between `[mid + 1, r]`, so we set `l = mid + 1`.

Finally, we return l.

The time complexity is O(log n), and the space complexity is O(1).

```python
# The isBadVersion API is already defined for you.
# def isBadVersion(version: int) -> bool:

class Solution:
    def firstBadVersion(self, n: int) -> int:
        l, r = 1, n
        while l < r:
            mid = (l + r) >> 1
            if isBadVersion(mid):
                r = mid
            else:
                l = mid + 1
        return l
```

# Tests

```python
def prepare(args):
    n, bad = args
    return [n], {"isBadVersion": lambda v: v >= bad}

def edge():
    return [[1, 1], [2, 1], [2, 2], [5, 4], [2**31 - 1, 2**31 - 1], [2**31 - 1, 1]]

def random_case(rng):
    n = rng.randint(1, 60)
    return [n, rng.randint(1, n)]

def perf(rng):
    return [[2**31 - 1, 1702766719]]
```
