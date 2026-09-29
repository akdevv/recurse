import json

m = [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12]]
top, bottom, left, right = 0, 2, 0, 3
seen, out, steps = [], [], []

def snap(r, c, caption):
    steps.append({"grid": m, "highlight": list(seen), "pointers": {"at": [r, c]},
                  "vars": {"top": top, "bottom": bottom, "left": left, "right": right, "out": list(out)}, "caption": caption})

steps.append({"grid": m, "highlight": [], "pointers": {}, "vars": {"top": top, "bottom": bottom, "left": left, "right": right},
              "caption": "The unread part is always the rectangle top..bottom × left..right. Read its edges, then shrink it."})
while top <= bottom and left <= right:
    for c in range(left, right + 1):
        seen.append([top, c]); out.append(m[top][c]); snap(top, c, f"Top row, going right: {m[top][c]}.")
    top += 1
    for r in range(top, bottom + 1):
        seen.append([r, right]); out.append(m[r][right]); snap(r, right, f"Right column, going down: {m[r][right]}.")
    right -= 1
    if top <= bottom:
        for c in range(right, left - 1, -1):
            seen.append([bottom, c]); out.append(m[bottom][c]); snap(bottom, c, f"Bottom row, going left: {m[bottom][c]}.")
        bottom -= 1
    if left <= right:
        for r in range(bottom, top - 1, -1):
            seen.append([r, left]); out.append(m[r][left]); snap(r, left, f"Left column, going up: {m[r][left]}. Every boundary moves in by one.")
        left += 1
steps.append({"grid": m, "highlight": list(seen), "pointers": {}, "vars": {"out": out},
              "caption": "Boundaries crossed: every cell was read exactly once. O(m·n)."})
print(json.dumps({"title": "Spiral order with four shrinking boundaries", "view": "grid", "steps": steps}))
