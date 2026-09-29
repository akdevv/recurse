import json
N = [{"id": "0", "x": 0, "y": 1}, {"id": "1", "x": 1.6, "y": 0}, {"id": "2", "x": 1.6, "y": 2}, {"id": "3", "x": 3.2, "y": 1}]
F = [("0", "1", 100), ("1", "2", 100), ("2", "0", 100), ("1", "3", 600), ("2", "3", 200)]
edges = [{"from": a, "to": b, "w": w} for a, b, w in F]
INF = float("inf")
dist = {"0": 0, "1": INF, "2": INF, "3": INF}
show = lambda: {k: "∞" if v == INF else str(v) for k, v in dist.items()}
k = 1
steps = [{"nodes": N, "edges": edges, "directed": True, "values": show(), "vars": {"k stops": k, "rounds": k + 1},
          "caption": f"Cheapest flight 0 → 3 with at most {k} stop = at most {k + 1} flights. Bellman-Ford: each round lets every path use one more flight."}]
for rnd in range(1, k + 2):
    prev = dict(dist)
    used = []
    for a, b, w in F:
        if prev[a] + w < dist[b]:
            dist[b] = prev[a] + w; used.append([a, b])
    steps.append({"nodes": N, "edges": edges, "directed": True, "edgeHighlight": used, "values": show(), "vars": {"round": rnd},
                  "caption": f"Round {rnd}: relax every flight using LAST round's prices (a copy), so no path gains two flights in one round." + (" 0 → 1 → 3 = 700 fits in 2 flights; 0 → 1 → 2 → 3 = 400 would need 3." if rnd == 2 else "")})
steps.append({"nodes": N, "edges": edges, "directed": True, "highlight": ["3"], "values": show(), "caption": f"Answer {dist['3']}. Plain Dijkstra would find 400, which breaks the stop limit. O(k · E)."})
print(json.dumps({"title": "Shortest path with at most k stops", "view": "graph", "steps": steps}))
