import json
from collections import deque
g = [[2, 1, 1], [1, 1, 0], [0, 1, 1]]
m, n = 3, 3
q = deque((r, c) for r in range(m) for c in range(n) if g[r][c] == 2)
fresh = sum(v == 1 for row in g for v in row)
show = lambda: [["🍊" if v == 1 else "🟫" if v == 2 else "·" for v in row] for row in g]
steps = [{"grid": show(), "highlight": [list(p) for p in q], "vars": {"minute": 0, "fresh": fresh},
          "caption": "Rotting oranges spread to 4 neighbours every minute. Put ALL rotten oranges in the queue at once (multi-source BFS)."}]
minute = 0
while q and fresh:
    minute += 1
    new = []
    for _ in range(len(q)):
        r, c = q.popleft()
        for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            a, b = r + dr, c + dc
            if 0 <= a < m and 0 <= b < n and g[a][b] == 1:
                g[a][b] = 2; fresh -= 1; q.append((a, b)); new.append([a, b])
    steps.append({"grid": show(), "highlight": new, "vars": {"minute": minute, "fresh": fresh},
                  "caption": f"Minute {minute}: one BFS level. {len(new)} orange(s) rot. {fresh} fresh left."})
steps.append({"grid": show(), "highlight": [], "vars": {"answer": minute if fresh == 0 else -1},
              "caption": f"No fresh oranges left after {minute} minutes. (If some fresh ones were unreachable, the answer would be −1.)"})
print(json.dumps({"title": "Multi-source BFS: every level is one minute", "view": "grid", "steps": steps}))
