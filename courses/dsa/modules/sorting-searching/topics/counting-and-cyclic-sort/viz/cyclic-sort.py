import json

a = [3, 5, 2, 1, 4]
steps = [{"array": list(a), "pointers": {}, "highlight": [], "vars": {},
          "caption": "Cyclic sort: values are 1..n, so value v belongs at index v − 1. Swap each value straight to its home."}]
i = 0
while i < len(a):
    v = a[i]
    if a[v - 1] != v:
        a[i], a[v - 1] = a[v - 1], a[i]
        steps.append({"array": list(a), "pointers": {"i": i, "home": v - 1}, "highlight": [k for k in range(len(a)) if a[k] == k + 1], "vars": {"moved": v},
                      "caption": f"{v} belongs at index {v - 1}: swap it there. Stay at i = {i}, the new value here needs placing too."})
    else:
        steps.append({"array": list(a), "pointers": {"i": i}, "highlight": [k for k in range(len(a)) if a[k] == k + 1], "vars": {},
                      "caption": f"{v} is at home (index {v - 1}). Move on."})
        i += 1
steps.append({"array": list(a), "pointers": {}, "highlight": list(range(len(a))), "vars": {},
              "caption": "Every swap puts one value home for good, so at most n swaps: O(n). Afterwards, a slot i not holding i + 1 reveals a missing or duplicate number."})
print(json.dumps({"title": "Cyclic sort: every value to index value − 1", "view": "array", "steps": steps}))
