## Core idea

**Bubble, selection and insertion sort all fix one element per round by comparing neighbours or scanning for a minimum, so they take O(n²).** You rarely use them in code, but interviewers ask how they work, and insertion sort is genuinely the best choice for small or nearly sorted data.

## Intuition

- **Insertion sort** is how you sort a hand of cards: pick up the next card and slide it left until it fits. The cards in your hand are always sorted.
- **Selection sort** is picking the shortest person out of a line, putting them first, then picking the shortest of the rest.
- **Bubble sort** walks the line swapping any neighbours in the wrong order. After each pass the tallest remaining person has "bubbled" to the end.

## Visualization

Insertion sort grows a sorted prefix; each new value shifts bigger ones right:

```viz
insertion
```

Selection sort does the fewest swaps (n − 1) but always scans everything:

```viz
selection
```

## Template code

```python
def insertion_sort(a):
    for i in range(1, len(a)):
        x, j = a[i], i - 1
        while j >= 0 and a[j] > x:     # shift bigger values right
            a[j + 1] = a[j]
            j -= 1
        a[j + 1] = x

def selection_sort(a):
    for i in range(len(a) - 1):
        m = min(range(i, len(a)), key=a.__getitem__)
        a[i], a[m] = a[m], a[i]

def bubble_sort(a):
    for end in range(len(a) - 1, 0, -1):
        swapped = False
        for j in range(end):
            if a[j] > a[j + 1]:
                a[j], a[j + 1] = a[j + 1], a[j]
                swapped = True
        if not swapped:                # already sorted: stop early
            break
```

## Complexity

| Sort | Best | Average / worst | Space | Stable? |
|---|---|---|---|---|
| Bubble (early exit) | O(n) | O(n²) | O(1) | yes |
| Selection | O(n²) | O(n²) | O(1) | no |
| Insertion | **O(n)** | O(n²) | O(1) | yes |

**Stable** means equal values keep their original order. That matters when you sort by one field after another (sort by name, then stable-sort by age: people of the same age stay in name order).

Python's `sorted` / `.sort()` is **Timsort**: O(n log n) worst case, O(n) on already sorted runs, stable. Internally it uses insertion sort on small chunks.

## When to use it

- **Tiny arrays (≤ ~20) or nearly sorted data** → insertion sort (few shifts)
- **Writes are expensive** → selection sort (at most n − 1 swaps)
- **The interviewer says "don't use the built-in sort"** → implement merge sort or quick sort instead (next topic), since O(n²) times out on large inputs
- **Counting how out of order an array is** → compare with a sorted copy (Height Checker)

## Common traps

- Claiming bubble sort is O(n) in general: only the early-exit version on already sorted input
- Selection sort isn't stable: a long-distance swap can jump an equal element
- Off-by-one in insertion sort: the loop must allow `j` to reach −1 so the value can land at index 0
- Submitting an O(n²) sort for n = 5·10⁴: 2.5 billion steps, it will time out
