import json, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[5]))
from vizlib import build, nodes, all_nodes, N

def insert(root, v, i):
    if root is None:
        return N(v, f"v{v}")
    if v < root.val:
        root.left = insert(root.left, v, i)
    else:
        root.right = insert(root.right, v, i)
    return root
def height(n):
    return 0 if not n else 1 + max(height(n.left), height(n.right))
steps = []
root = None
for i, v in enumerate([1, 2, 3, 4, 5]):
    root = insert(root, v, i)
    steps.append({"nodes": nodes(root), "highlight": [f"v{v}"], "vars": {"inserted": v, "height": height(root)},
                  "caption": f"Insert {v} in sorted order: it always goes right. Height {height(root)}." + (" This \"tree\" is really a linked list: search is O(n)." if v == 5 else "")})
root = None
for v in [3, 2, 4, 1, 5]:
    root = insert(root, v, 0)
steps.append({"nodes": nodes(root), "highlight": [], "vars": {"height": height(root)},
              "caption": f"The same 5 values inserted as 3, 2, 4, 1, 5: height {height(root)}. Balanced trees (AVL, red-black) rotate nodes to keep height O(log n) no matter the order."})
print(json.dumps({"title": "Why BSTs need balancing", "view": "tree", "steps": steps}))
