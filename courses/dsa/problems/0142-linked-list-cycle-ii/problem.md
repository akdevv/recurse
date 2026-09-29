---
lc: 142
title: "Linked List Cycle II"
difficulty: "Medium"
patterns: ["fast-slow-pointers"]
lcTags: ["hash-table", "linked-list", "two-pointers", "floyds-cycle-finding-algorithm"]
entry: {"method": "detectCycle", "params": [{"name": "head", "type": "ListNode"}, {"name": "pos", "type": "integer"}], "returns": "ListNode", "interactive": true}
examples: ["[3,2,0,-4]\n1", "[1,2]\n0", "[1]\n-1"]
---

Given the `head` of a linked list, return *the node where the cycle begins. If there is no cycle, return* `null`.

There is a cycle in a linked list if there is some node in the list that can be reached again by continuously following the `next` pointer. Internally, `pos` is used to denote the index of the node that tail's `next` pointer is connected to (**0-indexed**). It is `-1` if there is no cycle. **Note that** `pos` **is not passed as a parameter**.

**Do not modify** the linked list.

**Example 1:**

![](https://assets.leetcode.com/uploads/2018/12/07/circularlinkedlist.png)

```
Input: head = [3,2,0,-4], pos = 1
Output: tail connects to node index 1
Explanation: There is a cycle in the linked list, where tail connects to the second node.
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2018/12/07/circularlinkedlist_test2.png)

```
Input: head = [1,2], pos = 0
Output: tail connects to node index 0
Explanation: There is a cycle in the linked list, where tail connects to the first node.
```

**Example 3:**

![](https://assets.leetcode.com/uploads/2018/12/07/circularlinkedlist_test3.png)

```
Input: head = [1], pos = -1
Output: no cycle
Explanation: There is no cycle in the linked list.
```

**Constraints:**

- The number of the nodes in the list is in the range `[0, 10⁴]`.
- `-10⁵ <= Node.val <= 10⁵`
- `pos` is `-1` or a **valid index** in the linked-list.

**Follow up:** Can you solve it using `O(1)` (i.e. constant) memory?

# Starter

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, x):
#         self.val = x
#         self.next = None

class Solution:
    def detectCycle(self, head: Optional[ListNode]) -> Optional[ListNode]:
        
```

# Hints

1. First detect the cycle with fast/slow. Then: the distance from head to the cycle start equals the distance from the meeting point to the cycle start (going forward).
2. After slow and fast meet, move one pointer back to head. Advance both one step at a time; where they meet is the start of the cycle.

# Key points

- phase 1: Floyd detects the meeting point
- phase 2: one pointer from head, one from the meeting point, same speed → meet at the cycle start
- O(n) time, O(1) space; a visited set is the O(n)-space alternative
- your answer is the node itself; the tests report its index (-1 for none)

# Solution: two-pointers · Two Pointers · O(n) · O(1) · reference

We first use the fast and slow pointers to judge whether the linked list has a ring. If there is a ring, the fast and slow pointers will definitely meet, and the meeting node must be in the ring.

If there is no ring, the fast pointer will reach the tail of the linked list first, and return `null` directly.

If there is a ring, we then define an answer pointer ans to point to the head of the linked list, and then let ans and the slow pointer move forward together, moving one step at a time, until ans and the slow pointer meet, and the meeting node is the ring entrance node.

Why can this find the entrance node of the ring?

Let's assume that the distance from the head node of the linked list to the entrance of the ring is x, the distance from the entrance of the ring to the meeting node is y, and the distance from the meeting node to the entrance of the ring is z. Then the distance traveled by the slow pointer is `x + y`, and the distance traveled by the fast pointer is `x + y + k × (y + z)`, where k is the number of times the fast pointer goes around the ring.

<p><img src="https://fastly.jsdelivr.net/gh/doocs/leetcode@main/solution/0100-0199/0142.Linked%20List%20Cycle%20II/images/linked-list-cycle-ii.png" /></p>

Because the speed of the fast pointer is twice that of the slow pointer, it is `2 × (x + y) = x + y + k × (y + z)`, which can be deduced that `x + y = k × (y + z)`, that is `x = (k - 1) × (y + z) + z`.

That is to say, if we define an answer pointer ans to point to the head of the linked list, and the ans and the slow pointer move forward together, they will definitely meet at the ring entrance.

The time complexity is O(n), where n is the number of nodes in the linked list. The space complexity is O(1).

```python
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, x):
#         self.val = x
#         self.next = None

class Solution:
    def detectCycle(self, head: Optional[ListNode]) -> Optional[ListNode]:
        fast = slow = head
        while fast and fast.next:
            slow = slow.next
            fast = fast.next.next
            if slow == fast:
                ans = head
                while ans != slow:
                    ans = ans.next
                    slow = slow.next
                return ans
```

# Tests

```python
NODES = []

def prepare(args):
    vals, pos = args
    head = to_list_node(vals)
    NODES.clear()
    n = head
    while n:
        NODES.append(n)
        n = n.next
    if pos >= 0:
        NODES[-1].next = NODES[pos]
    return [head], {}

def output(ret):
    return next((i for i, x in enumerate(NODES) if x is ret), -1)

def edge():
    return [[[], -1], [[1], -1], [[1], 0], [[1, 2], 0], [[1, 2], 1], [[3, 2, 0, -4], 1]]

def random_case(rng):
    n = rng.randint(0, 10)
    return [[rng.randint(-5, 5) for _ in range(n)], rng.randint(-1, n - 1) if n and rng.random() < 0.6 else -1]

def perf(rng):
    return [[list(range(10000)), 5000]]
```
