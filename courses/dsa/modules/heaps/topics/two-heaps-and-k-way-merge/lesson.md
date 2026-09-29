## Core idea

**Two heaps split data into a lower half (max-heap) and an upper half (min-heap), so the middle is always at their tops: running median in O(log n) per insert.** A single min-heap holding one item per source merges k sorted sources: always pop the smallest head and push that source's next item.

## Intuition

**Median:** a see-saw with a pivot in the middle. The left side holds the smaller numbers with its biggest one closest to the pivot; the right side holds the larger numbers with its smallest one closest. Keep the sides the same size (left may have one extra) and the median is right at the pivot.

**K-way merge:** k queues at a bank, each already in order. To serve everyone in global order, you only compare the people at the *front* of each queue. A heap keeps those k fronts and tells you the smallest in O(log k).

## Visualization

Running median with a max-heap and a min-heap:

```viz
median
```

Merging k sorted lists with one head per list in the heap:

```viz
k-way
```

## Template code

```python
import heapq

# Running median
lo, hi = [], []                    # lo: max-heap (negated), hi: min-heap
def add(x):
    heapq.heappush(lo, -x)
    heapq.heappush(hi, -heapq.heappop(lo))    # largest of lo moves to hi
    if len(hi) > len(lo):
        heapq.heappush(lo, -heapq.heappop(hi))  # keep lo the same size or 1 bigger
def median():
    if len(lo) > len(hi):
        return -lo[0]
    return (-lo[0] + hi[0]) / 2

# K-way merge of sorted linked lists
h = [(node.val, i, node) for i, node in enumerate(lists) if node]
heapq.heapify(h)
dummy = tail = ListNode()
while h:
    val, i, node = heapq.heappop(h)
    tail.next = tail = node
    if node.next:
        heapq.heappush(h, (node.next.val, i, node.next))
return dummy.next
```

## Complexity

| Task | Time | Space |
|---|---|---|
| add a number (two heaps) | O(log n) | O(n) total |
| get the median | O(1) | – |
| merge k lists, N values in total | O(N log k) | O(k) heap |
| merge by concatenating and sorting | O(N log N) | O(N) |

## When to use it

- **"Median of a stream", "balance two halves"** → two heaps
- **Sliding window median** → two heaps with lazy deletion (harder variant)
- **"Merge k sorted lists/arrays", "smallest range covering k lists"** → k-way merge with a heap
- **"k-th smallest in a sorted matrix"** → treat each row as a sorted list, k-way merge
- **Only two lists** → plain two-pointer merge, no heap needed

## Common traps

- Letting the heaps drift in size: rebalance after every insert
- Forgetting to negate when pushing into / reading from the max-heap side
- Pushing ListNode objects without an index tie-breaker: comparing two nodes raises `TypeError` when values tie
- Integer vs float median: the average of two tops should be a float (e.g. 2.5)
- Pushing all N values into one heap for k-way merge: correct, but O(N log N) and more memory
