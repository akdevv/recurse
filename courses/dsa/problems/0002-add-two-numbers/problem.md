---
lc: 2
title: "Add Two Numbers"
difficulty: "Medium"
patterns: ["digit-math"]
lcTags: ["linked-list", "math", "recursion"]
entry: {"method": "addTwoNumbers", "params": [{"name": "l1", "type": "ListNode"}, {"name": "l2", "type": "ListNode"}], "returns": "ListNode"}
examples: ["[2,4,3]\n[5,6,4]", "[0]\n[0]", "[9,9,9,9,9,9,9]\n[9,9,9,9]"]
---

You are given two **non-empty** linked lists representing two non-negative integers. The digits are stored in **reverse order**, and each of their nodes contains a single digit. Add the two numbers and return the sum as a linked list.

You may assume the two numbers do not contain any leading zero, except the number 0 itself.

**Example 1:**

![](https://assets.leetcode.com/uploads/2020/10/02/addtwonumber1.jpg)

```
Input: l1 = [2,4,3], l2 = [5,6,4]
Output: [7,0,8]
Explanation: 342 + 465 = 807.
```

**Example 2:**

```
Input: l1 = [0], l2 = [0]
Output: [0]
```

**Example 3:**

```
Input: l1 = [9,9,9,9,9,9,9], l2 = [9,9,9,9]
Output: [8,9,9,9,0,0,0,1]
```

**Constraints:**

- The number of nodes in each linked list is in the range `[1, 100]`.
- `0 <= Node.val <= 9`
- It is guaranteed that the list represents a number that does not have leading zeros.

# Starter

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def addTwoNumbers(self, l1: ListNode | None, l2: ListNode | None) -> ListNode | None:
        
```

# Hints

1. Digits are stored in reverse, so the heads are the ones digits: add column by column like on paper.
2. Walk both lists with a carry. digit = (a + b + carry) % 10, carry = (a + b + carry) // 10. Continue while either list or the carry remains.

# Key points

- reverse order = least significant digit first, perfect for column addition
- keep a carry, stop when both lists and the carry are exhausted
- dummy head to build the result
- O(max(m, n)) time

# Solution: simulation · Simulation · O(max (m, n)) · O(1) · reference

We traverse two linked lists l_1 and l_2 at the same time, and use the variable carry to indicate whether there is a carry.

Each time we traverse, we take out the current bit of the corresponding linked list, calculate the sum with the carry carry, and then update the value of the carry. Then we add the current bit to the answer linked list. If both linked lists are traversed, and the carry is 0, the traversal ends.

Finally, we return the head node of the answer linked list.

The time complexity is O(max (m, n)), where m and n are the lengths of the two linked lists. We need to traverse the entire position of the two linked lists, and each position only needs O(1) time. Ignoring the space consumption of the answer, the space complexity is O(1).

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def addTwoNumbers(
        self, l1: Optional[ListNode], l2: Optional[ListNode]
    ) -> Optional[ListNode]:
        dummy = ListNode()
        carry, curr = 0, dummy
        while l1 or l2 or carry:
            s = (l1.val if l1 else 0) + (l2.val if l2 else 0) + carry
            carry, val = divmod(s, 10)
            curr.next = ListNode(val)
            curr = curr.next
            l1 = l1.next if l1 else None
            l2 = l2.next if l2 else None
        return dummy.next
```

# Tests

```python
def num(rng, k):
    digits = [rng.randint(0, 9) for _ in range(k)]
    if k > 1 and digits[-1] == 0:
        digits[-1] = rng.randint(1, 9)
    return digits

def edge():
    return [[[0], [0]], [[2, 4, 3], [5, 6, 4]], [[9, 9, 9, 9, 9, 9, 9], [9, 9, 9, 9]], [[5], [5]], [[1], [9] * 100]]

def random_case(rng):
    return [num(rng, rng.randint(1, 6)), num(rng, rng.randint(1, 6))]

def perf(rng):
    return [[num(rng, 100), num(rng, 100)]]
```
