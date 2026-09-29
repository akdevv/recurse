import json
from collections import deque
N = [{"id": "A", "x": 0, "y": 1}, {"id": "B", "x": 1.3, "y": 0}, {"id": "C", "x": 1.3, "y": 2}, {"id": "D", "x": 2.6, "y": 0}, {"id": "E", "x": 2.6, "y": 2}, {"id": "F", "x": 3.9, "y": 1}]
E = [("A", "B"), ("A", "C"), ("B", "D"), ("C", "D"), ("C", "E"), ("D", "F"), ("E", "F")]
adj = {n["id"]: [] for n in N}
for a, b in E:
    adj[a].append(b); adj[b].append(a)
edges = [{"from": a, "to": b} for a, b in E]
dist, q, used = {"A": 0}, deque(["A"]), []
steps = [{"nodes": N, "edges": edges, "active": "A", "values": {"A": "0"}, "vars": {"queue": ["A"]},
          "caption": "BFS from A. Mark a node visited when it's ADDED to the queue. Nodes come out in order of distance."}]
while q:
    u = q.popleft()
    added = []
    for v in adj[u]:
        if v not in dist:
            dist[v] = dist[u] + 1; q.append(v); added.append(v); used.append([u, v])
    steps.append({"nodes": N, "edges": edges, "active": u, "highlight": list(dist), "edgeHighlight": used[:], "values": {k: str(d) for k, d in dist.items()},
                  "vars": {"queue": list(q)}, "caption": f"Pop {u} (distance {dist[u]})." + (f" Discover {added}: distance {dist[u] + 1}." if added else " No new neighbours.")})
steps.append({"nodes": N, "edges": edges, "highlight": list(dist), "edgeHighlight": used, "values": {k: str(d) for k, d in dist.items()},
              "caption": "The highlighted edges form a BFS tree; each number is the fewest edges from A. O(V + E)."})
print(json.dumps({"title": "BFS: shortest paths by number of edges", "view": "graph", "steps": steps}))
