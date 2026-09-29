## Core idea

**Divide and conquer: split the problem, solve the parts recursively, combine.** Merge sort splits blindly and does the work when *merging*. Quick sort does the work when *partitioning* around a pivot and then just recurses. Both are O(n log n) on average.

## Intuition

**Merge sort** is two sorted piles of exam papers being combined: look at the top of each pile and take the smaller one, again and again. Merging two sorted piles is easy and linear. So: split until every pile has one paper (trivially sorted), then merge back up.

**Quick sort** is picking one student (the pivot) and saying "shorter than them go left, taller go right". The pivot is now exactly where it belongs. Repeat on each side. A good pivot splits the group in half; a terrible one (the shortest person every time) peels off one person per round.

## Visualization

Merge sort: sorted halves combined level by level:

```viz
merge-sort
```

Lomuto partition: one pass puts the pivot in its final spot:

```viz
partition
```

## Template code

```python
def merge_sort(a):
    if len(a) <= 1:
        return a
    mid = len(a) // 2
    left, right = merge_sort(a[:mid]), merge_sort(a[mid:])
    out, i, j = [], 0, 0
    while i < len(left) and j < len(right):
        if left[i] <= right[j]:          # <= keeps it stable
            out.append(left[i]); i += 1
        else:
            out.append(right[j]); j += 1
    return out + left[i:] + right[j:]

import random
def quick_sort(a, lo, hi):
    if lo >= hi:
        return
    p = random.randint(lo, hi)           # random pivot avoids the worst case
    a[p], a[hi] = a[hi], a[p]
    i = lo
    for j in range(lo, hi):              # Lomuto partition
        if a[j] < a[hi]:
            a[i], a[j] = a[j], a[i]
            i += 1
    a[i], a[hi] = a[hi], a[i]            # pivot lands at index i
    quick_sort(a, lo, i - 1)
    quick_sort(a, i + 1, hi)
```

## Complexity

| | Best / average | Worst | Extra space | Stable? |
|---|---|---|---|---|
| Merge sort | O(n log n) | **O(n log n)** | O(n) | yes |
| Quick sort | O(n log n) | O(n²) (bad pivots) | O(log n) stack | no |
| Timsort (Python) | O(n) on sorted runs | O(n log n) | O(n) | yes |

Why n log n: the array is halved log₂ n times, and each level of the recursion touches all n elements once.

Quick sort's worst case happens when the pivot is always the smallest or largest (e.g. last element on already sorted input). A random pivot makes that astronomically unlikely. Many equal values? A 3-way partition (less / equal / greater) keeps it fast.

## When to use it

- **"Sort without built-ins" with large n** → merge sort (guaranteed) or randomized quick sort
- **Need stability or sorting linked lists** → merge sort
- **In place, fast in practice** → quick sort
- **"k-th largest/smallest" without sorting everything** → quick*select*: partition, then recurse into one side only, O(n) average
- **Counting inversions, merging k sorted things** → the merge step is the tool

## Common traps

- Picking the first/last element as pivot on sorted input: O(n²)
- Forgetting the `left[i:] + right[j:]` leftovers after merging
- `<` instead of `<=` in the merge makes it unstable
- Quick sort recursion on already sorted input can blow the recursion limit without a random pivot
- Saying merge sort is in place: the classic version needs O(n) extra space
