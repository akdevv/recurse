---
lc: 455
title: "Assign Cookies"
difficulty: "Easy"
patterns: ["greedy"]
lcTags: ["array", "two-pointers", "greedy", "sorting", "quicksort"]
entry: {"method": "findContentChildren", "params": [{"name": "g", "type": "integer[]"}, {"name": "s", "type": "integer[]"}], "returns": "integer"}
examples: ["[1,2,3]\n[1,1]", "[1,2]\n[1,2,3]"]
---

Assume you are an awesome parent and want to give your children some cookies. But, you should give each child at most one cookie.

Each child `i` has a greed factor `g[i]`, which is the minimum size of a cookie that the child will be content with; and each cookie `j` has a size `s[j]`. If `s[j] >= g[i]`, we can assign the cookie `j` to the child `i`, and the child `i` will be content. Your goal is to maximize the number of your content children and output the maximum number.

**Example 1:**

```
Input: g = [1,2,3], s = [1,1]
Output: 1
Explanation: You have 3 children and 2 cookies. The greed factors of 3 children are 1, 2, 3.
And even though you have 2 cookies, since their size is both 1, you could only make the child whose greed factor is 1 content.
You need to output 1.
```

**Example 2:**

```
Input: g = [1,2], s = [1,2,3]
Output: 2
Explanation: You have 2 children and 3 cookies. The greed factors of 2 children are 1, 2.
You have 3 cookies and their sizes are big enough to gratify all of the children,
You need to output 2.
```

**Constraints:**

- `1 <= g.length <= 3 * 10⁴`
- `0 <= s.length <= 3 * 10⁴`
- `1 <= g[i], s[j] <= 2³¹ - 1`

**Note:** This question is the same as  [2410: Maximum Matching of Players With Trainers.](https://leetcode.com/problems/maximum-matching-of-players-with-trainers/description/)

# Starter

```python
class Solution:
    def findContentChildren(self, g: list[int], s: list[int]) -> int:
        
```

# Hints

1. Give the smallest cookie that satisfies a child. Which children should you try to satisfy first?
2. Sort both. Two pointers: if cookie j satisfies child i, move both; otherwise try the next (bigger) cookie.

# Key points

- sort greed factors and cookie sizes
- greedily match the smallest sufficient cookie to the least greedy child
- O(n log n + m log m) time

# Solution: sorting-two-pointers · Sorting + Two Pointers · O(m × log m + n × log n) · O(log m + log n) · reference

According to the problem description, we should prioritize giving cookies to children with smaller appetites, so as to satisfy as many children as possible.

Therefore, we first sort the two arrays, and then use two pointers i and j to point to the head of arrays g and s respectively. Each time we compare the size of `g[i]` and `s[j]`:

- If `s[j] < g[i]`, it means that the current cookie `s[j]` cannot satisfy the current child `g[i]`. We should allocate a larger cookie to the current child, so j should move to the right by one. If j goes out of bounds, it means that the current child cannot be satisfied. At this time, the number of successfully allocated children is i, and we can return directly.
- If `s[j] >= g[i]`, it means that the current cookie `s[j]` can satisfy the current child `g[i]`. We allocate the current cookie to the current child, so both i and j should move to the right by one.

If we have traversed the array g, it means that all children have been allocated cookies, and we can return the total number of children.

The time complexity is O(m × log m + n × log n), and the space complexity is O(log m + log n). Where m and n are the lengths of arrays g and s respectively.

```python
class Solution:
    def findContentChildren(self, g: List[int], s: List[int]) -> int:
        g.sort()
        s.sort()
        j = 0
        for i, x in enumerate(g):
            while j < len(s) and s[j] < g[i]:
                j += 1
            if j >= len(s):
                return i
            j += 1
        return len(g)
```

# Tests

```python

```
