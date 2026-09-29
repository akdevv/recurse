---
lc: 141
title: "Linked List Cycle"
difficulty: "Easy"
patterns: ["fast-slow-pointers"]
lcTags: ["hash-table", "linked-list", "two-pointers", "floyds-cycle-finding-algorithm"]
entry: {"method": "hasCycle", "params": [{"name": "head", "type": "ListNode"}, {"name": "pos", "type": "integer"}], "returns": "boolean", "interactive": true}
examples: ["[3,2,0,-4]\n1", "[1,2]\n0", "[1]\n-1"]
---

Given `head`, the head of a linked list, determine if the linked list has a cycle in it.

There is a cycle in a linked list if there is some node in the list that can be reached again by continuously following the `next` pointer. Internally, `pos` is used to denote the index of the node that tail's `next` pointer is connected to. **Note that `pos` is not passed as a parameter**.

Return `true` *if there is a cycle in the linked list*. Otherwise, return `false`.

**Example 1:**

![](https://assets.leetcode.com/uploads/2018/12/07/circularlinkedlist.png)

```
Input: head = [3,2,0,-4], pos = 1
Output: true
Explanation: There is a cycle in the linked list, where the tail connects to the 1st node (0-indexed).
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2018/12/07/circularlinkedlist_test2.png)

```
Input: head = [1,2], pos = 0
Output: true
Explanation: There is a cycle in the linked list, where the tail connects to the 0th node.
```

**Example 3:**

![](https://assets.leetcode.com/uploads/2018/12/07/circularlinkedlist_test3.png)

```
Input: head = [1], pos = -1
Output: false
Explanation: There is no cycle in the linked list.
```

**Constraints:**

- The number of the nodes in the list is in the range `[0, 10⁴]`.
- `-10⁵ <= Node.val <= 10⁵`
- `pos` is `-1` or a **valid index** in the linked-list.

**Follow up:** Can you solve it using `O(1)` (i.e. constant) memory?

# Starter

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, x):
#         self.val = x
#         self.next = None

class Solution:
    def hasCycle(self, head: Optional[ListNode]) -> bool:
        
```

# Hints

1. A set of visited nodes works. For O(1) memory: what happens to two runners of different speeds on a circular track?
2. slow moves 1 step, fast moves 2. If fast reaches None there's no cycle; if slow == fast at some point, there is one.

# Key points

- visited set: O(n) space
- Floyd: fast gains one step per move, so inside a cycle it must land on slow
- fast reaching None means no cycle
- O(n) time, O(1) space

# Solution: hash-table · Hash Table · O(n) · O(n) · reference

We can traverse the linked list and use a hash table s to record each node. When a node appears for the second time, it indicates that there is a cycle, and we directly return `true`. Otherwise, when the linked list traversal ends, we return `false`.

The time complexity is O(n), and the space complexity is O(n), where n is the number of nodes in the linked list.

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, x):
#         self.val = x
#         self.next = None

class Solution:
    def hasCycle(self, head: Optional[ListNode]) -> bool:
        s = set()
        while head:
            if head in s:
                return True
            s.add(head)
            head = head.next
        return False
```

# Solution: fast-and-slow-pointers · Fast and Slow Pointers · O(n) · O(1)

We define two pointers, fast and slow, both initially pointing to head.

The fast pointer moves two steps at a time, and the slow pointer moves one step at a time, in a continuous loop. When the fast and slow pointers meet, it indicates that there is a cycle in the linked list. If the loop ends without the pointers meeting, it indicates that there is no cycle in the linked list.

The time complexity is O(n), and the space complexity is O(1), where n is the number of nodes in the linked list.

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, x):
#         self.val = x
#         self.next = None

class Solution:
    def hasCycle(self, head: ListNode) -> bool:
        slow = fast = head
        while fast and fast.next:
            slow, fast = slow.next, fast.next.next
            if slow == fast:
                return True
        return False
```

# Tests

```python
def prepare(args):
    vals, pos = args
    head = to_list_node(vals)
    nodes = []
    n = head
    while n:
        nodes.append(n)
        n = n.next
    if pos >= 0:
        nodes[-1].next = nodes[pos]
    return [head], {}

def edge():
    return [[[], -1], [[1], -1], [[1], 0], [[1, 2], 0], [[1, 2], 1], [[3, 2, 0, -4], 1]]

def random_case(rng):
    n = rng.randint(0, 10)
    return [[rng.randint(-5, 5) for _ in range(n)], rng.randint(-1, n - 1) if n and rng.random() < 0.6 else -1]

def perf(rng):
    return [[list(range(10000)), 0], [list(range(10000)), -1]]
```
