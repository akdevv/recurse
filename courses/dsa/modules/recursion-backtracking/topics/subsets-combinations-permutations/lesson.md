## Core idea

**Backtracking builds every answer one choice at a time: choose, explore the rest recursively, then un-choose so the next option starts from a clean state.** The choices form a decision tree; a DFS through that tree visits every subset, combination or permutation exactly once.

## Intuition

Packing for a trip by going through your wardrobe item by item: for each item you either **pick** it or **skip** it. Every complete sequence of decisions is one possible bag. Drawing all the decisions gives a tree with 2ⁿ leaves: one per subset.

Permutations are a different question per level: not "this item, yes or no?" but "which unused item goes in the next position?" That gives n choices, then n − 1, … → n! leaves.

The **un-choose** step (`path.pop()`) is what makes it backtracking: after exploring everything that includes a choice, you undo it and try the next.

## Visualization

Subsets as pick / skip decisions (each leaf is one subset):

```viz
pick-tree
```

Permutations: at each level, try every element not used yet:

```viz
perm-tree
```

## Template code

```python
def backtrack(start, path):
    res.append(path[:])                  # record (copy!) at every node for subsets
    for i in range(start, len(nums)):
        if i > start and nums[i] == nums[i - 1]:
            continue                     # skip duplicates at the same level (sorted input)
        path.append(nums[i])             # choose
        backtrack(i + 1, path)           # explore (i, not i + 1, to allow reuse)
        path.pop()                       # un-choose

# Pick / not pick form (subsets, target sums)
def dfs(i, path):
    if i == len(nums):
        res.append(path[:]); return
    path.append(nums[i]); dfs(i + 1, path); path.pop()   # pick
    dfs(i + 1, path)                                      # not pick

# Permutations: used[] marks what's already in the path
def perm(path):
    if len(path) == len(nums):
        res.append(path[:]); return
    for j in range(len(nums)):
        if not used[j]:
            used[j] = True; path.append(nums[j])
            perm(path)
            path.pop(); used[j] = False
```

## Complexity

| Problem | Number of results | Time |
|---|---|---|
| subsets | 2ⁿ | O(n · 2ⁿ) |
| combinations C(n, k) | n! / (k!(n−k)!) | O(k · C(n, k)) |
| permutations | n! | O(n · n!) |
| generate parentheses | Catalan(n) | O(4ⁿ / √n) |

The extra factor is the cost of copying each result. Space besides the output is O(n) for the path and the recursion depth.

## When to use it

- **"All subsets / combinations / permutations / arrangements"** → backtracking
- **"All combinations that sum to target"** → backtracking with pruning (sort, stop when too big)
- **Reuse allowed** → recurse with `i`; **each once** → recurse with `i + 1`
- **Duplicates in input** → sort, skip equal values at the same depth
- **Building strings with rules (valid parentheses, phone letters)** → add a character only when the rule allows it
- **Only need the count or best value, not the list** → often dynamic programming instead (Module 12)

## Common traps

- `res.append(path)` without copying: every result ends up as the same (empty) list
- Forgetting to `pop()`, so choices leak into sibling branches
- Skipping duplicates with `i > 0` instead of `i > start`: that wrongly skips valid combinations like [1, 1]
- Combinations produced as permutations ([2, 3] and [3, 2]) because the loop restarts from 0
- Exponential output: n = 20 subsets is a million lists; backtracking is only practical for small n
