---
lc: 160
title: "Intersection of Two Linked Lists"
difficulty: "Easy"
patterns: ["two-pointers"]
lcTags: ["hash-table", "linked-list", "two-pointers"]
entry: {"method": "getIntersectionNode", "params": [{"name": "intersectVal", "type": "integer"}, {"name": "listA", "type": "ListNode"}, {"name": "listB", "type": "ListNode"}, {"name": "skipA", "type": "integer"}, {"name": "skipB", "type": "integer"}], "returns": "ListNode", "interactive": true}
examples: ["8\n[4,1,8,4,5]\n[5,6,1,8,4,5]\n2\n3", "2\n[1,9,1,2,4]\n[3,2,4]\n3\n1", "0\n[2,6,4]\n[1,5]\n3\n2"]
---

Given the heads of two singly linked-lists `headA` and `headB`, return *the node at which the two lists intersect*. If the two linked lists have no intersection at all, return `null`.

For example, the following two linked lists begin to intersect at node `c1`:

![](https://assets.leetcode.com/uploads/2021/03/05/160_statement.png)

The test cases are generated such that there are no cycles anywhere in the entire linked structure.

**Note** that the linked lists must **retain their original structure** after the function returns.

**Custom Judge:**

The inputs to the **judge** are given as follows (your program is **not** given these inputs):

- `intersectVal` - The value of the node where the intersection occurs. This is `0` if there is no intersected node.
- `listA` - The first linked list.
- `listB` - The second linked list.
- `skipA` - The number of nodes to skip ahead in `listA` (starting from the head) to get to the intersected node.
- `skipB` - The number of nodes to skip ahead in `listB` (starting from the head) to get to the intersected node.

The judge will then create the linked structure based on these inputs and pass the two heads, `headA` and `headB` to your program. If you correctly return the intersected node, then your solution will be **accepted**.

**Example 1:**

![](https://assets.leetcode.com/uploads/2021/03/05/160_example_1_1.png)

```
Input: intersectVal = 8, listA = [4,1,8,4,5], listB = [5,6,1,8,4,5], skipA = 2, skipB = 3
Output: Intersected at '8'
Explanation: The intersected node's value is 8 (note that this must not be 0 if the two lists intersect).
From the head of A, it reads as [4,1,8,4,5]. From the head of B, it reads as [5,6,1,8,4,5]. There are 2 nodes before the intersected node in A; There are 3 nodes before the intersected node in B.
- Note that the intersected node's value is not 1 because the nodes with value 1 in A and B (2nd node in A and 3rd node in B) are different node references. In other words, they point to two different locations in memory, while the nodes with value 8 in A and B (3rd node in A and 4th node in B) point to the same location in memory.
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2021/03/05/160_example_2.png)

```
Input: intersectVal = 2, listA = [1,9,1,2,4], listB = [3,2,4], skipA = 3, skipB = 1
Output: Intersected at '2'
Explanation: The intersected node's value is 2 (note that this must not be 0 if the two lists intersect).
From the head of A, it reads as [1,9,1,2,4]. From the head of B, it reads as [3,2,4]. There are 3 nodes before the intersected node in A; There are 1 node before the intersected node in B.
```

**Example 3:**

![](https://assets.leetcode.com/uploads/2021/03/05/160_example_3.png)

```
Input: intersectVal = 0, listA = [2,6,4], listB = [1,5], skipA = 3, skipB = 2
Output: No intersection
Explanation: From the head of A, it reads as [2,6,4]. From the head of B, it reads as [1,5]. Since the two lists do not intersect, intersectVal must be 0, while skipA and skipB can be arbitrary values.
Explanation: The two lists do not intersect, so return null.
```

**Constraints:**

- The number of nodes of `listA` is in the `m`.
- The number of nodes of `listB` is in the `n`.
- `1 <= m, n <= 3 * 10⁴`
- `1 <= Node.val <= 10⁵`
- `0 <= skipA <= m`
- `0 <= skipB <= n`
- `intersectVal` is `0` if `listA` and `listB` do not intersect.
- `intersectVal == listA[skipA] == listB[skipB]` if `listA` and `listB` intersect.

**Follow up:** Could you write a solution that runs in `O(m + n)` time and use only `O(1)` memory?

# Starter

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, x):
#         self.val = x
#         self.next = None

class Solution:
    def getIntersectionNode(self, headA: ListNode, headB: ListNode) -> Optional[ListNode]:
        
```

# Hints

1. The lists may have different lengths before they join. How can two pointers "cancel out" that difference?
2. Walk pointer a through A then B, and pointer b through B then A. Both travel lenA + lenB, so they arrive at the intersection at the same time (or both reach None).

# Key points

- compare nodes by identity, not value
- switch each pointer to the other list's head at the end: both walk the same total distance
- O(m + n) time, O(1) space; a set of A's nodes is the O(m)-space version
- your answer is the node; the tests report its position in list A (-1 for none)

# Solution: two-pointers · Two Pointers · O(m + n) · O(1) · reference

We use two pointers a and b to point to the heads of the two linked lists headA and headB, respectively.

Traverse the linked lists simultaneously. When a reaches the end of headA, redirect it to the head of headB. Similarly, when b reaches the end of headB, redirect it to the head of headA.

If the two pointers meet, the node they point to is the first common node. If they do not meet, it means the two linked lists have no common nodes, and both pointers will point to `null`. Return either pointer.

The time complexity is O(m + n), where m and n are the lengths of the linked lists headA and headB, respectively. The space complexity is O(1).

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, x):
#         self.val = x
#         self.next = None

class Solution:
    def getIntersectionNode(self, headA: ListNode, headB: ListNode) -> ListNode:
        a, b = headA, headB
        while a != b:
            a = a.next if a else headB
            b = b.next if b else headA
        return a
```

# Tests

```python
A = []

def prepare(args):
    _, a_vals, b_vals, skip_a, skip_b = args
    A.clear()
    a = to_list_node(a_vals)
    n = a
    while n:
        A.append(n)
        n = n.next
    b = to_list_node(b_vals[:skip_b])
    shared = A[skip_a] if skip_a < len(A) else None
    if b is None:
        b = shared
    else:
        t = b
        while t.next:
            t = t.next
        t.next = shared
    return [a, b], {}

def output(ret):
    return next((i for i, x in enumerate(A) if x is ret), -1)

def make(a_pre, b_pre, tail):
    a, b = a_pre + tail, b_pre + tail
    return [tail[0] if tail else 0, a, b, len(a_pre) if tail else len(a), len(b_pre) if tail else len(b)]

def edge():
    return [make([4, 1], [5, 6, 1], [8, 4, 5]), make([1, 9, 1], [3], [2, 4]), make([2, 6, 4], [1, 5], []),
            make([], [], [1]), make([], [7], [1, 2]), make([1], [1], [])]

def random_case(rng):
    r = lambda k: [rng.randint(1, 9) for _ in range(k)]
    while True:
        a_pre, b_pre, tail = r(rng.randint(0, 4)), r(rng.randint(0, 4)), r(rng.randint(0, 4))
        if a_pre + tail and b_pre + tail:
            return make(a_pre, b_pre, tail)

def perf(rng):
    return [make(list(range(1, 20001)), list(range(1, 10001)), list(range(1, 10001)))]
```
