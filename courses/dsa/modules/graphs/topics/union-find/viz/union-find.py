import json
ids = ["0", "1", "2", "3", "4", "5"]
pos = {"0": (0, 0), "1": (1.2, 0), "2": (2.4, 0), "3": (3.6, 0), "4": (4.8, 0), "5": (6, 0)}
parent = {k: k for k in ids}
def layout():
    depth = {}
    def d(x):
        return 0 if parent[x] == x else 1 + d(parent[x])
    cols = {}
    out = []
    for k in ids:
        out.append({"id": k, "x": pos[k][0], "y": d(k) * 1.3})
    return out
def edges():
    return [{"from": k, "to": parent[k]} for k in ids if parent[k] != k]
def find(x, path):
    path.append(x)
    if parent[x] != x:
        parent[x] = find(parent[x], path)
    return parent[x]
steps = [{"nodes": layout(), "edges": [], "directed": True, "values": {}, "caption": "Union-find: every node points to a parent; a node pointing to itself is a root. Two nodes are connected iff they have the same root."}]
for a, b in [("0", "1"), ("2", "3"), ("1", "3"), ("4", "5")]:
    ra, rb = find(a, []), find(b, [])
    parent[ra] = rb
    steps.append({"nodes": layout(), "edges": edges(), "directed": True, "highlight": [rb], "edgeHighlight": [[ra, rb]],
                  "caption": f"union({a}, {b}): root of {a} is {ra}, root of {b} is {rb}. Point {ra} at {rb}; the two groups merge in O(1) after the finds."})
# show a long chain then compress
path = []
root = find("0", path)
steps.append({"nodes": layout(), "edges": edges(), "directed": True, "highlight": [root], "active": "0",
              "caption": f"find(0) walked {' → '.join(path)}. Path compression: every node on that walk now points straight at the root {root}, so the next find is one step."})
steps.append({"nodes": layout(), "edges": edges(), "directed": True, "values": {k: f"root {find(k, [])}" for k in ids},
              "caption": "Two components: {0, 1, 2, 3} and {4, 5}. With path compression and union by rank, each operation is almost O(1) (inverse Ackermann)."})
print(json.dumps({"title": "Union-find: roots, unions and path compression", "view": "graph", "steps": steps}))
