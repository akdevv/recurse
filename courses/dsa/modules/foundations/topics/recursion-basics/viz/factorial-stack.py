import json

steps, stack = [], []


def fact(n):
    stack.append(f"factorial({n})")
    steps.append({"stack": list(stack), "vars": {"n": n},
                  "caption": f"Call factorial({n}), pushed on the stack." + (" Base case!" if n <= 1 else f" It needs factorial({n - 1}) first, so it waits.")})
    r = 1 if n <= 1 else n * fact(n - 1)
    stack[-1] = f"factorial({n}) = {r}"
    steps.append({"stack": list(stack), "vars": {"n": n, "returns": r},
                  "caption": f"factorial({n}) returns {r}" + (f" (= {n} × {r // n})" if n > 1 else "") + ", popped off the stack."})
    stack.pop()
    return r


fact(4)
steps.append({"stack": [], "vars": {"result": 24}, "caption": "Stack empty. Max depth was 4 frames, so space is O(n)."})
print(json.dumps({"title": "Call stack of factorial(4)", "view": "stack", "steps": steps}))
