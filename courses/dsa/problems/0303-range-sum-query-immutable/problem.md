---
lc: 303
title: "Range Sum Query - Immutable"
difficulty: "Easy"
patterns: ["prefix-sum"]
lcTags: ["array", "design", "prefix-sum"]
entry: {"method": "NumArray", "design": true, "params": [{"name": "operations", "type": "string[]"}, {"name": "arguments", "type": "list"}], "returns": "list"}
examples: ["[\"NumArray\",\"sumRange\",\"sumRange\",\"sumRange\"]\n[[[-2,0,3,-5,2,-1]],[0,2],[2,5],[0,5]]"]
---

Given an integer array `nums`, handle multiple queries of the following type:

1. Calculate the **sum** of the elements of `nums` between indices `left` and `right` **inclusive** where `left <= right`.

Implement the `NumArray` class:

- `NumArray(int[] nums)` Initializes the object with the integer array `nums`.
- `int sumRange(int left, int right)` Returns the **sum** of the elements of `nums` between indices `left` and `right` **inclusive** (i.e. `nums[left] + nums[left + 1] + ... + nums[right]`).

**Example 1:**

```
Input
["NumArray", "sumRange", "sumRange", "sumRange"]
[[[-2, 0, 3, -5, 2, -1]], [0, 2], [2, 5], [0, 5]]
Output
[null, 1, -1, -3]

Explanation
NumArray numArray = new NumArray([-2, 0, 3, -5, 2, -1]);
numArray.sumRange(0, 2); // return (-2) + 0 + 3 = 1
numArray.sumRange(2, 5); // return 3 + (-5) + 2 + (-1) = -1
numArray.sumRange(0, 5); // return (-2) + 0 + 3 + (-5) + 2 + (-1) = -3
```

**Constraints:**

- `1 <= nums.length <= 10⁴`
- `-10⁵ <= nums[i] <= 10⁵`
- `0 <= left <= right < nums.length`
- At most `10⁴` calls will be made to `sumRange`.

# Starter

```python
class NumArray:

    def __init__(self, nums: list[int]):
        

    def sumRange(self, left: int, right: int) -> int:
        

# Your NumArray object will be instantiated and called as such:
# obj = NumArray(nums)
# param_1 = obj.sumRange(left,right)
```

# Hints

1. Summing the range on every call is O(n) per query. The array never changes, so what could you precompute once?
2. prefix[i] = sum of the first i numbers. Then sum(left..right) = prefix[right + 1] − prefix[left].

# Key points

- precompute prefix sums once in the constructor: O(n)
- prefix has n + 1 entries with prefix[0] = 0
- sumRange(l, r) = prefix[r + 1] − prefix[l], O(1) per query
- works because the array is immutable; updates would need a Fenwick/segment tree

# Solution: loop · Sum on every call · O(n) per query · O(1)

## Idea
Add up the range each time it's asked for. Passes at these limits (`sum` runs in C), but it's O(n·q) and the point of the problem is O(1) queries.

## Complexity
- **Time: O(n)** per query, O(n·q) for q queries.
- **Space: O(1)** extra.

```python
class NumArray:
    def __init__(self, nums: list[int]):
        self.nums = nums

    def sumRange(self, left: int, right: int) -> int:
        return sum(self.nums[left:right + 1])
```

# Solution: prefix · Prefix sums · O(1) per query · O(n) · reference

## Idea
`prefix[i]` is the sum of `nums[0..i-1]`, with `prefix[0] = 0`. The sum from `left` to `right` is "everything up to right" minus "everything before left".

The extra leading 0 removes the special case for `left == 0`.

## Complexity
- **Time: O(n)** to build, **O(1)** per query.
- **Space: O(n)**.

```python
class NumArray:
    def __init__(self, nums: list[int]):
        self.prefix = [0]
        for x in nums:
            self.prefix.append(self.prefix[-1] + x)

    def sumRange(self, left: int, right: int) -> int:
        return self.prefix[right + 1] - self.prefix[left]
```

# Tests

```python
def make(nums, qs):
    return [["NumArray"] + ["sumRange"] * len(qs), [[nums]] + [list(q) for q in qs]]

def edge():
    return [make([5], [(0, 0)]), make([-1, -2], [(0, 1), (1, 1), (0, 0)])]

def random_case(rng):
    n = rng.randint(1, 8)
    nums = [rng.randint(-10, 10) for _ in range(n)]
    qs = [tuple(sorted((rng.randrange(n), rng.randrange(n)))) for _ in range(rng.randint(1, 5))]
    return make(nums, qs)

def perf(rng):
    n = 10000
    nums = [rng.randint(-10**5, 10**5) for _ in range(n)]
    return [make(nums, [(0, n - 1)] * 10000)]
```
