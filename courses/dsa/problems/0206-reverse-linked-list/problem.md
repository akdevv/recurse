---
lc: 206
title: "Reverse Linked List"
difficulty: "Easy"
patterns: ["list-reversal"]
lcTags: ["linked-list", "recursion"]
entry: {"method": "reverseList", "params": [{"name": "head", "type": "ListNode"}], "returns": "ListNode"}
examples: ["[1,2,3,4,5]", "[1,2]", "[]"]
---

Given the `head` of a singly linked list, reverse the list, and return *the reversed list*.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/02/19/rev1ex1.jpg)

```
Input: head = [1,2,3,4,5]
Output: [5,4,3,2,1]
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2021/02/19/rev1ex2.jpg)

```
Input: head = [1,2]
Output: [2,1]
```

**Example 3:**

```
Input: head = []
Output: []
```

**Constraints:**

- The number of nodes in the list is the range `[0, 5000]`.
- `-5000 <= Node.val <= 5000`

**Follow up:** A linked list can be reversed either iteratively or recursively. Could you implement both?

# Starter

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def reverseList(self, head: ListNode | None) -> ListNode | None:
        
```

# Hints

1. Walk the list once and turn each arrow around. What do you need to remember so you don't lose the rest of the list?
2. Keep prev = None and cur = head. Each step: save nxt = cur.next, set cur.next = prev, then prev = cur, cur = nxt. Return prev.

# Key points

- three pointers: prev, cur, next
- save next before overwriting cur.next
- return prev (the old tail) as the new head
- O(n) time, O(1) space iteratively; recursion uses O(n) stack

# Solution: head-insertion-method · Head Insertion Method · O(n) · O(1) · reference

We create a dummy node dummy, then traverse the linked list and insert each node after the dummy node. After traversal, return dummy.next.

The time complexity is O(n), where n is the length of the linked list. The space complexity is O(1).

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def reverseList(self, head: ListNode) -> ListNode:
        dummy = ListNode()
        curr = head
        while curr:
            next = curr.next
            curr.next = dummy.next
            dummy.next = curr
            curr = next
        return dummy.next
```

# Solution: recursion · Recursion · O(n) · O(n)

We recursively reverse all nodes from the second node to the end of the list, then attach the head to the end of the reversed list.

The time complexity is O(n), and the space complexity is O(n). Where n is the length of the linked list.

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def reverseList(self, head: ListNode) -> ListNode:
        if head is None or head.next is None:
            return head
        ans = self.reverseList(head.next)
        head.next.next = head
        head.next = None
        return ans
```

# Tests

```python

```
