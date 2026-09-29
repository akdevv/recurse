---
lc: 169
title: "Majority Element"
difficulty: "Easy"
patterns: ["hash-map"]
lcTags: ["array", "hash-table", "divide-and-conquer", "sorting", "counting", "boyer-moore-majority-vote-algorithm"]
entry: {"method": "majorityElement", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer"}
examples: ["[3,2,3]", "[2,2,1,1,1,2,2]"]
---

Given an array `nums` of size `n`, return *the majority element*.

The majority element is the element that appears more than `⌊n / 2⌋` times. You may assume that the majority element always exists in the array.

**Example 1:**

```
Input: nums = [3,2,3]
Output: 3
```

**Example 2:**

```
Input: nums = [2,2,1,1,1,2,2]
Output: 2
```

**Constraints:**

- `n == nums.length`
- `1 <= n <= 5 * 10⁴`
- `-10⁹ <= nums[i] <= 10⁹`
- The input is generated such that a majority element will exist in the array.

**Follow-up:** Could you solve the problem in linear time and in `O(1)` space?

# Starter

```python
class Solution:
    def majorityElement(self, nums: list[int]) -> int:
        
```

# Hints

1. A hash map of counts solves it in O(n). Can you do it with O(1) extra space?
2. Boyer-Moore voting: keep a candidate and a count. Same value: count + 1. Different: count − 1. At 0, take the current value as the new candidate.

# Key points

- counting with a hash map is O(n) time and O(n) space
- Boyer-Moore: pairing off different values can never cancel all copies of an element that appears more than n/2 times
- O(n) time, O(1) space; sorting and taking the middle is O(n log n)

# Solution: count-map · Count with a hash map · O(n) · O(n)

## Idea
Count every value, return the most frequent one.

## Complexity
- **Time: O(n)**.
- **Space: O(n)** for the counts.

This is the answer most people give first, and it's a fine one. The follow-up is always "now in O(1) space".

```python
from collections import Counter

class Solution:
    def majorityElement(self, nums: list[int]) -> int:
        return Counter(nums).most_common(1)[0][0]
```

# Solution: sort-middle · Sort and take the middle · O(n log n) · O(n)

## Idea
A value that fills more than half the array must cover the middle index once sorted.

## Complexity
- **Time: O(n log n)** for the sort.
- **Space: O(n)** for the sorted copy (O(1) if you sort in place).

```python
class Solution:
    def majorityElement(self, nums: list[int]) -> int:
        return sorted(nums)[len(nums) // 2]
```

# Solution: boyer-moore · Boyer-Moore voting · O(n) · O(1) · reference

## Idea
Think of it as a fight: every copy of the majority can be cancelled only by a different value. Pair off different values and discard both. Since the majority has **more than half** the array, it can't be fully cancelled, so it's the one standing at the end.

`count` is how many unpaired copies of `cand` we have. When it drops to 0, everything so far has been paired off and we start fresh with the current value.

## Complexity
- **Time: O(n)**, one pass.
- **Space: O(1)**.

Only valid because the problem guarantees a majority exists. Without that guarantee you'd need a second pass to confirm the candidate.

```python
class Solution:
    def majorityElement(self, nums: list[int]) -> int:
        cand, count = None, 0
        for x in nums:
            if count == 0:
                cand = x
            count += 1 if x == cand else -1
        return cand
```

# Tests

```python
def edge():
    return [[[1]], [[3, 2, 3]], [[2, 2, 1, 1, 1, 2, 2]], [[-1, -1, -1]], [[5, 4, 5]], [[6, 6, 6, 7, 7]]]

def random_case(rng):
    n = rng.randint(1, 15)
    maj = rng.randint(-5, 5)
    k = n // 2 + 1 + rng.randint(0, n - n // 2 - 1)
    vals = [maj] * k + [rng.randint(-5, 5) for _ in range(n - k)]
    rng.shuffle(vals)
    return [vals]

def perf(rng):
    return []
```
