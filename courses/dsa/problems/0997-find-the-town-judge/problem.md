---
lc: 997
title: "Find the Town Judge"
difficulty: "Easy"
patterns: ["simulation"]
lcTags: ["array", "hash-table", "graph"]
entry: {"method": "findJudge", "params": [{"name": "n", "type": "integer"}, {"name": "trust", "type": "integer[][]"}], "returns": "integer"}
examples: ["2\n[[1,2]]", "3\n[[1,3],[2,3]]", "3\n[[1,3],[2,3],[3,1]]"]
---

In a town, there are `n` people labeled from `1` to `n`. There is a rumor that one of these people is secretly the town judge.

If the town judge exists, then:

1. The town judge trusts nobody.
1. Everybody (except for the town judge) trusts the town judge.
1. There is exactly one person that satisfies properties **1** and **2**.

You are given an array `trust` where `trust[i] = [aᵢ, bᵢ]` representing that the person labeled `aᵢ` trusts the person labeled `bᵢ`. If a trust relationship does not exist in `trust` array, then such a trust relationship does not exist.

Return *the label of the town judge if the town judge exists and can be identified, or return* `-1` *otherwise*.

**Example 1:**

```
Input: n = 2, trust = [[1,2]]
Output: 2
```

**Example 2:**

```
Input: n = 3, trust = [[1,3],[2,3]]
Output: 3
```

**Example 3:**

```
Input: n = 3, trust = [[1,3],[2,3],[3,1]]
Output: -1
```

**Constraints:**

- `1 <= n <= 1000`
- `0 <= trust.length <= 10⁴`
- `trust[i].length == 2`
- All the pairs of `trust` are **unique**.
- `aᵢ != bᵢ`
- `1 <= aᵢ, bᵢ <= n`

# Starter

```python
class Solution:
    def findJudge(self, n: int, trust: list[list[int]]) -> int:
        
```

# Hints

1. Think of trust as edges. The judge has in-degree n − 1 and out-degree 0.
2. Score each person: +1 when trusted, −1 when trusting someone. The judge is the one with score n − 1.

# Key points

- in-degree / out-degree counting
- judge: trusted by n - 1 people, trusts nobody
- one array of scores: O(n + t) time

# Solution: counting · Counting · O(n) · O(n) · reference

We create two arrays cnt1 and cnt2 of length `n + 1`, representing the number of people each person trusts and the number of people who trust each person, respectively.

Next, we traverse the array trust, for each item `[a_i, b_i]`, we increment `cnt1[a_i]` and `cnt2[b_i]` by 1.

Finally, we enumerate each person i in the range `[1,..n]`. If `cnt1[i] = 0` and `cnt2[i] = n - 1`, it means that i is the town judge, and we return i. Otherwise, if no such person is found after the traversal, we return -1.

The time complexity is O(n), and the space complexity is O(n). Here, n is the length of the array trust.

```python
class Solution:
    def findJudge(self, n: int, trust: List[List[int]]) -> int:
        cnt1 = [0] * (n + 1)
        cnt2 = [0] * (n + 1)
        for a, b in trust:
            cnt1[a] += 1
            cnt2[b] += 1
        for i in range(1, n + 1):
            if cnt1[i] == 0 and cnt2[i] == n - 1:
                return i
        return -1
```

# Tests

```python
def edge():
    return [[1, []], [2, [[1, 2]]], [3, [[1, 3], [2, 3]]], [3, [[1, 3], [2, 3], [3, 1]]], [2, []]]

def random_case(rng):
    n = rng.randint(1, 6)
    pairs = [[a, b] for a in range(1, n + 1) for b in range(1, n + 1) if a != b]
    if n > 1 and rng.random() < 0.5:
        j = rng.randint(1, n)
        must = [[a, j] for a in range(1, n + 1) if a != j]
        rest = [p for p in pairs if p[0] != j and p not in must]
        return [n, must + rng.sample(rest, rng.randint(0, len(rest)))]
    return [n, rng.sample(pairs, rng.randint(0, len(pairs)))]
```
