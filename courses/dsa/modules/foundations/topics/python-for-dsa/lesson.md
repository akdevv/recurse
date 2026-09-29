## Core idea

**Every Python line has a price tag.** DSA in Python means knowing which built-ins are O(1), which are O(n), and which tool fits each job.

## Intuition

Think of a **list** as a row of numbered lockers: jump to locker #57 instantly, but finding "the locker with the red bag" means opening them one by one.
A **set / dict** is a coat check: hand over the ticket (the key) and the attendant goes straight to the right hook.

## Visualization

A running total is the most common loop shape in DSA: one variable carries information forward.

```viz
running-sum
```

## Template code

The toolkit you'll use in almost every module:

```python
from collections import deque, Counter, defaultdict
import heapq, bisect

nums = [5, 2, 8, 2]

# lists
nums.append(7)            # O(1) amortized
nums.pop()                # O(1)   (pop from the END)
nums.pop(0)               # O(n)   everything shifts left, so use deque instead
nums[1:3]                 # O(k)   slicing COPIES k elements
sorted(nums, key=lambda x: -x)   # O(n log n), returns a new list

# dict / set: O(1) average insert, delete, lookup
seen = set()
counts = Counter(nums)            # {2: 2, 5: 1, 8: 1}
groups = defaultdict(list)        # missing keys start as []
groups["even"].append(2)

# deque: O(1) at BOTH ends (queues, BFS)
q = deque([1, 2]); q.appendleft(0); q.popleft()

# heapq: min-heap on a plain list
h = []; heapq.heappush(h, 5); heapq.heappush(h, 1); heapq.heappop(h)   # 1

# bisect: binary search on a sorted list
bisect.bisect_left([1, 3, 5], 4)   # 2 (where 4 would go)

# handy
best = float("inf")                # "larger than anything" start value
a, b = b, a                        # swap without a temp variable
for i, x in enumerate(nums): ...   # index + value
```

## Complexity

| Operation | list | dict / set | deque |
|---|---|---|---|
| index `a[i]` | O(1) | n/a | O(n) |
| append / pop at end | O(1)* | n/a | O(1) |
| insert / pop at front | **O(n)** | n/a | O(1) |
| `x in …` | **O(n)** | **O(1)** avg | O(n) |
| add / remove key | n/a | O(1) avg | n/a |
| slice / copy | O(k) | O(n) | n/a |
| `sorted()` / `.sort()` | O(n log n) | n/a | n/a |

\* amortized: an occasional resize copies everything, but spread over all appends it averages O(1).

**Strings are immutable**: `s += c` in a loop builds a new string each time (can be O(n²)). Collect pieces in a list and `"".join(parts)` once.

## When to use it

- Need **"have I seen this?"** → `set`
- Need **"how many times?"** → `Counter` / `dict`
- Need **"group things by key"** → `defaultdict(list)`
- Need **"add/remove at both ends"** → `deque`
- Need **"always get the smallest next"** → `heapq`
- Need **"search a sorted list"** → `bisect`

## Common traps

- `x in list` inside a loop: a hidden O(n²)
- `list.pop(0)` for a queue: O(n) each; use `deque.popleft()`
- Slicing inside a loop (`nums[i:]`) copies every time
- Calling `max(nums)` / `len(...)`-style scans inside a loop when the value doesn't change (see Kids With Candies)
- Mutating a list while iterating over it
- `[[0] * m] * n` creates n references to the **same** row; use `[[0] * m for _ in range(n)]`
