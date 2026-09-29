## Core idea

**A hash table turns a key into an array index, so finding, adding or removing a key takes O(1) on average.** It's the tool that turns "search the whole array again" (O(n)) into "look it up" (O(1)).

## Intuition

Think of a coat check. You hand over your coat and get ticket #42. When you come back, the attendant doesn't search every hook, they walk straight to hook 42. A **hash function** is the ticket machine: it turns any key (a number, a string, a tuple) into a hook number.

Two keys can get the same hook: a **collision**. The usual fix is **chaining**: each hook holds a short list. As long as the lists stay short, every lookup is still instant.

## Visualization

Keys go into buckets by `hash(key) % buckets`. A lookup only searches one bucket:

```viz
buckets
```

The pattern you'll use most: walk the array once and ask the hash map "have I seen what I need?"

```viz
two-sum
```

## Template code

```python
# set: "have I seen x?"
seen = set()
for x in nums:
    if x in seen:           # O(1) average
        return True
    seen.add(x)

# dict: remember something about each value (index, count, …)
index = {}
for i, x in enumerate(nums):
    if target - x in index:
        return [index[target - x], i]
    index[x] = i

# counting
from collections import Counter, defaultdict
counts = Counter(s)                 # {'a': 3, 'n': 2, 'b': 1}
counts = defaultdict(int)
for c in s:
    counts[c] += 1                  # no KeyError for new keys

counts.get(key, 0)                  # safe read with a default
```

## Complexity

| Operation | Average | Worst case |
|---|---|---|
| `x in s`, `d[k]`, insert, delete | **O(1)** | O(n) (every key in one bucket) |
| build from n items | O(n) | O(n²) |
| iterate over everything | O(n) | O(n) |
| space | O(n) | O(n) |

The table **resizes** when it gets too full (the **load factor** = items ÷ buckets gets high), keeping buckets short. Like `list.append`, that makes inserts O(1) amortized.

**Keys must be hashable**: numbers, strings, tuples work; lists and dicts don't (they can change, which would change their hash).

## When to use it

- **"Have I seen this before?"** / duplicates → set
- **"Find a pair that sums to…"** → dict of value → index, look up the complement
- **"Count", "most frequent", "anagram"** → `Counter` or a dict of counts
- **"Map each x to one y" (isomorphic, word pattern)** → two dicts, one per direction
- **An O(n²) double loop where the inner loop searches** → replace the inner search with a lookup

## Common traps

- `x in some_list` is O(n). Convert to a set first if you'll check many times
- Checking and inserting in the wrong order (Two Sum: look up the partner *before* storing x, or x pairs with itself)
- `d[k]` on a missing key raises `KeyError`: use `get`, `defaultdict` or `Counter`
- Using a list as a key: convert it to a `tuple`
- Saying "O(1)" without "average": interviewers like to hear that the worst case is O(n)
- Hash maps trade memory for speed: O(n) extra space. If the question demands O(1) space, look for another idea
