import json
a = [2, 1, 5, 3, 4, 6, 1, 2]
nodes, sums = [], {}
def build(lo, hi, parent):
    nid = f"{lo}-{hi}"
    nodes.append({"id": nid, "label": f"[{lo}..{hi}]", "parent": parent})
    if lo == hi:
        sums[nid] = a[lo]
    else:
        mid = (lo + hi) // 2
        build(lo, mid, nid); build(mid + 1, hi, nid)
        sums[nid] = sums[f"{lo}-{mid}"] + sums[f"{mid + 1}-{hi}"]
build(0, len(a) - 1, None)
steps = [{"nodes": nodes, "values": dict(sums), "caption": f"Segment tree over {a}: each node stores the sum of its range. Built in O(n)."}]
used, visited = [], []
def query(lo, hi, l, r):
    nid = f"{lo}-{hi}"
    if r < lo or hi < l:
        return 0
    visited.append(nid)
    if l <= lo and hi <= r:
        used.append(nid)
        steps.append({"nodes": nodes, "values": dict(sums), "highlight": list(used), "active": nid,
                      "caption": f"[{lo}..{hi}] lies fully inside the query [2..6]: take its stored sum {sums[nid]} without going deeper."})
        return sums[nid]
    mid = (lo + hi) // 2
    return query(lo, mid, l, r) + query(mid + 1, hi, l, r)
total = query(0, len(a) - 1, 2, 6)
steps.append({"nodes": nodes, "values": dict(sums), "highlight": used,
              "caption": f"sum(a[2..6]) = {' + '.join(str(sums[u]) for u in used)} = {total}, from {len(used)} nodes instead of 5 elements. Queries and point updates are O(log n)."})
print(json.dumps({"title": "Segment tree: range sums in O(log n)", "view": "tree", "steps": steps}))
