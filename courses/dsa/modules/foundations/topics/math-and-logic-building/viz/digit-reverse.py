import json

x0 = 1221
x, rev = x0, 0
steps = [{"array": [int(c) for c in str(x)], "pointers": {}, "highlight": [], "vars": {"x": x, "rev": rev},
          "caption": f"Is {x0} a palindrome? Reverse it with math and compare."}]
while x > 0:
    d = x % 10
    digits = [int(c) for c in str(x)]
    steps.append({"array": digits, "pointers": {"x % 10": len(digits) - 1}, "highlight": [len(digits) - 1],
                  "vars": {"x": x, "digit": d, "rev": rev},
                  "caption": f"Pop last digit: {x} % 10 = {d}."})
    rev = rev * 10 + d
    x //= 10
    steps.append({"array": [int(c) for c in str(x)] if x else [], "pointers": {}, "highlight": [],
                  "vars": {"x": x, "digit": d, "rev": rev},
                  "caption": f"Push onto rev: rev·10 + {d} = {rev}. Drop it from x: x // 10 = {x}."})
steps.append({"array": [int(c) for c in str(rev)], "pointers": {}, "highlight": list(range(len(str(rev)))),
              "vars": {"original": x0, "rev": rev},
              "caption": f"rev = {rev} {'==' if rev == x0 else '!='} {x0}, so it {'IS' if rev == x0 else 'is NOT'} a palindrome. 4 digits → 4 loop iterations: O(log n)."})
print(json.dumps({"title": "Digit loop: pop with % 10, push with × 10", "view": "array", "steps": steps}))
