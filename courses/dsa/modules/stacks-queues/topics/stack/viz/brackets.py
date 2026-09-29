import json

s = "{[()]}("
pairs = {")": "(", "]": "[", "}": "{"}
st = []
steps = [{"array": list(s), "pointers": {}, "highlight": [], "stack": [], "vars": {},
          "caption": "Valid parentheses. Openers wait on a stack; a closer must match the most recent opener still waiting."}]
ok = True
for i, c in enumerate(s):
    if c in "([{":
        st.append(c)
        cap = f"'{c}' opens: push it."
    elif st and st[-1] == pairs[c]:
        st.pop()
        cap = f"'{c}' matches the top '{pairs[c]}': pop."
    else:
        ok = False
        cap = f"'{c}' doesn't match the top: invalid."
    steps.append({"array": list(s), "pointers": {"i": i}, "highlight": [i], "stack": list(st), "vars": {}, "caption": cap})
    if not ok:
        break
if ok:
    steps.append({"array": list(s), "pointers": {}, "highlight": [], "stack": list(st), "vars": {"valid": not st},
                  "caption": f"End of string with {len(st)} opener(s) still waiting: " + ("valid." if not st else "invalid. The stack must end empty.")})
print(json.dumps({"title": "Matching brackets with a stack", "view": "array", "steps": steps}))
