---
lc: 933
title: "Number of Recent Calls"
difficulty: "Easy"
patterns: ["sliding-window"]
lcTags: ["design", "queue", "data-stream"]
entry: {"method": "RecentCounter", "design": true, "params": [{"name": "operations", "type": "string[]"}, {"name": "arguments", "type": "list"}], "returns": "list", "voids": []}
examples: ["[\"RecentCounter\",\"ping\",\"ping\",\"ping\",\"ping\"]\n[[],[1],[100],[3001],[3002]]"]
---

You have a `RecentCounter` class which counts the number of recent requests within a certain time frame.

Implement the `RecentCounter` class:

- `RecentCounter()` Initializes the counter with zero recent requests.
- `int ping(int t)` Adds a new request at time `t`, where `t` represents some time in milliseconds, and returns the number of requests that have happened in the inclusive range `[t - 3000, t]`, that is, the new request plus every earlier request that is no more than `3000` milliseconds older.

It is **guaranteed** that every call to `ping` uses a strictly larger value of `t` than the previous call.

**Example 1:**

```
Input
["RecentCounter", "ping", "ping", "ping", "ping"]
[[], [1], [100], [3001], [3002]]
Output
[null, 1, 2, 3, 3]

Explanation
RecentCounter recentCounter = new RecentCounter();
recentCounter.ping(1);     // requests = [1], range is [-2999,1], return 1
recentCounter.ping(100);   // requests = [1, 100], range is [-2900,100], return 2
recentCounter.ping(3001);  // requests = [1, 100, 3001], range is [1,3001], return 3
recentCounter.ping(3002);  // requests = [1, 100, 3001, 3002], range is [2,3002], return 3
```

**Constraints:**

- `1 <= t <= 10⁹`
- Each test case will call `ping` with **strictly increasing** values of `t`.
- At most `10⁴` calls will be made to `ping`.

# Starter

```python
class RecentCounter:

    def __init__(self):
        

    def ping(self, t: int) -> int:
        

# Your RecentCounter object will be instantiated and called as such:
# obj = RecentCounter()
# param_1 = obj.ping(t)
```

# Hints

1. Times arrive in increasing order, so old pings only ever need to be removed from the front.
2. Keep a deque. On ping(t): append t, pop from the left while the front is < t − 3000, return the length.

# Key points

- a queue of timestamps in the window [t - 3000, t]
- times increase, so expired ones are always at the front
- amortized O(1) per ping

# Solution: solution-1 · Queue · amortized O(1) · O(n) · reference

## Idea
Keep the pings in a queue. Times only increase, so pings older than t − 3000 are always at the front: pop them, then the queue size is the answer.

## Complexity
- **Time: amortized O(1)**
- **Space: O(n)**

```python
class RecentCounter:
    def __init__(self):
        self.q = deque()

    def ping(self, t: int) -> int:
        self.q.append(t)
        while self.q[0] < t - 3000:
            self.q.popleft()
        return len(self.q)

# Your RecentCounter object will be instantiated and called as such:
# obj = RecentCounter()
# param_1 = obj.ping(t)
```

# Solution: solution-2 · Binary search over all pings · O(log n) · O(n)

## Idea
Keep every ping in a sorted list (they arrive in order). The answer is the number of pings at or after t − 3000, found with binary search.

## Complexity
- **Time: O(log n)**
- **Space: O(n)**

```python
class RecentCounter:
    def __init__(self):
        self.s = []

    def ping(self, t: int) -> int:
        self.s.append(t)
        return len(self.s) - bisect_left(self.s, t - 3000)

# Your RecentCounter object will be instantiated and called as such:
# obj = RecentCounter()
# param_1 = obj.ping(t)
```

# Tests

```python
def edge():
    return [[["RecentCounter", "ping", "ping", "ping", "ping"], [[], [1], [100], [3001], [3002]]],
            [["RecentCounter", "ping"], [[], [10**9]]]]

def random_case(rng):
    o, a, t = ["RecentCounter"], [[]], 0
    for _ in range(rng.randint(1, 12)):
        t += rng.randint(1, 2000)
        o.append("ping"); a.append([t])
    return [o, a]

def perf(rng):
    return [[["RecentCounter"] + ["ping"] * 10000, [[]] + [[i * 10] for i in range(1, 10001)]]]
```
