import json
from collections import deque
N = [{"id": "math", "x": 0, "y": 0}, {"id": "cs1", "x": 0, "y": 2}, {"id": "algo", "x": 2, "y": 1}, {"id": "ml", "x": 4, "y": 0}, {"id": "os", "x": 4, "y": 2}]
E = [("math", "algo"), ("cs1", "algo"), ("algo", "ml"), ("cs1", "os"), ("math", "ml")]
edges = [{"from": a, "to": b} for a, b in E]
indeg = {n["id"]: 0 for n in N}
adj = {n["id"]: [] for n in N}
for a, b in E:
    adj[a].append(b); indeg[b] += 1
q = deque(k for k, v in indeg.items() if v == 0)
order = []
steps = [{"nodes": N, "edges": edges, "directed": True, "values": {k: f"in {v}" for k, v in indeg.items()}, "vars": {"queue": list(q), "order": []},
          "caption": "Kahn's algorithm. Arrow a → b means \"take a before b\". A course with in-degree 0 has no pending prerequisites: start with those."}]
while q:
    u = q.popleft(); order.append(u)
    freed = []
    for v in adj[u]:
        indeg[v] -= 1
        if indeg[v] == 0:
            q.append(v); freed.append(v)
    steps.append({"nodes": N, "edges": edges, "directed": True, "highlight": order[:], "active": u, "dim": order[:-1],
                  "values": {k: f"in {v}" for k, v in indeg.items() if k not in order}, "vars": {"queue": list(q), "order": order[:]},
                  "caption": f"Take {u}. Remove its arrows: lower its dependents' in-degrees." + (f" {freed} reach 0: queue them." if freed else "")})
steps.append({"nodes": N, "edges": edges, "directed": True, "highlight": order, "values": {k: f"#{i + 1}" for i, k in enumerate(order)}, "vars": {"order": order},
              "caption": "All 5 courses taken: a valid order. If some course never reached in-degree 0, there'd be a cycle. O(V + E)."})
print(json.dumps({"title": "Topological sort with in-degrees (Kahn)", "view": "graph", "steps": steps}))
