import json

vals = [1, 2, 3, 4]
links = [1, 2, 3, None]
prev, cur = None, 0
P = lambda **kw: {k: v for k, v in kw.items() if v is not None}
steps = [{"nodes": vals, "links": list(links), "pointers": P(head=0, cur=cur), "highlight": [], "vars": {"prev": "None"},
          "caption": "Reverse a linked list by turning every arrow around. prev starts as None, cur at the head."}]
while cur is not None:
    nxt = links[cur]
    steps.append({"nodes": vals, "links": list(links), "pointers": P(prev=prev, cur=cur, nxt=nxt), "highlight": [], "vars": {"prev": vals[prev] if prev is not None else "None"},
                  "caption": f"Save nxt = cur.next ({vals[nxt] if nxt is not None else 'None'}) first, or the rest of the list is lost."})
    links[cur] = prev
    steps.append({"nodes": vals, "links": list(links), "pointers": P(prev=prev, cur=cur, nxt=nxt), "highlight": [cur], "vars": {"prev": vals[prev] if prev is not None else "None"},
                  "caption": f"cur.next = prev: {vals[cur]} now points {'back to ' + str(vals[prev]) if prev is not None else 'to None'}."})
    prev, cur = cur, nxt
steps.append({"nodes": vals, "links": list(links), "pointers": P(head=prev), "highlight": list(range(len(vals))), "vars": {},
              "caption": f"cur is None. prev ({vals[prev]}) is the new head. One pass, O(n) time, O(1) space."})
print(json.dumps({"title": "Reversing a linked list: prev, cur, next", "view": "list", "steps": steps}))
