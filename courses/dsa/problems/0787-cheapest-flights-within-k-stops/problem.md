---
lc: 787
title: "Cheapest Flights Within K Stops"
difficulty: "Medium"
patterns: ["dijkstra", "dynamic-programming"]
lcTags: ["dynamic-programming", "depth-first-search", "breadth-first-search", "graph", "heap-priority-queue", "shortest-path"]
entry: {"method": "findCheapestPrice", "params": [{"name": "n", "type": "integer"}, {"name": "flights", "type": "integer[][]"}, {"name": "src", "type": "integer"}, {"name": "dst", "type": "integer"}, {"name": "k", "type": "integer"}], "returns": "integer"}
examples: ["4\n[[0,1,100],[1,2,100],[2,0,100],[1,3,600],[2,3,200]]\n0\n3\n1", "3\n[[0,1,100],[1,2,100],[0,2,500]]\n0\n2\n1", "3\n[[0,1,100],[1,2,100],[0,2,500]]\n0\n2\n0"]
---

There are `n` cities connected by some number of flights. You are given an array `flights` where `flights[i] = [fromᵢ, toᵢ, priceᵢ]` indicates that there is a flight from city `fromᵢ` to city `toᵢ` with cost `priceᵢ`.

You are also given three integers `src`, `dst`, and `k`, return ***the cheapest price** from* `src` *to* `dst` *with at most* `k` *stops.* If there is no such route, return `-1`.

**Example 1:**

![](https://assets.leetcode.com/uploads/2022/03/18/cheapest-flights-within-k-stops-3drawio.png)

```
Input: n = 4, flights = [[0,1,100],[1,2,100],[2,0,100],[1,3,600],[2,3,200]], src = 0, dst = 3, k = 1
Output: 700
Explanation:
The graph is shown above.
The optimal path with at most 1 stop from city 0 to 3 is marked in red and has cost 100 + 600 = 700.
Note that the path through cities [0,1,2,3] is cheaper but is invalid because it uses 2 stops.
```

**Example 2:**

![](https://assets.leetcode.com/uploads/2022/03/18/cheapest-flights-within-k-stops-1drawio.png)

```
Input: n = 3, flights = [[0,1,100],[1,2,100],[0,2,500]], src = 0, dst = 2, k = 1
Output: 200
Explanation:
The graph is shown above.
The optimal path with at most 1 stop from city 0 to 2 is marked in red and has cost 100 + 100 = 200.
```

**Example 3:**

![](https://assets.leetcode.com/uploads/2022/03/18/cheapest-flights-within-k-stops-2drawio.png)

```
Input: n = 3, flights = [[0,1,100],[1,2,100],[0,2,500]], src = 0, dst = 2, k = 0
Output: 500
Explanation:
The graph is shown above.
The optimal path with no stops from city 0 to 2 is marked in red and has cost 500.
```

**Constraints:**

- `2 <= n <= 100`
- `0 <= flights.length <= (n * (n - 1) / 2)`
- `flights[i].length == 3`
- `0 <= fromᵢ, toᵢ < n`
- `fromᵢ != toᵢ`
- `1 <= priceᵢ <= 10⁴`
- There will not be any multiple flights between two cities.
- `0 <= src, dst, k < n`
- `src != dst`

# Starter

```python
class Solution:
    def findCheapestPrice(self, n: int, flights: list[list[int]], src: int, dst: int, k: int) -> int:
        
```

# Hints

1. Plain Dijkstra ignores the stop limit. At most k stops means at most k + 1 flights.
2. Bellman-Ford for k + 1 rounds: each round relax every flight using a copy of the previous round's prices (so one round adds at most one flight).

# Key points

- limit = k + 1 edges → k + 1 rounds of Bellman-Ford
- copy the distances each round so paths don't use more than one new edge per round
- O(k·E) time

# Solution: solution-1 · Bellman-Ford, k + 1 rounds · O(k × E) · O(n) · reference

## Idea
Bellman-Ford limited to k + 1 rounds (at most k stops = k + 1 flights). Each round relaxes every flight using a copy of the previous round's prices, so a round can add only one flight to any path.

## Complexity
- **Time: O(k × E)**
- **Space: O(n)**

```python
class Solution:
    def findCheapestPrice(
        self, n: int, flights: List[List[int]], src: int, dst: int, k: int
    ) -> int:
        INF = 0x3F3F3F3F
        dist = [INF] * n
        dist[src] = 0
        for _ in range(k + 1):
            backup = dist.copy()
            for f, t, p in flights:
                dist[t] = min(dist[t], backup[f] + p)
        return -1 if dist[dst] == INF else dist[dst]
```

# Solution: solution-2 · Memoized DFS · O(k × E) · O(n × k)

## Idea
Memoized DFS: `dfs(u, k)` is the cheapest price from u to dst using at most k flights. Try every flight out of u and take the minimum; reaching dst costs 0, running out of flights is infinity.

## Complexity
- **Time: O(k × E)**
- **Space: O(n × k)**

```python
class Solution:
    def findCheapestPrice(
        self, n: int, flights: List[List[int]], src: int, dst: int, k: int
    ) -> int:
        @cache
        def dfs(u, k):
            if u == dst:
                return 0
            if k <= 0:
                return inf
            k -= 1
            ans = inf
            for v, p in g[u]:
                ans = min(ans, dfs(v, k) + p)
            return ans

        g = defaultdict(list)
        for u, v, p in flights:
            g[u].append((v, p))
        ans = dfs(src, k + 1)
        return -1 if ans >= inf else ans
```

# Tests

```python
def make(rng, n, m):
    pairs = [(u, v) for u in range(n) for v in range(n) if u != v]
    return [[u, v, rng.randint(1, 20)] for u, v in rng.sample(pairs, min(m, len(pairs)))]

def edge():
    f = [[0, 1, 100], [1, 2, 100], [2, 0, 100], [1, 3, 600], [2, 3, 200]]
    return [[4, f, 0, 3, 1], [3, [[0, 1, 100], [1, 2, 100], [0, 2, 500]], 0, 2, 1], [3, [[0, 1, 100], [1, 2, 100], [0, 2, 500]], 0, 2, 0], [2, [], 0, 1, 0]]

def random_case(rng):
    n = rng.randint(2, 6)
    src, dst = rng.sample(range(n), 2)
    return [n, make(rng, n, rng.randint(0, n * (n - 1) // 2)), src, dst, rng.randint(0, n - 1)]

def perf(rng):
    return [[100, make(rng, 100, 4950), 0, 99, 99]]
```
