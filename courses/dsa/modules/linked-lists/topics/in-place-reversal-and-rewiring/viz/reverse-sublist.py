import json

vals = ["dummy", 1, 2, 3, 4, 5]
order = [0, 1, 2, 3, 4, 5]          # current list order, as node indexes
left, right = 2, 4                  # 1-based positions of the values to reverse (2..4)
def links_of(order):
    l = [None] * len(vals)
    for a, b in zip(order, order[1:]):
        l[a] = b
    return l
steps = [{"nodes": vals, "links": links_of(order), "pointers": {"prev": 1}, "highlight": [2, 3, 4], "vars": {"left": left, "right": right},
          "caption": "Reverse positions 2..4. Walk prev to the node just before the sublist (value 1). The sublist's first node (2) will end up last."}]
prev_pos = 1
start = order[prev_pos + 1]
for _ in range(right - left):
    i = order.index(start)
    moved = order.pop(i + 1)
    order.insert(prev_pos + 1, moved)
    steps.append({"nodes": [vals[k] for k in order], "links": links_of(list(range(len(order)))), "pointers": {"prev": prev_pos, "start": order.index(start)},
                  "highlight": [prev_pos + 1], "vars": {"moved to front": vals[moved]},
                  "caption": f"Take the node after `start` ({vals[moved]}) and move it right after prev. The sublist's front is now {vals[moved]}."})
steps.append({"nodes": [vals[k] for k in order], "links": links_of(list(range(len(order)))), "pointers": {}, "highlight": [2, 3, 4], "vars": {},
              "caption": "right − left moves, each O(1): the sublist is reversed and still connected on both ends. One pass, O(1) space."})
print(json.dumps({"title": "Reversing a sublist by moving nodes to its front", "view": "list", "steps": steps}))
