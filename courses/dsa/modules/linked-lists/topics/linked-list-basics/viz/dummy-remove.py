import json

vals = ["dummy", 6, 1, 6, 2]
links = [1, 2, 3, 4, None]
val = 6
steps = [{"nodes": vals, "links": list(links), "pointers": {"pre": 0}, "highlight": [], "vars": {"remove": val},
          "caption": f"Remove every {val}. A dummy node before the head means even the head is removed the same way as any other node."}]
pre = 0
while links[pre] is not None:
    nx = links[pre]
    if vals[nx] == val:
        links[pre] = links[nx]
        steps.append({"nodes": vals, "links": list(links), "pointers": {"pre": pre}, "highlight": [], "dim": [nx], "vars": {"remove": val},
                      "caption": f"pre.next is {val}: skip it with pre.next = pre.next.next. Don't move pre; the new next might also be {val}."})
    else:
        pre = nx
        steps.append({"nodes": vals, "links": list(links), "pointers": {"pre": pre}, "highlight": [pre], "vars": {"remove": val},
                      "caption": f"pre.next is {vals[nx]}: keep it, move pre forward."})
steps.append({"nodes": vals, "links": list(links), "pointers": {"head": links[0]}, "highlight": [], "vars": {},
              "caption": "Return dummy.next as the new head. No special case for removing the first node."})
print(json.dumps({"title": "Deleting with a dummy node", "view": "list", "steps": steps}))
