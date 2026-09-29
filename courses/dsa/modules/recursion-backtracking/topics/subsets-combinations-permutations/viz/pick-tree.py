import json

nums = [1, 2, 3]
nodes, found, steps = [], [], []
lab = lambda path: "{" + ",".join(map(str, path)) + "}"

def dfs(i, path, nid, parent):
    nodes.append({"id": nid, "label": lab(path), "parent": parent})
    if i == len(nums):
        found.append(nid)
        steps.append({"nodes": list(nodes), "active": nid, "highlight": list(found), "stack": [f"dfs({k})" for k in range(i + 1)],
                      "caption": f"All {len(nums)} numbers decided: record {lab(path)}."})
        return
    steps.append({"nodes": list(nodes), "active": nid, "highlight": list(found), "stack": [f"dfs({k})" for k in range(i + 1)],
                  "caption": f"At {lab(path)}: decide on {nums[i]}. Branch 1 picks it, branch 2 skips it."})
    path.append(nums[i])
    dfs(i + 1, path, nid + "L", nid)
    path.pop()                                   # un-choose
    dfs(i + 1, path, nid + "R", nid)

dfs(0, [], "r", None)
steps.append({"nodes": list(nodes), "active": None, "highlight": list(found), "stack": [],
              "caption": f"{len(found)} = 2³ leaves = all subsets. Each level is one element's pick / skip decision: O(n·2ⁿ) with copying."})
print(json.dumps({"title": "Subsets as a pick / not-pick decision tree", "view": "tree", "steps": steps}))
