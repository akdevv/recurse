## Core idea

**Knapsack problems ask what you can build from a set of items under a capacity: which sums are reachable, the best value, or how many ways.** The state is "items considered so far × capacity used". **0/1 knapsack** (each item once) loops the capacity *downward*; **unbounded knapsack** (items reusable) loops it *upward*.

## Intuition

Packing a bag with a weight limit. For each item you decide: leave it, or take it and use up some capacity. After considering all items, the table tells you everything achievable at every capacity.

Many problems are knapsack in disguise:
- **Partition Equal Subset Sum** → can some items sum to exactly half the total?
- **Target Sum** (+/− signs) → choosing the "+" group P means sum(P) = (total + target) / 2: count subsets with that sum
- **Coin Change II** → coins are reusable items; count combinations reaching the amount

## Visualization

0/1 knapsack as reachable sums (loop downward so each item is used once):

```viz
subset-sum
```

Unbounded knapsack counting combinations (coins in the outer loop):

```viz
coin-change-ii
```

## Template code

```python
# 0/1: can a subset sum to target? (each item once → iterate s DOWN)
can = [True] + [False] * target
for x in nums:
    for s in range(target, x - 1, -1):
        can[s] = can[s] or can[s - x]

# 0/1 counting: number of subsets with sum = target
ways = [1] + [0] * target
for x in nums:
    for s in range(target, x - 1, -1):
        ways[s] += ways[s - x]

# Target Sum → subset count with sum (total + target) / 2
if (total + target) % 2 or abs(target) > total: return 0

# Unbounded counting (Coin Change II): coins OUTER, amounts UP
ways = [1] + [0] * amount
for c in coins:
    for a in range(c, amount + 1):
        ways[a] += ways[a - c]

# Unbounded minimum (Coin Change I): order doesn't matter for min
dp[a] = min(dp[a], dp[a - c] + 1)
```

## Complexity

**O(n × capacity)** time and **O(capacity)** space with a 1D table. This is "pseudo-polynomial": fast when the capacity (a number) is small, like 1000 or 5000, and hopeless when it's 10⁹.

## When to use it

- **"Split into two equal-sum groups"** → subset sum to total / 2
- **"Assign + and − to reach a target"** → count subsets with (total + target) / 2
- **"Number of combinations of coins/items to make X"** → unbounded knapsack, items outer
- **"Fewest items to make X", items reusable** → unbounded, min
- **Each item at most once** → iterate capacity downward (or keep two rows)

## Common traps

- 0/1 knapsack looping capacity upward: an item gets reused within the same round
- Coin Change II with the loops swapped (amount outer, coins inner): counts permutations ([1,2] and [2,1] separately)
- Target Sum: forgetting to check parity and |target| ≤ total before dividing
- Zeros in Target Sum: each zero doubles the count (+0 and −0); the counting DP handles it if you don't skip zeros
- Odd total in Partition Equal Subset Sum: return False immediately
