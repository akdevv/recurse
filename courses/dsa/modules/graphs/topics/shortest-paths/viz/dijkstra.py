import json, heapq
N = [{"id": "A", "x": 0, "y": 1}, {"id": "B", "x": 1.6, "y": 0}, {"id": "C", "x": 1.6, "y": 2}, {"id": "D", "x": 3.2, "y": 0}, {"id": "E", "x": 3.2, "y": 2}]
E = [("A", "B", 4), ("A", "C", 1), ("C", "B", 2), ("B", "D", 1), ("C", "E", 5), ("D", "E", 1)]
adj = {n["id"]: [] for n in N}
for a, b, w in E:
    adj[a].append((b, w)); adj[b].append((a, w))
edges = [{"from": a, "to": b, "w": w} for a, b, w in E]
dist = {"A": 0}
h, done, prev = [(0, "A")], [], {}
show = lambda: {k: str(dist[k]) if k in dist else "∞" for k in adj}
steps = [{"nodes": N, "edges": edges, "values": show(), "vars": {"heap": [[0, "A"]]}, "caption": "Dijkstra from A: always settle the unsettled node with the smallest known distance (a min-heap gives it)."}]
while h:
    d, u = heapq.heappop(h)
    if u in done:
        continue
    done.append(u)
    upd = []
    for v, w in adj[u]:
        if v not in done and d + w < dist.get(v, 1e9):
            dist[v] = d + w; prev[v] = u; heapq.heappush(h, (d + w, v)); upd.append(f"{v}: {d + w}")
    steps.append({"nodes": N, "edges": edges, "active": u, "highlight": done[:], "edgeHighlight": [[prev[k], k] for k in prev], "values": show(),
                  "vars": {"heap": sorted([list(x) for x in h])}, "caption": f"Settle {u} at distance {d}: nothing can reach it cheaper later (weights are ≥ 0)." + (f" Relax neighbours → {', '.join(upd)}." if upd else "")})
steps.append({"nodes": N, "edges": edges, "highlight": done, "edgeHighlight": [[prev[k], k] for k in prev], "values": show(),
              "caption": "Note B: the direct edge costs 4, but A → C → B costs 3. O((V + E) log V) with a heap."})
print(json.dumps({"title": "Dijkstra: settle the closest node first", "view": "graph", "steps": steps}))
