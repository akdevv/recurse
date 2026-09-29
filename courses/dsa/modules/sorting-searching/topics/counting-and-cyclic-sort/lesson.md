## Core idea

**When values come from a small, known range, you don't need to compare them: use the value itself as an index.** Counting sort counts each value; cyclic sort puts each value `v` from 1..n directly at index `v − 1`. Both are O(n).

## Intuition

Sorting a stack of exam papers by grade A–F: you don't compare papers, you drop each into one of six trays and then stack the trays in order. That's **counting sort**, and its speed comes from the number of trays being small.

**Cyclic sort** is a cloakroom where coat #5 belongs on hook 5. Pick up a coat, hang it on its own hook, pick up the coat that was there, hang *that* one on its hook, and so on. Every move puts one coat home for good. Afterwards, an empty or wrong hook tells you which number is missing or doubled.

## Visualization

Counting sort for values 0..4:

```viz
counting-sort
```

Cyclic sort for values 1..n:

```viz
cyclic-sort
```

## Template code

```python
# Counting sort (values in 0..K)
counts = [0] * (K + 1)
for x in nums:
    counts[x] += 1
out = [v for v in range(K + 1) for _ in range(counts[v])]

# Cyclic sort (values 1..n): swap each value to its home index
i = 0
while i < len(nums):
    home = nums[i] - 1
    if 0 <= home < len(nums) and nums[home] != nums[i]:
        nums[i], nums[home] = nums[home], nums[i]   # don't advance i
    else:
        i += 1
missing = [i + 1 for i in range(len(nums)) if nums[i] != i + 1]

# Mark "seen" in place without moving anything (values 1..n)
for x in nums:
    j = abs(x) - 1
    nums[j] = -abs(nums[j])
missing = [i + 1 for i, x in enumerate(nums) if x > 0]

# Missing number in 0..n by arithmetic
missing = n * (n + 1) // 2 - sum(nums)
```

## Complexity

| Technique | Time | Extra space |
|---|---|---|
| counting sort | O(n + K) | O(K) |
| cyclic sort | O(n): each swap homes one value | O(1) |
| sign marking | O(n) | O(1) |
| comparison sorts (for reference) | O(n log n) at best | – |

Comparison sorts can't beat O(n log n). Counting and cyclic sort can because they never compare two elements: they use values as addresses.

## When to use it

- **Small value range (grades, digits, 0..1000)** → counting sort / count array
- **"Numbers from 1 to n" or "0 to n"** → cyclic sort or sign marking
- **"Find the missing / duplicate / disappeared numbers" in O(1) space** → cyclic sort or negation
- **"First missing positive"** → cyclic sort, ignoring values outside 1..n
- **Relative order given by another array** → count, then emit in that order

## Common traps

- Advancing `i` right after a swap in cyclic sort: the value swapped in hasn't been placed yet
- Infinite swapping with duplicates: check `nums[home] != nums[i]` before swapping
- Reading a sign-marked value without `abs()`
- Counting sort with a huge range (up to 10⁹): the count array is too big, sort instead
- Forgetting that the problem may forbid modifying the input (then use a set or math)
