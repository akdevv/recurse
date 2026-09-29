## Core idea

**An array is a row of equal-sized slots in one block of memory.** That makes jumping to any index instant (O(1)), and makes inserting or deleting in the middle slow (O(n)), because everything after it has to shift.

## Intuition

Picture a row of numbered seats in a cinema. Finding seat 57 is instant: you walk straight to it. But if someone wants to squeeze in at seat 3, everybody from seat 3 onwards has to stand up and move one seat over.

Almost every array trick in interviews is about **avoiding that shifting**: instead of deleting, overwrite. Instead of inserting at the front, fill from the back. Instead of making a copy, swap in place.

## Visualization

The most useful in-place pattern: one pointer **reads** every value, another marks where the next value you want to **keep** gets written. Nothing shifts, nothing gets deleted.

```viz
write-pointer
```

Swapping from both ends toward the middle reverses any stretch of the array in place. Three reversals rotate the whole array:

```viz
three-reversals
```

## Template code

```python
# Read / write pointers: compact the values you want to keep to the front
def compact(nums, keep):
    k = 0
    for x in nums:
        if keep(x):
            nums[k] = x
            k += 1
    return k                     # nums[:k] is the answer

# Reverse nums[lo..hi] in place (two pointers moving inward)
def reverse(nums, lo, hi):
    while lo < hi:
        nums[lo], nums[hi] = nums[hi], nums[lo]
        lo, hi = lo + 1, hi - 1

# Fill from the back when the free space is at the end (Merge Sorted Array)
i, j, w = m - 1, n - 1, m + n - 1

# One pass with a running value (max streak, running sum, best so far)
best = cur = 0
for x in nums:
    cur = cur + 1 if x == 1 else 0
    best = max(best, cur)
```

## Complexity

| Operation | Cost | Why |
|---|---|---|
| read / write `a[i]` | O(1) | the address is `start + i × size` |
| append at the end | O(1) amortized | occasional resize copies everything |
| insert / delete in the middle | **O(n)** | everything after it shifts |
| search an unsorted array | O(n) | must look at every slot |
| reverse / rotate in place | O(n) time, O(1) space | each value swapped a constant number of times |

**Static vs dynamic arrays:** a static array has a fixed size. Python's `list` is dynamic: when it fills up it allocates a bigger block (about 1.125×) and copies everything over. Spread over many appends that's still O(1) each on average.

## When to use it

- **"Do it in place" / "O(1) extra space"** → read/write pointers, or swapping with two pointers
- **"Remove / move certain values"** → read/write pointer compaction
- **"Longest run", "best so far"** → one pass, carry a running value
- **Free space at the end of the array** → fill from the back
- **"Rotate", "reverse part of"** → reversals with two pointers
- **A value appears more than n/2 times** → Boyer-Moore voting

## Common traps

- Deleting inside a loop (`nums.remove(x)`, `del nums[i]`): O(n) each, O(n²) total, and it shifts the indices you're looping over
- `nums = other` inside a function only rebinds the local name. To change the caller's list use `nums[:] = other`
- Rotating by k larger than n: always `k %= n` first
- Writing from the front when the destination still holds unread data (Merge Sorted Array)
- Off-by-one at the ends: an empty array, a single element, all values the same
