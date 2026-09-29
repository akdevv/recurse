import json
from collections import defaultdict

words = ["eat", "tea", "tan", "ate", "nat", "bat"]
groups = defaultdict(list)
steps = [{"array": words, "pointers": {}, "highlight": [], "vars": {"groups": {}},
          "caption": "Group the anagrams. Idea: compute a key that is the same for every anagram, and use it as the dict key."}]
for i, w in enumerate(words):
    key = "".join(sorted(w))
    new = key not in groups
    groups[key].append(w)
    steps.append({"array": words, "pointers": {"w": i}, "highlight": [i], "vars": {"word": w, "key": key, "groups": dict(groups)},
                  "caption": f"'{w}' sorted is '{key}'." + (" New key: start a group." if new else f" Key exists: '{w}' joins that group.")})
steps.append({"array": words, "pointers": {}, "highlight": [], "vars": {"answer": list(groups.values())},
              "caption": "Return the dict's values. One pass over the words; each key costs O(k log k) to build (or O(k) with a 26-count tuple)."})
print(json.dumps({"title": "Grouping anagrams by a canonical key", "view": "array", "steps": steps}))
