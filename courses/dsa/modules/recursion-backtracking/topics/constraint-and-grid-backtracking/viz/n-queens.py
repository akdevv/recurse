import json

n = 4
cols, d1, d2 = set(), set(), set()
board = [["·"] * n for _ in range(n)]
steps = [{"grid": [r[:] for r in board], "highlight": [], "vars": {}, "caption": "Place 4 queens so none attack each other. One queen per row; try each column, undo when stuck."}]
queens = []
def snap(cap, extra=None):
    steps.append({"grid": [r[:] for r in board], "highlight": [list(q) for q in queens], "pointers": {"try": list(extra)} if extra else {}, "vars": {"cols": sorted(cols)}, "caption": cap})

def place(r):
    if r == n:
        snap("All 4 rows filled: a solution.")
        return True
    for c in range(n):
        if c in cols or r - c in d1 or r + c in d2:
            snap(f"Row {r}, column {c}: attacked (column or diagonal already used). Skip.", (r, c))
            continue
        cols.add(c); d1.add(r - c); d2.add(r + c); board[r][c] = "Q"; queens.append((r, c))
        snap(f"Row {r}, column {c}: safe. Place a queen and go to row {r + 1}.", (r, c))
        if place(r + 1):
            return True
        cols.remove(c); d1.remove(r - c); d2.remove(r + c); board[r][c] = "·"; queens.pop()
        snap(f"Row {r + 1} had no safe column. Remove the queen at ({r},{c}) and try the next column.", (r, c))
    return False

place(0)
print(json.dumps({"title": "N-Queens: place, recurse, remove", "view": "grid", "steps": steps}))
