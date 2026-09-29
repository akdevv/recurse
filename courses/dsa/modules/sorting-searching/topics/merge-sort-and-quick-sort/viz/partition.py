import json

a = [7, 2, 1, 8, 6, 3, 5, 4]
hi = len(a) - 1
pivot = a[hi]
i = 0
steps = [{"array": list(a), "pointers": {"pivot": hi}, "highlight": [], "vars": {"pivot": pivot},
          "caption": f"Quick sort's partition (Lomuto): pivot = last element ({pivot}). Everything left of i will be < pivot."}]
for j in range(hi):
    if a[j] < pivot:
        a[i], a[j] = a[j], a[i]
        steps.append({"array": list(a), "pointers": {"i": i + 1, "j": j, "pivot": hi}, "highlight": list(range(i + 1)), "vars": {"a[j]": a[i]},
                      "caption": f"{a[i]} < {pivot}: swap it into the small side at index {i}, i = {i + 1}."})
        i += 1
    else:
        steps.append({"array": list(a), "pointers": {"i": i, "j": j, "pivot": hi}, "highlight": list(range(i)), "dim": [j], "vars": {"a[j]": a[j]},
                      "caption": f"{a[j]} ≥ {pivot}: leave it on the big side."})
a[i], a[hi] = a[hi], a[i]
steps.append({"array": list(a), "pointers": {"pivot": i}, "highlight": [i], "vars": {"pivot index": i},
              "caption": f"Swap the pivot to index {i}. It's now in its final sorted position; recurse on the two sides. Good pivots → O(n log n); always the smallest/largest → O(n²)."})
print(json.dumps({"title": "Partition around a pivot", "view": "array", "steps": steps}))
