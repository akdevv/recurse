import json

n = 30
nums = list(range(2, n))           # index k holds number k + 2
crossed = set()
steps = [{"array": nums, "pointers": {}, "highlight": [], "dim": [], "vars": {"n": n},
          "caption": "Start by assuming every number from 2 to 29 is prime."}]
p = 2
while p * p < n:
    if p - 2 not in crossed:
        marked = []
        for m in range(p * p, n, p):
            if m - 2 not in crossed:
                crossed.add(m - 2)
                marked.append(m - 2)
        steps.append({"array": nums, "pointers": {"p": p - 2}, "highlight": marked, "dim": sorted(crossed),
                      "vars": {"p": p, "crossed out": len(crossed)},
                      "caption": f"{p} is prime. Cross out its multiples from {p}² = {p * p}: {[nums[k] for k in marked]}."})
    p += 1
primes = [nums[k] for k in range(len(nums)) if k not in crossed]
steps.append({"array": nums, "pointers": {}, "highlight": [k for k in range(len(nums)) if k not in crossed], "dim": sorted(crossed),
              "vars": {"primes": len(primes)},
              "caption": f"{p}² ≥ {n}, stop. Survivors are prime: {primes}."})
print(json.dumps({"title": "Sieve of Eratosthenes (n = 30)", "view": "array", "steps": steps}))
