## Core idea

**Breadth-first search visits the tree level by level using a queue.** The trick for level-based questions: at the start of each round, the queue length is exactly the number of nodes on the current level, so process that many and you've processed one level.

## Intuition

Ripples in a pond: everything one step away first, then everything two steps away. DFS dives down one branch to the bottom before trying another; BFS sweeps across.

That's why BFS answers "per level" questions (averages, right view, zigzag) and "nearest" questions (minimum depth: the first leaf BFS reaches is the closest one, so you can stop right there).

## Visualization

Level order: take `len(queue)` nodes per round:

```viz
level-order
```

Right side view: the last node of each level:

```viz
right-view
```

## Template code

```python
from collections import deque

def level_order(root):
    if not root:
        return []
    res, q = [], deque([root])
    while q:
        level = []
        for _ in range(len(q)):          # exactly one level
            n = q.popleft()
            level.append(n.val)
            if n.left:  q.append(n.left)
            if n.right: q.append(n.right)
        res.append(level)
    return res

# Variations on the per-level loop
right_view.append(level[-1])                 # last node of each level
averages.append(sum(level) / len(level))     # average per level
if depth % 2: level.reverse()                # zigzag

# Minimum depth: return at the first leaf
depth = 0
while q:
    depth += 1
    for _ in range(len(q)):
        n = q.popleft()
        if not n.left and not n.right:
            return depth
        ...
```

## Complexity

| | BFS | DFS |
|---|---|---|
| time | O(n) | O(n) |
| extra space | O(w), w = widest level (up to n/2) | O(h), h = height |
| finds the shallowest target first | **yes** | no |

## When to use it

- **"Level order", "per level", "zigzag", "average of levels"** → BFS with the level-size loop
- **"Right/left side view"** → last/first node per level (or DFS right-first)
- **"Minimum depth", "nearest"** → BFS stops at the first hit
- **Connect nodes on the same level** → BFS
- **Anything about a single root-to-leaf path** → DFS is usually simpler

## Common traps

- Not snapshotting `len(q)` before the loop: the queue grows while you process the level
- `list.pop(0)` instead of `deque.popleft()`: O(n) per pop
- Right side view taken as "always go right": a left subtree can be visible when the right side is shorter
- Minimum depth with DFS: `min(left, right)` is wrong when one child is missing (that side isn't a leaf path)
- Forgetting the empty tree
