---
lc: 703
title: "Kth Largest Element in a Stream"
difficulty: "Easy"
patterns: ["top-k-heap"]
lcTags: ["tree", "design", "binary-search-tree", "heap-priority-queue", "binary-tree", "data-stream"]
entry: {"method": "KthLargest", "design": true, "params": [{"name": "operations", "type": "string[]"}, {"name": "arguments", "type": "list"}], "returns": "list", "voids": []}
examples: ["[\"KthLargest\",\"add\",\"add\",\"add\",\"add\",\"add\"]\n[[3,[4,5,8,2]],[3],[5],[10],[9],[4]]", "[\"KthLargest\",\"add\",\"add\",\"add\",\"add\"]\n[[4,[7,7,7,7,8,3]],[2],[10],[9],[9]]"]
---

You are part of a university admissions office and need to keep track of the `kth` highest test score from applicants in real-time. This helps to determine cut-off marks for interviews and admissions dynamically as new applicants submit their scores.

You are tasked to implement a class which, for a given integer `k`, maintains a stream of test scores and continuously returns the `k`th highest test score **after** a new score has been submitted. More specifically, we are looking for the `k`th highest score in the sorted list of all scores.

Implement the `KthLargest` class:

- `KthLargest(int k, int[] nums)` Initializes the object with the integer `k` and the stream of test scores `nums`.
- `int add(int val)` Adds a new test score `val` to the stream and returns the element representing the `kᵗʰ` largest element in the pool of test scores so far.

**Example 1:**

**Input:**<br> ["KthLargest", "add", "add", "add", "add", "add"]<br> [[3, [4, 5, 8, 2]], [3], [5], [10], [9], [4]]

**Output:** [null, 4, 5, 5, 8, 8]

**Explanation:**

KthLargest kthLargest = new KthLargest(3, [4, 5, 8, 2]);<br> kthLargest.add(3); // return 4<br> kthLargest.add(5); // return 5<br> kthLargest.add(10); // return 5<br> kthLargest.add(9); // return 8<br> kthLargest.add(4); // return 8

**Example 2:**

**Input:**<br> ["KthLargest", "add", "add", "add", "add"]<br> [[4, [7, 7, 7, 7, 8, 3]], [2], [10], [9], [9]]

**Output:** [null, 7, 7, 7, 8]

**Explanation:**

KthLargest kthLargest = new KthLargest(4, [7, 7, 7, 7, 8, 3]);<br> kthLargest.add(2); // return 7<br> kthLargest.add(10); // return 7<br> kthLargest.add(9); // return 7<br> kthLargest.add(9); // return 8

**Constraints:**

- `0 <= nums.length <= 10⁴`
- `1 <= k <= nums.length + 1`
- `-10⁴ <= nums[i] <= 10⁴`
- `-10⁴ <= val <= 10⁴`
- At most `10⁴` calls will be made to `add`.

# Starter

```python
class KthLargest:

    def __init__(self, k: int, nums: list[int]):
        

    def add(self, val: int) -> int:
        

# Your KthLargest object will be instantiated and called as such:
# obj = KthLargest(k, nums)
# param_1 = obj.add(val)
```

# Hints

1. You only ever need the k largest values seen so far. What's the smallest of those?
2. Keep a min-heap of size k. On add, push the value and pop if the heap has more than k items. The heap's top is the answer.

# Key points

- min-heap holding the k largest values
- top of that heap = kth largest overall
- O(log k) per add, O(k) space

# Solution: priority-queue-min-heap · Priority Queue (Min Heap) · O(n × log k) · O(k) · reference

We maintain a priority queue (min heap) minQ.

Initially, we add the elements of the array nums to minQ one by one, ensuring that the size of minQ does not exceed k. The time complexity is O(n × log k).

Each time a new element is added, if the size of minQ exceeds k, we pop the top element of the heap to ensure that the size of minQ is k. The time complexity is O(log k).

In this way, the elements in minQ are the largest k elements in the array nums, and the top element of the heap is the `k^{th}` largest element.

The space complexity is O(k).

```python
class KthLargest:

    def __init__(self, k: int, nums: List[int]):
        self.k = k
        self.min_q = []
        for x in nums:
            self.add(x)

    def add(self, val: int) -> int:
        heappush(self.min_q, val)
        if len(self.min_q) > self.k:
            heappop(self.min_q)
        return self.min_q[0]

# Your KthLargest object will be instantiated and called as such:
# obj = KthLargest(k, nums)
# param_1 = obj.add(val)
```

# Tests

```python
def ops(rng, k, nums, adds):
    return [["KthLargest"] + ["add"] * len(adds), [[k, nums]] + [[v] for v in adds]]

def edge():
    return [ops(None, 3, [4, 5, 8, 2], [3, 5, 10, 9, 4]), ops(None, 1, [], [-3, -2, -4, 0, 4]), ops(None, 2, [0], [-1, 1, -2, -4, 3])]

def random_case(rng):
    nums = [rng.randint(-10, 10) for _ in range(rng.randint(0, 6))]
    k = rng.randint(1, len(nums) + 1)
    return ops(rng, k, nums, [rng.randint(-10, 10) for _ in range(rng.randint(1, 8))])

def perf(rng):
    nums = [rng.randint(-10**4, 10**4) for _ in range(10000)]
    return [ops(rng, 5000, nums, [rng.randint(-10**4, 10**4) for _ in range(10000)])]
```
