import json

a = [5, 2, 4, 6, 1, 3]
steps = [{"array": list(a), "pointers": {}, "highlight": [0], "vars": {},
          "caption": "Insertion sort: like sorting cards in your hand. The left part (highlighted) is always sorted; take the next card and slide it into place."}]
for i in range(1, len(a)):
    x, j = a[i], i - 1
    steps.append({"array": list(a), "pointers": {"i": i}, "highlight": list(range(i)), "vars": {"card": x},
                  "caption": f"Pick up {x}. Shift bigger cards in the sorted part one step right to make room."})
    while j >= 0 and a[j] > x:
        a[j + 1] = a[j]
        j -= 1
    a[j + 1] = x
    steps.append({"array": list(a), "pointers": {"i": i, "placed": j + 1}, "highlight": list(range(i + 1)), "vars": {"card": x, "shifts": i - 1 - j},
                  "caption": f"{x} goes to index {j + 1} ({i - 1 - j} shifts). Sorted part is now {i + 1} long."})
steps.append({"array": list(a), "pointers": {}, "highlight": list(range(len(a))), "vars": {},
              "caption": "Done. Worst case O(n²) shifts, but on nearly sorted input almost nothing shifts: close to O(n)."})
print(json.dumps({"title": "Insertion sort: grow a sorted prefix", "view": "array", "steps": steps}))
