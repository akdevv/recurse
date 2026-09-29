import json

m = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
n = len(m)
steps = [{"grid": [r[:] for r in m], "highlight": [], "pointers": {}, "vars": {},
          "caption": "Rotate 90° clockwise in place = transpose, then reverse every row."}]
for r in range(n):
    for c in range(r + 1, n):
        m[r][c], m[c][r] = m[c][r], m[r][c]
        steps.append({"grid": [row[:] for row in m], "highlight": [[r, c], [c, r]], "pointers": {}, "vars": {"r": r, "c": c},
                      "caption": f"Transpose: swap ({r},{c}) with ({c},{r}). Only cells above the diagonal, or each pair would swap back."})
steps.append({"grid": [row[:] for row in m], "highlight": [[i, i] for i in range(n)], "pointers": {}, "vars": {},
              "caption": "Transposed: rows became columns. The diagonal never moves."})
for r in range(n):
    m[r].reverse()
    steps.append({"grid": [row[:] for row in m], "highlight": [[r, c] for c in range(n)], "pointers": {}, "vars": {"row": r},
                  "caption": f"Reverse row {r}."})
steps.append({"grid": [row[:] for row in m], "highlight": [], "pointers": {}, "vars": {},
              "caption": "Rotated clockwise with O(1) extra space. The old first row (1 2 3) is now the last column."})
print(json.dumps({"title": "Rotating a matrix in place", "view": "grid", "steps": steps}))
