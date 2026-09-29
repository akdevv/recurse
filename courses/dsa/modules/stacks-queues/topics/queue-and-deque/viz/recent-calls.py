import json
from collections import deque

pings = [1, 100, 3001, 3002, 7000]
q = deque()
steps = [{"array": pings, "pointers": {}, "highlight": [], "vars": {"queue": []},
          "caption": "Number of Recent Calls: count pings in the last 3000 ms. Times only increase, so old pings leave from the front: a queue."}]
for i, t in enumerate(pings):
    q.append(t)
    gone = []
    while q[0] < t - 3000:
        gone.append(q.popleft())
    steps.append({"array": pings, "pointers": {"t": i}, "highlight": [pings.index(x) for x in q], "dim": [pings.index(x) for x in pings[:i] if x not in q],
                  "vars": {"window": f"[{t - 3000}, {t}]", "queue": list(q), "return": len(q)},
                  "caption": f"ping({t}): append it." + (f" Pop {gone} from the front (older than {t - 3000})." if gone else " Nothing expired.") + f" Answer {len(q)}."})
print(json.dumps({"title": "A queue as a time window", "view": "array", "steps": steps}))
