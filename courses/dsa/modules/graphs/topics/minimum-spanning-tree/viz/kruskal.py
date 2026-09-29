import json
N = [{"id": "A", "x": 0, "y": 0}, {"id": "B", "x": 2, "y": 0}, {"id": "C", "x": 0, "y": 2}, {"id": "D", "x": 2, "y": 2}, {"id": "E", "x": 4, "y": 1}]
E = [("A", "B", 4), ("A", "C", 1), ("B", "D", 2), ("C", "D", 3), ("B", "E", 6), ("D", "E", 5), ("A", "D", 7)]
edges = [{"from": a, "to": b, "w": w} for a, b, w in E]
parent = {n["id"]: n["id"] for n in N}
def find(x):
    while parent[x] != x:
        x = parent[x]
    return x
tree, total = [], 0
steps = [{"nodes": N, "edges": edges, "vars": {"total": 0}, "caption": "Kruskal's MST: take edges from cheapest to most expensive; keep an edge unless it would close a cycle (union-find checks that)."}]
for a, b, w in sorted(E, key=lambda e: e[2]):
    ra, rb = find(a), find(b)
    if ra == rb:
        steps.append({"nodes": N, "edges": edges, "edgeHighlight": tree[:], "highlight": [a, b], "vars": {"total": total},
                      "caption": f"{a}–{b} ({w}): {a} and {b} are already connected. Skip it, it would make a cycle."})
        continue
    parent[ra] = rb; tree.append([a, b]); total += w
    steps.append({"nodes": N, "edges": edges, "edgeHighlight": tree[:], "vars": {"total": total},
                  "caption": f"{a}–{b} ({w}): connects two separate groups. Keep it." + (" That's V − 1 = 4 edges: done." if len(tree) == 4 else "")})
    if len(tree) == 4:
        break
print(json.dumps({"title": "Kruskal: cheapest edges first, skip cycles", "view": "graph", "steps": steps}))
