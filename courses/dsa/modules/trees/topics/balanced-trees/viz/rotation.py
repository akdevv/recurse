import json, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[5]))
from vizlib import build, nodes, all_nodes, N

def tree(spec):
    # spec: (val, left, right)
    if spec is None:
        return None
    v, l, r = spec
    n = N(v, f"v{v}")
    n.left, n.right = tree(l), tree(r)
    return n
before = tree((30, (20, (10, None, None), None), None))
after = tree((20, (10, None, None), (30, None, None)))
steps = [
  {"nodes": nodes(before), "active": "v30", "vars": {"balance(30)": "left 2, right 0"}, "caption": "AVL rule: at every node, the heights of the two subtrees differ by at most 1. Node 30 is off by 2 (left-left case)."},
  {"nodes": nodes(before), "highlight": ["v20"], "vars": {"fix": "right rotation at 30"}, "caption": "Right rotation: 20 moves up to take 30's place, 30 becomes 20's right child. (20's old right subtree, if any, becomes 30's left.)"},
  {"nodes": nodes(after), "highlight": ["v20"], "vars": {"height": "3 → 2"}, "caption": "Balanced again, and it's still a valid BST: 10 < 20 < 30. A rotation is O(1): only three pointers change."},
]
print(json.dumps({"title": "An AVL rotation", "view": "tree", "steps": steps}))
