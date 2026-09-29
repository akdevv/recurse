import json

T = [73, 74, 75, 71, 69, 72, 76, 73]
ans = [0] * len(T)
st = []
steps = [{"array": T, "pointers": {}, "highlight": [], "stack": [], "vars": {"answer": ans[:]},
          "caption": "Daily Temperatures: days waiting for a warmer day sit on a stack. Their temperatures always decrease from bottom to top."}]
for i, t in enumerate(T):
    resolved = []
    while st and T[st[-1]] < t:
        j = st.pop()
        ans[j] = i - j
        resolved.append(f"day {j} ({T[j]}°) waited {i - j}")
    st.append(i)
    cap = f"Day {i} is {t}°. " + ("It's warmer than the waiting days on top: " + "; ".join(resolved) + ". " if resolved else "Not warmer than the top, so nothing resolves. ") + f"Push day {i}."
    steps.append({"array": T, "pointers": {"i": i}, "highlight": [j for j in st], "stack": [f"day {j}: {T[j]}°" for j in st], "vars": {"answer": ans[:]}, "caption": cap})
steps.append({"array": T, "pointers": {}, "highlight": [], "stack": [f"day {j}: {T[j]}°" for j in st], "vars": {"answer": ans},
              "caption": "Days still on the stack never got warmer: 0. Every day is pushed once and popped at most once: O(n)."})
print(json.dumps({"title": "Monotonic stack: the next warmer day", "view": "array", "steps": steps}))
