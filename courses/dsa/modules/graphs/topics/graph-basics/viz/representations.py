import json
N = [{"id": "0", "x": 0, "y": 1}, {"id": "1", "x": 1.5, "y": 0}, {"id": "2", "x": 1.5, "y": 2}, {"id": "3", "x": 3, "y": 1}, {"id": "4", "x": 4.5, "y": 1}]
E = [("0", "1"), ("0", "2"), ("1", "2"), ("1", "3"), ("3", "4")]
edges = [{"from": a, "to": b} for a, b in E]
adj = {n["id"]: [] for n in N}
for a, b in E:
    adj[a].append(int(b)); adj[b].append(int(a))
steps = [
 {"nodes": N, "edges": edges, "vars": {"edges": [[int(a), int(b)] for a, b in E]},
  "caption": "A graph: nodes (vertices) joined by edges. Problems usually hand you an EDGE LIST like this, or an adjacency matrix."},
 {"nodes": N, "edges": edges, "vars": {"adjacency list": {k: v for k, v in adj.items()}},
  "caption": "First step of almost every graph problem: build an adjacency list, node → its neighbours. Undirected edges are added in both directions."},
 {"nodes": N, "edges": edges, "active": "1", "highlight": ["0", "2", "3"], "edgeHighlight": [["1", "0"], ["1", "2"], ["1", "3"]], "values": {"1": "deg 3"},
  "vars": {"adj[1]": adj["1"]}, "caption": "Neighbours of 1 are adj[1] = [0, 2, 3]: looking them up is O(degree). Degree of a node = its number of edges."},
 {"nodes": N, "edges": edges, "values": {k: f"deg {len(v)}" for k, v in adj.items()},
  "vars": {"V": 5, "E": 5, "sum of degrees": 2 * len(E)}, "caption": "Every edge adds 1 to two degrees, so degrees sum to 2E. Adjacency list: O(V + E) space; matrix: O(V²)."},
]
print(json.dumps({"title": "Graphs: edge list → adjacency list", "view": "graph", "steps": steps}))
