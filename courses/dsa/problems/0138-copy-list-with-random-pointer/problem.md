---
lc: 138
title: "Copy List with Random Pointer"
difficulty: "Medium"
patterns: ["hash-map"]
lcTags: ["hash-table", "linked-list"]
entry: {"method": "copyRandomList", "params": [{"name": "head", "type": "ListNode"}], "returns": "ListNode", "interactive": true}
examples: ["[[7,null],[13,0],[11,4],[10,2],[1,0]]", "[[1,1],[2,1]]", "[[3,null],[3,0],[3,null]]"]
lcHints: ["Just iterate the linked list and create copies of the nodes on the go. Since a node can be referenced from multiple nodes due to the random pointers, ensure you are not making multiple copies of the same node.", "You may want to use extra space to keep old_node ---> new_node mapping to prevent creating multiple copies of the same node.", "We can avoid using extra space for old_node ---> new_node mapping by tweaking the original linked list. Simply interweave the nodes of the old and copied list. For example:\r\nOld List: A --> B --> C --> D\r\nInterWeaved List: A --> A' --> B --> B' --> C --> C' --> D --> D'", "The interweaving is done using next</b> pointers and we can make use of interweaved structure to get the correct reference nodes for random</b> pointers."]
---

A linked list of length `n` is given such that each node contains an additional random pointer, which could point to any node in the list, or `null`.

