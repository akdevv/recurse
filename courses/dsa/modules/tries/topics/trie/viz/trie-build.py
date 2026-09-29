import json
words = ["app", "apple", "bat", "ball"]
nodes = [{"id": "root", "label": "·", "parent": None}]
children, ends = {"root": {}}, set()
steps = [{"nodes": list(nodes), "values": {}, "caption": "A trie stores words letter by letter. The root is empty; each edge down is one letter; words sharing a prefix share a path."}]
for w in words:
    cur, new = "root", []
    for i, ch in enumerate(w):
        if ch not in children[cur]:
            nid = f"{cur}/{ch}"
            children[cur][ch] = nid; children[nid] = {}
            nodes.append({"id": nid, "label": ch, "parent": cur}); new.append(ch)
        cur = children[cur][ch]
    ends.add(cur)
    shared = len(w) - len(new)
    steps.append({"nodes": list(nodes), "active": cur, "values": {e: "end" for e in ends},
                  "caption": f"Insert \"{w}\": " + (f"reuse the first {shared} letter(s) \"{w[:shared]}\", " if shared else "") + (f"create {''.join(new)}" if new else "no new nodes") + ". Mark the last node as a word end."})
steps.append({"nodes": list(nodes), "values": {e: "end" for e in ends},
              "caption": "\"app\" is a word AND a prefix of \"apple\": the end flag is what tells them apart. Insert/search cost O(word length), independent of how many words are stored."})
print(json.dumps({"title": "Building a trie", "view": "tree", "steps": steps}))
