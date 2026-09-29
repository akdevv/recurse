import json
N = [{"id": "1", "x": 0, "y": 0}, {"id": "2", "x": 2, "y": 0}, {"id": "3", "x": 1, "y": 1.5}, {"id": "4", "x": 3, "y": 1.5}]
T = [("1", "3"), ("2", "3"), ("4", "3"), ("1", "4"), ("2", "4")]
edges = [{"from": a, "to": b} for a, b in T]
score = {n["id"]: 0 for n in N}
steps = [{"nodes": N, "edges": edges, "directed": True, "values": {}, "caption": "Find the Town Judge. A trust relation a → b is a DIRECTED edge. The judge is trusted by everyone else (in-degree n − 1) and trusts nobody (out-degree 0)."}]
for a, b in T:
    score[a] -= 1; score[b] += 1
    steps.append({"nodes": N, "edges": edges, "directed": True, "edgeHighlight": [[a, b]], "values": {k: f"{v:+d}" for k, v in score.items()},
                  "caption": f"{a} trusts {b}: score[{a}] −= 1 (it trusts someone), score[{b}] += 1 (someone trusts it)."})
j = [k for k, v in score.items() if v == len(N) - 1]
steps.append({"nodes": N, "edges": edges, "directed": True, "highlight": j, "values": {k: f"{v:+d}" for k, v in score.items()},
              "caption": f"Only node {j[0]} scores n − 1 = {len(N) - 1}: trusted by all 3 others, trusts no one. It's the judge. O(n + t)."})
print(json.dumps({"title": "In-degree and out-degree", "view": "graph", "steps": steps}))
