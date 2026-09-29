---
lc: 26
title: "Remove Duplicates from Sorted Array"
difficulty: "Easy"
patterns: ["two-pointers"]
lcTags: ["array", "two-pointers"]
entry: {"method": "removeDuplicates", "params": [{"name": "nums", "type": "integer[]"}], "returns": "integer", "outputParam": 0, "kPrefix": "ordered"}
examples: ["[1,1,2]", "[0,0,1,1,1,2,2,3,3,4]"]
lcHints: ["In this problem, the key point to focus on is the input array being sorted. As far as duplicate elements are concerned, what is their positioning in the array when the given array is sorted? Look at the image below for the answer. If we know the position of one of the elements, do we also know the positioning of all the duplicate elements?\r\n\r\n<br>\r\n<img src=\"https://assets.leetcode.com/uploads/2019/10/20/hint_rem_dup.png\" width=\"500\"/>", "We need to modify the array in-place and the size of the final array would potentially be smaller than the size of the input array. So, we ought to use a two-pointer approach here. One, that would keep track of the current element in the original array and another one for just the unique elements.", "Essentially, once an element is encountered, you simply need to <b>bypass</b> its duplicates and move on to the next unique element."]
---

Given an integer array `nums` sorted in **non-decreasing order**, remove the duplicates [**in-place**](https://en.wikipedia.org/wiki/In-place_algorithm) such that each unique element appears only **once**. The **relative order** of the elements should be kept the **same**.

Consider the number of *unique elements* in `nums` to be `k**​​​​​​​**`​​​​​​​. After removing duplicates, return the number of unique elements `k`.

The first `k` elements of `nums` should contain the unique numbers in **sorted order**. The remaining elements beyond index `k - 1` can be ignored.

**Custom Judge:**

The judge will test your solution with the following code:

```
int[] nums = [...]; // Input array
int[] expectedNums = [...]; // The expected answer with correct length

int k = removeDuplicates(nums); // Calls your implementation

assert k == expectedNums.length;
for (int i = 0; i < k; i++) {
    assert nums[i] == expectedNums[i];
}
```

If all assertions pass, then your solution will be **accepted**.

**Example 1:**

```
Input: nums = [1,1,2]
Output: 2, nums = [1,2,_]
Explanation: Your function should return k = 2, with the first two elements of nums being 1 and 2 respectively.
It does not matter what you leave beyond the returned k (hence they are underscores).
```

**Example 2:**

```
Input: nums = [0,0,1,1,1,2,2,3,3,4]
Output: 5, nums = [0,1,2,3,4,_,_,_,_,_]
Explanation: Your function should return k = 5, with the first five elements of nums being 0, 1, 2, 3, and 4 respectively.
It does not matter what you leave beyond the returned k (hence they are underscores).
```

**Constraints:**

- `1 <= nums.length <= 3 * 10⁴`
- `-100 <= nums[i] <= 100`
- `nums` is sorted in **non-decreasing** order.

# Starter

```python
class Solution:
    def removeDuplicates(self, nums: list[int]) -> int:
        
```

# Hints

1. Equal values are next to each other because the array is sorted. How do you know a value is new?
2. Keep a write index k. Walk with a read index; when nums[i] differs from nums[k − 1], write it at nums[k] and increase k.

# Key points

- sorted → duplicates are adjacent, a value is new if it differs from the last kept one
- read pointer scans, write pointer marks where the next unique value goes
- O(n) time, O(1) space, in place
- return k; only the first k slots matter

# Solution: write-pointer · Read and write pointers · O(n) · O(1) · reference

## Idea
`k` is the length of the unique prefix built so far. A value is new exactly when it differs from the last kept value `nums[k - 1]`. Copy it to `nums[k]` and grow the prefix.

## Complexity
- **Time: O(n)**.
- **Space: O(1)**.

```python
class Solution:
    def removeDuplicates(self, nums: list[int]) -> int:
        k = 1
        for i in range(1, len(nums)):
            if nums[i] != nums[k - 1]:
                nums[k] = nums[i]
                k += 1
        return k
```

# Tests

```python
def edge():
    return [[[1]], [[1, 1]], [[1, 2]], [[1, 1, 1, 1]], [[-100, 0, 0, 100]], [[0, 0, 1, 1, 1, 2, 2, 3, 3, 4]]]

def random_case(rng):
    return [sorted(rng.randint(-5, 5) for _ in range(rng.randint(1, 12)))]

def perf(rng):
    return [[sorted(rng.randint(-100, 100) for _ in range(30000))]]
```
