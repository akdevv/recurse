## Core idea

**Two pointers move through the list at different speeds or with a fixed gap. Their relative position tells you something about the list's shape:** where the middle is, whether there's a cycle, where the cycle starts, which node is n-th from the end. All in one pass and O(1) space.

## Intuition

Two runners on a track, one twice as fast as the other.
- On a straight road, when the fast runner finishes, the slow one is exactly halfway. → **the middle**
- On a circular track, the fast runner laps the slow one and they meet. → **a cycle**
- Two runners walking at the same speed with a fixed gap of n between them: when the front one reaches the end, the back one is n from the end. → **n-th from the end**

## Visualization

Finding the middle:

```viz
middle
```

Floyd's algorithm: detect the cycle, then find where it starts:

```viz
cycle
```

Why phase 2 works: let **a** = steps from the head to the cycle start, **b** = steps from the start to the meeting point, **L** = cycle length. Slow walked a + b, fast walked twice that, and fast's extra distance is whole laps: a + b = kL. So a = kL − b: walking **a** steps from the meeting point lands exactly on the cycle start, at the same moment a pointer starting from the head gets there.

## Template code

```python
# Middle (second middle for even lengths)
slow = fast = head
while fast and fast.next:
    slow, fast = slow.next, fast.next.next
return slow

# Cycle detection + cycle start
slow = fast = head
while fast and fast.next:
    slow, fast = slow.next, fast.next.next
    if slow is fast:
        a = head
        while a is not slow:
            a, slow = a.next, slow.next
        return a                          # start of the cycle
return None

# n-th from the end: open a gap of n, then move together
dummy = ListNode(0, head)
fast = slow = dummy
for _ in range(n + 1):
    fast = fast.next
while fast:
    slow, fast = slow.next, fast.next
slow.next = slow.next.next               # remove it
```

## Complexity

| Task | Time | Space | Alternative |
|---|---|---|---|
| middle | O(n) | O(1) | count length first: 2 passes |
| cycle detection | O(n) | **O(1)** | set of visited nodes: O(n) space |
| cycle start | O(n) | O(1) | set of visited nodes |
| n-th from end | O(n), one pass | O(1) | count length first |

## When to use it

- **"Middle of the list", split in half** → slow/fast
- **"Is there a cycle", "where does it start"** → Floyd
- **"n-th from the end", "remove the n-th last"** → fixed gap
- **Palindrome list in O(1) space** → middle, reverse the second half, compare
- **A sequence that must repeat or reach an end (Happy Number, Find the Duplicate)** → treat `x → f(x)` as a list and run Floyd

## Common traps

- `while fast.next` without checking `fast` first: crash on even lengths
- Comparing values instead of nodes (`is`): different nodes can hold equal values
- n-th from end: without a dummy, removing the head needs a special case
- Starting fast one step ahead in some templates and not others: pick one and stick to it
- Forgetting that "second middle" vs "first middle" depends on the loop condition
