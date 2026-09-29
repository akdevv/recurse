import json

a = [38, 27, 43, 3, 9, 82, 10, 5]
steps = [{"array": list(a), "pointers": {}, "highlight": [], "vars": {},
          "caption": "Merge sort: split in half until pieces have one element (already sorted), then merge sorted pieces back together."}]

def sort(lo, hi, depth):
    if hi - lo <= 1:
        return
    mid = (lo + hi) // 2
    sort(lo, mid, depth + 1)
    sort(mid, hi, depth + 1)
    left, right = a[lo:mid], a[mid:hi]
    merged, i, j = [], 0, 0
    while i < len(left) and j < len(right):
        if left[i] <= right[j]:
            merged.append(left[i]); i += 1
        else:
            merged.append(right[j]); j += 1
    merged += left[i:] + right[j:]
    a[lo:hi] = merged
    steps.append({"array": list(a), "pointers": {"lo": lo, "mid": mid}, "highlight": list(range(lo, hi)),
                  "vars": {"left": left, "right": right, "merged": merged},
                  "caption": f"Merge {left} and {right}: repeatedly take the smaller front element. {hi - lo} elements, {hi - lo} steps."})

sort(0, len(a), 0)
steps.append({"array": list(a), "pointers": {}, "highlight": list(range(len(a))), "vars": {"levels": 3, "work per level": "n"},
              "caption": "log₂(8) = 3 levels of merging, each level touches all n elements: O(n log n), every time."})
print(json.dumps({"title": "Merge sort: sort halves, then merge", "view": "array", "steps": steps}))
