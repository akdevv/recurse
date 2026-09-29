import json
g, s = [1, 2, 3], [1, 1, 3]
g.sort(); s.sort()
i = j = 0
steps = [{"array": [f"child {x}" for x in g], "pointers": {}, "highlight": [], "vars": {"cookies": s},
          "caption": "Assign Cookies: sort children by greed and cookies by size. Give each child the smallest cookie that satisfies them."}]
while i < len(g) and j < len(s):
    if s[j] >= g[i]:
        steps.append({"array": [f"child {x}" for x in g], "pointers": {"child": i}, "highlight": list(range(i + 1)), "vars": {"cookie": s[j], "cookies left": s[j + 1:]},
                      "caption": f"Cookie {s[j]} ≥ greed {g[i]}: give it. Using the SMALLEST cookie that works keeps bigger ones for greedier children."})
        i += 1
    else:
        steps.append({"array": [f"child {x}" for x in g], "pointers": {"child": i}, "highlight": list(range(i)), "vars": {"cookie": s[j], "cookies left": s[j + 1:]},
                      "caption": f"Cookie {s[j]} < greed {g[i]}: too small for this child, and for every greedier child too. Throw it away."})
    j += 1
steps.append({"array": [f"child {x}" for x in g], "pointers": {}, "highlight": list(range(i)), "vars": {"content": i},
              "caption": f"{i} children content. Exchange argument: giving a bigger cookie to an easy child can never help, so the greedy choice is safe."})
print(json.dumps({"title": "Greedy matching with two sorted lists", "view": "array", "steps": steps}))
