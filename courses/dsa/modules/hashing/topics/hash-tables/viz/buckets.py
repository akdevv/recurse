import json

M = 5
keys = [12, 7, 22, 5, 17]
buckets = [[] for _ in range(M)]
grid = lambda: [list(b) or ["·"] for b in buckets]
steps = [{"grid": grid(), "highlight": [], "vars": {"buckets": M, "hash(k)": "k % 5"},
          "caption": "A hash table is an array of buckets. hash(key) picks the bucket, so we jump straight to it instead of scanning."}]
for k in keys:
    b = k % M
    buckets[b].append(k)
    note = " Another key is already here: a collision. With chaining, the bucket just holds a short list." if len(buckets[b]) > 1 else ""
    steps.append({"grid": grid(), "highlight": [[b, len(buckets[b]) - 1]], "vars": {"key": k, "bucket": f"{k} % 5 = {b}"},
                  "caption": f"Insert {k}: {k} % 5 = {b}, so it goes into bucket {b}.{note}"})
q = 17
b = q % M
for i, k in enumerate(buckets[b]):
    steps.append({"grid": grid(), "highlight": [[b, i]], "pointers": {"look": [b, i]}, "vars": {"find": q, "bucket": b},
                  "caption": f"Look up {q}: go to bucket {q} % 5 = {b} and compare with {k}." + (" Found it." if k == q else " Not it, check the next one.")})
steps.append({"grid": grid(), "highlight": [], "vars": {"average cost": "O(1)", "worst case": "O(n)"},
              "caption": "Only one bucket was searched. With a good hash and a low load factor buckets stay tiny: O(1) on average. If every key collided, one bucket would hold all n keys: O(n)."})
print(json.dumps({"title": "Hashing keys into buckets (chaining)", "view": "grid", "steps": steps}))
