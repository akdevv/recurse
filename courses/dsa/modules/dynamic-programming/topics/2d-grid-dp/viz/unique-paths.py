import json
m, n = 3, 5
dp = [["" for _ in range(n)] for _ in range(m)]
steps = [{"grid": [r[:] for r in dp], "highlight": [], "vars": {"grid": f"{m} × {n}"},
          "caption": "Unique Paths: you can only move right or down. dp[r][c] = number of ways to reach cell (r, c)."}]
for r in range(m):
    for c in range(n):
        if r == 0 or c == 0:
            dp[r][c] = 1
            cap = f"({r},{c}) is on the top row or left column: only one way to get there. dp = 1."
        else:
            dp[r][c] = dp[r - 1][c] + dp[r][c - 1]
            cap = f"({r},{c}): arrive from above ({dp[r-1][c]}) or from the left ({dp[r][c-1]}). dp = {dp[r][c]}."
        if r == 0 or c == 0:
            if (r, c) not in ((0, n - 1), (m - 1, 0)):
                continue
        steps.append({"grid": [row[:] for row in dp], "highlight": [[r, c]] + ([[r - 1, c], [r, c - 1]] if r and c else []), "pointers": {"cell": [r, c]}, "vars": {}, "caption": cap})
steps.append({"grid": [row[:] for row in dp], "highlight": [[m - 1, n - 1]], "vars": {"answer": dp[m - 1][n - 1]},
              "caption": f"{dp[m-1][n-1]} paths. Fill row by row: O(m·n) time; one row of dp is enough for O(n) space."})
print(json.dumps({"title": "Grid DP: ways from above + ways from the left", "view": "grid", "steps": steps}))
