import json

nums = [2, 0, 2, 1, 1, 0]
lo = mid = 0
hi = len(nums) - 1
steps = [{"array": list(nums), "pointers": {"lo": lo, "mid": mid, "hi": hi}, "highlight": [], "vars": {},
          "caption": "Sort 0s, 1s and 2s in one pass. [0, lo) are 0s, [lo, mid) are 1s, (hi, end] are 2s, [mid, hi] is unknown."}]
while mid <= hi:
    v = nums[mid]
    if v == 0:
        nums[lo], nums[mid] = nums[mid], nums[lo]
        cap = f"nums[mid] = 0: swap it to lo. Both lo and mid move right."
        lo += 1; mid += 1
    elif v == 1:
        cap = "nums[mid] = 1: it's already in the middle region. mid += 1."
        mid += 1
    else:
        nums[mid], nums[hi] = nums[hi], nums[mid]
        cap = "nums[mid] = 2: swap it to hi, hi -= 1. mid stays: the value swapped in hasn't been checked yet."
        hi -= 1
    steps.append({"array": list(nums), "pointers": {"lo": lo, "mid": mid, "hi": hi}, "highlight": list(range(lo)) + list(range(hi + 1, len(nums))), "vars": {"saw": v}, "caption": cap})
steps.append({"array": list(nums), "pointers": {}, "highlight": list(range(len(nums))), "vars": {}, "caption": "mid passed hi: everything is sorted in one pass, O(1) extra space."})
print(json.dumps({"title": "Dutch national flag: three regions, three pointers", "view": "array", "steps": steps}))
