import json, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[5]))
from vizlib import build, nodes, all_nodes, N

root = build([1, 2, 3, 4, 5, None, 6])
pre, ino, post, steps = [], [], [], []
def snap(n, cap, stack):
    steps.append({"nodes": nodes(root), "active": n.id if n else None, "highlight": [], "stack": stack[:],
                  "vars": {"preorder": pre[:], "inorder": ino[:], "postorder": post[:]}, "caption": cap})
snap(None, "One DFS visits every node three times: on the way down (preorder), between the two children (inorder), on the way back up (postorder).", [])
def dfs(n, stack):
    if not n:
        return
    stack.append(f"dfs({n.val})")
    pre.append(n.val); snap(n, f"Arrive at {n.val}: record it for PREorder (node before children).", stack)
    dfs(n.left, stack)
    ino.append(n.val); snap(n, f"Back from {n.val}'s left subtree: record it for INorder (left, node, right).", stack)
    dfs(n.right, stack)
    post.append(n.val); snap(n, f"Both children done: record {n.val} for POSTorder (children before node).", stack)
    stack.pop()
dfs(root, [])
print(json.dumps({"title": "Pre-, in- and post-order are the same walk", "view": "tree", "steps": steps}))
