## Core idea

**A queue is first in, first out (FIFO): add at the back, remove from the front.** A deque ("deck", double-ended queue) allows both at both ends. In Python use `collections.deque`: every end operation is O(1). A plain list is O(n) to pop from the front.

## Intuition

A line at a ticket counter: whoever arrived first is served first. Nobody cuts in, nobody leaves from the middle.

Queues show up whenever things must be handled **in arrival order**: requests in a time window, tasks waiting to run, and, most importantly, the frontier of **breadth-first search** (Trees and Graphs modules), where nodes are explored in the order they were discovered.

## Visualization

A fixed-size circular queue: the indexes wrap around, nothing ever shifts.

```viz
circular
```

A queue as a sliding time window: old entries always leave from the front.

```viz
recent-calls
```

## Template code

```python
from collections import deque

q = deque()
q.append(x)          # enqueue at the back, O(1)
q.popleft()          # dequeue from the front, O(1)
q[0], q[-1]          # peek front / back
q.appendleft(x)      # deque: add at the front, O(1)
q.pop()              # deque: remove from the back, O(1)

# DON'T: list.pop(0) shifts every element, O(n)

# Time window: drop expired items from the front
q.append(t)
while q[0] < t - 3000:
    q.popleft()

# Circular buffer with a fixed array
buf = [0] * k
head = count = 0
tail = (head + count) % k            # next write position
head = (head + 1) % k                # after a dequeue

# Stack from one queue: rotate after every push
q.append(x)
for _ in range(len(q) - 1):
    q.append(q.popleft())            # x is now at the front
```

## Complexity

| Operation | `deque` | `list` |
|---|---|---|
| append / pop at the back | O(1) | O(1) |
| append / pop at the front | **O(1)** | **O(n)** |
| index in the middle | O(n) | O(1) |

A circular array queue is O(1) for everything and never reallocates: that's how fixed-size buffers work in real systems.

## When to use it

- **Process in arrival order / "first come, first served"** → queue
- **Events in the last X seconds** → queue of timestamps, drop from the front
- **Level-by-level exploration, shortest path in unweighted graphs** → BFS with a queue
- **Need both ends (window max, palindrome checks)** → deque
- **Fixed capacity buffer** → circular array with head + count

## Common traps

- `list.pop(0)` in a loop: O(n²) overall. Use `deque.popleft()`
- Circular queue: telling "empty" from "full" with only head and tail. Track `count` (or leave one slot empty)
- Forgetting `% k` when advancing an index
- Implementing a queue with two stacks and moving items on every pop: only refill the out-stack when it's empty, which makes each item move once (amortized O(1))
