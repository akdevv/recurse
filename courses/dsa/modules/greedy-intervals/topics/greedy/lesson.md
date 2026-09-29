## Core idea

**A greedy algorithm makes the choice that looks best right now and never reconsiders it.** It's fast and simple, but only correct when you can argue that the local choice never hurts the final answer. That argument (usually an "exchange argument") is the real skill; many problems that look greedy actually need dynamic programming.

## Intuition

Giving change with coins 25, 10, 5, 1: take the biggest coin that fits, repeat. It works for these coins. But with coins 1, 3, 4 and amount 6, greedy takes 4 + 1 + 1 (three coins) while 3 + 3 uses two. The first choice looked best and locked you into a worse answer.

The **exchange argument**: take any optimal answer that differs from the greedy one; show you can swap in the greedy choice without making it worse. If you can, greedy is safe. If you find a counterexample, it isn't.

## Visualization

Assign Cookies: smallest cookie that satisfies the least greedy child:

```viz
cookies
```

Jump Game II: think in ranges of indexes reachable with k jumps:

```viz
jumps
```

A counterexample, and why testing one is worth it:

```viz
greedy-fails
```

## Template code

```python
# Sort, then match greedily (cookies, boats, meeting people)
g.sort(); s.sort()
i = 0
for size in s:
    if i < len(g) and size >= g[i]:
        i += 1
return i

# Reachability: farthest index so far
far = 0
for i, x in enumerate(nums):
    if i > far:
        return False
    far = max(far, i + x)
return True

# Minimum jumps: ranges (implicit BFS)
jumps = end = far = 0
for i in range(len(nums) - 1):
    far = max(far, i + nums[i])
    if i == end:
        jumps, end = jumps + 1, far

# Kadane (max subarray): drop a running sum that went negative
cur = best = nums[0]
for x in nums[1:]:
    cur = max(x, cur + x)
    best = max(best, cur)

# Gas station: restart after any stretch that runs dry
tank = start = 0
for i in range(len(gas)):
    tank += gas[i] - cost[i]
    if tank < 0:
        start, tank = i + 1, 0
```

## Complexity

Greedy solutions are usually **O(n)** after an optional **O(n log n)** sort, with O(1) extra space. That speed is why it's worth checking whether greedy is valid before reaching for DP.

## When to use it

- **Matching sizes to needs** (cookies, boats, people) → sort both, match smallest-first
- **"Can you reach the end", "minimum jumps"** → track the farthest reachable index
- **"Maximum subarray sum"** → Kadane
- **"Buy/sell as many times as you like"** → take every upward step
- **Scheduling / intervals** → sort by end (next topic)
- **Greedy has a counterexample** (coin change with odd coins, 0/1 knapsack) → dynamic programming

## Common traps

- Trusting greedy because it passes the examples: try to break it with a small counterexample first
- Sorting by the wrong key (start vs end, value vs ratio)
- Lemonade change: paying $15 change as 5 + 5 + 5 when a 10 + 5 is available wastes $5 bills
- Jump Game II: incrementing `jumps` at every index instead of at the end of each range
- Gas station: checking every start separately is O(n²); a failed stretch rules out every start inside it
