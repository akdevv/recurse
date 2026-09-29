import json

vals = [1, 2, 3, 4, 5, 6]
slow = fast = 0
n = len(vals)
steps = [{"nodes": vals, "pointers": {"slow": 0, "fast": 0}, "highlight": [], "vars": {},
          "caption": "Find the middle in one pass: slow moves 1 step, fast moves 2."}]
while fast is not None and fast + 1 < n:
    slow += 1
    fast = fast + 2 if fast + 2 < n else None
    steps.append({"nodes": vals, "pointers": {"slow": slow, **({"fast": fast} if fast is not None else {})}, "highlight": [slow], "vars": {"fast": "None" if fast is None else vals[fast]},
                  "caption": f"slow → {vals[slow]}, fast → {'None (fell off the end)' if fast is None else vals[fast]}."})
steps.append({"nodes": vals, "pointers": {"middle": slow}, "highlight": [slow], "vars": {},
              "caption": f"fast reached the end, so slow is halfway: {vals[slow]}. For even lengths this gives the second middle."})
print(json.dumps({"title": "Fast and slow pointers: the middle node", "view": "list", "steps": steps}))
