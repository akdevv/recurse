## Core idea

**Pick a key that is the same for everything that belongs together, and let a dict collect them.** Grouping, counting and "does this sequence continue?" questions all reduce to choosing the right key.

## Intuition

Sorting mail into pigeonholes: you don't compare every letter with every other letter, you read one thing off each envelope (the street) and drop it in that hole. The street is the **key**.

For anagrams, the "street" is the letters themselves: `"eat"`, `"tea"` and `"ate"` all sort to `"aet"`. For frequencies, the key is the value and the dict holds a count. For consecutive runs, a set answers "is the next number here?" in O(1).

## Visualization

One pass, one key per word:

```viz
group-anagrams
```

With a set you can grow a run upwards, but only start from numbers that begin a run, so nothing is counted twice:

```viz
consecutive
```

## Template code

```python
from collections import defaultdict, Counter

# Group by a canonical key
groups = defaultdict(list)
for w in words:
    groups["".join(sorted(w))].append(w)       # or tuple of 26 counts
return list(groups.values())

# Frequencies, then the top k
counts = Counter(nums)
counts.most_common(k)                          # heap under the hood, O(n log k)

# Bucket by frequency: index = count (at most n)
buckets = [[] for _ in range(len(nums) + 1)]
for x, f in counts.items():
    buckets[f].append(x)

# Runs with a set: only start where x - 1 is missing
s = set(nums)
for x in s:
    if x - 1 not in s:
        y = x
        while y + 1 in s:
            y += 1
        best = max(best, y - x + 1)
```

## Complexity

| Task | Cost |
|---|---|
| group n words of length k, sorted key | O(n · k log k) |
| group with a 26-count tuple key | O(n · k) |
| count n values | O(n) |
| top k by sorting counts | O(n log n) |
| top k with bucket sort | **O(n)** |
| longest consecutive run with a set | **O(n)**: every value is walked once |

## When to use it

- **"Group", "categorize", "which ones belong together"** → dict of key → list
- **"Anagram"** → sorted string or letter-count tuple as the key
- **"Most frequent", "top k"** → `Counter`, then heap or buckets
- **"Longest consecutive" without sorting** → set + start-of-run check
- **Several rules to check at once (Sudoku)** → one set per rule, or tuples like `("row", r, d)` in one set

## Common traps

- Using a list as a dict key: make it a `tuple`
- Sorting when the question asks for better than O(n log n): think buckets or a heap
- Longest consecutive: walking up from *every* number is O(n²); only start where `x - 1` isn't in the set
- Duplicates: a set drops them, which is what you want for runs but not for counts
- Sudoku box index is `(r // 3, c // 3)`, not `r // 3 + c // 3` alone (that collides)
