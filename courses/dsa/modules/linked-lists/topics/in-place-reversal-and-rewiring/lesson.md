## Core idea

**Harder list problems are combinations of a few moves: find a node, cut the list, reverse a piece, reconnect, merge.** Treat each as a small step, keep a pointer to every boundary you'll need later, and the problem stops being scary. Add a hash map when you need to find nodes instantly (LRU cache, copying random pointers).

## Intuition

Rearranging train carriages in a yard. Before uncoupling a group, you note which carriage is in front of the group and which comes after it. Then you can turn the group around and couple both ends back on. Lose track of either end and part of the train rolls away.

Reorder List is three yard moves in a row: find the middle, turn the back half around, then interleave the two halves.

## Visualization

Reversing positions left..right by repeatedly moving the next node to the front of the sublist:

```viz
reverse-sublist
```

LRU cache: a hash map finds the node, a doubly linked list keeps the usage order:

```viz
lru
```

## Template code

```python
# Reverse nodes between positions left and right (1-based)
dummy = ListNode(0, head)
prev = dummy
for _ in range(left - 1):
    prev = prev.next                     # node before the sublist
cur = prev.next                          # will become the sublist's tail
for _ in range(right - left):
    nxt = cur.next
    cur.next = nxt.next                  # unhook nxt
    nxt.next = prev.next                 # put it at the front
    prev.next = nxt
return dummy.next

# Add two numbers stored in reverse (digit per node)
dummy = tail = ListNode()
carry = 0
while l1 or l2 or carry:
    s = carry + (l1.val if l1 else 0) + (l2.val if l2 else 0)
    carry, d = divmod(s, 10)
    tail.next = tail = ListNode(d)
    l1, l2 = l1 and l1.next, l2 and l2.next
return dummy.next

# Intersection of two lists: switch heads, walk the same total distance
a, b = headA, headB
while a is not b:
    a = a.next if a else headB
    b = b.next if b else headA
return a

# LRU cache in Python
from collections import OrderedDict
cache.move_to_end(key)                    # mark as most recent
cache.popitem(last=False)                 # evict least recent
```

## Complexity

| Problem | Time | Space |
|---|---|---|
| reverse a sublist / k-groups | O(n) | O(1) |
| reorder list (middle + reverse + merge) | O(n) | O(1) |
| add two numbers | O(max(m, n)) | O(1) besides the output |
| intersection | O(m + n) | O(1) |
| copy list with random pointer | O(n) | O(n) map (O(1) with interleaving) |
| LRU get / put | **O(1)** | O(capacity) |

## When to use it

- **"Reverse between positions", "reverse in groups of k"** → dummy + move-to-front loop
- **"Reorder", "odd/even", "palindrome"** → split at the middle, reverse, merge
- **Digits in nodes** → walk both lists with a carry
- **"Do these lists meet?"** → switch-heads trick, or a set of nodes
- **Pointers you need to recreate (`random`)** → map old node → new node
- **O(1) lookup + O(1) reordering by recency** → hash map + doubly linked list

## Common traps

- Reversing a group before checking k nodes actually remain
- Losing the node before or after the reversed section
- Forgetting the final carry in Add Two Numbers (99 + 1)
- Copying random pointers before all new nodes exist: build them first, wire in a second pass
- LRU: a `get` also counts as a use, so it must move the key to the most-recent end
