---
lc: 143
title: "Reorder List"
difficulty: "Medium"
patterns: ["fast-slow-pointers", "list-reversal"]
lcTags: ["linked-list", "two-pointers", "stack", "recursion"]
entry: {"method": "reorderList", "params": [{"name": "head", "type": "ListNode"}], "returns": "void", "outputParam": 0}
examples: ["[1,2,3,4]", "[1,2,3,4,5]"]
---

You are given the head of a singly linked-list. The list can be represented as:

```
L0 → L1 → … → Ln - 1 → Ln
```

*Reorder the list to be on the following form:*

```
L0 → Ln → L1 → Ln - 1 → L2 → Ln - 2 → …
```

You may not modify the values in the list's nodes. Only nodes themselves may be changed.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/03/04/reorder1linked-list.jpg)

```
Input: head = [1,2,3,4]
Output: [1,4,2,3]
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2021/03/09/reorder2-linked-list.jpg)

```
Input: head = [1,2,3,4,5]
Output: [1,5,2,4,3]
```

**Constraints:**

- The number of nodes in the list is in the range `[1, 5 * 10⁴]`.
- `1 <= Node.val <= 1000`

# Starter

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def reorderList(self, head: ListNode | None) -> None:
        """
        Do not return anything, modify head in-place instead.
        """
        
```

# Hints

1. The result alternates nodes from the front half and the reversed back half.
2. Find the middle (fast/slow), reverse the second half, then merge the two halves by alternating nodes.

# Key points

- three classic steps: middle, reverse, merge
- cut the list at the middle so the halves don't loop
- O(n) time, O(1) space

# Solution: fast-and-slow-pointers-reverse-list-merg · Fast and Slow Pointers + Reverse List + Merge Lists · O(n) · O(1) · reference

We first use fast and slow pointers to find the midpoint of the linked list, then reverse the second half of the list, and finally merge the two halves.

The time complexity is O(n), where n is the length of the linked list. The space complexity is O(1).

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def reorderList(self, head: Optional[ListNode]) -> None:
        fast = slow = head
        while fast.next and fast.next.next:
            slow = slow.next
            fast = fast.next.next

        cur = slow.next
        slow.next = None

        pre = None
        while cur:
            t = cur.next
            cur.next = pre
            pre, cur = cur, t
        cur = head

        while pre:
            t = pre.next
            pre.next = cur.next
            cur.next = pre
            cur, pre = pre.next, t
```

# Tests

```python

```
