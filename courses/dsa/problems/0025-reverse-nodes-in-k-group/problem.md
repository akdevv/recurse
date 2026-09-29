---
lc: 25
title: "Reverse Nodes in k-Group"
difficulty: "Hard"
patterns: ["list-reversal"]
lcTags: ["linked-list", "recursion"]
entry: {"method": "reverseKGroup", "params": [{"name": "head", "type": "ListNode"}, {"name": "k", "type": "integer"}], "returns": "ListNode"}
examples: ["[1,2,3,4,5]\n2", "[1,2,3,4,5]\n3"]
---

Given the `head` of a linked list, reverse the nodes of the list `k` at a time, and return *the modified list*.

`k` is a positive integer and is less than or equal to the length of the linked list. If the number of nodes is not a multiple of `k` then left-out nodes, in the end, should remain as it is.

You may not alter the values in the list's nodes, only nodes themselves may be changed.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/10/03/reverse_ex1.jpg)

```
Input: head = [1,2,3,4,5], k = 2
Output: [2,1,4,3,5]
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2020/10/03/reverse_ex2.jpg)

```
Input: head = [1,2,3,4,5], k = 3
Output: [3,2,1,4,5]
```

**Constraints:**

- The number of nodes in the list is `n`.
- `1 <= k <= n <= 5000`
- `0 <= Node.val <= 1000`

**Follow-up:** Can you solve the problem in `O(1)` extra memory space?

# Starter

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def reverseKGroup(self, head: ListNode | None, k: int) -> ListNode | None:
        
```

# Hints

1. Process the list k nodes at a time. Before reversing a group, check that k nodes actually remain.
2. Keep groupPrev (node before the group). Find the k-th node; if it doesn't exist, stop. Reverse the group, then connect groupPrev to the new front and the old front to the next group.

# Key points

- check k nodes exist before reversing; leftovers stay as they are
- reverse each group in place and reconnect both ends
- dummy node before head simplifies the first group
- O(n) time, O(1) space

# Solution: simulation · Simulation · O(n) · O(1) · reference

We can simulate the entire reversal process according to the problem description.

First, we define a helper function reverse to reverse a linked list. Then, we define a dummy head node dummy and set its next pointer to head.

Next, we traverse the linked list, processing k nodes at a time. If the remaining nodes are fewer than k, we do not perform the reversal. Otherwise, we extract k nodes and call the reverse function to reverse these k nodes. Then, we connect the reversed linked list back to the original linked list. We continue to process the next k nodes until the entire linked list is traversed.

The time complexity is O(n), where n is the length of the linked list. The space complexity is O(1).

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def reverseKGroup(self, head: Optional[ListNode], k: int) -> Optional[ListNode]:
        def reverse(head: Optional[ListNode]) -> Optional[ListNode]:
            dummy = ListNode()
            cur = head
            while cur:
                nxt = cur.next
                cur.next = dummy.next
                dummy.next = cur
                cur = nxt
            return dummy.next

        dummy = pre = ListNode(next=head)
        while pre:
            cur = pre
            for _ in range(k):
                cur = cur.next
                if cur is None:
                    return dummy.next
            node = pre.next
            nxt = cur.next
            cur.next = None
            pre.next = reverse(node)
            node.next = nxt
            pre = node
        return dummy.next
```

# Tests

```python

```
