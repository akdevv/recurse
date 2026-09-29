import json
a, b = "abcde", "ace"
m, n = len(a), len(b)
dp = [[0] * (n + 1) for _ in range(m + 1)]
def grid():
    top = [" ", "∅"] + list(b)
    rows = [top]
    for i in range(m + 1):
        rows.append([("∅" if i == 0 else a[i - 1])] + [dp[i][j] if (i == 0 or j == 0 or filled[i][j]) else "" for j in range(n + 1)])
    return rows
filled = [[False] * (n + 1) for _ in range(m + 1)]
steps = [{"grid": grid(), "highlight": [], "vars": {"text1": a, "text2": b},
          "caption": "Longest common subsequence. dp[i][j] = LCS of the first i letters of text1 and the first j of text2. Row 0 / column 0 (empty string) are 0."}]
for i in range(1, m + 1):
    for j in range(1, n + 1):
        if a[i - 1] == b[j - 1]:
            dp[i][j] = dp[i - 1][j - 1] + 1
            cap = f"'{a[i-1]}' == '{b[j-1]}': extend the diagonal. dp = dp[{i-1}][{j-1}] + 1 = {dp[i][j]}."
            hl = [[i + 1, j + 1], [i, j]]
        else:
            dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
            cap = f"'{a[i-1]}' ≠ '{b[j-1]}': drop a letter from one string. dp = max(up {dp[i-1][j]}, left {dp[i][j-1]}) = {dp[i][j]}."
            hl = [[i + 1, j + 1], [i, j + 1], [i + 1, j]]
        filled[i][j] = True
        steps.append({"grid": grid(), "highlight": hl, "vars": {}, "caption": cap})
steps.append({"grid": grid(), "highlight": [[m + 1, n + 1]], "vars": {"answer": dp[m][n]},
              "caption": f"LCS length {dp[m][n]} (\"ace\"). O(m·n) time; Edit Distance fills the same kind of table with 1 + min(insert, delete, replace)."})
print(json.dumps({"title": "Two-string DP: match → diagonal, mismatch → best neighbour", "view": "grid", "steps": steps}))
