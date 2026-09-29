import json

a = [4, 1, 3, 1, 0, 4, 2]
counts = [0] * 5
steps = [{"array": counts[:], "pointers": {}, "highlight": [], "vars": {"input": a},
          "caption": "Counting sort: values are small (0..4), so count how many of each value there are. The array shown is counts[value]."}]
for x in a:
    counts[x] += 1
    steps.append({"array": counts[:], "pointers": {"value": x}, "highlight": [x], "vars": {"read": x},
                  "caption": f"Read {x}: counts[{x}] += 1."})
out = [v for v in range(5) for _ in range(counts[v])]
steps.append({"array": out, "pointers": {}, "highlight": list(range(len(out))), "vars": {"counts": counts},
              "caption": "Write each value as many times as it was counted, in order. O(n + range), no comparisons at all."})
print(json.dumps({"title": "Counting sort: count, then write back", "view": "array", "steps": steps}))
