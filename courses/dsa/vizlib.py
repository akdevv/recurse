"""Shared helpers for viz scripts (import with sys.path.insert(0, <courses/dsa>)).

Trees: build(level_order) -> root; nodes(root) -> the tree view's node list, with hidden
placeholders so a lone right child is drawn on the right."""


class N:
    def __init__(self, val, id):
        self.val, self.id, self.left, self.right = val, id, None, None


def build(level):
    """LeetCode level-order list (None = missing) -> root N. Node ids are 'n<index>'."""
    if not level or level[0] is None:
        return None
    root = N(level[0], "n0")
    q, i = [root], 1
    while q and i < len(level):
        cur = q.pop(0)
        for side in ("left", "right"):
            if i < len(level) and level[i] is not None:
                child = N(level[i], f"n{i}")
                setattr(cur, side, child)
                q.append(child)
            i += 1
    return root


def nodes(root, label=lambda n: str(n.val)):
    out = []

    def walk(n, parent):
        out.append({"id": n.id, "label": label(n), "parent": parent})
        if n.left or n.right:
            for side in ("left", "right"):
                c = getattr(n, side)
                if c:
                    walk(c, n.id)
                else:
                    out.append({"id": f"{n.id}-{side}", "label": "", "parent": n.id, "hidden": True})

    if root:
        walk(root, None)
    return out


def all_nodes(root):
    out, q = [], [root] if root else []
    while q:
        n = q.pop(0)
        out.append(n)
        q += [c for c in (n.left, n.right) if c]
    return out
