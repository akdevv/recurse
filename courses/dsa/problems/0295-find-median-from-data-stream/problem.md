---
lc: 295
title: "Find Median from Data Stream"
difficulty: "Hard"
patterns: ["two-heaps"]
lcTags: ["two-pointers", "design", "sorting", "heap-priority-queue", "data-stream"]
compare: "float"
entry: {"method": "MedianFinder", "design": true, "params": [{"name": "operations", "type": "string[]"}, {"name": "arguments", "type": "list"}], "returns": "list", "voids": ["addNum"]}
examples: ["[\"MedianFinder\",\"addNum\",\"addNum\",\"findMedian\",\"addNum\",\"findMedian\"]\n[[],[1],[2],[],[3],[]]"]
---

The **median** is the middle value in an ordered integer list. If the size of the list is even, there is no middle value, and the median is the mean of the two middle values.

- For example, for `arr = [2,3,4]`, the median is `3`.
- For example, for `arr = [2,3]`, the median is `(2 + 3) / 2 = 2.5`.

Implement the MedianFinder class:

- `MedianFinder()` initializes the `MedianFinder` object.
- `void addNum(int num)` adds the integer `num` from the data stream to the data structure.
- `double findMedian()` returns the median of all elements so far. Answers within `10⁻⁵` of the actual answer will be accepted.

**Example 1:**

```
Input
["MedianFinder", "addNum", "addNum", "findMedian", "addNum", "findMedian"]
[[], [1], [2], [], [3], []]
Output
[null, null, null, 1.5, null, 2.0]

Explanation
MedianFinder medianFinder = new MedianFinder();
medianFinder.addNum(1);    // arr = [1]
medianFinder.addNum(2);    // arr = [1, 2]
medianFinder.findMedian(); // return 1.5 (i.e., (1 + 2) / 2)
medianFinder.addNum(3);    // arr[1, 2, 3]
medianFinder.findMedian(); // return 2.0
```

**Constraints:**

- `-10⁵ <= num <= 10⁵`
- There will be at least one element in the data structure before calling `findMedian`.
- At most `5 * 10⁴` calls will be made to `addNum` and `findMedian`.

**Follow up:**

- If all integer numbers from the stream are in the range `[0, 100]`, how would you optimize your solution?
- If `99%` of all integer numbers from the stream are in the range `[0, 100]`, how would you optimize your solution?

# Starter

```python
class MedianFinder:

    def __init__(self):
        

    def addNum(self, num: int) -> None:
        

    def findMedian(self) -> float:
        

# Your MedianFinder object will be instantiated and called as such:
# obj = MedianFinder()
# obj.addNum(num)
# param_2 = obj.findMedian()
```

# Hints

1. Split the numbers into a lower half and an upper half. The median only depends on the largest of the lower half and the smallest of the upper half.
2. Max-heap for the lower half, min-heap for the upper half. Keep sizes equal or lower one bigger by 1; move tops between heaps to rebalance.

# Key points

- two heaps: max-heap (lower half), min-heap (upper half)
- every lower value <= every upper value; sizes differ by at most 1
- median = top of the bigger heap, or the average of both tops
- O(log n) add, O(1) median

# Solution: min-heap-and-max-heap-priority-queue · Min Heap and Max Heap (Priority Queue) · O(log n) · O(n) · reference

We can use two heaps to maintain all the elements, a min heap minQ and a max heap maxQ, where the min heap minQ stores the larger half, and the max heap maxQ stores the smaller half.

When calling the `addNum` method, we first add the element to the max heap maxQ, then pop the top element of maxQ and add it to the min heap minQ. If at this time the size difference between minQ and maxQ is greater than 1, we pop the top element of minQ and add it to maxQ. The time complexity is O(log n).

When calling the `findMedian` method, if the size of minQ is equal to the size of maxQ, it means the total number of elements is even, and we can return the average value of the top elements of minQ and maxQ; otherwise, we return the top element of minQ. The time complexity is O(1).

The space complexity is O(n), where n is the number of elements.

```python
class MedianFinder:

    def __init__(self):
        self.minq = []
        self.maxq = []

    def addNum(self, num: int) -> None:
        heappush(self.minq, -heappushpop(self.maxq, -num))
        if len(self.minq) - len(self.maxq) > 1:
            heappush(self.maxq, -heappop(self.minq))

    def findMedian(self) -> float:
        if len(self.minq) == len(self.maxq):
            return (self.minq[0] - self.maxq[0]) / 2
        return self.minq[0]

# Your MedianFinder object will be instantiated and called as such:
# obj = MedianFinder()
# obj.addNum(num)
# param_2 = obj.findMedian()
```

# Tests

```python
def ops(rng, n):
    o, a, count = ["MedianFinder"], [[]], 0
    for _ in range(n):
        if count and rng.random() < 0.4:
            o.append("findMedian"); a.append([])
        else:
            o.append("addNum"); a.append([rng.randint(-10, 10)]); count += 1
    return [o, a]

def edge():
    return [[["MedianFinder", "addNum", "addNum", "findMedian", "addNum", "findMedian"], [[], [1], [2], [], [3], []]],
            [["MedianFinder", "addNum", "findMedian"], [[], [-100000], []]]]

def random_case(rng):
    return ops(rng, rng.randint(1, 15))

def perf(rng):
    return [ops(rng, 50000)]
```
