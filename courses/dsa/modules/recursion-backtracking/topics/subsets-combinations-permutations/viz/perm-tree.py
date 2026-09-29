import json

nums = [1, 2, 3]
nodes, found, steps = [], [], []
lab = lambda p: "[" + ",".join(map(str, p)) + "]"
used = [False] * len(nums)

def dfs(path, nid, parent):
    nodes.append({"id": nid, "label": lab(path), "parent": parent})
    if len(path) == len(nums):
        found.append(nid)
        steps.append({"nodes": list(nodes), "active": nid, "highlight": list(found), "caption": f"Length {len(nums)}: record {lab(path)}."})
        return
    free = [x for x, u in zip(nums, used) if not u]
    steps.append({"nodes": list(nodes), "active": nid, "highlight": list(found),
                  "caption": f"At {lab(path)}: unused {free}. Try each one next, then undo it."})
    for j, x in enumerate(nums):
        if not used[j]:
            used[j] = True
            path.append(x)
            dfs(path, f"{nid}{x}", nid)
            path.pop()
            used[j] = False

dfs([], "r", None)
steps.append({"nodes": list(nodes), "active": None, "highlight": list(found),
              "caption": f"3 choices, then 2, then 1: 3! = {len(found)} permutations. O(n·n!)."})
print(json.dumps({"title": "Permutations: at each level choose any unused element", "view": "tree", "steps": steps}))
