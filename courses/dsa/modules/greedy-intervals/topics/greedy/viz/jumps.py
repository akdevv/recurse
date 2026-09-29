import json
nums = [2, 3, 1, 1, 4, 1, 2]
jumps = end = far = 0
steps = [{"array": nums, "pointers": {"end": 0}, "highlight": [0], "vars": {"jumps": 0},
          "caption": "Jump Game II: think in ranges. With 0 jumps you can stand on index 0. Scan the range and track the farthest index reachable from it."}]
start = 0
for i in range(len(nums) - 1):
    far = max(far, i + nums[i])
    if i == end:
        jumps += 1
        steps.append({"array": nums, "pointers": {"i": i, "far": min(far, len(nums) - 1)}, "highlight": list(range(end + 1, min(far, len(nums) - 1) + 1)),
                      "dim": list(range(0, end + 1)), "vars": {"jumps": jumps, "next range": f"{end + 1}..{min(far, len(nums) - 1)}"},
                      "caption": f"End of the range reachable with {jumps - 1} jump(s). Everything up to index {far} is reachable with {jumps}. That's the next range."})
        end = far
        if end >= len(nums) - 1:
            break
steps.append({"array": nums, "pointers": {"last": len(nums) - 1}, "highlight": [len(nums) - 1], "vars": {"jumps": jumps},
              "caption": f"The last index is inside range #{jumps}: minimum {jumps} jumps. It's BFS over indexes without a queue: O(n), O(1) space."})
print(json.dumps({"title": "Greedy ranges: minimum jumps", "view": "array", "steps": steps}))
