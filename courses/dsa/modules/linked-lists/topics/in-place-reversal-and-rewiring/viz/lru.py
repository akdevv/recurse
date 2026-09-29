import json
from collections import OrderedDict

cap = 2
cache = OrderedDict()
ops = [("put", 1, 1), ("put", 2, 2), ("get", 1), ("put", 3, 3), ("get", 2), ("get", 3)]
def state():
    return [f"{k}:{v}" for k, v in cache.items()]
steps = [{"nodes": [], "pointers": {}, "highlight": [], "vars": {"capacity": cap},
          "caption": "LRU cache: a hash map for O(1) lookup + a doubly linked list ordered by use (left = least recent, right = most recent)."}]
for op in ops:
    if op[0] == "put":
        _, k, v = op
        evicted = None
        if k not in cache and len(cache) == cap:
            evicted = cache.popitem(last=False)
        cache[k] = v
        cache.move_to_end(k)
        cap_txt = f" Full: evict the least recent ({evicted[0]})." if evicted else ""
        steps.append({"nodes": state(), "pointers": {}, "highlight": [len(cache) - 1], "vars": {"op": f"put({k}, {v})", "map keys": list(cache)},
                      "caption": f"put({k}, {v}): add at the most-recent end.{cap_txt}"})
    else:
        _, k = op
        hit = k in cache
        if hit:
            cache.move_to_end(k)
        steps.append({"nodes": state(), "pointers": {}, "highlight": [len(cache) - 1] if hit else [], "vars": {"op": f"get({k})", "returns": cache[k] if hit else -1},
                      "caption": f"get({k}): " + ("found via the map in O(1); move its node to the most-recent end." if hit else "not in the map: return −1.")})
steps.append({"nodes": state(), "pointers": {}, "highlight": [], "vars": {},
              "caption": "Both operations are O(1): the map finds the node, the doubly linked list unlinks and relinks it without scanning."})
print(json.dumps({"title": "LRU cache: hash map + recency list", "view": "list", "steps": steps}))
