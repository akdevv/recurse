---
lc: 2558
title: "Take Gifts From the Richest Pile"
difficulty: "Easy"
patterns: ["top-k-heap"]
lcTags: ["array", "heap-priority-queue", "simulation"]
entry: {"method": "pickGifts", "params": [{"name": "gifts", "type": "integer[]"}, {"name": "k", "type": "integer"}], "returns": "long"}
examples: ["[25,64,9,4,100]\n4", "[1,1,1,1]\n4"]
lcHints: ["How can you keep track of the largest gifts in the array", "What is an efficient way to find the square root of a number?", "Can you keep adding up the values of the gifts while ensuring they are in a certain order?", "Can we use a priority queue or heap here?"]
---

You are given an integer array `gifts` denoting the number of gifts in various piles. Every second, you do the following:

- Choose the pile with the maximum number of gifts.
- If there is more than one pile with the maximum number of gifts, choose any.
- Reduce the number of gifts in the pile to the floor of the square root of the original number of gifts in the pile.

Return *the number of gifts remaining after* `k` *seconds.*

**Example 1:**

```
Input: gifts = [25,64,9,4,100], k = 4
Output: 29
Explanation:
The gifts are taken in the following way:
- In the first second, the last pile is chosen and 10 gifts are left behind.
- Then the second pile is chosen and 8 gifts are left behind.
- After that the first pile is chosen and 5 gifts are left behind.
- Finally, the last pile is chosen again and 3 gifts are left behind.
The final remaining gifts are [5,8,9,4,3], so the total number of gifts remaining is 29.
```

**Example 2:**

```
Input: gifts = [1,1,1,1], k = 4
Output: 4
Explanation:
In this case, regardless which pile you choose, you have to leave behind 1 gift in each pile.
That is, you can't take any pile with you.
So, the total gifts remaining are 4.
```

**Constraints:**

- `1 <= gifts.length <= 10³`
- `1 <= gifts[i] <= 10⁹`
- `1 <= k <= 10³`

# Starter

```python
class Solution:
    def pickGifts(self, gifts: List[int], k: int) -> int:
        
```

# Hints

1. Each second you need the largest pile. A max-heap gives it in O(log n).
2. Max-heap (negated values). k times: pop the largest, push back isqrt(value). Return the sum of the heap.

# Key points

- max-heap, repeat k times: pop max, push floor(sqrt(max))
- math.isqrt avoids float rounding
- O(n + k log n) time

# Solution: priority-queue-max-heap · Priority Queue (Max Heap) · O(n + k × log n) · O(n) · reference

We can store the array gifts in a max heap, and then loop k times, each time taking out the top element of the heap, taking the square root of it, and putting the result back into the heap.

Finally, we add up all the elements in the heap as the answer.

The time complexity is O(n + k × log n), and the space complexity is O(n). Here, n is the length of the array gifts.

```python
class Solution:
    def pickGifts(self, gifts: List[int], k: int) -> int:
        h = [-v for v in gifts]
        heapify(h)
        for _ in range(k):
            heapreplace(h, -int(sqrt(-h[0])))
        return -sum(h)
```

# Tests

```python

```
