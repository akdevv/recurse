---
lc: 23
title: "Merge k Sorted Lists"
difficulty: "Hard"
patterns: ["k-way-merge"]
lcTags: ["linked-list", "divide-and-conquer", "heap-priority-queue", "merge-sort", "tournament-sort"]
entry: {"method": "mergeKLists", "params": [{"name": "lists", "type": "ListNode[]"}], "returns": "ListNode"}
examples: ["[[1,4,5],[1,3,4],[2,6]]", "[]", "[[]]"]
---

You are given an array of `k` linked-lists `lists`, each linked-list is sorted in ascending order.

*Merge all the linked-lists into one sorted linked-list and return it.*

**Example 1:**

```
Input: lists = [[1,4,5],[1,3,4],[2,6]]
Output: [1,1,2,3,4,4,5,6]
Explanation: The linked-lists are:
[
  1->4->5,
  1->3->4,
  2->6
]
merging them into one sorted linked list:
1->1->2->3->4->4->5->6
```

**Example 2:**

```
Input: lists = []
Output: []
```

**Example 3:**

```
Input: lists = [[]]
Output: []
```

**Constraints:**

- `k == lists.length`
- `0 <= k <= 10⁴`
- `0 <= lists[i].length <= 500`
- `-10⁴ <= lists[i][j] <= 10⁴`
- `lists[i]` is sorted in **ascending order**.
- The sum of `lists[i].length` will not exceed `10⁴`.

# Starter

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def mergeKLists(self, lists: list[ListNode | None]) -> ListNode | None:
        
```

# Hints

1. The next node of the result is the smallest head among the k lists. How do you find that quickly every time?
2. Push (value, index, node) for every list head into a min-heap. Pop the smallest, attach it, push its next node. (Or merge lists in pairs, divide and conquer.)

# Key points

- min-heap of the current heads, size <= k
- pop smallest, attach, push that node's successor
- O(N log k) time, N = total nodes
- the index in the tuple breaks ties so nodes are never compared

# Solution: priority-queue-min-heap · Priority Queue (Min Heap) · O(n × log k) · O(k) · reference

We can create a min heap pq to maintain the head nodes of all linked lists. Each time, we take out the node with the smallest value from the min heap, add it to the end of the result linked list, and then add the next node of this node to the heap. Repeat the above steps until the heap is empty.

The time complexity is O(n × log k), and the space complexity is O(k). Here, n is the total number of all linked list nodes, and k is the number of linked lists given in the problem.

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def mergeKLists(self, lists: List[Optional[ListNode]]) -> Optional[ListNode]:
        setattr(ListNode, "__lt__", lambda a, b: a.val < b.val)
        pq = [head for head in lists if head]
        heapify(pq)
        dummy = cur = ListNode()
        while pq:
            node = heappop(pq)
            if node.next:
                heappush(pq, node.next)
            cur.next = node
            cur = cur.next
        return dummy.next
```

# Tests

```python
def edge():
    return [[[]], [[[]]], [[[1, 4, 5], [1, 3, 4], [2, 6]]], [[[], [1]]], [[[1], [1], [1]]]]

def random_case(rng):
    return [[sorted(rng.randint(-5, 5) for _ in range(rng.randint(0, 4))) for _ in range(rng.randint(0, 5))]]

def perf(rng):
    return [[[sorted(rng.randint(-10**4, 10**4) for _ in range(10)) for _ in range(1000)]]]
```
