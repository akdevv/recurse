import json

a = [0, 0, 1, 1, 1, 2, 3, 3]
nums = list(a)
k = 1
steps = [{"array": list(nums), "pointers": {"k": 1, "i": 1}, "highlight": [0], "vars": {"k": 1},
          "caption": "Remove duplicates from a sorted array in place. nums[0..k-1] is the unique part; `i` reads ahead."}]
for i in range(1, len(nums)):
    if nums[i] != nums[k - 1]:
        nums[k] = nums[i]
        k += 1
        steps.append({"array": list(nums), "pointers": {"k": k, "i": i}, "highlight": list(range(k)), "vars": {"k": k},
                      "caption": f"{nums[k - 1]} differs from the last kept value: write it at index {k - 1}, k = {k}."})
    else:
        steps.append({"array": list(nums), "pointers": {"k": k, "i": i}, "highlight": list(range(k)), "dim": [i], "vars": {"k": k},
                      "caption": f"{nums[i]} equals the last kept value {nums[k - 1]}: skip. Sorted input means duplicates are always next to each other."})
steps.append({"array": list(nums), "pointers": {}, "highlight": list(range(k)), "dim": list(range(k, len(nums))), "vars": {"return": k},
              "caption": f"Return k = {k}. The slow pointer marks the answer, the fast pointer explores."})
print(json.dumps({"title": "Slow writer, fast reader", "view": "array", "steps": steps}))
