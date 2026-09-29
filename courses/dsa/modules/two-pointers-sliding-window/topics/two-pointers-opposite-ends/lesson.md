## Core idea

**Put one pointer at each end and move them toward each other. Each step uses a comparison to throw away one element for good, so a pair search that would be O(n²) becomes O(n).**

## Intuition

Two people searching a sorted bookshelf for two books whose page counts add up to exactly 500. One starts at the thin end, one at the thick end. Too many pages? The person at the thick end steps in. Too few? The person at the thin end steps in. Neither ever needs to walk back, because every step removes a book that could never be part of the answer.

That "never walk back" guarantee is the whole trick. It only holds when the input has an order (sorted values) or a symmetry (a palindrome reads the same from both ends).

## Visualization

Pair sum on a sorted array: each comparison eliminates one end.

```viz
pair-sum
```

Container With Most Water: the shorter line limits the area, so it's the one that moves.

```viz
container
```

## Template code

```python
# Pair with a target sum in a sorted array
l, r = 0, len(nums) - 1
while l < r:
    s = nums[l] + nums[r]
    if s == target:
        return [l, r]
    if s < target:
        l += 1          # need bigger: drop the smallest
    else:
        r -= 1          # need smaller: drop the largest

# Symmetry check (palindrome): compare mirrored positions
while l < r:
    if s[l] != s[r]:
        return False
    l, r = l + 1, r - 1

# 3Sum: sort, fix one value, two-pointer the rest, skip duplicates
nums.sort()
for i in range(len(nums) - 2):
    if i and nums[i] == nums[i - 1]:
        continue
    l, r = i + 1, len(nums) - 1
    # ... pair search for -nums[i]
```

## Complexity

| Approach | Time | Space |
|---|---|---|
| check every pair | O(n²) | O(1) |
| two pointers on sorted input | **O(n)** | O(1) |
| sort first, then two pointers | O(n log n) | O(1)–O(n) |
| 3Sum: fix one + two pointers | O(n²) | O(1) extra |

Each pointer moves at most n times and they never cross, so the loop is linear.

## When to use it

- **Sorted array + pair/triplet with a target sum** → move in from both ends
- **Palindrome / "reads the same"** → compare mirrored characters
- **"Maximize area/width" between two positions** → start widest, move the limiting side
- **Squares of a sorted array, merging from the extremes** → the largest values sit at the ends
- **Unsorted but order doesn't matter** → sort first (costs O(n log n)), then two pointers

## Common traps

- Using it on unsorted input: moving a pointer no longer rules anything out
- `while l <= r` for pair problems: the same element would pair with itself
- 3Sum duplicates: skip equal values for the fixed element *and* after each found triplet
- Returning 0-based indexes when the problem wants 1-based (Two Sum II)
- Moving the taller line in Container With Most Water: it can never help, you lose width and keep the same cap
