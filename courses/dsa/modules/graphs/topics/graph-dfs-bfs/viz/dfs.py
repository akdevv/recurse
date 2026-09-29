import json
N = [{"id": "A", "x": 0, "y": 1}, {"id": "B", "x": 1.3, "y": 0}, {"id": "C", "x": 1.3, "y": 2}, {"id": "D", "x": 2.6, "y": 0}, {"id": "E", "x": 2.6, "y": 2}, {"id": "F", "x": 3.9, "y": 1}, {"id": "G", "x": 5.2, "y": 1}, {"id": "H", "x": 5.2, "y": 2.3}]
E = [("A", "B"), ("A", "C"), ("B", "D"), ("C", "D"), ("C", "E"), ("D", "F"), ("E", "F"), ("G", "H")]
adj = {n["id"]: [] for n in N}
for a, b in E:
    adj[a].append(b); adj[b].append(a)
edges = [{"from": a, "to": b} for a, b in E]
seen, order, steps, used = set(), [], [], []
comp = 0
steps.append({"nodes": N, "edges": edges, "values": {}, "stack": [], "caption": "DFS goes as deep as possible before backing up. Run it from every unvisited node to count connected components."})
def dfs(u, path):
    seen.add(u); order.append(u)
    steps.append({"nodes": N, "edges": edges, "active": u, "highlight": sorted(seen), "edgeHighlight": used[:], "values": {k: f"#{i + 1}" for i, k in enumerate(order)},
                  "caption": f"Visit {u} (component {comp}). Go to its first unvisited neighbour."})
    for v in adj[u]:
        if v not in seen:
            used.append([u, v])
            dfs(v, path + [v])
for s in adj:
    if s not in seen:
        comp += 1
        dfs(s, [s])
steps.append({"nodes": N, "edges": edges, "highlight": sorted(seen), "edgeHighlight": used, "values": {k: f"#{i + 1}" for i, k in enumerate(order)},
              "caption": f"All nodes visited. DFS had to be started {comp} times: {comp} connected components. O(V + E)."})
print(json.dumps({"title": "DFS and connected components", "view": "graph", "steps": steps}))
