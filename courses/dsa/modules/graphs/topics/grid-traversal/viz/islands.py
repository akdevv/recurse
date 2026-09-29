import json
g = [list("11000"), list("11010"), list("00100"), list("00011")]
m, n = len(g), len(g[0])
count, steps = 0, []
steps.append({"grid": [r[:] for r in g], "highlight": [], "vars": {"islands": 0}, "caption": "Number of islands. Scan every cell; an unvisited '1' starts a new island. Then flood it so its other cells aren't counted again."})
for r in range(m):
    for c in range(n):
        if g[r][c] == "1":
            count += 1
            stack, cells = [(r, c)], []
            g[r][c] = "#"
            while stack:
                i, j = stack.pop()
                cells.append([i, j])
                for di, dj in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    a, b = i + di, j + dj
                    if 0 <= a < m and 0 <= b < n and g[a][b] == "1":
                        g[a][b] = "#"
                        stack.append((a, b))
            for i, j in cells:
                g[i][j] = chr(ord("A") + count - 1)
            steps.append({"grid": [row[:] for row in g], "highlight": cells, "pointers": {"start": [r, c]}, "vars": {"islands": count},
                          "caption": f"Land at ({r},{c}) not visited yet: island #{count}. DFS over its 4-neighbours marks all {len(cells)} cell(s) as {chr(ord('A') + count - 1)}."})
steps.append({"grid": g, "highlight": [], "vars": {"islands": count}, "caption": f"{count} islands. Every cell is visited a constant number of times: O(m·n)."})
print(json.dumps({"title": "Counting islands by flooding them", "view": "grid", "steps": steps}))
