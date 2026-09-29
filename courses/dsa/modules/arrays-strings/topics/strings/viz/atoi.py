import json

s = "  -042abc"
chars = list(s.replace(" ", "␣"))
steps = [{"array": chars, "pointers": {"i": 0}, "highlight": [], "vars": {"sign": 1, "num": 0},
          "caption": "Parse a number the way atoi does: spaces, then an optional sign, then digits, then stop."}]
i, sign, num = 0, 1, 0
while i < len(s) and s[i] == " ":
    steps.append({"array": chars, "pointers": {"i": i}, "highlight": [i], "vars": {"sign": sign, "num": num},
                  "caption": "Phase 1: skip leading spaces."})
    i += 1
if i < len(s) and s[i] in "+-":
    sign = -1 if s[i] == "-" else 1
    steps.append({"array": chars, "pointers": {"i": i}, "highlight": [i], "vars": {"sign": sign, "num": num},
                  "caption": f"Phase 2: one sign character. '{s[i]}' → sign = {sign}."})
    i += 1
while i < len(s) and s[i].isdigit():
    d = ord(s[i]) - ord("0")
    num = num * 10 + d
    steps.append({"array": chars, "pointers": {"i": i}, "highlight": [i], "vars": {"sign": sign, "digit": d, "num": num},
                  "caption": f"Phase 3: digit {d}. num = num × 10 + {d} = {num}. Leading zeros cost nothing."})
    i += 1
steps.append({"array": chars, "pointers": {"i": i}, "highlight": [], "dim": list(range(i, len(s))), "vars": {"result": sign * num},
              "caption": f"'{s[i]}' isn't a digit: stop. Result = sign × num = {sign * num} (then clamp to 32 bits)."})
print(json.dumps({"title": "Parsing a string into an integer, one character at a time", "view": "array", "steps": steps}))
