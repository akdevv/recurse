---
lc: 92
title: "Reverse Linked List II"
difficulty: "Medium"
patterns: ["list-reversal"]
lcTags: ["linked-list"]
entry: {"method": "reverseBetween", "params": [{"name": "head", "type": "ListNode"}, {"name": "left", "type": "integer"}, {"name": "right", "type": "integer"}], "returns": "ListNode"}
examples: ["[1,2,3,4,5]\n2\n4", "[5]\n1\n1"]
---

Given the `head` of a singly linked list and two integers `left` and `right` where `left <= right`, reverse the nodes of the list from position `left` to position `right`, and return *the reversed list*.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/02/19/rev2ex2.jpg)

```
Input: head = [1,2,3,4,5], left = 2, right = 4
Output: [1,4,3,2,5]
```

**Example 2:**

```
Input: head = [5], left = 1, right = 1
Output: [5]
```

**Constraints:**

- The number of nodes in the list is `n`.
- `1 <= n <= 500`
- `-500 <= Node.val <= 500`
- `1 <= left <= right <= n`

**Follow up:** Could you do it in one pass?

# Starter

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def reverseBetween(self, head: ListNode | None, left: int, right: int) -> ListNode | None:
        
```

# Hints

1. Find the node just before position left. From there, reverse exactly right − left + 1 nodes and reconnect both ends.
2. With a dummy node, walk to prev (node before left). Then repeatedly move the node after cur to the front of the sublist (right − left times).

# Key points

- dummy node, walk to the node before `left`
- reverse the sublist and reconnect: prev → new front, old front → node after `right`
- one pass, O(1) space

# Solution: simulation · Simulation · O(n) · O(1) · reference

Define a dummy head node `dummy`, pointing to the head node `head` of the linked list. Then define a pointer `pre` pointing to `dummy`. Start traversing the linked list from the dummy head node. When you traverse to the `left` node, point `pre` to this node. Then start traversing `right - left + 1` times from this node, and insert the nodes you traverse into the back of `pre`. Finally, return `dummy.next`.

The time complexity is O(n), and the space complexity is O(1). Here, n is the length of the linked list.

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def reverseBetween(
        self, head: Optional[ListNode], left: int, right: int
    ) -> Optional[ListNode]:
        if head.next is None or left == right:
            return head
        dummy = ListNode(0, head)
        pre = dummy
        for _ in range(left - 1):
            pre = pre.next
        p, q = pre, pre.next
        cur = q
        for _ in range(right - left + 1):
            t = cur.next
            cur.next = pre
            pre, cur = cur, t
        p.next = pre
        q.next = cur
        return dummy.next
```

# Tests

```python

```
