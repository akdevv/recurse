---
lc: 239
title: "Sliding Window Maximum"
difficulty: "Hard"
patterns: ["monotonic-stack", "sliding-window"]
lcTags: ["array", "queue", "sliding-window", "heap-priority-queue", "monotonic-queue", "range-minimum-maximum-query"]
entry: {"method": "maxSlidingWindow", "params": [{"name": "nums", "type": "integer[]"}, {"name": "k", "type": "integer"}], "returns": "integer[]"}
examples: ["[1,3,-1,-3,5,3,6,7]\n3", "[1]\n1"]
lcHints: ["How about using a data structure such as deque (double-ended queue)?", "The queue size need not be the same as the window’s size.", "Remove redundant elements and the queue should store only elements that need to be considered."]
---

You are given an array of integers `nums`, there is a sliding window of size `k` which is moving from the very left of the array to the very right. You can only see the `k` numbers in the window. Each time the sliding window moves right by one position.

Return *the max sliding window*.

**Example 1:**

```
Input: nums = [1,3,-1,-3,5,3,6,7], k = 3
Output: [3,3,5,5,6,7]
Explanation:
Window position                Max
---------------               -----
[1  3  -1] -3  5  3  6  7       3
 1 [3  -1  -3] 5  3  6  7       3
 1  3 [-1  -3  5] 3  6  7       5
 1  3  -1 [-3  5  3] 6  7       5
 1  3  -1  -3 [5  3  6] 7       6
 1  3  -1  -3  5 [3  6  7]      7
```

**Example 2:**

```
Input: nums = [1], k = 1
Output: [1]
```

**Constraints:**

- `1 <= nums.length <= 10⁵`
- `-10⁴ <= nums[i] <= 10⁴`
- `1 <= k <= nums.length`

# Starter

```python
class Solution:
    def maxSlidingWindow(self, nums: list[int], k: int) -> list[int]:
        
```

# Hints

1. A smaller element that comes before a bigger one inside the window can never be the maximum again.
2. Keep a deque of indices with decreasing values. Pop from the back while the new value is bigger; pop from the front when that index leaves the window. The front is the max.

# Key points

- monotonic decreasing deque of indices
- back: remove smaller values (they're useless); front: remove indices outside the window
- front of the deque is the window maximum
- O(n) time, each index enters and leaves once

# Solution: priority-queue-max-heap · Priority Queue (Max-Heap) · O(n × log k) · O(k) · reference

We can use a priority queue (max-heap) to maintain the maximum value in the sliding window.

First, add the first `k-1` elements to the priority queue. Then, starting from the k-th element, add the new element to the priority queue and check if the top element of the heap is out of the window. If it is, remove the top element. Then, add the top element of the heap to the result array.

The time complexity is O(n × log k), and the space complexity is O(k). Here, n is the length of the array.

```python
class Solution:
    def maxSlidingWindow(self, nums: List[int], k: int) -> List[int]:
        q = [(-v, i) for i, v in enumerate(nums[: k - 1])]
        heapify(q)
        ans = []
        for i in range(k - 1, len(nums)):
            heappush(q, (-nums[i], i))
            while q[0][1] <= i - k:
                heappop(q)
            ans.append(-q[0][0])
        return ans
```

# Solution: monotonic-queue · Monotonic Queue · O(n) · O(k)

To find the maximum value in a sliding window, a common method is to use a monotonic queue.

We can maintain a queue q that is monotonically decreasing from the front to the back, storing the indices of the elements. As we traverse the array nums, for the current element `nums[i]`, we first check if the front element of the queue is out of the window. If it is, we remove the front element. Then, we compare the current element `nums[i]` with the elements at the back of the queue. If the elements at the back are less than or equal to the current element, we remove them until the element at the back is greater than the current element or the queue is empty. Then, we add the index of the current element to the queue. At this point, the front element of the queue is the maximum value of the current sliding window. Note that we add the front element of the queue to the result array when the index i is greater than or equal to `k-1`.

The time complexity is O(n), and the space complexity is O(k). Here, n is the length of the array nums.

```python
class Solution:
    def maxSlidingWindow(self, nums: List[int], k: int) -> List[int]:
        q = deque()
        ans = []
        for i, x in enumerate(nums):
            if q and i - q[0] >= k:
                q.popleft()
            while q and nums[q[-1]] <= x:
                q.pop()
            q.append(i)
            if i >= k - 1:
                ans.append(nums[q[0]])
        return ans
```

# Tests

```python

```
