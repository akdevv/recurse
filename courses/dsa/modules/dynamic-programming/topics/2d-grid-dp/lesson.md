## Core idea

**When the state needs two numbers (a cell `(r, c)`, or positions `i` and `j` in two strings), the DP table is 2D.** Each cell depends on a few neighbours computed earlier (above, left, diagonal), so filling row by row works, and usually one row of memory is enough.

## Intuition

A city grid where you can only walk right or down. The number of routes to a corner is the routes to the corner above it plus the routes to the corner on its left: you must have arrived from one of them.

Two strings work the same way. To compare "abcde" and "ace", look at their last letters. If they match, that letter extends the answer for both strings shortened by one (the diagonal). If not, drop the last letter of one string or the other and take the better result (up or left).

## Visualization

Unique Paths: ways from above + ways from the left:

```viz
unique-paths
```

Longest common subsequence: diagonal on a match, best neighbour otherwise:

```viz
lcs
```

## Template code

```python
# Grid paths: dp[r][c] = dp[r-1][c] + dp[r][c-1], one row at a time
row = [1] * n
for _ in range(1, m):
    for c in range(1, n):
        row[c] += row[c - 1]              # row[c] already holds "from above"
return row[-1]

# Minimum path sum: min of the two ways in, plus this cell
grid[r][c] += min(grid[r-1][c], grid[r][c-1])   # handle row 0 / col 0 separately

# Obstacles: a blocked cell has 0 ways

# LCS of a and b
dp = [[0] * (n + 1) for _ in range(m + 1)]
for i in range(1, m + 1):
    for j in range(1, n + 1):
        if a[i-1] == b[j-1]:
            dp[i][j] = dp[i-1][j-1] + 1
        else:
            dp[i][j] = max(dp[i-1][j], dp[i][j-1])

# Edit distance: base row/col = i or j (delete/insert everything)
dp[i][j] = dp[i-1][j-1] if a[i-1] == b[j-1] else 1 + min(
    dp[i-1][j],        # delete
    dp[i][j-1],        # insert
    dp[i-1][j-1],      # replace
)

# Longest palindromic substring: expand around each of the 2n - 1 centres (O(1) space)
```

## Complexity

| Problem | Time | Space |
|---|---|---|
| Unique Paths / Min Path Sum | O(m·n) | O(n) with one row |
| LCS / Edit Distance | O(m·n) | O(min(m, n)) with rolling rows |
| Longest palindromic substring | O(n²) | O(1) expanding centres |

The extra row/column for the empty string (index 0) removes most edge cases in string DP.

## When to use it

- **Moves only right/down on a grid, count or minimise** → grid DP
- **Two strings: "common subsequence", "edits to convert", "interleave"** → dp[i][j] over prefixes
- **Substrings of one string (palindromes)** → dp[i][j] over ranges, or expand around centres
- **Only the previous row is read** → keep one or two rows

## Common traps

- Forgetting the empty-string row/column (off-by-one between dp indexes and string indexes)
- Edit distance base cases: `dp[i][0] = i`, `dp[0][j] = j`, not 0
- Obstacles in the first row/column: every cell after a blocked one is also unreachable
- Subsequence (letters can be skipped) vs substring (must be contiguous): different recurrences
- Updating a single row in the wrong direction and reading values already overwritten this row
