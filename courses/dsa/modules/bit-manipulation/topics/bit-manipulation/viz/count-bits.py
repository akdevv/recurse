import json
n = 44
bits = lambda x: list(format(x, "08b"))
steps = [{"array": bits(n), "pointers": {}, "highlight": [i for i, b in enumerate(bits(n)) if b == "1"], "vars": {"n": n, "binary": format(n, "b")},
          "caption": f"{n} in binary is {format(n, 'b')}. Count the 1-bits. Trick: n & (n − 1) clears the LOWEST 1-bit."}]
count = 0
while n:
    m = n - 1
    steps.append({"array": bits(m), "pointers": {}, "highlight": [i for i, b in enumerate(bits(m)) if b == "1"], "vars": {"n": format(n, "08b"), "n − 1": format(m, "08b")},
                  "caption": f"n − 1 flips the lowest 1-bit to 0 and every 0 below it to 1."})
    n &= m
    count += 1
    steps.append({"array": bits(n), "pointers": {}, "highlight": [i for i, b in enumerate(bits(n)) if b == "1"], "vars": {"n & (n − 1)": format(n, "08b"), "count": count},
                  "caption": f"AND them: the lowest 1-bit is gone, everything above it is unchanged. count = {count}."})
steps.append({"array": bits(0), "pointers": {}, "highlight": [], "vars": {"answer": count},
              "caption": f"n is 0 after {count} steps: exactly one loop per set bit. n & (n − 1) == 0 also tests \"is n a power of two?\"."})
print(json.dumps({"title": "n & (n − 1): drop the lowest set bit", "view": "array", "steps": steps}))
