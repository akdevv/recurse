---
lc: 83
title: "Remove Duplicates from Sorted List"
difficulty: "Easy"
patterns: ["list-reversal"]
lcTags: ["linked-list"]
entry: {"method": "deleteDuplicates", "params": [{"name": "head", "type": "ListNode"}], "returns": "ListNode"}
examples: ["[1,1,2]", "[1,1,2,3,3]"]
---

Given the `head` of a sorted linked list, *delete all duplicates such that each element appears only once*. Return *the linked list **sorted** as well*.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/01/04/list1.jpg)

```
Input: head = [1,1,2]
Output: [1,2]
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2021/01/04/list2.jpg)

```
Input: head = [1,1,2,3,3]
Output: [1,2,3]
```

**Constraints:**

- The number of nodes in the list is in the range `[0, 300]`.
- `-100 <= Node.val <= 100`
- The list is guaranteed to be **sorted** in ascending order.

# Starter

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def deleteDuplicates(self, head: ListNode | None) -> ListNode | None:
        
```

# Hints

1. The list is sorted, so duplicates are next to each other.
2. Walk with cur. While cur.next has the same value as cur, skip it; otherwise move on.

# Key points

- sorted → duplicates are adjacent
- compare cur with cur.next and unlink equal nodes
- don't advance cur after unlinking: the new next may be equal too
- O(n) time, O(1) space

# Solution: single-pass · Single Pass · O(n) · O(1) · reference

We use a pointer cur to traverse the linked list. If the element corresponding to the current cur is the same as the element corresponding to cur.next, we set the next pointer of cur to point to the next node of cur.next. Otherwise, it means that the element corresponding to cur in the linked list is not duplicated, so we can move the cur pointer to the next node.

After the traversal ends, return the head node of the linked list.

The time complexity is O(n), where n is the length of the linked list. The space complexity is O(1).

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def deleteDuplicates(self, head: Optional[ListNode]) -> Optional[ListNode]:
        cur = head
        while cur and cur.next:
            if cur.val == cur.next.val:
                cur.next = cur.next.next
            else:
                cur = cur.next
        return head
```

# Tests

```python
def edge():
    return [[[]], [[1]], [[1, 1]], [[1, 1, 1]], [[1, 1, 2]], [[1, 1, 2, 3, 3]], [[-100, 100]]]

def random_case(rng):
    return [sorted(rng.randint(-3, 3) for _ in range(rng.randint(0, 10)))]
```
