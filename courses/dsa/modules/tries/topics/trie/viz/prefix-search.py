import json
words = ["app", "apple", "bat", "ball"]
nodes = [{"id": "root", "label": "·", "parent": None}]
children, ends = {"root": {}}, set()
for w in words:
    cur = "root"
    for ch in w:
        if ch not in children[cur]:
            nid = f"{cur}/{ch}"; children[cur][ch] = nid; children[nid] = {}
            nodes.append({"id": nid, "label": ch, "parent": cur})
        cur = children[cur][ch]
    ends.add(cur)
ev = {e: "end" for e in ends}
steps = []
for q, kind in [("ba", "startsWith"), ("ba", "search"), ("apx", "search")]:
    cur, path = "root", []
    ok = True
    for ch in q:
        if ch not in children[cur]:
            ok = False
            steps.append({"nodes": nodes, "values": ev, "highlight": path[:], "active": cur,
                          "caption": f"{kind}(\"{q}\"): no child '{ch}' under this node. Stop: False."})
            break
        cur = children[cur][ch]; path.append(cur)
        steps.append({"nodes": nodes, "values": ev, "highlight": path[:], "active": cur, "caption": f"{kind}(\"{q}\"): follow '{ch}'."})
    if ok:
        res = True if kind == "startsWith" else cur in ends
        steps.append({"nodes": nodes, "values": ev, "highlight": path[:], "active": cur,
                      "caption": f"{kind}(\"{q}\"): walked all letters. " + ("For startsWith that's enough: True." if kind == "startsWith" else f"search also needs the end flag here: {res}.")})
print(json.dumps({"title": "search vs startsWith", "view": "tree", "steps": steps}))
