import json

tokens = ["4", "13", "5", "/", "+", "2", "*"]
st = []
steps = [{"array": tokens, "pointers": {}, "highlight": [], "stack": [], "vars": {},
          "caption": "Reverse Polish notation: numbers wait on a stack; an operator takes the two most recent."}]
for i, t in enumerate(tokens):
    if t in "+-*/":
        b, a = st.pop(), st.pop()
        r = {"+": a + b, "-": a - b, "*": a * b, "/": int(a / b)}[t]
        st.append(r)
        cap = f"'{t}': pop {b}, then {a}. Push {a} {t} {b} = {r}." + (" Division truncates toward zero." if t == "/" else "")
    else:
        st.append(int(t))
        cap = f"Push {t}."
    steps.append({"array": tokens, "pointers": {"i": i}, "highlight": [i], "stack": [str(x) for x in st], "vars": {}, "caption": cap})
steps.append({"array": tokens, "pointers": {}, "highlight": [], "stack": [str(x) for x in st], "vars": {"result": st[-1]},
              "caption": f"One value left: {st[-1]}. Each token is pushed or popped a constant number of times: O(n)."})
print(json.dumps({"title": "Evaluating reverse Polish notation", "view": "array", "steps": steps}))
