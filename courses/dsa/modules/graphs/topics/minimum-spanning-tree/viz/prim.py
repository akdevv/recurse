import json, heapq
N = [{"id": "A", "x": 0, "y": 0}, {"id": "B", "x": 2, "y": 0}, {"id": "C", "x": 0, "y": 2}, {"id": "D", "x": 2, "y": 2}, {"id": "E", "x": 4, "y": 1}]
E = [("A", "B", 4), ("A", "C", 1), ("B", "D", 2), ("C", "D", 3), ("B", "E", 6), ("D", "E", 5), ("A", "D", 7)]
adj = {n["id"]: [] for n in N}
for a, b, w in E:
    adj[a].append((w, b)); adj[b].append((w, a))
edges = [{"from": a, "to": b, "w": w} for a, b, w in E]
inside, tree, total = {"A"}, [], 0
h = [(w, "A", v) for w, v in adj["A"]]
heapq.heapify(h)
steps = [{"nodes": N, "edges": edges, "highlight": ["A"], "vars": {"total": 0}, "caption": "Prim's MST: grow one tree from A. Repeatedly add the cheapest edge that leaves the tree."}]
while h and len(inside) < len(N):
    w, u, v = heapq.heappop(h)
    if v in inside:
        continue
    inside.add(v); tree.append([u, v]); total += w
    for w2, x in adj[v]:
        if x not in inside:
            heapq.heappush(h, (w2, v, x))
    steps.append({"nodes": N, "edges": edges, "highlight": sorted(inside), "edgeHighlight": tree[:], "active": v, "vars": {"total": total},
                  "caption": f"Cheapest edge leaving the tree: {u}–{v} ({w}). Add {v}; its edges become candidates."})
steps.append({"nodes": N, "edges": edges, "highlight": sorted(inside), "edgeHighlight": tree, "vars": {"total": total},
              "caption": f"Same total ({total}) as Kruskal. With a heap O(E log V); on dense graphs an O(V²) array version is better (Min Cost to Connect All Points)."})
print(json.dumps({"title": "Prim: grow the tree by the cheapest leaving edge", "view": "graph", "steps": steps}))
