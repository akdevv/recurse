import json

a, k = [1, 2, 3, 4, 5, 6, 7], 3
n = len(a)
steps = [{"array": list(a), "pointers": {}, "highlight": list(range(n - k, n)), "vars": {"k": k},
          "caption": f"Rotate right by {k}: the last {k} values must end up in front, in the same order."}]

def rev(lo, hi, label):
    while lo < hi:
        a[lo], a[hi] = a[hi], a[lo]
        steps.append({"array": list(a), "pointers": {"lo": lo, "hi": hi}, "highlight": [lo, hi], "vars": {"step": label},
                      "caption": f"{label}: swap positions {lo} and {hi}, then move both pointers inward."})
        lo, hi = lo + 1, hi - 1

rev(0, n - 1, "reverse all")
steps.append({"array": list(a), "pointers": {}, "highlight": list(range(k)), "vars": {},
              "caption": f"The last {k} values are in front now, but backwards. So is the rest."})
rev(0, k - 1, "reverse first k")
rev(k, n - 1, "reverse the rest")
steps.append({"array": list(a), "pointers": {}, "highlight": [], "vars": {"result": a},
              "caption": "Rotated in place: O(n) time, O(1) extra space. No second array needed."})
print(json.dumps({"title": "Rotate by k with three reversals", "view": "array", "steps": steps}))
