import json

board = [list("ABCE"), list("SFCS"), list("ADEE")]
word = "SEE"
steps = []
path = []

def snap(cap, cell=None):
    steps.append({"grid": [row[:] for row in board], "highlight": [list(p) for p in path], "pointers": {"at": list(cell)} if cell else {},
                  "vars": {"word": word, "matched": word[:len(path)]}, "caption": cap})

snap(f"Find \"{word}\". DFS from a matching cell; the path can't reuse a cell, so mark it while it's on the path.")

def dfs(r, c, i):
    if not (0 <= r < 3 and 0 <= c < 4) or board[r][c] != word[i] or (r, c) in path:
        return False
    path.append((r, c))
    snap(f"({r},{c}) = '{word[i]}' matches letter {i + 1}. Mark it and try its 4 neighbours for '{word[i + 1]}'." if i + 1 < len(word) else f"({r},{c}) = '{word[i]}': last letter matched. Found!", (r, c))
    if i == len(word) - 1:
        return True
    for dr, dc in ((0, 1), (1, 0), (0, -1), (-1, 0)):
        if dfs(r + dr, c + dc, i + 1):
            return True
    path.pop()
    snap(f"Dead end from ({r},{c}): unmark it and back up (this is the backtracking step).", (r, c))
    return False

for r in range(3):
    for c in range(4):
        if dfs(r, c, 0):
            break
    else:
        continue
    break
print(json.dumps({"title": "Word Search: DFS with mark and unmark", "view": "grid", "steps": steps}))
