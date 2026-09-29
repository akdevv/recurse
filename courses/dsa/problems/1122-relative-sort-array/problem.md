---
lc: 1122
title: "Relative Sort Array"
difficulty: "Easy"
patterns: ["cyclic-sort", "hash-map"]
lcTags: ["array", "hash-table", "sorting", "counting-sort", "quicksort", "bubble-sort"]
entry: {"method": "relativeSortArray", "params": [{"name": "arr1", "type": "integer[]"}, {"name": "arr2", "type": "integer[]"}], "returns": "integer[]"}
examples: ["[2,3,1,3,2,4,6,7,9,2,19]\n[2,1,4,3,9,6]", "[28,6,22,8,44,17]\n[22,28,8,6]"]
lcHints: ["Using a hashmap, we can map the values of arr2 to their position in arr2.", "After, we can use a custom sorting function."]
---

Given two arrays `arr1` and `arr2`, the elements of `arr2` are distinct, and all elements in `arr2` are also in `arr1`.

Sort the elements of `arr1` such that the relative ordering of items in `arr1` are the same as in `arr2`. Elements that do not appear in `arr2` should be placed at the end of `arr1` in **ascending** order.

**Example 1:**

```
Input: arr1 = [2,3,1,3,2,4,6,7,9,2,19], arr2 = [2,1,4,3,9,6]
Output: [2,2,2,1,4,3,3,9,6,7,19]
```

**Example 2:**

```
Input: arr1 = [28,6,22,8,44,17], arr2 = [22,28,8,6]
Output: [22,28,8,6,17,44]
```

**Constraints:**

- `1 <= arr1.length, arr2.length <= 1000`
- `0 <= arr1[i], arr2[i] <= 1000`
- All the elements of `arr2` are **distinct**.
- Each `arr2[i]` is in `arr1`.

# Starter

```python
class Solution:
    def relativeSortArray(self, arr1: list[int], arr2: list[int]) -> list[int]:
        
```

# Hints

1. Values are between 0 and 1000. Count how many times each value appears in arr1.
2. Walk arr2 and output each value as many times as it was counted. Then output the remaining values in increasing order.

# Key points

- count arr1 values (array of 1001 or a Counter)
- emit arr2's values first, in arr2's order, with their counts
- then the leftovers in ascending order
- O(n + m + range) time with counting

# Solution: custom-sorting · Custom Sorting · O(n × log n + m) · O(n + m) · reference

First, we use a hash table pos to record the position of each element in array arr2. Then, we map each element in array arr1 to a tuple `(pos.get(x, 1000 + x), x)`, and sort these tuples. Finally, we take out the second element of all tuples and return it.

The time complexity is O(n × log n + m), and the space complexity is O(n + m). Here, n and m are the lengths of arrays arr1 and arr2, respectively.

```python
class Solution:
    def relativeSortArray(self, arr1: List[int], arr2: List[int]) -> List[int]:
        pos = {x: i for i, x in enumerate(arr2)}
        return sorted(arr1, key=lambda x: pos.get(x, 1000 + x))
```

# Solution: counting-sort · Counting Sort · O(n + m) · O(n)

We can use the idea of counting sort. First, count the occurrence of each element in array arr1. Then, according to the order in array arr2, put the elements in arr1 into the answer array ans according to their occurrence. Finally, we traverse all elements in arr1 and put the elements that do not appear in arr2 in ascending order at the end of the answer array ans.

The time complexity is O(n + m), and the space complexity is O(n). Where n and m are the lengths of arrays arr1 and arr2 respectively.

```python
class Solution:
    def relativeSortArray(self, arr1: List[int], arr2: List[int]) -> List[int]:
        cnt = Counter(arr1)
        ans = []
        for x in arr2:
            ans.extend([x] * cnt[x])
            cnt.pop(x)
        mi, mx = min(arr1), max(arr1)
        for x in range(mi, mx + 1):
            ans.extend([x] * cnt[x])
        return ans
```

# Tests

```python
def edge():
    return [[[1], [1]], [[2, 1], [1]], [[2, 3, 1, 3, 2, 4, 6, 7, 9, 2, 19], [2, 1, 4, 3, 9, 6]], [[28, 6, 22, 8, 44, 17], [22, 28, 8, 6]], [[0, 1000, 5], [5]]]

def random_case(rng):
    arr1 = [rng.randint(0, 12) for _ in range(rng.randint(1, 10))]
    distinct = list(set(arr1))
    rng.shuffle(distinct)
    return [arr1, distinct[: rng.randint(1, len(distinct))]]

def perf(rng):
    arr1 = [rng.randint(0, 1000) for _ in range(1000)]
    arr2 = list(set(arr1))[:1000]
    rng.shuffle(arr2)
    return [[arr1, arr2]]
```
