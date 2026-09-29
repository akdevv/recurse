---
lc: 622
title: "Design Circular Queue"
difficulty: "Medium"
patterns: ["simulation"]
lcTags: ["array", "linked-list", "design", "queue"]
entry: {"method": "MyCircularQueue", "design": true, "params": [{"name": "operations", "type": "string[]"}, {"name": "arguments", "type": "list"}], "returns": "list"}
examples: ["[\"MyCircularQueue\",\"enQueue\",\"enQueue\",\"enQueue\",\"enQueue\",\"Rear\",\"isFull\",\"deQueue\",\"enQueue\",\"Rear\"]\n[[3],[1],[2],[3],[4],[],[],[],[4],[]]"]
---

Design your implementation of the circular queue. The circular queue is a linear data structure in which the operations are performed based on FIFO (First In First Out) principle, and the last position is connected back to the first position to make a circle. It is also called "Ring Buffer".

One of the benefits of the circular queue is that we can make use of the spaces in front of the queue. In a normal queue, once the queue becomes full, we cannot insert the next element even if there is a space in front of the queue. But using the circular queue, we can use the space to store new values.

Implement the `MyCircularQueue` class:

- `MyCircularQueue(k)` Initializes the object with the size of the queue to be `k`.
- `int Front()` Gets the front item from the queue. If the queue is empty, return `-1`.
- `int Rear()` Gets the last item from the queue. If the queue is empty, return `-1`.
- `boolean enQueue(int value)` Inserts an element into the circular queue. Return `true` if the operation is successful.
- `boolean deQueue()` Deletes an element from the circular queue. Return `true` if the operation is successful.
- `boolean isEmpty()` Checks whether the circular queue is empty or not.
- `boolean isFull()` Checks whether the circular queue is full or not.

You must solve the problem without using the built-in queue data structure in your programming language.

**Example 1:**

```
Input
["MyCircularQueue", "enQueue", "enQueue", "enQueue", "enQueue", "Rear", "isFull", "deQueue", "enQueue", "Rear"]
[[3], [1], [2], [3], [4], [], [], [], [4], []]
Output
[null, true, true, true, false, 3, true, true, true, 4]

Explanation
MyCircularQueue myCircularQueue = new MyCircularQueue(3);
myCircularQueue.enQueue(1); // return True
myCircularQueue.enQueue(2); // return True
myCircularQueue.enQueue(3); // return True
myCircularQueue.enQueue(4); // return False
myCircularQueue.Rear();     // return 3
myCircularQueue.isFull();   // return True
myCircularQueue.deQueue();  // return True
myCircularQueue.enQueue(4); // return True
myCircularQueue.Rear();     // return 4
```

**Constraints:**

- `1 <= k <= 1000`
- `0 <= value <= 1000`
- At most `3000` calls will be made to `enQueue`, `deQueue`, `Front`, `Rear`, `isEmpty`, and `isFull`.

# Starter

```python
class MyCircularQueue:

    def __init__(self, k: int):
        

    def enQueue(self, value: int) -> bool:
        

    def deQueue(self) -> bool:
        

    def Front(self) -> int:
        

    def Rear(self) -> int:
        

    def isEmpty(self) -> bool:
        

    def isFull(self) -> bool:
        

# Your MyCircularQueue object will be instantiated and called as such:
# obj = MyCircularQueue(k)
# param_1 = obj.enQueue(value)
# param_2 = obj.deQueue()
# param_3 = obj.Front()
# param_4 = obj.Rear()
# param_5 = obj.isEmpty()
# param_6 = obj.isFull()
```

# Hints

1. Use a fixed array of size k. What do you need besides the array to know where the front is and how full it is?
2. Keep head index and count. Rear index = (head + count − 1) % k; enqueue writes at (head + count) % k; dequeue moves head = (head + 1) % k.

# Key points

- fixed array + head + count (or head + tail + size)
- indices wrap with % k
- count tells empty (0) and full (k) apart
- all operations O(1)

# Solution: array-simulation · Array Simulation · O(1) · O(k) · reference

We can use an array q of length k to simulate a circular queue, with a pointer front to record the position of the front element. Initially, the queue is empty, and front is 0. Additionally, we use a variable size to record the number of elements in the queue, initially size is 0.

When calling the `enQueue` method, we first check if the queue is full, i.e., `size = k`. If it is full, we return false. Otherwise, we insert the element at position `(front + size) mod k`, then `size = size + 1`, indicating that the number of elements in the queue has increased by 1. Finally, we return true.

When calling the `deQueue` method, we first check if the queue is empty, i.e., `size = 0`. If it is empty, we return false. Otherwise, we set `front = (front + 1) mod k`, indicating that the front element has been dequeued, then `size = size - 1`.

When calling the `Front` method, we first check if the queue is empty, i.e., `size = 0`. If it is empty, we return -1. Otherwise, we return `q[front]`.

When calling the `Rear` method, we first check if the queue is empty, i.e., `size = 0`. If it is empty, we return -1. Otherwise, we return `q[(front + size - 1) mod k]`.

When calling the `isEmpty` method, we simply check if `size = 0`.

When calling the `isFull` method, we simply check if `size = k`.

In terms of time complexity, the above operations all have a time complexity of O(1). The space complexity is O(k).

```python
class MyCircularQueue:

    def __init__(self, k: int):
        self.q = [0] * k
        self.size = 0
        self.capacity = k
        self.front = 0

    def enQueue(self, value: int) -> bool:
        if self.isFull():
            return False
        self.q[(self.front + self.size) % self.capacity] = value
        self.size += 1
        return True

    def deQueue(self) -> bool:
        if self.isEmpty():
            return False
        self.front = (self.front + 1) % self.capacity
        self.size -= 1
        return True

    def Front(self) -> int:
        return -1 if self.isEmpty() else self.q[self.front]

    def Rear(self) -> int:
        if self.isEmpty():
            return -1
        return self.q[(self.front + self.size - 1) % self.capacity]

    def isEmpty(self) -> bool:
        return self.size == 0

    def isFull(self) -> bool:
        return self.size == self.capacity

# Your MyCircularQueue object will be instantiated and called as such:
# obj = MyCircularQueue(k)
# param_1 = obj.enQueue(value)
# param_2 = obj.deQueue()
# param_3 = obj.Front()
# param_4 = obj.Rear()
# param_5 = obj.isEmpty()
# param_6 = obj.isFull()
```

# Tests

```python
def ops(rng, n, k):
    o, a = ["MyCircularQueue"], [[k]]
    for _ in range(n):
        op = rng.choice(["enQueue", "enQueue", "deQueue", "Front", "Rear", "isEmpty", "isFull"])
        o.append(op)
        a.append([rng.randint(0, 20)] if op == "enQueue" else [])
    return [o, a]

def edge():
    return [[["MyCircularQueue", "enQueue", "enQueue", "enQueue", "enQueue", "Rear", "isFull", "deQueue", "enQueue", "Rear"],
             [[3], [1], [2], [3], [4], [], [], [], [4], []]],
            [["MyCircularQueue", "Front", "Rear", "deQueue", "isEmpty", "enQueue", "isFull"], [[1], [], [], [], [], [5], []]]]

def random_case(rng):
    return ops(rng, rng.randint(1, 15), rng.randint(1, 4))
```
