## Core idea

**In 1D DP the state is one index or amount: `dp[i]` is the best answer for a prefix (first i items) or for a smaller target (amount i).** The whole problem is choosing that meaning and writing how `dp[i]` depends on earlier entries.

## Intuition

House Robber: walking down a street deciding house by house. At each house you ask one question: rob it (then the previous house was skipped, so add `dp[i − 2]`) or skip it (keep `dp[i − 1]`). You never need to remember the whole plan, only the best totals for the last two positions.

Coin Change: to make amount 6, the last coin was 1, 3 or 4, so the answer is 1 + the best way to make 5, 3 or 2. Solve every smaller amount first and each one is a lookup.

## Visualization

House Robber: take it or leave it at every house:

```viz
house-robber
```

Coin Change: best answer for every amount up to the target:

```viz
coin-change
```

## Template code

```python
# Prefix DP: best for houses 0..i
prev2 = prev1 = 0
for x in nums:
    prev2, prev1 = prev1, max(prev1, prev2 + x)
return prev1

# Circular street (House Robber II): exclude the first OR the last house
max(rob(nums[1:]), rob(nums[:-1]))

# Amount DP: fewest coins
dp = [0] + [float("inf")] * amount
for a in range(1, amount + 1):
    for c in coins:
        if c <= a:
            dp[a] = min(dp[a], dp[a - c] + 1)
return dp[amount] if dp[amount] != float("inf") else -1

# Decode Ways: last step decodes 1 digit or 2 digits
dp[i] = (dp[i-1] if s[i-1] != "0" else 0) + (dp[i-2] if 10 <= int(s[i-2:i]) <= 26 else 0)

# Word Break: dp[i] = prefix of length i can be split into words
dp[i] = any(dp[j] and s[j:i] in words for j in range(i))

# LIS O(n²): dp[i] = longest increasing subsequence ending at i
dp[i] = 1 + max((dp[j] for j in range(i) if nums[j] < nums[i]), default=0)

# Max product subarray: track both max and min ending here
```

## Complexity

| Problem | Time | Space |
|---|---|---|
| House Robber I/II | O(n) | O(1) |
| Decode Ways | O(n) | O(1) |
| Coin Change | O(amount × coins) | O(amount) |
| Word Break | O(n²) substring checks (fewer if you cap by the longest word) | O(n) |
| LIS | O(n²), or O(n log n) with binary search | O(n) |

## When to use it

- **Choices along a line (houses, steps, characters)** → dp over the prefix
- **"Fewest items / ways to make a total"** → dp over amounts
- **"Can this string be split / decoded"** → dp over prefix lengths
- **"Longest increasing …"** → dp ending at each index (or patience sorting)
- **Negatives flip the best into the worst (products)** → track max and min together

## Common traps

- Coin Change: initialising with 0 instead of infinity, or returning infinity instead of −1
- House Robber II: forgetting the single-house case when splitting into two ranges
- Decode Ways: "06" is not valid; a '0' can only be the second digit of 10 or 20
- LIS: `dp[-1]` is not the answer; take `max(dp)` (the best can end anywhere)
- Word Break: checking every `j` down to 0 when words are at most 20 long; limit the inner loop
