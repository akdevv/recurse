## Core idea

**A matrix is a list of rows, and every cell has an address `(row, col)`.** Most matrix problems are about walking those addresses in a particular order (row by row, down a diagonal, in a spiral) or moving values between them with a simple formula.

## Intuition

Think of a spreadsheet. `matrix[r][c]` is "row r, column c". Rows go down, columns go across. An m × n matrix has m rows and n columns.

Every transformation is just a rule for where a cell moves:
- **Transpose** (flip over the diagonal): `(r, c) → (c, r)`
- **Rotate 90° clockwise**: `(r, c) → (c, n-1-r)`
- **Mirror left-right**: `(r, c) → (r, n-1-c)`

Write the rule down on a 3 × 3 example first, and the code follows.

## Visualization

Spiral order: keep four boundaries and peel the matrix like an onion.

```viz
spiral
```

Rotating in place: a transpose followed by reversing every row.

```viz
rotate
```

## Template code

```python
rows, cols = len(matrix), len(matrix[0])

# Create a grid: one list per row (NOT [[0] * cols] * rows)
grid = [[0] * cols for _ in range(rows)]

# Visit every cell
for r in range(rows):
    for c in range(cols):
        ...

# The four neighbours of (r, c): a direction array, used in every grid problem
DIRS = [(0, 1), (1, 0), (0, -1), (-1, 0)]      # right, down, left, up
for dr, dc in DIRS:
    nr, nc = r + dr, c + dc
    if 0 <= nr < rows and 0 <= nc < cols:
        ...

# Diagonals of an n × n matrix
primary = [matrix[i][i] for i in range(n)]
secondary = [matrix[i][n - 1 - i] for i in range(n)]

# Transpose in place (square only): swap above the diagonal only
for r in range(n):
    for c in range(r + 1, n):
        matrix[r][c], matrix[c][r] = matrix[c][r], matrix[r][c]

# Columns as tuples
list(zip(*matrix))
```

## Complexity

| Task | Time | Extra space |
|---|---|---|
| visit every cell | O(m·n) | O(1) |
| read one diagonal | O(n) | O(1) |
| transpose into a new matrix | O(m·n) | O(m·n) |
| rotate / transpose in place (square) | O(n²) | O(1) |
| spiral order | O(m·n) | O(1) besides the output |

Remember that the input size here is **m·n**, not n. An "O(m·n)" matrix solution is linear in the number of cells.

## When to use it

- **"Rotate / flip the image"** → write the `(r, c) → (?, ?)` rule, then look for transpose + reverse
- **"Spiral", "zigzag", "diagonal order"** → boundaries or a direction array
- **"In place" with a whole-row/column effect** → first record what to change, then write (Set Matrix Zeroes)
- **Neighbours, islands, paths** → the direction array (Modules 10 and 12 build on this)

## Common traps

- `[[0] * cols] * rows`: every row is the **same** list, so changing one changes all
- Mixing up `len(matrix)` (rows) and `len(matrix[0])` (columns) on non-square inputs
- Changing cells while you're still scanning, so new values look like original ones
- Transposing in place over every cell swaps each pair twice (back to the start)
- Single row, single column and 1 × 1 matrices: test them, especially for spiral order
