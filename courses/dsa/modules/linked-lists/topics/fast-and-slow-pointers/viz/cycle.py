import json

vals = [3, 2, 0, -4, 7, 9]
links = [1, 2, 3, 4, 5, 2]
slow = fast = 0
steps = [{"nodes": vals, "links": links, "pointers": {"slow": 0, "fast": 0}, "highlight": [], "vars": {},
          "caption": "The last node points back to index 2: a cycle. Phase 1: slow moves 1, fast moves 2. In a cycle, fast catches up by 1 each step."}]
while True:
    slow, fast = links[slow], links[links[fast]]
    steps.append({"nodes": vals, "links": links, "pointers": {"slow": slow, "fast": fast}, "highlight": [slow] if slow == fast else [], "vars": {},
                  "caption": f"slow at {vals[slow]}, fast at {vals[fast]}." + (" They meet: there is a cycle." if slow == fast else "")})
    if slow == fast:
        break
a = 0
steps.append({"nodes": vals, "links": links, "pointers": {"a": a, "b": fast}, "highlight": [], "vars": {},
              "caption": "Phase 2: put one pointer back at the head, leave the other at the meeting point. Move both 1 step at a time."})
b = fast
while a != b:
    a, b = links[a], links[b]
    steps.append({"nodes": vals, "links": links, "pointers": {"a": a, "b": b}, "highlight": [a] if a == b else [], "vars": {},
                  "caption": f"a at {vals[a]}, b at {vals[b]}." + (f" They meet at {vals[a]} (index {a}): the start of the cycle." if a == b else "")})
steps.append({"nodes": vals, "links": links, "pointers": {"start": a}, "highlight": [a], "vars": {},
              "caption": "Why: the distance from the head to the cycle start equals the distance from the meeting point to the start (going around). O(n) time, O(1) space."})
print(json.dumps({"title": "Floyd's cycle detection, then the cycle start", "view": "list", "steps": steps}))
