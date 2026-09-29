import json

h = [1, 8, 6, 2, 5, 4, 8, 3, 7]
l, r, best = 0, len(h) - 1, 0
steps = [{"array": h, "pointers": {"l": l, "r": r}, "highlight": [], "vars": {"best": 0},
          "caption": "Container With Most Water: area = width × the shorter line. Start with the widest container."}]
while l < r:
    area = (r - l) * min(h[l], h[r])
    best = max(best, area)
    short = "l" if h[l] < h[r] else "r"
    steps.append({"array": h, "pointers": {"l": l, "r": r}, "highlight": list(range(l, r + 1)), "vars": {"area": f"{r - l} × {min(h[l], h[r])} = {area}", "best": best},
                  "caption": f"Area {area}. The shorter line ({min(h[l], h[r])}) caps every narrower container that keeps it, so move {short} inward."})
    if h[l] < h[r]:
        l += 1
    else:
        r -= 1
steps.append({"array": h, "pointers": {}, "highlight": [], "vars": {"answer": best}, "caption": f"Pointers met. Best area {best}, found in one O(n) pass."})
print(json.dumps({"title": "Always move the shorter line", "view": "array", "steps": steps}))
