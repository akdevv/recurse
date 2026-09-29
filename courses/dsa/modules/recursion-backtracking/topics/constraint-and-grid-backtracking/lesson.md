## Core idea

**Same choose / explore / un-choose template, but now choices must obey constraints: a cell can't be reused, a queen can't be attacked, a piece must be a palindrome. Check the constraint before recursing and cut the branch the moment it fails (pruning).** On grids, "choose" means marking a cell visited and "un-choose" means unmarking it.

## Intuition

Walking a maze with chalk. At every junction you mark the path you took. Hit a dead end, walk back to the last junction, rub out the chalk, and try the next corridor. The chalk stops you walking in circles; rubbing it out lets a *different* path use those corridors later.

**Pruning** is what makes it fast enough: you stop the moment a partial answer can't work (a queen is attacked, the next letter doesn't match), instead of building complete answers and checking them at the end.

## Visualization

Word Search: mark the path, unmark on a dead end:

```viz
word-search
```

N-Queens: one queen per row, undo when a row has no safe column:

```viz
n-queens
```

## Template code

```python
# Grid DFS with mark / unmark (Word Search)
def dfs(r, c, i):
    if i == len(word):
        return True
    if not (0 <= r < m and 0 <= c < n) or board[r][c] != word[i]:
        return False                          # prune: out of bounds or mismatch
    tmp, board[r][c] = board[r][c], "#"       # mark
    found = any(dfs(r + dr, c + dc, i + 1) for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)))
    board[r][c] = tmp                         # unmark
    return found

# N-Queens: O(1) attack checks with sets
cols, diag, anti = set(), set(), set()
def place(r):
    if r == n:
        res.append(["".join(row) for row in board]); return
    for c in range(n):
        if c in cols or r - c in diag or r + c in anti:
            continue                          # prune
        cols.add(c); diag.add(r - c); anti.add(r + c); board[r][c] = "Q"
        place(r + 1)
        cols.remove(c); diag.remove(r - c); anti.remove(r + c); board[r][c] = "."

# Palindrome partitioning: cut a palindromic prefix, recurse on the rest
def part(start, path):
    if start == len(s):
        res.append(path[:]); return
    for end in range(start + 1, len(s) + 1):
        if s[start:end] == s[start:end][::-1]:
            path.append(s[start:end]); part(end, path); path.pop()
```

## Complexity

| Problem | Time (worst case) | Space |
|---|---|---|
| Word Search | O(m · n · 3^L), L = word length | O(L) recursion |
| N-Queens | O(n!) placements | O(n) |
| Palindrome Partitioning | O(n · 2ⁿ) | O(n) |

Branches that fail early are cut, so real running time is usually far below the worst case.

## When to use it

- **"Find a path / word in a grid" with no reuse** → DFS + mark / unmark
- **Placement puzzles (queens, Sudoku)** → try each option, check constraints, undo
- **"Split into pieces that each satisfy X"** → choose the first piece, recurse on the rest
- **Early "this can't work" checks exist** → prune as soon as possible
- **Searching many words on one grid** → build a trie so all words share the DFS (Module 13)

## Common traps

- Forgetting to unmark on the way back: later paths can't use the cell
- Checking bounds after indexing into the grid
- N-Queens diagonals: `r − c` identifies one direction, `r + c` the other
- Returning early without restoring the board when the word is found (fine for a yes/no answer, wrong if you keep searching)
- Recomputing palindrome checks repeatedly: precompute `is_pal[i][j]` if it's slow
