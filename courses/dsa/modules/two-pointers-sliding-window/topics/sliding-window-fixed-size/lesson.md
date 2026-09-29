## Core idea

**A window of exactly k elements slides one step at a time: add the element entering on the right, remove the one leaving on the left, update the answer. Each step is O(1), so all windows together cost O(n) instead of O(n·k).**

## Intuition

A train passing a platform, one carriage at a time, where you can see exactly k carriages. When it moves, one carriage appears on the right and one disappears on the left. You don't recount everyone in view, you add the newcomer and subtract the one who left.

What you keep about the window (a sum, a count, a set of values) is called the **window state**. The whole skill is choosing a state that can be updated in O(1) when one element enters and one leaves.

## Visualization

Maximum sum of k consecutive numbers:

```viz
fixed-window
```

The state can be a set: "is this value among the last k?" (Contains Duplicate II)

```viz
window-set
```

## Template code

```python
# Fixed window of size k
state = sum(nums[:k])            # build the first window
best = state
for r in range(k, len(nums)):
    state += nums[r]             # element entering
    state -= nums[r - k]         # element leaving
    best = max(best, state)

# Same idea with a counter (e.g. vowels in each window)
cnt = sum(c in vowels for c in s[:k])
for r in range(k, len(s)):
    cnt += (s[r] in vowels) - (s[r - k] in vowels)

# Window as a set of the last k values
window = set()
for i, x in enumerate(nums):
    if x in window:
        return True
    window.add(x)
    if len(window) > k:
        window.remove(nums[i - k])

# Window as letter counts (permutation / anagram in a string)
need, have = [0] * 26, [0] * 26
```

## Complexity

| Approach | Time | Space |
|---|---|---|
| recompute every window | O(n·k) | O(1) |
| sliding update | **O(n)** | O(1) for sums/counts |
| sliding set / letter counts | O(n) | O(k) or O(26) |

## When to use it

- **"Subarray / substring of length k"** → fixed window
- **"Max/min/average of every k consecutive…"** → running sum or count
- **"Within distance k", "at most k apart"** → window of the last k values
- **"Contains a permutation / anagram of p"** → window of len(p) with letter counts
- **Sliding window maximum** → the window state is a monotonic deque (Module 6)

## Common traps

- Off-by-one: the element leaving when `r` enters is `nums[r - k]`, not `nums[r - k + 1]`
- Forgetting to count the very first window before the loop
- Rebuilding the state inside the loop (`sum(nums[r-k+1:r+1])`) brings back O(n·k)
- Comparing two 26-count arrays is fine (O(26)); comparing Counters of growing size isn't
- Average vs sum: maximize the sum, divide once at the end
