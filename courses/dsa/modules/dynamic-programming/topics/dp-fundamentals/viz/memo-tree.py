import json
n = 5
nodes, memo, steps = [], {}, []
counter = [0]
def ways(k, parent):
    nid = f"n{counter[0]}"; counter[0] += 1
    nodes.append({"id": nid, "label": f"ways({k})", "parent": parent})
    if k in memo:
        steps.append({"nodes": list(nodes), "active": nid, "values": {x["id"]: memo[int(x["label"][5:-1])] for x in nodes if int(x["label"][5:-1]) in memo and x["id"] != nid},
                      "highlight": [nid], "caption": f"ways({k}) was already computed: return memo[{k}] = {memo[k]} immediately. No subtree below it."})
        return memo[k]
    if k <= 1:
        memo[k] = 1
    else:
        steps.append({"nodes": list(nodes), "active": nid, "values": {x["id"]: memo[int(x["label"][5:-1])] for x in nodes if int(x["label"][5:-1]) in memo},
                      "caption": f"ways({k}) = ways({k - 1}) + ways({k - 2}): last step was 1 stair or 2 stairs."})
        memo[k] = ways(k - 1, nid) + ways(k - 2, nid)
    steps.append({"nodes": list(nodes), "active": nid, "values": {x["id"]: memo[int(x["label"][5:-1])] for x in nodes if int(x["label"][5:-1]) in memo},
                  "caption": f"ways({k}) = {memo[k]}. Store it in memo." if k > 1 else f"Base case: ways({k}) = 1."})
    return memo[k]
ways(n, None)
steps.append({"nodes": list(nodes), "values": {x["id"]: memo[int(x["label"][5:-1])] for x in nodes},
              "caption": f"With the memo, each ways(k) is computed once: O(n) calls instead of O(2ⁿ). That's dynamic programming: recursion + remembering answers."})
print(json.dumps({"title": "Memoization: solve each subproblem once", "view": "tree", "steps": steps}))
