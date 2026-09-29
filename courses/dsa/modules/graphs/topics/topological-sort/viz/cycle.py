import json
from collections import deque
N = [{"id": "0", "x": 0, "y": 1}, {"id": "1", "x": 1.5, "y": 1}, {"id": "2", "x": 3, "y": 0}, {"id": "3", "x": 3, "y": 2}]
E = [("0", "1"), ("1", "2"), ("2", "3"), ("3", "1")]
edges = [{"from": a, "to": b} for a, b in E]
indeg = {n["id"]: 0 for n in N}
adj = {n["id"]: [] for n in N}
for a, b in E:
    adj[a].append(b); indeg[b] += 1
q = deque(k for k, v in indeg.items() if v == 0)
order = []
steps = [{"nodes": N, "edges": edges, "directed": True, "values": {k: f"in {v}" for k, v in indeg.items()}, "caption": "Courses 1 → 2 → 3 → 1 form a cycle: each is a prerequisite of the next, all the way round."}]
while q:
    u = q.popleft(); order.append(u)
    for v in adj[u]:
        indeg[v] -= 1
        if indeg[v] == 0:
            q.append(v)
    steps.append({"nodes": N, "edges": edges, "directed": True, "highlight": order[:], "dim": order[:], "values": {k: f"in {v}" for k, v in indeg.items() if k not in order},
                  "caption": f"Take {u}. Course 1 drops to in-degree {indeg['1']}, but it still waits on 3."})
stuck = [k for k in indeg if k not in order]
steps.append({"nodes": N, "edges": edges, "directed": True, "highlight": stuck, "edgeHighlight": [["1", "2"], ["2", "3"], ["3", "1"]], "values": {k: f"in {indeg[k]}" for k in stuck},
              "caption": f"The queue is empty but {stuck} were never taken: they wait on each other. Processed {len(order)} of {len(N)} → cycle → impossible."})
print(json.dumps({"title": "A cycle means no valid order", "view": "graph", "steps": steps}))
