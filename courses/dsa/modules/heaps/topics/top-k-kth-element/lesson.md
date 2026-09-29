## Core idea

**To get the k largest items, keep a min-heap of size k: its root is the smallest of your current top k, so any newcomer only needs to beat the root.** That's O(n log k) instead of sorting everything in O(n log n). Quickselect goes further: O(n) on average for a single k-th element.

## Intuition

A talent show where only 3 finalists are allowed on stage. The judge only watches the *weakest* finalist. When a new act comes in and beats that one, the weakest leaves and the new act joins; otherwise the new act goes home. The weakest finalist on stage at the end is exactly the 3rd best overall.

Counter-intuitive but key: **k largest → min-heap**, **k smallest → max-heap**. The heap's root is the one in danger of being kicked out.

## Visualization

Size-k min-heap over a stream:

```viz
topk-heap
```

Quickselect: partition like quick sort, but only continue on the side holding the answer:

```viz
quickselect
```

## Template code

```python
import heapq

# k-th largest: min-heap of size k
h = []
for x in nums:
    heapq.heappush(h, x)
    if len(h) > k:
        heapq.heappop(h)          # drop the smallest
return h[0]

# k closest points: max-heap of size k on distance (negate)
for x, y in points:
    heapq.heappush(h, (-(x * x + y * y), x, y))
    if len(h) > k:
        heapq.heappop(h)

# top k frequent: count, then heap / sort by (-count, key)
from collections import Counter
counts = Counter(words)
heapq.nsmallest(k, counts, key=lambda w: (-counts[w], w))

# Task scheduler (greedy): the most frequent task shapes the schedule
most = max(counts.values())
ties = sum(v == most for v in counts.values())
answer = max(len(tasks), (most - 1) * (n + 1) + ties)
```

## Complexity

| Approach | Time | Space | Notes |
|---|---|---|---|
| sort, take k | O(n log n) | O(n) | simplest |
| size-k heap | **O(n log k)** | O(k) | great when k ≪ n, works on streams |
| heapify all + pop k | O(n + k log n) | O(n) | |
| quickselect | **O(n)** average, O(n²) worst | O(1) | one answer, modifies the array |
| bucket sort (frequencies ≤ n) | O(n) | O(n) | top-k frequent |

## When to use it

- **"k largest / smallest / closest / most frequent"** → size-k heap
- **Data arrives as a stream, k fixed** → size-k heap (Kth Largest in a Stream)
- **One k-th element, array fits in memory** → quickselect
- **Frequencies bounded by n** → bucket sort
- **Scheduling with cooldowns** → count the most frequent, or simulate with a max-heap

## Common traps

- Using a max-heap of all n items for "k largest": works, but O(n log n) memory-heavy
- Comparing distances with `sqrt`: unnecessary and introduces floats; compare squares
- Top K Frequent Words: ties must be broken alphabetically, so the key is `(-count, word)`
- Quickselect with a fixed pivot on sorted input: O(n²); randomize it
- Forgetting that k is 1-based (1st largest = the maximum)
