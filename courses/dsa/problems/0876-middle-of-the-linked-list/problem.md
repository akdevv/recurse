---
lc: 876
title: "Middle of the Linked List"
difficulty: "Easy"
patterns: ["fast-slow-pointers"]
lcTags: ["linked-list", "two-pointers"]
entry: {"method": "middleNode", "params": [{"name": "head", "type": "ListNode"}], "returns": "ListNode"}
examples: ["[1,2,3,4,5]", "[1,2,3,4,5,6]"]
---

Given the `head` of a singly linked list, return *the middle node of the linked list*.

If there are two middle nodes, return **the second middle** node.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/07/23/lc-midlist1.jpg)

```
Input: head = [1,2,3,4,5]
Output: [3,4,5]
Explanation: The middle node of the list is node 3.
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2021/07/23/lc-midlist2.jpg)

```
Input: head = [1,2,3,4,5,6]
Output: [4,5,6]
Explanation: Since the list has two middle nodes with values 3 and 4, we return the second one.
```

**Constraints:**

- The number of nodes in the list is in the range `[1, 100]`.
- `1 <= Node.val <= 100`

# Starter

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def middleNode(self, head: ListNode | None) -> ListNode | None:
        
```

# Hints

1. Move one pointer twice as fast as another. Where is the slow one when the fast one reaches the end?
2. slow = fast = head; while fast and fast.next: slow = slow.next, fast = fast.next.next. Return slow.

# Key points

- fast moves 2 steps, slow 1 step: slow ends at the middle
- `while fast and fast.next` returns the second middle for even lengths
- one pass, O(1) space (vs counting the length first)

# Solution: fast-and-slow-pointers · Fast and Slow Pointers · O(n) · O(1) · reference

We define two pointers fast and slow, both initially pointing to the head of the linked list.

The fast pointer fast moves two steps at a time, while the slow pointer slow moves one step at a time. When the fast pointer reaches the end of the linked list, the node pointed to by the slow pointer is the middle node.

The time complexity is O(n), where n is the length of the linked list. The space complexity is O(1).

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def middleNode(self, head: ListNode) -> ListNode:
        slow = fast = head
        while fast and fast.next:
            slow, fast = slow.next, fast.next.next
        return slow
```

# Tests

```python

```
