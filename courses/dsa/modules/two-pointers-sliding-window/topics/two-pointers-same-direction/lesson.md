## Core idea

**Two pointers move the same way: a fast one reads every element, a slow one marks where the next element you want to keep goes (or how far you've matched).** It filters, compacts or matches in one pass without extra memory.

## Intuition

A librarian re-shelving books. She walks along the shelf (fast pointer) and picks up every book worth keeping, putting it back at the next free spot on the left (slow pointer). Damaged books are simply walked past. At the end, the good books sit packed together at the start of the shelf.

The same shape handles subsequence checks: the slow pointer walks the short string only when the fast pointer finds its next character.

## Visualization

Removing duplicates from a sorted array: the slow pointer only moves when something new appears.

```viz
dedupe
```

Three pointers split an array into three regions in a single pass (Sort Colors):

```viz
dutch-flag
```

## Template code

```python
# Read / write: keep the values that pass a test
k = 0
for x in nums:
    if keep(x):
        nums[k] = x
        k += 1
return k                                # nums[:k] is the answer

# Move zeros back but keep order: swap instead of copy
k = 0
for i in range(len(nums)):
    if nums[i] != 0:
        nums[k], nums[i] = nums[i], nums[k]
        k += 1

# Subsequence: slow pointer on s, fast pointer on t
i = 0
for c in t:
    if i < len(s) and s[i] == c:
        i += 1
return i == len(s)

# Dutch flag: lo, mid, hi
lo = mid = 0; hi = len(nums) - 1
while mid <= hi:
    if nums[mid] == 0:   swap(lo, mid); lo += 1; mid += 1
    elif nums[mid] == 1: mid += 1
    else:                swap(mid, hi); hi -= 1     # mid stays
```

## Complexity

| Task | Time | Space |
|---|---|---|
| filter / compact in place | O(n) | O(1) |
| subsequence check | O(len(t)) | O(1) |
| Dutch flag (3 values) | O(n), one pass | O(1) |
| building a new list instead | O(n) | O(n) |

## When to use it

- **"In place", "O(1) extra space", "return the new length"** → read/write pointers
- **Sorted input with duplicates to remove** → compare with the last kept value
- **"Move all X to the end, keep the order"** → swap non-X values forward
- **"Is s a subsequence of t", merging two sorted lists** → one pointer per sequence
- **Only 2–3 distinct values to arrange** → Dutch national flag
- **Strings with backspaces** → a stack, or walk backwards with a skip counter

## Common traps

- Comparing with `nums[i - 1]` instead of the last *kept* value `nums[k - 1]` when duplicates may repeat more than twice
- Copying non-zeros forward and forgetting to zero-fill the rest (swapping avoids this)
- Dutch flag: advancing `mid` after swapping with `hi`; the value that came back is unchecked
- Returning the array when the problem wants `k`, or the other way round
- Starting the write pointer at 0 when the first element is always kept (Remove Duplicates starts at 1)
