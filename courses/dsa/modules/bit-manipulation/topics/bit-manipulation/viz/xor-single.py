import json
nums = [4, 1, 2, 1, 2]
acc = 0
bits = lambda x: list(format(x, "04b"))
steps = [{"array": bits(0), "pointers": {}, "highlight": [], "vars": {"nums": nums, "acc": 0},
          "caption": "Single Number: every value appears twice except one. XOR rules: x ^ x = 0 and x ^ 0 = x, in any order."}]
for x in nums:
    acc ^= x
    steps.append({"array": bits(acc), "pointers": {}, "highlight": [i for i, b in enumerate(bits(acc)) if b == "1"], "vars": {"x": f"{x} ({format(x, '04b')})", "acc": acc},
                  "caption": f"acc ^= {x}. XOR flips the bits where x has a 1. A value seen twice flips its bits back."})
steps.append({"array": bits(acc), "pointers": {}, "highlight": [i for i, b in enumerate(bits(acc)) if b == "1"], "vars": {"answer": acc},
              "caption": f"The pairs cancelled out; {acc} is left. O(n) time, O(1) space, no hash set."})
print(json.dumps({"title": "XOR cancels pairs", "view": "array", "steps": steps}))
