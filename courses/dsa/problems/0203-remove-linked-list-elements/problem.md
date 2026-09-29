---
lc: 203
title: "Remove Linked List Elements"
difficulty: "Easy"
patterns: ["list-reversal"]
lcTags: ["linked-list", "recursion"]
entry: {"method": "removeElements", "params": [{"name": "head", "type": "ListNode"}, {"name": "val", "type": "integer"}], "returns": "ListNode"}
examples: ["[1,2,6,3,4,5,6]\n6", "[]\n1", "[7,7,7,7]\n7"]
---

Given the `head` of a linked list and an integer `val`, remove all the nodes of the linked list that has `Node.val == val`, and return *the new head*.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/03/06/removelinked-list.jpg)

```
Input: head = [1,2,6,3,4,5,6], val = 6
Output: [1,2,3,4,5]
```

**Example 2:**

```
Input: head = [], val = 1
Output: []
```

**Example 3:**

```
Input: head = [7,7,7,7], val = 7
Output: []
```

**Constraints:**

- The number of nodes in the list is in the range `[0, 10⁴]`.
- `1 <= Node.val <= 50`
- `0 <= val <= 50`

# Starter

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def removeElements(self, head: ListNode | None, val: int) -> ListNode | None:
        
```

# Hints

1. Removing the head is a special case. What if there were a node before the head?
2. Use a dummy node pointing at head. Walk with cur; if cur.next.val == val, skip it (cur.next = cur.next.next), else move cur forward.

# Key points

- dummy node removes the "delete the head" special case
- look one ahead: decide about cur.next, only advance when you didn't delete
- O(n) time, O(1) space

# Solution: solution-1 · Dummy node · O(n) · O(1) · reference

## Idea
A dummy node in front of head makes removing the head the same as removing any node. Look at `pre.next`: unlink it if it has the value, otherwise move `pre` forward.

## Complexity
- **Time: O(n)**
- **Space: O(1)**

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def removeElements(self, head: ListNode, val: int) -> ListNode:
        dummy = ListNode(-1, head)
        pre = dummy
        while pre.next:
            if pre.next.val != val:
                pre = pre.next
            else:
                pre.next = pre.next.next
        return dummy.next
```

# Tests

```python

```