Construct a [**deep copy**](https://en.wikipedia.org/wiki/Object_copying#Deep_copy) of the list. The deep copy should consist of exactly `n` **brand new** nodes, where each new node has its value set to the value of its corresponding original node. Both the `next` and `random` pointer of the new nodes should point to new nodes in the copied list such that the pointers in the original list and copied list represent the same list state. **None of the pointers in the new list should point to nodes in the original list**.

For example, if there are two nodes `X` and `Y` in the original list, where `X.random --> Y`, then for the corresponding two nodes `x` and `y` in the copied list, `x.random --> y`.

Return *the head of the copied linked list*.

The linked list is represented in the input/output as a list of `n` nodes. Each node is represented as a pair of `[val, random_index]` where:

- `val`: an integer representing `Node.val`
- `random_index`: the index of the node (range from `0` to `n-1`) that the `random` pointer points to, or `null` if it does not point to any node.

Your code will **only** be given the `head` of the original linked list.

**Example 1:**

![](https://assets.leetcode.com/uploads/2019/12/18/e1.png)

```
Input: head = [[7,null],[13,0],[11,4],[10,2],[1,0]]
Output: [[7,null],[13,0],[11,4],[10,2],[1,0]]
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2019/12/18/e2.png)

```
Input: head = [[1,1],[2,1]]
Output: [[1,1],[2,1]]
```

**Example 3:**

**![](https://assets.leetcode.com/uploads/2019/12/18/e3.png)**

```
Input: head = [[3,null],[3,0],[3,null]]
Output: [[3,null],[3,0],[3,null]]
```

**Constraints:**

- `0 <= n <= 1000`
- `-10⁴ <= Node.val <= 10⁴`
- `Node.random` is `null` or is pointing to some node in the linked list.

# Starter

```python
"""
# Definition for a Node.
class Node:
    def __init__(self, x: int, next: 'Node' = None, random: 'Node' = None):
        self.val = int(x)
        self.next = next
        self.random = random
"""

class Solution:
    def copyRandomList(self, head: 'Optional[Node]') -> 'Optional[Node]':
        
```

# Hints

1. The hard part is `random`: it can point to a node you haven't copied yet.
2. Two passes with a dict old → new: first create every copy, then set each copy's next and random through the dict. (O(1) space trick: interleave copies A → A' → B → B'.)

# Key points

- map each original node to its copy
- pass 1 creates nodes, pass 2 wires next and random through the map
- the copy must not share any node with the original
- O(n) time, O(n) space; interleaving gets O(1) extra space

# Solution: hash-table · Hash Table · O(n) · O(n) · reference

We can define a dummy head node dummy and use a pointer tail to point to the dummy head node. Then, we traverse the linked list, copying each node and storing the mapping between each node and its copy in a hash table d, while also connecting the next pointers of the copied nodes.

Next, we traverse the linked list again and use the mappings stored in the hash table to connect the random pointers of the copied nodes.

The time complexity is O(n), and the space complexity is O(n). Here, n is the length of the linked list.

```python
"""
# Definition for a Node.
class Node:
    def __init__(self, x: int, next: 'Node' = None, random: 'Node' = None):
        self.val = int(x)
        self.next = next
        self.random = random
"""

class Solution:
    def copyRandomList(self, head: "Optional[Node]") -> "Optional[Node]":
        d = {}
        dummy = tail = Node(0)
        cur = head
        while cur:
            node = Node(cur.val)
            tail.next = node
            tail = tail.next
            d[cur] = node
            cur = cur.next
        cur = head
        while cur:
            d[cur].random = d[cur.random] if cur.random else None
            cur = cur.next
        return dummy.next
```

# Solution: simulation-space-optimization · Simulation (Space Optimization) · O(n) · O(1)

In Solution 1, we used an additional hash table to store the mapping between the original nodes and the copied nodes. We can also achieve this without using extra space, as follows:

1. Traverse the original linked list, and for each node, create a new node and insert it between the original node and the original node's next node.
2. Traverse the linked list again, and set the random pointer of the new node based on the random pointer of the original node.
3. Finally, split the linked list into the original linked list and the copied linked list.

The time complexity is O(n), where n is the length of the linked list. Ignoring the space occupied by the answer linked list, the space complexity is O(1).

```python
"""
# Definition for a Node.
class Node:
    def __init__(self, x: int, next: 'Node' = None, random: 'Node' = None):
        self.val = int(x)
        self.next = next
        self.random = random
"""

class Solution:
    def copyRandomList(self, head: "Optional[Node]") -> "Optional[Node]":
        if head is None:
            return None
        cur = head
        while cur:
            node = Node(cur.val, cur.next)
            cur.next = node
            cur = node.next
        cur = head
        while cur:
            cur.next.random = cur.random.next if cur.random else None
            cur = cur.next.next
        cur = head
        ans = head.next
        while cur.next:
            node = cur.next
            cur.next = node.next
            cur = node
        return ans
```

# Tests

```python
class Node:
    def __init__(self, x, next=None, random=None):
        self.val, self.next, self.random = int(x), next, random

ORIG = []

def prepare(args):
    pairs = args[0]
    ORIG[:] = [Node(v) for v, _ in pairs]
    for i, (_, r) in enumerate(pairs):
        if i + 1 < len(ORIG):
            ORIG[i].next = ORIG[i + 1]
        ORIG[i].random = ORIG[r] if r is not None else None
    return [ORIG[0] if ORIG else None], {"Node": Node}

def output(ret):
    nodes, n = [], ret
    while n and len(nodes) <= len(ORIG):
        if any(n is o for o in ORIG):
            return "copy shares nodes with the original"
        nodes.append(n)
        n = n.next
    return [[x.val, next((i for i, y in enumerate(nodes) if y is x.random), None)] for x in nodes]

def edge():
    return [[[]], [[[1, None]]], [[[1, 0]]], [[[1, 1], [2, 1]]], [[[7, None], [13, 0], [11, 4], [10, 2], [1, 0]]], [[[3, None], [3, 0], [3, None]]]]

def random_case(rng):
    n = rng.randint(0, 8)
    return [[[rng.randint(-5, 5), rng.choice([None, *range(n)])] for _ in range(n)]]

def perf(rng):
    n = 1000
    return [[[[rng.randint(-10**4, 10**4), rng.choice([None, *range(n)])] for _ in range(n)]]]
```
