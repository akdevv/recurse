import json
N = [{"id": "1", "x": 0, "y": 0}, {"id": "2", "x": 2, "y": 0}, {"id": "3", "x": 1, "y": 1.5}, {"id": "4", "x": 3, "y": 1.5}]
E = [("1", "2"), ("2", "4"), ("1", "3"), ("3", "4")]
parent = {n["id"]: n["id"] for n in N}
def find(x):
    while parent[x] != x:
        parent[x] = parent[parent[x]]; x = parent[x]
    return x
edges = [{"from": a, "to": b} for a, b in E]
added, steps = [], [{"nodes": N, "edges": edges, "values": {}, "caption": "Redundant Connection: a tree plus one extra edge. Add edges one at a time; the first edge whose ends are ALREADY connected closes a cycle."}]
for a, b in E:
    ra, rb = find(a), find(b)
    if ra == rb:
        steps.append({"nodes": N, "edges": edges, "highlight": [a, b], "edgeHighlight": added + [[a, b]], "values": {k: f"root {find(k)}" for k in parent},
                      "caption": f"Edge {a}–{b}: both already have root {ra}. They're connected, so this edge makes a cycle. Answer [{a}, {b}]."})
        break
    parent[ra] = rb
    added.append([a, b])
    steps.append({"nodes": N, "edges": edges, "edgeHighlight": added[:], "values": {k: f"root {find(k)}" for k in parent},
                  "caption": f"Edge {a}–{b}: different roots ({ra}, {rb}). union them."})
print(json.dumps({"title": "Detecting the edge that closes a cycle", "view": "graph", "steps": steps}))
