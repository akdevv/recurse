## Core idea

**A linked list is a chain of nodes where each node stores a value and a pointer to the next node.** There's no indexing: to reach the k-th node you walk k steps. In exchange, inserting or removing a node you already hold is O(1): you just rewire a pointer, nothing shifts.

## Intuition

A treasure hunt: each clue tells you where the next clue is. To reach clue 7 you must follow clues 1 to 6. But adding a detour is easy: change one clue to point to the new spot, and have the new spot point to where the old clue pointed.

Most linked list bugs come from **losing the rest of the chain**: overwrite `node.next` before saving it and everything after is gone. So the rule is: **save what you'll need, then rewire**.

## Visualization

Reversing: turn each arrow around, carrying `prev`, `cur` and `next`:

```viz
reverse
```

A dummy node before the head removes every "what if it's the head?" special case:

```viz
dummy-remove
```

## Template code

```python
class ListNode:
    def __init__(self, val=0, next=None):
        self.val, self.next = val, next

# Traverse
cur = head
while cur:
    cur = cur.next

# Dummy node: build or edit without head special cases
dummy = ListNode(0, head)
pre = dummy
while pre.next:
    if pre.next.val == val:
        pre.next = pre.next.next         # unlink
    else:
        pre = pre.next
return dummy.next

# Reverse
prev, cur = None, head
while cur:
    nxt = cur.next                       # 1. save
    cur.next = prev                      # 2. rewire
    prev, cur = cur, nxt                 # 3. advance
return prev

# Merge two sorted lists with a tail pointer
dummy = tail = ListNode()
while a and b:
    if a.val <= b.val:
        tail.next, a = a, a.next
    else:
        tail.next, b = b, b.next
    tail = tail.next
tail.next = a or b
```

## Complexity

| Operation | Array | Singly linked list |
|---|---|---|
| access k-th element | O(1) | O(k) |
| insert/delete at the front | O(n) | **O(1)** |
| insert/delete after a node you hold | O(n) | **O(1)** |
| search by value | O(n) | O(n) |
| extra memory per element | none | one pointer |

A **doubly linked list** also stores `prev`, so you can remove a node given only that node, in O(1). That's what LRU caches use.

## When to use it

- **Frequent inserts/removes in the middle or front** → linked list
- **The input is a list: removing nodes** → dummy node + look at `pre.next`
- **"Reverse"** → prev / cur / next
- **Merge sorted lists** → dummy + tail pointer, reuse existing nodes
- **Build a result list** → dummy head, append at the tail, return `dummy.next`

## Common traps

- Overwriting `cur.next` before saving it: the rest of the list is lost
- Advancing after deleting: the new `pre.next` hasn't been checked yet
- Forgetting the empty list (`head is None`) and the single-node list
- Returning `head` after the head node was removed: return `dummy.next`
- Leaving a cycle behind when rewiring (e.g. the old head still points to the second node after reversing)
