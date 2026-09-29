---
lc: 912
title: "Sort an Array"
difficulty: "Medium"
patterns: ["divide-and-conquer"]
lcTags: ["array", "divide-and-conquer", "sorting", "heap-priority-queue", "merge-sort", "bucket-sort", "radix-sort", "counting-sort"]
entry: {"method": "sortArray", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer[]"}
examples: ["[5,2,3,1]", "[5,1,1,2,0,0]"]
---

Given an array of integers `nums`, sort the array in ascending order and return it.

You must solve the problem **without using any built-in** functions in `O(nlog(n))` time complexity and with the smallest space complexity possible.

**Example 1:**

```
Input: nums = [5,2,3,1]
Output: [1,2,3,5]
Explanation: After sorting the array, the positions of some numbers are not changed (for example, 2 and 3), while the positions of other numbers are changed (for example, 1 and 5).
```

**Example 2:**

```
Input: nums = [5,1,1,2,0,0]
Output: [0,0,1,1,2,5]
Explanation: Note that the values of nums are not necessarily unique.
```

**Constraints:**

- `1 <= nums.length <= 5 * 10⁴`
- `-5 * 10⁴ <= nums[i] <= 5 * 10⁴`

# Starter

```python
class Solution:
    def sortArray(self, nums: list[int]) -> list[int]:
        
```

# Hints

1. You need O(n log n) without built-ins. Which sorts guarantee that in the worst case?
2. Merge sort: sort each half recursively, then merge the two sorted halves with two pointers.

# Key points

- merge sort: split in half, sort both, merge → O(n log n) always, O(n) extra space
- quick sort: partition around a pivot; random pivot avoids the O(n²) worst case on sorted input
- insertion/bubble/selection sort are O(n²) and time out
- values in a small range → counting sort is O(n + range)

# Solution: solution-1 · Quick sort (random pivot, 3-way partition) · O(n log n) average · O(log n) · reference

## Idea
Quick sort with a random pivot and a three-way partition (less, equal, greater). The random pivot avoids the O(n²) worst case on sorted input, and grouping equal values handles many duplicates.

## Complexity
- **Time: O(n log n) average**
- **Space: O(log n)**

```python
class Solution:
    def sortArray(self, nums: List[int]) -> List[int]:
        def quick_sort(l, r):
            if l >= r:
                return
            x = nums[randint(l, r)]
            i, j, k = l - 1, r + 1, l
            while k < j:
                if nums[k] < x:
                    nums[i + 1], nums[k] = nums[k], nums[i + 1]
                    i, k = i + 1, k + 1
                elif nums[k] > x:
                    j -= 1
                    nums[j], nums[k] = nums[k], nums[j]
                else:
                    k = k + 1
            quick_sort(l, i)
            quick_sort(j, r)

        quick_sort(0, len(nums) - 1)
        return nums
```

# Solution: solution-2 · Merge sort · O(n log n) · O(n)

## Idea
Merge sort: sort the left and right halves recursively, then merge them with two pointers into a temporary list and copy it back. Always O(n log n).

## Complexity
- **Time: O(n log n)**
- **Space: O(n)**

```python
class Solution:
    def sortArray(self, nums: List[int]) -> List[int]:
        def merge_sort(l, r):
            if l >= r:
                return
            mid = (l + r) >> 1
            merge_sort(l, mid)
            merge_sort(mid + 1, r)
            i, j = l, mid + 1
            tmp = []
            while i <= mid and j <= r:
                if nums[i] <= nums[j]:
                    tmp.append(nums[i])
                    i += 1
                else:
                    tmp.append(nums[j])
                    j += 1
            if i <= mid:
                tmp.extend(nums[i : mid + 1])
            if j <= r:
                tmp.extend(nums[j : r + 1])
            for i in range(l, r + 1):
                nums[i] = tmp[i - l]

        merge_sort(0, len(nums) - 1)
        return nums
```

# Tests

```python
def edge():
    return [[[1]], [[2, 1]], [[5, 2, 3, 1]], [[5, 1, 1, 2, 0, 0]], [[-50000, 50000, 0]], [[3, 3, 3]]]

def random_case(rng):
    return [[rng.randint(-10, 10) for _ in range(rng.randint(1, 12))]]

def perf(rng):
    return [[[rng.randint(-50000, 50000) for _ in range(50000)]], [list(range(50000))], [[7] * 50000]]
```
