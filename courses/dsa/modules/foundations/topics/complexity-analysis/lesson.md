## Core idea

**Big-O answers one question: when the input gets 10× bigger, how much slower (or hungrier for memory) does my code get?**

## Intuition

You're not measuring seconds; that depends on the machine. You're counting **how the number of steps grows with n**.

- Reading one page of a book: same effort for any book → **O(1)**
- Reading every page: twice the pages, twice the time → **O(n)**
- Comparing every page with every other page: 2× pages, **4×** time → **O(n²)**
- Finding a word in a dictionary by opening the middle and halving: 2× pages, **one** extra step → **O(log n)**

## Visualization

A loop inside a loop visits every pair. Watch the operation counter grow like n × n.

```viz
nested-loops
```

Halving is the opposite: the range collapses fast, so even a million items need only ~20 steps.

```viz
halving
```

## Template code

How to read complexity straight off the code:

```python
def f(nums):                 # n = len(nums)
    total = 0                # O(1)
    for x in nums:           # n times
        total += x           #   O(1)  → loop is O(n)

    for i in range(len(nums)):          # n times
        for j in range(len(nums)):      #   n times
            pass                        #     → O(n²)

    k = len(nums)
    while k > 1:             # k halves each time
        k //= 2              # → O(log n)

    return total             # overall: O(n) + O(n²) + O(log n) = O(n²)
```

**Rules:**
1. **Sequential blocks add**, then keep the biggest term: O(n) + O(n²) → O(n²)
2. **Nested loops multiply**: n outer × m inner → O(n·m)
3. **Drop constants**: 2n, n/2, 100n are all O(n)
4. **Halving/doubling** the remaining work → O(log n)
5. **Recursion**: (number of calls) × (work per call). Stack depth = extra space
6. Different inputs get different letters: two arrays of sizes n and m → O(n + m), not O(n)

## Complexity

The common runtimes, fastest to slowest (n = 1,000,000):

| Big-O | Name | Rough steps | Typical source |
|---|---|---|---|
| O(1) | constant | 1 | index, hash lookup, math formula |
| O(log n) | logarithmic | ~20 | binary search, halving |
| O(n) | linear | 10⁶ | one loop |
| O(n log n) | linearithmic | ~2·10⁷ | good sorting |
| O(n²) | quadratic | 10¹² ✗ | nested loops over the same data |
| O(2ⁿ) | exponential | ✗✗ | all subsets, naive recursion |
| O(n!) | factorial | ✗✗✗ | all orderings |

**Rule of thumb:** Python does roughly 10⁷ simple operations per second. Check the constraints: n ≤ 10⁵ means you need about O(n log n) or better; n ≤ 20 hints that O(2ⁿ) is acceptable.

**Other notations:** Big-O = upper bound ("at most"), Ω (Omega) = lower bound ("at least"), Θ (Theta) = tight ("exactly this growth"). In interviews people say "Big-O" and mean the tight worst case.

**Best / average / worst case:** linear search is O(1) if the target is first, O(n) worst. Quote the **worst** case unless asked.

**Amortized:** `list.append` sometimes resizes (O(n) copy), but doubling the capacity makes resizes rare, so the **average per append is O(1)**.

**Space complexity** counts *extra* memory you allocate: new lists, dicts, and the **recursion call stack**. The input itself usually doesn't count.

## When to use it

Always. State both **time and space** for every solution you present, and justify them in one sentence ("one pass over n elements, hash set up to n entries → O(n) time, O(n) space").

## Common traps

- **Hidden loops**: `x in list`, `list.index`, `max()`, slicing `a[i:]`, `s += c` all cost O(n)
- Saying O(2n): drop the constant, it's O(n)
- Forgetting the recursion stack in space complexity
- Two different inputs: `for a in A: for b in B` is O(|A|·|B|), not O(n²)
- A loop to √n is O(√n), not O(n)
- Using complexity to compare solutions with tiny n: constants matter there, Big-O doesn't tell the whole story
