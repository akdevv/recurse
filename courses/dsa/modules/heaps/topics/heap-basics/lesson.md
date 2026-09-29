## Core idea

**A heap always gives you the smallest (min-heap) or largest (max-heap) element in O(1), and adding or removing costs only O(log n).** It's a complete binary tree where every parent beats its children, stored compactly in an array. Python's `heapq` is a min-heap on a plain list.

## Intuition

A hospital emergency room: patients aren't treated in arrival order, the most urgent one goes next. New patients are slotted in by urgency; nobody needs the whole waiting list fully sorted, just who's *next*. That's a **priority queue**, and a heap is the standard way to build one.

A heap is only *partially* ordered: parent ≤ children, but siblings and cousins can be in any order. That's exactly enough to keep the minimum at the top, and cheap enough to repair in O(log n) after each change.

## Visualization

Push: add at the end, swap upward while smaller than the parent:

```viz
sift-up
```

Pop: move the last element to the root, swap downward with the smaller child:

```viz
sift-down
```

## Template code

```python
import heapq

h = []
heapq.heappush(h, 5)          # O(log n)
smallest = h[0]               # peek, O(1)
heapq.heappop(h)              # remove smallest, O(log n)
heapq.heapify(nums)           # turn a list into a heap in place, O(n)
heapq.heappushpop(h, x)       # push then pop, faster than both
heapq.nlargest(k, nums)       # top k, O(n log k)

# Max-heap: push negated values
heapq.heappush(h, -x)
largest = -h[0]

# Heap of tuples: ordered by the first field, ties by the next
heapq.heappush(h, (priority, index, item))

# Array layout (0-based)
parent = (i - 1) // 2
left, right = 2 * i + 1, 2 * i + 2
```

## Complexity

| Operation | Heap | Sorted list | Unsorted list |
|---|---|---|---|
| peek min | **O(1)** | O(1) | O(n) |
| insert | **O(log n)** | O(n) | O(1) |
| remove min | **O(log n)** | O(1)–O(n) | O(n) |
| build from n items | **O(n)** (heapify) | O(n log n) | – |
| heap sort | O(n log n) | – | – |

Why is heapify O(n) and not O(n log n)? Most nodes are near the bottom and only sift down a level or two; only the few nodes near the top can travel far.

## When to use it

- **"Repeatedly take the largest/smallest"** (Last Stone Weight, gifts, schedulers) → heap
- **A stream where you need the current k-th largest** → min-heap of size k
- **Merging sorted sources, Dijkstra, event simulation** → heap as the priority queue
- **Need everything sorted once** → just sort; a heap wins when items keep arriving or you only need a few

## Common traps

- Forgetting `heapq` is a **min**-heap: negate values for a max-heap (and negate back when reading)
- Treating the heap list as sorted: only `h[0]` is guaranteed; `h[1]` isn't the second smallest
- Pushing objects that can't be compared: add a tie-breaker index to the tuple
- Calling `heapify` after every push: O(n) each time instead of O(log n)
- Using `sqrt` with floats for "floor of square root": use `math.isqrt`
