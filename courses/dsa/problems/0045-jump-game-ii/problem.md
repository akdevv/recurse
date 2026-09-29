---
lc: 45
title: "Jump Game II"
difficulty: "Medium"
patterns: ["greedy", "bfs"]
lcTags: ["array", "dynamic-programming", "greedy"]
entry: {"method": "jump", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer"}
examples: ["[2,3,1,1,4]", "[2,3,0,1,4]"]
---

You are given a **0-indexed** array of integers `nums` of length `n`. You are initially positioned at index 0.

Each element `nums[i]` represents the maximum length of a forward jump from index `i`. In other words, if you are at index `i`, you can jump to any index `(i + j)` where:

- `0 <= j <= nums[i]` and
- `i + j < n`

Return *the minimum number of jumps to reach index* `n - 1`. The test cases are generated such that you can reach index `n - 1`.

**Example 1:**

```
Input: nums = [2,3,1,1,4]
Output: 2
Explanation: The minimum number of jumps to reach the last index is 2. Jump 1 step from index 0 to 1, then 3 steps to the last index.
```

**Example 2:**

```
Input: nums = [2,3,0,1,4]
Output: 2
```

**Constraints:**

- `1 <= nums.length <= 10⁴`
- `0 <= nums[i] <= 1000`
- It's guaranteed that you can reach `nums[n - 1]`.

# Starter

```python
class Solution:
    def jump(self, nums: list[int]) -> int:
        
```

# Hints

1. Think of it as BFS by levels: all indices reachable with j jumps form a range.
2. Keep the end of the current range and the farthest reach from it. When i reaches the current end, you must jump: jumps += 1, end = farthest.

# Key points

- implicit BFS: each "level" is a range of indices
- jump when you pass the current range's end
- O(n) time, O(1) space

# Solution: greedy-algorithm · Greedy Algorithm · O(n) · O(1) · reference

We can use a variable mx to record the farthest position that can be reached from the current position, a variable last to record the position of the last jump, and a variable ans to record the number of jumps.

Next, we traverse each position i in `[0,..n - 2]`. For each position i, we can calculate the farthest position that can be reached from the current position through `i + nums[i]`. We use mx to record this farthest position, that is, `mx = max(mx, i + nums[i])`. Then, we check whether the current position has reached the boundary of the last jump, that is, `i = last`. If it has reached, then we need to make a jump, update last to mx, and increase the number of jumps ans by 1.

Finally, we return the number of jumps ans.

The time complexity is O(n), where n is the length of the array. The space complexity is O(1).

Similar problems:

- [55. Jump Game](https://github.com/doocs/leetcode/blob/main/solution/0000-0099/0055.Jump%20Game/README_EN.md)
- [1024. Video Stitching](https://github.com/doocs/leetcode/blob/main/solution/1000-1099/1024.Video%20Stitching/README_EN.md)
- [1326. Minimum Number of Taps to Open to Water a Garden](https://github.com/doocs/leetcode/blob/main/solution/1300-1399/1326.Minimum%20Number%20of%20Taps%20to%20Open%20to%20Water%20a%20Garden/README_EN.md)

```python
class Solution:
    def jump(self, nums: List[int]) -> int:
        ans = mx = last = 0
        for i, x in enumerate(nums[:-1]):
            mx = max(mx, i + x)
            if last == i:
                ans += 1
                last = mx
        return ans
```

# Tests

```python
def edge():
    return [[[0]], [[1]], [[2, 3, 1, 1, 4]], [[2, 3, 0, 1, 4]], [[1, 1, 1, 1]], [[5, 0, 0, 0, 0, 0]]]

def random_case(rng):
    n = rng.randint(1, 10)
    while True:
        nums = [rng.randint(0, 3) for _ in range(n)]
        far = 0
        for i, x in enumerate(nums):
            if i > far:
                break
            far = max(far, i + x)
        if far >= n - 1:
            return [nums]

def perf(rng):
    return [[[1] * 10000], [[rng.randint(1, 1000) for _ in range(10000)]]]
```
