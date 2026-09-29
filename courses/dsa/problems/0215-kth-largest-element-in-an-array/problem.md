---
lc: 215
title: "Kth Largest Element in an Array"
difficulty: "Medium"
patterns: ["top-k-heap"]
lcTags: ["array", "divide-and-conquer", "sorting", "heap-priority-queue", "quickselect"]
entry: {"method": "findKthLargest", "params": [{"name": "nums", "type": "integer[]"}, {"name": "k", "type": "integer"}], "returns": "integer"}
examples: ["[3,2,1,5,6,4]\n2", "[3,2,3,1,2,4,5,5,6]\n4"]
---

Given an integer array `nums` and an integer `k`, return *the* `kᵗʰ` *largest element in the array*.

Note that it is the `kᵗʰ` largest element in the sorted order, not the `kᵗʰ` distinct element.

Can you solve it without sorting?

**Example 1:**

```
Input: nums = [3,2,1,5,6,4], k = 2
Output: 5
```

**Example 2:**

```
Input: nums = [3,2,3,1,2,4,5,5,6], k = 4
Output: 4
```

**Constraints:**

- `1 <= k <= nums.length <= 10⁵`
- `-10⁴ <= nums[i] <= 10⁴`

# Starter

```python
class Solution:
    def findKthLargest(self, nums: list[int], k: int) -> int:
        
```

# Hints

1. Sorting works in O(n log n). Can you avoid sorting everything when you only need one position?
2. Keep a min-heap of size k: push each number, pop when the heap grows past k. The heap's top is the answer. Quickselect is O(n) on average.

# Key points

- sort and index: O(n log n)
- min-heap of size k: O(n log k), top of the heap = kth largest
- quickselect: partition like quick sort but recurse into one side only, O(n) average
- duplicates count separately (kth largest in sorted order, not kth distinct)

# Solution: quick-select · Quick Select · O(n) · O(log n) · reference

Quick Select is an algorithm for finding the `k^{th}` largest or smallest element in an unsorted array. Its basic idea is to select a pivot element each time, dividing the array into two parts: one part contains elements smaller than the pivot, and the other part contains elements larger than the pivot. Then, based on the position of the pivot, it decides whether to continue the search on the left or right side until the `k^{th}` largest element is found.

The time complexity is O(n), and the space complexity is O(log n). Here, n is the length of the array nums.

```python
class Solution:
    def findKthLargest(self, nums: List[int], k: int) -> int:
        def quick_sort(l: int, r: int) -> int:
            if l == r:
                return nums[l]
            i, j = l - 1, r + 1
            x = nums[(l + r) >> 1]
            while i < j:
                while 1:
                    i += 1
                    if nums[i] >= x:
                        break
                while 1:
                    j -= 1
                    if nums[j] <= x:
                        break
                if i < j:
                    nums[i], nums[j] = nums[j], nums[i]
            if j < k:
                return quick_sort(j + 1, r)
            return quick_sort(l, j)

        n = len(nums)
        k = n - k
        return quick_sort(0, n - 1)
```

# Solution: priority-queue-min-heap · Priority Queue (Min Heap) · O(nlog k) · O(k)

We can maintain a min heap minQ of size k, and then iterate through the array nums, adding each element to the min heap. When the size of the min heap exceeds k, we pop the top element of the heap. This way, the final k elements in the min heap are the k largest elements in the array, and the top element of the heap is the `k^{th}` largest element.

The time complexity is O(nlog k), and the space complexity is O(k). Here, n is the length of the array nums.

```python
class Solution:
    def findKthLargest(self, nums: List[int], k: int) -> int:
        return nlargest(k, nums)[-1]
```

# Solution: counting-sort · Counting Sort · O(n + m) · O(n)

We can use the idea of counting sort, counting the occurrence of each element in the array nums and recording it in a hash table cnt. Then, we iterate over the elements i from largest to smallest, subtracting the occurrence count `cnt[i]` each time, until k is less than or equal to 0. At this point, the element i is the `k^{th}` largest element in the array.

The time complexity is O(n + m), and the space complexity is O(n). Here, n is the length of the array nums, and m is the maximum value among the elements in nums.

```python
class Solution:
    def findKthLargest(self, nums: List[int], k: int) -> int:
        cnt = Counter(nums)
        for i in count(max(cnt), -1):
            k -= cnt[i]
            if k <= 0:
                return i
```

# Tests

```python
def edge():
    return [[[1], 1], [[2, 1], 1], [[2, 1], 2], [[3, 3, 3], 2], [[3, 2, 3, 1, 2, 4, 5, 5, 6], 4], [[-1, -1], 2]]

def random_case(rng):
    n = rng.randint(1, 10)
    return [[rng.randint(-10, 10) for _ in range(n)], rng.randint(1, n)]

def perf(rng):
    return [[[rng.randint(-10**4, 10**4) for _ in range(100000)], 50000], [[1] * 100000, 1]]
```
