---
lc: 146
title: "LRU Cache"
difficulty: "Medium"
patterns: ["hash-map"]
lcTags: ["hash-table", "linked-list", "design", "doubly-linked-list"]
entry: {"method": "LRUCache", "design": true, "params": [{"name": "operations", "type": "string[]"}, {"name": "arguments", "type": "list"}], "returns": "list"}
examples: ["[\"LRUCache\",\"put\",\"put\",\"get\",\"put\",\"get\",\"put\",\"get\",\"get\",\"get\"]\n[[2],[1,1],[2,2],[1],[3,3],[2],[4,4],[1],[3],[4]]"]
---

Design a data structure that follows the constraints of a **[Least Recently Used (LRU) cache](https://en.wikipedia.org/wiki/Cache_replacement_policies#LRU)**.

Implement the `LRUCache` class:

- `LRUCache(int capacity)` Initialize the LRU cache with **positive** size `capacity`.
- `int get(int key)` Return the value of the `key` if the key exists, otherwise return `-1`.
- `void put(int key, int value)` Update the value of the `key` if the `key` exists. Otherwise, add the `key-value` pair to the cache. If the number of keys exceeds the `capacity` from this operation, **evict** the least recently used key.

The functions `get` and `put` must each run in `O(1)` average time complexity.

**Example 1:**

```
Input
["LRUCache", "put", "put", "get", "put", "get", "put", "get", "get", "get"]
[[2], [1, 1], [2, 2], [1], [3, 3], [2], [4, 4], [1], [3], [4]]
Output
[null, null, null, 1, null, -1, null, -1, 3, 4]

Explanation
LRUCache lRUCache = new LRUCache(2);
lRUCache.put(1, 1); // cache is {1=1}
lRUCache.put(2, 2); // cache is {1=1, 2=2}
lRUCache.get(1);    // return 1
lRUCache.put(3, 3); // LRU key was 2, evicts key 2, cache is {1=1, 3=3}
lRUCache.get(2);    // returns -1 (not found)
lRUCache.put(4, 4); // LRU key was 1, evicts key 1, cache is {4=4, 3=3}
lRUCache.get(1);    // return -1 (not found)
lRUCache.get(3);    // return 3
lRUCache.get(4);    // return 4
```

**Constraints:**

- `1 <= capacity <= 3000`
- `0 <= key <= 10⁴`
- `0 <= value <= 10⁵`
- At most `2 * 10⁵` calls will be made to `get` and `put`.

# Starter

```python
class LRUCache:

    def __init__(self, capacity: int):
        

    def get(self, key: int) -> int:
        

    def put(self, key: int, value: int) -> None:
        

# Your LRUCache object will be instantiated and called as such:
# obj = LRUCache(capacity)
# param_1 = obj.get(key)
# obj.put(key,value)
```

# Hints

1. You need O(1) lookup by key (a dict) and O(1) "move to most recent" / "remove least recent". Which structure keeps an order you can reorder in O(1)?
2. Dict key → node of a doubly linked list ordered by recency. get/put move the node to the front; when over capacity, remove the node at the back. (In Python, OrderedDict with move_to_end/popitem(last=False) does this.)

# Key points

- hash map for O(1) lookup + doubly linked list for O(1) reordering
- most recent at one end, evict from the other
- sentinel head/tail nodes avoid edge cases
- every get and put counts as a use

# Solution: hash-table-doubly-linked-list · Hash Table + Doubly Linked List · O(1) · O(capacity) · reference

We can implement an LRU (Least Recently Used) cache using a "hash table" and a "doubly linked list".

- Hash Table: Used to store the key and its corresponding node location.
- Doubly Linked List: Used to store node data, sorted by access time.

When accessing a node, if the node exists, we delete it from its original position and reinsert it at the head of the list. This ensures that the node stored at the tail of the list is the least recently used node. When the number of nodes exceeds the maximum cache space, we eliminate the node at the tail of the list.

When inserting a node, if the node exists, we delete it from its original position and reinsert it at the head of the list. If it does not exist, we first check if the cache is full. If it is full, we delete the node at the tail of the list and insert the new node at the head of the list.

The time complexity is O(1), and the space complexity is O(capacity).

```python
class Node:
    def __init__(self, key: int = 0, val: int = 0):
        self.key = key
        self.val = val
        self.prev = None
        self.next = None

class LRUCache:

    def __init__(self, capacity: int):
        self.size = 0
        self.capacity = capacity
        self.cache = {}
        self.head = Node()
        self.tail = Node()
        self.head.next = self.tail
        self.tail.prev = self.head

    def get(self, key: int) -> int:
        if key not in self.cache:
            return -1
        node = self.cache[key]
        self.remove_node(node)
        self.add_to_head(node)
        return node.val

    def put(self, key: int, value: int) -> None:
        if key in self.cache:
            node = self.cache[key]
            self.remove_node(node)
            node.val = value
            self.add_to_head(node)
        else:
            node = Node(key, value)
            self.cache[key] = node
            self.add_to_head(node)
            self.size += 1
            if self.size > self.capacity:
                node = self.tail.prev
                self.cache.pop(node.key)
                self.remove_node(node)
                self.size -= 1

    def remove_node(self, node):
        node.prev.next = node.next
        node.next.prev = node.prev

    def add_to_head(self, node):
        node.next = self.head.next
        node.prev = self.head
        self.head.next = node
        node.next.prev = node

# Your LRUCache object will be instantiated and called as such:
# obj = LRUCache(capacity)
# param_1 = obj.get(key)
# obj.put(key,value)
```

# Tests

```python
def ops(rng, n, cap, keys):
    o, a = ["LRUCache"], [[cap]]
    for _ in range(n):
        if rng.random() < 0.5:
            o.append("put"); a.append([rng.randint(0, keys), rng.randint(0, 100)])
        else:
            o.append("get"); a.append([rng.randint(0, keys)])
    return [o, a]

def edge():
    return [[["LRUCache", "put", "get"], [[1], [1, 1], [1]]],
            [["LRUCache", "put", "put", "get", "put", "get"], [[1], [1, 1], [2, 2], [1], [1, 3], [1]]],
            [["LRUCache", "put", "put", "put", "get", "get"], [[2], [1, 1], [1, 2], [2, 3], [1], [2]]]]

def random_case(rng):
    return ops(rng, rng.randint(1, 15), rng.randint(1, 4), 6)

def perf(rng):
    return [ops(rng, 200000, 3000, 10**4)]
```
