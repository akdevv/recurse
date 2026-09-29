---
lc: 875
title: "Koko Eating Bananas"
difficulty: "Medium"
patterns: ["binary-search-answer"]
lcTags: ["array", "binary-search"]
entry: {"method": "minEatingSpeed", "params": [{"name": "piles", "type": "integer[]"}, {"name": "h", "type": "integer"}], "returns": "integer"}
examples: ["[3,6,7,11]\n8", "[30,11,23,4,20]\n5", "[30,11,23,4,20]\n6"]
---

Koko loves to eat bananas. There are `n` piles of bananas, the `iᵗʰ` pile has `piles[i]` bananas. The guards have gone and will come back in `h` hours.

Koko can decide her bananas-per-hour eating speed of `k`. Each hour, she chooses some pile of bananas and eats `k` bananas from that pile. If the pile has less than `k` bananas, she eats all of them instead and will not eat any more bananas during this hour.

Koko likes to eat slowly but still wants to finish eating all the bananas before the guards return.

Return *the minimum integer* `k` *such that she can eat all the bananas within* `h` *hours*.

**Example 1:**

```
Input: piles = [3,6,7,11], h = 8
Output: 4
```

**Example 2:**

```
Input: piles = [30,11,23,4,20], h = 5
Output: 30
```

**Example 3:**

```
Input: piles = [30,11,23,4,20], h = 6
Output: 23
```

**Constraints:**

- `1 <= piles.length <= 10⁴`
- `piles.length <= h <= 10⁹`
- `1 <= piles[i] <= 10⁹`

# Starter

```python
class Solution:
    def minEatingSpeed(self, piles: list[int], h: int) -> int:
        
```

# Hints

1. If Koko can finish at speed k, she can finish at any speed above k too. That monotonic yes/no lets you binary search the speed.
2. Search k in [1, max(piles)]. Hours at speed k = sum of ceil(p / k). If hours ≤ h, try slower (hi = k); otherwise faster (lo = k + 1).

# Key points

- answer space is speeds 1..max(piles), feasibility is monotonic
- hours(k) = sum(ceil(p / k)) = sum((p + k - 1) // k)
- binary search for the smallest feasible k
- O(n log max) time, O(1) space

# Solution: binary-search · Binary Search · O(n × log M) · O(1) · reference

We notice that if Koko can eat all the bananas at a speed of k within h hours, then she can also eat all the bananas at a speed of `k' > k` within h hours. This shows monotonicity, so we can use binary search to find the smallest k that satisfies the condition.

We define the left boundary of the binary search as `l = 1`, and the right boundary as `r = max(piles)`. For each binary search, we take the middle value `mid = (l + r) / (2)`, and then calculate the time s required to eat bananas at a speed of mid. If `s <= h`, it means that the speed of mid can meet the condition, and we update the right boundary r to mid; otherwise, we update the left boundary l to `mid + 1`. Finally, when `l = r`, we find the smallest k that satisfies the condition.

The time complexity is O(n × log M), where n and M are the length and maximum value of the array piles respectively. The space complexity is O(1).

```python
class Solution:
    def minEatingSpeed(self, piles: List[int], h: int) -> int:
        def check(k: int) -> bool:
            return sum((x + k - 1) // k for x in piles) <= h

        return 1 + bisect_left(range(1, max(piles) + 1), True, key=check)
```

# Tests

```python

```
