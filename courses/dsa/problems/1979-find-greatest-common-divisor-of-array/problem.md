---
lc: 1979
title: "Find Greatest Common Divisor of Array"
difficulty: "Easy"
patterns: ["number-theory"]
lcTags: ["array", "math", "number-theory", "euclidean-algorithm", "greatest-common-divisor"]
entry: {"method": "findGCD", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer"}
examples: ["[2,5,6,9,10]", "[7,5,6,8,3]", "[3,3]"]
lcHints: ["Find the minimum and maximum in one iteration. Let them be mn and mx.", "Try all the numbers in the range [1, mn] and check the largest number which divides both of them."]
---

Given an integer array `nums`, return *the **greatest common divisor** of the smallest number and largest number in* `nums`.

The **greatest common divisor** of two numbers is the largest positive integer that evenly divides both numbers.

**Example 1:**

```
Input: nums = [2,5,6,9,10]
Output: 2
Explanation:
The smallest number in nums is 2.
The largest number in nums is 10.
The greatest common divisor of 2 and 10 is 2.
```

**Example 2:**

```
Input: nums = [7,5,6,8,3]
Output: 1
Explanation:
The smallest number in nums is 3.
The largest number in nums is 8.
The greatest common divisor of 3 and 8 is 1.
```

**Example 3:**

```
Input: nums = [3,3]
Output: 3
Explanation:
The smallest number in nums is 3.
The largest number in nums is 3.
The greatest common divisor of 3 and 3 is 3.
```

**Constraints:**

- `2 <= nums.length <= 1000`
- `1 <= nums[i] <= 1000`

# Starter

```python
class Solution:
    def findGCD(self, nums: list[int]) -> int:
        
```

# Hints

1. Only two numbers matter: the smallest and the largest.
2. GCD(a, b): Euclid's algorithm: while b: a, b = b, a % b.

# Key points

- only min and max matter
- Euclid: gcd(a, b) = gcd(b, a % b), stop when b == 0
- Euclid is O(log(min(a, b))) vs O(min(a, b)) for trying every divisor

# Solution: try-divisors · Try every divisor · O(n + min) · O(1)

## Idea
Only `min(nums)` and `max(nums)` matter. Count down from the smaller one and return the first number that divides both.

## Complexity
- **Time: O(n + min)**: O(n) to find min/max, then up to `min` tries. Fine for values ≤ 1000, too slow for large numbers.
- **Space: O(1)**

```python
class Solution:
    def findGCD(self, nums: List[int]) -> int:
        a, b = min(nums), max(nums)
        for d in range(a, 0, -1):
            if a % d == 0 and b % d == 0:
                return d
```

# Solution: euclid · Euclid's algorithm · O(n + log min) · O(1) · reference

## Idea
Any common divisor of a and b also divides `a % b`, so **gcd(a, b) = gcd(b, a % b)**. Repeat until the second number is 0; the first is the answer.

```
gcd(10, 4) → gcd(4, 2) → gcd(2, 0) → 2
```

## Complexity
- **Time: O(n)** for min/max + **O(log min(a, b))** for Euclid (the numbers at least halve every two steps).
- **Space: O(1)**

Python has `math.gcd`. Know it exists, but be able to write Euclid.

```python
class Solution:
    def findGCD(self, nums: List[int]) -> int:
        a, b = min(nums), max(nums)
        while b:
            a, b = b, a % b
        return a
```

# Tests

```python
def edge():
    return [[[1, 1]], [[1000, 1000]], [[7, 13]], [[2, 1000]], [[500, 1000]]]

def random_case(rng):
    k = rng.randint(1, 20)
    return [[k * rng.randint(1, 1000 // k) for _ in range(rng.randint(2, 8))]]
```
