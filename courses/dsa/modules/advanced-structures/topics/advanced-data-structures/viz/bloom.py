import json
M = 12
bits = [0] * M
h = lambda w, k: (sum((i + 1) * ord(c) for i, c in enumerate(w)) * (k + 3) + k * 7) % M
steps = [{"array": bits[:], "pointers": {}, "highlight": [], "vars": {"hash functions": 2},
          "caption": f"A Bloom filter: {M} bits, all 0, and 2 hash functions. It answers \"definitely not in the set\" or \"probably in the set\"."}]
for w in ["dog", "owl", "fox"]:
    idx = sorted({h(w, 0), h(w, 1)})
    for i in idx:
        bits[i] = 1
    steps.append({"array": bits[:], "pointers": {}, "highlight": idx, "vars": {"add": w, "bits set": idx},
                  "caption": f"add(\"{w}\"): set the bits at its 2 hash positions {idx}."})
for w in ["owl", "emu", "bee"]:
    idx = sorted({h(w, 0), h(w, 1)})
    hit = all(bits[i] for i in idx)
    added = w in ("dog", "owl", "fox")
    verdict = "probably present (it was added)" if hit and added else ("probably present, but it was NEVER added: a false positive" if hit else "a bit is 0, so definitely NOT present")
    steps.append({"array": bits[:], "pointers": {}, "highlight": idx, "dim": [i for i in idx if not bits[i]], "vars": {"check": w, "positions": idx},
                  "caption": f"contains(\"{w}\"): bits {idx} → {verdict}."})
steps.append({"array": bits[:], "pointers": {}, "highlight": [], "vars": {},
              "caption": "No false negatives, occasional false positives, tiny memory, no deletions. Used to skip expensive lookups (databases, caches, spell checkers)."})
print(json.dumps({"title": "Bloom filter: probably yes, definitely no", "view": "array", "steps": steps}))
