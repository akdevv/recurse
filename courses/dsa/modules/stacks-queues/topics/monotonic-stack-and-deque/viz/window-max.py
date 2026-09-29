import json
from collections import deque

nums, k = [1, 3, -1, -3, 5, 3, 6, 7], 3
dq = deque()
out = []
steps = [{"array": nums, "pointers": {}, "highlight": [], "stack": [], "stackLabel": "deque (front at bottom)", "vars": {"k": k, "maxes": []},
          "caption": f"Sliding window maximum, k = {k}. The deque holds indexes with decreasing values; its front is the current max."}]
for i, x in enumerate(nums):
    dropped = []
    while dq and nums[dq[-1]] <= x:
        dropped.append(nums[dq.pop()])
    dq.append(i)
    expired = dq[0] <= i - k
    if expired:
        dq.popleft()
    cap = f"Add {x}." + (f" Pop {dropped} from the back: smaller and older, they can never be a max again." if dropped else "") + (" Front index left the window: pop it." if expired else "")
    if i >= k - 1:
        out.append(nums[dq[0]])
        cap += f" Window max = {nums[dq[0]]}."
    steps.append({"array": nums, "pointers": {"i": i}, "highlight": list(range(max(0, i - k + 1), i + 1)), "stack": [f"{nums[j]} (i={j})" for j in dq],
                  "stackLabel": "deque (front at bottom)", "vars": {"maxes": list(out)}, "caption": cap})
print(json.dumps({"title": "Monotonic deque: window maximum in O(n)", "view": "array", "steps": steps}))
