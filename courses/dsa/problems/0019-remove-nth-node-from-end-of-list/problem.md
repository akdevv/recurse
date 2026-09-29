---
lc: 19
title: "Remove Nth Node From End of List"
difficulty: "Medium"
patterns: ["fast-slow-pointers"]
lcTags: ["linked-list", "two-pointers"]
entry: {"method": "removeNthFromEnd", "params": [{"name": "head", "type": "ListNode"}, {"name": "n", "type": "integer"}], "returns": "ListNode"}
examples: ["[1,2,3,4,5]\n2", "[1]\n1", "[1,2]\n1"]
lcHints: ["Maintain two pointers and update one with a delay of n steps."]
---

Given the `head` of a linked list, remove the `nᵗʰ` node from the end of the list and return its head.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/10/03/remove_ex1.jpg)

```
Input: head = [1,2,3,4,5], n = 2
Output: [1,2,3,5]
```

**Example 2:**

```
Input: head = [1], n = 1
Output: []
```

**Example 3:**

```
Input: head = [1,2], n = 1
Output: [1]
```

**Constraints:**

- The number of nodes in the list is `sz`.
- `1 <= sz <= 30`
- `0 <= Node.val <= 100`
- `1 <= n <= sz`

**Follow up:** Could you do this in one pass?

# Starter

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def removeNthFromEnd(self, head: ListNode | None, n: int) -> ListNode | None:
        
```

# Hints

1. Can you find the n-th node from the end without counting the length first?
2. Start two pointers at a dummy node. Move fast n + 1 steps ahead, then move both until fast is None. slow.next is the node to remove.

# Key points

- gap of n between two pointers → when fast hits the end, slow is just before the target
- dummy node handles removing the head
- one pass, O(1) space

# Solution: fast-and-slow-pointers · Fast and Slow Pointers · O(n) · O(1) · reference

We define two pointers `fast` and `slow`, both initially pointing to the dummy head node of the linked list.

Next, the `fast` pointer moves forward n steps first, then `fast` and `slow` pointers move forward together until the `fast` pointer reaches the end of the linked list. At this point, the node pointed to by `slow.next` is the predecessor of the n-th node from the end, and we can delete it.

The time complexity is O(n), where n is the length of the linked list. The space complexity is O(1).

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def removeNthFromEnd(self, head: Optional[ListNode], n: int) -> Optional[ListNode]:
        dummy = ListNode(next=head)
        fast = slow = dummy
        for _ in range(n):
            fast = fast.next
        while fast.next:
            slow, fast = slow.next, fast.next
        slow.next = slow.next.next
        return dummy.next
```

# Tests

```python

```
