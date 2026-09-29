---
lc: 846
title: "Hand of Straights"
difficulty: "Medium"
patterns: ["greedy", "hash-map"]
lcTags: ["array", "hash-table", "greedy", "sorting"]
entry: {"method": "isNStraightHand", "params": [{"name": "hand", "type": "integer[]"}, {"name": "groupSize", "type": "integer"}], "returns": "boolean"}
examples: ["[1,2,3,6,2,3,4,7,8]\n3", "[1,2,3,4,5]\n4"]
---

Alice has some number of cards and she wants to rearrange the cards into groups so that each group is of size `groupSize`, and consists of `groupSize` consecutive cards.

Given an integer array `hand` where `hand[i]` is the value written on the `iᵗʰ` card and an integer `groupSize`, return `true` if she can rearrange the cards, or `false` otherwise.

**Example 1:**

```
Input: hand = [1,2,3,6,2,3,4,7,8], groupSize = 3
Output: true
Explanation: Alice's hand can be rearranged as [1,2,3],[2,3,4],[6,7,8]
```

**Example 2:**

```
Input: hand = [1,2,3,4,5], groupSize = 4
Output: false
Explanation: Alice's hand can not be rearranged into groups of 4.
```

**Constraints:**

- `1 <= hand.length <= 10⁴`
- `0 <= hand[i] <= 10⁹`
- `1 <= groupSize <= hand.length`

**Note:** This question is the same as 1296: [https://leetcode.com/problems/divide-array-in-sets-of-k-consecutive-numbers/](https://leetcode.com/problems/divide-array-in-sets-of-k-consecutive-numbers/)

# Starter

```python
class Solution:
    def isNStraightHand(self, hand: list[int], groupSize: int) -> bool:
        
```

# Hints

1. The smallest card must start a group. So always build groups from the smallest remaining card.
2. Count cards. For each card in sorted order that still has count > 0, take groupSize consecutive values starting there, decrementing counts; fail if any is missing.

# Key points

- the smallest remaining card must be the start of some group
- Counter + sorted distinct values
- if len(hand) % groupSize != 0, fail immediately
- O(n log n) time

# Solution: hash-table-sorting · Hash Table + Sorting · O(n × log n) · O(n) · reference

We first check whether the length of the array hand is divisible by groupSize. If it is not, this means that the array cannot be partitioned into multiple subarrays of length groupSize, so we return false.

Next, we use a hash table cnt to count the occurrences of each number in the array hand, and then we sort the array hand.

After that, we iterate over the sorted array hand. For each number x, if `cnt[x] != 0`, we enumerate every number y from x to `x + groupSize - 1`. If `cnt[y] = 0`, it means that we cannot partition the array into multiple subarrays of length groupSize, so we return false. Otherwise, we decrement `cnt[y]` by 1.

If the iteration completes successfully, it means that the array can be partitioned into multiple valid subarrays, so we return true.

The time complexity is O(n × log n), and the space complexity is O(n), where n is the length of the array hand.

```python
class Solution:
    def isNStraightHand(self, hand: List[int], groupSize: int) -> bool:
        if len(hand) % groupSize:
            return False
        cnt = Counter(hand)
        for x in sorted(hand):
            if cnt[x]:
                for y in range(x, x + groupSize):
                    if cnt[y] == 0:
                        return False
                    cnt[y] -= 1
        return True
```

# Tests

```python

```
