import json

nodes, values, stack, steps = [], {}, [], []
calls = {"n": 0}


def fib(n, parent):
    nid = f"n{len(nodes)}"
    nodes.append({"id": nid, "label": f"fib({n})", "parent": parent})
    calls["n"] += 1
    stack.append(f"fib({n})")
    steps.append({"nodes": list(nodes), "active": nid, "values": dict(values), "stack": list(stack),
                  "vars": {"calls": calls["n"]},
                  "caption": f"Call fib({n})." + (" Base case." if n < 2 else f" Needs fib({n - 1}) and fib({n - 2}).")})
    r = n if n < 2 else fib(n - 1, nid) + fib(n - 2, nid)
    values[nid] = r
    stack.pop()
    steps.append({"nodes": list(nodes), "active": nid, "values": dict(values), "stack": list(stack),
                  "vars": {"calls": calls["n"]}, "caption": f"fib({n}) returns {r}."})
    return r


fib(4, None)
steps.append({"nodes": list(nodes), "active": None, "values": dict(values), "stack": [],
              "vars": {"calls": calls["n"]},
              "caption": f"{calls['n']} calls for fib(4). fib(2) was computed twice. fib(30) makes ~1.6 million calls: O(2ⁿ). Memoization fixes it."})
print(json.dumps({"title": "Recursion tree of naive fib(4)", "view": "tree", "steps": steps}))
