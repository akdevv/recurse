---
lc: 234
title: "Palindrome Linked List"
difficulty: "Easy"
patterns: ["fast-slow-pointers", "list-reversal"]
lcTags: ["linked-list", "two-pointers", "stack", "recursion"]
entry: {"method": "isPalindrome", "params": [{"name": "head", "type": "ListNode"}], "returns": "boolean"}
examples: ["[1,2,2,1]", "[1,2]"]
---

Given the `head` of a singly linked list, return `true` *if it is a* *palindrome* *or* `false` *otherwise*.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/03/03/pal1linked-list.jpg)

```
Input: head = [1,2,2,1]
Output: true
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2021/03/03/pal2linked-list.jpg)

```
Input: head = [1,2]
Output: false
```

**Constraints:**

- The number of nodes in the list is in the range `[1, 10⁵]`.
- `0 <= Node.val <= 9`

**Follow up:** Could you do it in `O(n)` time and `O(1)` space?

# Starter

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def isPalindrome(self, head: ListNode | None) -> bool:
        
```

# Hints

1. Copying the values into a list and comparing with its reverse is O(n) space. For O(1): how can you walk the second half backwards?
2. Find the middle with fast/slow pointers, reverse the second half, compare it with the first half node by node.

# Key points

- fast/slow to find the middle
- reverse the second half in place, compare with the first half
- O(n) time, O(1) space (optionally restore the list afterwards)

# Solution: fast-and-slow-pointers · Fast and Slow Pointers · O(n) · O(1) · reference

We can use fast and slow pointers to find the middle of the linked list, then reverse the right half of the list. After that, we traverse both halves simultaneously, checking if the corresponding node values are equal. If any pair of values is unequal, it's not a palindrome linked list; otherwise, it is a palindrome linked list.

The time complexity is O(n), where n is the length of the linked list. The space complexity is O(1).

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def isPalindrome(self, head: Optional[ListNode]) -> bool:
        slow, fast = head, head.next
        while fast and fast.next:
            slow, fast = slow.next, fast.next.next
        pre, cur = None, slow.next
        while cur:
            t = cur.next
            cur.next = pre
            pre, cur = cur, t
        while pre:
            if pre.val != head.val:
                return False
            pre, head = pre.next, head.next
        return True
```

# Tests

```python

```
