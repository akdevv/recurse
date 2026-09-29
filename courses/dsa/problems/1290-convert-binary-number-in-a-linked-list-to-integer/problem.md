---
lc: 1290
title: "Convert Binary Number in a Linked List to Integer"
difficulty: "Easy"
patterns: ["digit-math"]
lcTags: ["linked-list", "math"]
entry: {"method": "getDecimalValue", "params": [{"name": "head", "type": "ListNode"}], "returns": "integer"}
examples: ["[1,0,1]", "[0]"]
lcHints: ["Traverse the linked list and store all values in a string or array. convert the values obtained to decimal value.", "You can solve the problem in O(1) memory using bits operation. use shift left operation ( << ) and or operation ( | ) to get the decimal value in one operation."]
---

Given `head` which is a reference node to a singly-linked list. The value of each node in the linked list is either `0` or `1`. The linked list holds the binary representation of a number.

Return the *decimal value* of the number in the linked list.

The **most significant bit** is at the head of the linked list.

**Example 1:**

![](https://assets.leetcode.com/uploads/2019/12/05/graph-1.png)

```
Input: head = [1,0,1]
Output: 5
Explanation: (101) in base 2 = (5) in base 10
```

**Example 2:**

```
Input: head = [0]
Output: 0
```

**Constraints:**

- The Linked List is not empty.
- Number of nodes will not exceed `30`.
- Each node's value is either `0` or `1`.

# Starter

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def getDecimalValue(self, head: ListNode | None) -> int:
        
```

# Hints

1. Reading binary left to right: each new bit doubles what you had and adds itself.
2. value = 0; for each node: value = value * 2 + node.val.

# Key points

- walk once: value = value * 2 + bit (or value << 1 | bit)
- same idea as building a decimal number digit by digit
- O(n) time, O(1) space

# Solution: traverse-the-linked-list · Traverse the Linked List · O(n) · O(1) · reference

We use a variable ans to record the current decimal value, with an initial value of 0.

Traverse the linked list. For each node, left-shift ans by one bit, then perform a bitwise OR with the current node's value. After traversal, ans is the decimal value.

The time complexity is O(n), where n is the length of the linked list. The space complexity is O(1).

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
class Solution:
    def getDecimalValue(self, head: ListNode) -> int:
        ans = 0
        while head:
            ans = ans << 1 | head.val
            head = head.next
        return ans
```

# Tests

```python
def edge():
    return [[[0]], [[1]], [[1, 0, 1]], [[1] * 30], [[1] + [0] * 29]]

def random_case(rng):
    n = rng.randint(1, 30)
    return [[1] + [rng.randint(0, 1) for _ in range(n - 1)] if n > 1 else [rng.randint(0, 1)]]
```
