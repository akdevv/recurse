import json

arr = ["a", "b", "c", "d"]
n = len(arr)
steps, ops = [], 0
for i in range(n):
    for j in range(n):
        ops += 1
        steps.append({"array": arr, "pointers": {"i": i, "j": j}, "highlight": [i, j],
                      "vars": {"n": n, "ops": ops, "n × n": n * n},
                      "caption": f"Pair ({arr[i]}, {arr[j]}): operation #{ops}."})
steps.append({"array": arr, "pointers": {}, "highlight": [], "vars": {"n": n, "ops": ops},
              "caption": f"{ops} operations for n = {n}. Double n to 8 → 64 operations. That's O(n²)."})
print(json.dumps({"title": "Nested loops: every pair → n × n", "view": "array", "steps": steps}))
