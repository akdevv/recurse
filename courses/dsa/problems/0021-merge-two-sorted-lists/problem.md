---
lc: 21
title: "Merge Two Sorted Lists"
difficulty: "Easy"
patterns: ["list-reversal"]
lcTags: ["linked-list", "recursion"]
entry: {"method": "mergeTwoLists", "params": [{"name": "list1", "type": "ListNode"}, {"name": "list2", "type": "ListNode"}], "returns": "ListNode"}
examples: ["[1,2,4]\n[1,3,4]", "[]\n[]", "[]\n[0]"]
---

You are given the heads of two sorted linked lists `list1` and `list2`.

Merge the two lists into one **sorted** list. The list should be made by splicing together the nodes of the first two lists.

Return *the head of the merged linked list*.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/10/03/merge_ex1.jpg)

```
Input: list1 = [1,2,4], list2 = [1,3,4]
Output: [1,1,2,3,4,4]
```

**Example 2:**

```
Input: list1 = [], list2 = []
Output: []
```

**Example 3:**

```
Input: list1 = [], list2 = [0]
Output: [0]
```

**Constraints:**

- The number of nodes in both lists is in the range `[0, 50]`.
- `-100 <= Node.val <= 100`
- Both `list1` and `list2` are sorted in **non-decreasing** order.

# Starter

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def mergeTwoLists(self, list1: ListNode | None, list2: ListNode | None) -> ListNode | None:
        
```

# Hints

1. Like merging two sorted arrays: always take the smaller front node.
2. Use a dummy head and a tail pointer. Attach the smaller of list1/list2 to tail, advance that list. At the end attach whatever is left.

# Key points

- dummy node + tail pointer builds the result without special cases
- pick the smaller head each step, reuse the existing nodes
- attach the remaining list at the end
- O(m + n) time, O(1) extra space

# Solution: recursion · Recursion · O(m + n) · O(m + n) · reference

First, we judge whether the linked lists l_1 and l_2 are empty. If one of them is empty, we return the other linked list. Otherwise, we compare the head nodes of l_1 and l_2:

- If the value of the head node of l_1 is less than or equal to the value of the head node of l_2, we recursively call the function `mergeTwoLists(l_1.next, l_2)`, and connect the head node of l_1 with the returned linked list head node, and return the head node of l_1.
- Otherwise, we recursively call the function `mergeTwoLists(l_1, l_2.next)`, and connect the head node of l_2 with the returned linked list head node, and return the head node of l_2.

The time complexity is O(m + n), and the space complexity is O(m + n). Here, m and n are the lengths of the two linked lists respectively.

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def mergeTwoLists(
        self, list1: Optional[ListNode], list2: Optional[ListNode]
    ) -> Optional[ListNode]:
        if list1 is None or list2 is None:
            return list1 or list2
        if list1.val <= list2.val:
            list1.next = self.mergeTwoLists(list1.next, list2)
            return list1
        else:
            list2.next = self.mergeTwoLists(list1, list2.next)
            return list2
```

# Solution: iteration · Iteration · O(m + n) · O(1)

We can also use iteration to implement the merging of two sorted linked lists.

First, we define a dummy head node dummy, then loop through the two linked lists, compare the head nodes of the two linked lists, add the smaller node to the end of dummy, until one of the linked lists is empty, then add the remaining part of the other linked list to the end of dummy.

Finally, return dummy.next.

The time complexity is O(m + n), where m and n are the lengths of the two linked lists respectively. Ignoring the space consumption of the answer linked list, the space complexity is O(1).

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def mergeTwoLists(
        self, list1: Optional[ListNode], list2: Optional[ListNode]
    ) -> Optional[ListNode]:
        dummy = ListNode()
        curr = dummy
        while list1 and list2:
            if list1.val <= list2.val:
                curr.next = list1
                list1 = list1.next
            else:
                curr.next = list2
                list2 = list2.next
            curr = curr.next
        curr.next = list1 or list2
        return dummy.next
```

# Tests

```python
def edge():
    return [[[], []], [[], [0]], [[1], []], [[1, 2, 4], [1, 3, 4]], [[5], [1, 2, 3]], [[1, 1], [1, 1]]]

def random_case(rng):
    return [sorted(rng.randint(-5, 5) for _ in range(rng.randint(0, 6))),
            sorted(rng.randint(-5, 5) for _ in range(rng.randint(0, 6)))]
```
