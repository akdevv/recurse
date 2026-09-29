import json

s = "abcabcbb"
chars = list(s)
window, l, best = set(), 0, 0
steps = [{"array": chars, "pointers": {"l": 0, "r": 0}, "highlight": [], "vars": {"best": 0},
          "caption": "Longest substring without repeats. Grow r; if the new char is already in the window, shrink from l until it isn't."}]
for r, c in enumerate(s):
    while c in window:
        window.remove(s[l])
        steps.append({"array": chars, "pointers": {"l": l + 1, "r": r}, "highlight": list(range(l + 1, r)), "dim": [l], "vars": {"window": "".join(s[l + 1:r]), "best": best},
                      "caption": f"'{c}' is already inside. Drop '{s[l]}' from the left."})
        l += 1
    window.add(c)
    best = max(best, r - l + 1)
    steps.append({"array": chars, "pointers": {"l": l, "r": r}, "highlight": list(range(l, r + 1)), "vars": {"window": s[l:r + 1], "best": best},
                  "caption": f"Add '{c}'. Window '{s[l:r + 1]}' is valid (length {r - l + 1}). best = {best}."})
print(json.dumps({"title": "Variable window: expand right, shrink left while invalid", "view": "array", "steps": steps}))
