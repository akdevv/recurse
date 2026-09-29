---
lc: 621
title: "Task Scheduler"
difficulty: "Medium"
patterns: ["greedy", "top-k-heap"]
lcTags: ["array", "hash-table", "greedy", "sorting", "heap-priority-queue", "counting"]
entry: {"method": "leastInterval", "params": [{"name": "tasks", "type": "character[]"}, {"name": "n", "type": "integer"}], "returns": "integer"}
examples: ["[\"A\",\"A\",\"A\",\"B\",\"B\",\"B\"]\n2", "[\"A\",\"C\",\"A\",\"B\",\"D\",\"B\"]\n1", "[\"A\",\"A\",\"A\", \"B\",\"B\",\"B\"]\n3"]
lcHints: ["There are many different solutions for this problem, including a greedy algorithm.", "For every cycle, find the most frequent letter that can be placed in this cycle. After placing, decrease the frequency of that letter by one.", "Use Priority Queue."]
---

You are given an array of CPU `tasks`, each labeled with a letter from A to Z, and a number `n`. Each CPU interval can be idle or allow the completion of one task. Tasks can be completed in any order, but there's a constraint: there has to be a gap of **at least** `n` intervals between two tasks with the same label.

Return the **minimum** number of CPU intervals required to complete all tasks.

**Example 1:**

**Input:** tasks = ["A","A","A","B","B","B"], n = 2

**Output:** 8

**Explanation:** A possible sequence is: A -> B -> idle -> A -> B -> idle -> A -> B.

After completing task A, you must wait two intervals before doing A again. The same applies to task B. In the 3<sup>rd</sup> interval, neither A nor B can be done, so you idle. By the 4<sup>th</sup> interval, you can do A again as 2 intervals have passed.

**Example 2:**

**Input:** tasks = ["A","C","A","B","D","B"], n = 1

**Output:** 6

**Explanation:** A possible sequence is: A -> B -> C -> D -> A -> B.

With a cooling interval of 1, you can repeat a task after just one other task.

**Example 3:**

**Input:** tasks = ["A","A","A", "B","B","B"], n = 3

**Output:** 10

**Explanation:** A possible sequence is: A -> B -> idle -> idle -> A -> B -> idle -> idle -> A -> B.

There are only two types of tasks, A and B, which need to be separated by 3 intervals. This leads to idling twice between repetitions of these tasks.

**Constraints:**

- `1 <= tasks.length <= 10⁴`
- `tasks[i]` is an uppercase English letter.
- `0 <= n <= 100`

# Starter

```python
class Solution:
    def leastInterval(self, tasks: list[str], n: int) -> int:
        
```

# Hints

1. The most frequent task decides the shape: it needs (maxCount − 1) gaps of length n between its copies.
2. Answer = max(len(tasks), (maxCount − 1) · (n + 1) + number of tasks that have maxCount).

# Key points

- the most frequent task forms the frame: (maxCount - 1) blocks of size n + 1
- tasks tied for max frequency fill the final row
- if there are enough tasks to fill all gaps, the answer is just len(tasks)
- O(n) time; simulation with a heap also works

# Solution: solution-1 · Count the most frequent task · O(n) · O(1) · reference

## Idea
The most frequent task (count x) needs x − 1 gaps of n slots between its copies: `(x − 1) × (n + 1)` slots, plus one final slot for each task tied at count x. If there are more tasks than that, there's no idle time and the answer is just the number of tasks.

## Complexity
- **Time: O(n)**
- **Space: O(1)**

```python
class Solution:
    def leastInterval(self, tasks: List[str], n: int) -> int:
        cnt = Counter(tasks)
        x = max(cnt.values())
        s = sum(v == x for v in cnt.values())
        return max(len(tasks), (x - 1) * (n + 1) + s)
```

# Tests

```python
def edge():
    return [[["A"], 0], [["A", "A", "A", "B", "B", "B"], 2], [["A", "C", "A", "B", "D", "B"], 1], [["A", "A", "A", "B", "B", "B"], 3], [["A", "A", "A"], 100]]

def random_case(rng):
    return [[rng.choice("ABCD") for _ in range(rng.randint(1, 12))], rng.randint(0, 4)]

def perf(rng):
    return [[[rng.choice("ABCDEFGHIJKLMNOPQRSTUVWXYZ") for _ in range(10000)], 100]]
```
