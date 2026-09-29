---
lc: 232
title: "Implement Queue using Stacks"
difficulty: "Easy"
patterns: ["stack"]
lcTags: ["stack", "design", "queue"]
entry: {"method": "MyQueue", "design": true, "params": [{"name": "operations", "type": "string[]"}, {"name": "arguments", "type": "list"}], "returns": "list", "voids": ["push"]}
examples: ["[\"MyQueue\",\"push\",\"push\",\"peek\",\"pop\",\"empty\"]\n[[],[1],[2],[],[],[]]"]
---

Implement a first in first out (FIFO) queue using only two stacks. The implemented queue should support all the functions of a normal queue (`push`, `peek`, `pop`, and `empty`).

Implement the `MyQueue` class:

- `void push(int x)` Pushes element x to the back of the queue.
- `int pop()` Removes the element from the front of the queue and returns it.
- `int peek()` Returns the element at the front of the queue.
- `boolean empty()` Returns `true` if the queue is empty, `false` otherwise.

**Notes:**

- You must use **only** standard operations of a stack, which means only `push to top`, `peek/pop from top`, `size`, and `is empty` operations are valid.
- Depending on your language, the stack may not be supported natively. You may simulate a stack using a list or deque (double-ended queue) as long as you use only a stack's standard operations.

**Example 1:**

```
Input
["MyQueue", "push", "push", "peek", "pop", "empty"]
[[], [1], [2], [], [], []]
Output
[null, null, null, 1, 1, false]

Explanation
MyQueue myQueue = new MyQueue();
myQueue.push(1); // queue is: [1]
myQueue.push(2); // queue is: [1, 2] (leftmost is front of the queue)
myQueue.peek(); // return 1
myQueue.pop(); // return 1, queue is [2]
myQueue.empty(); // return false
```

**Constraints:**

- `1 <= x <= 9`
- At most `100` calls will be made to `push`, `pop`, `peek`, and `empty`.
- All the calls to `pop` and `peek` are valid.

**Follow-up:** Can you implement the queue such that each operation is **[amortized](https://en.wikipedia.org/wiki/Amortized_analysis)** `O(1)` time complexity? In other words, performing `n` operations will take overall `O(n)` time even if one of those operations may take longer.

# Starter

```python
class MyQueue:

    def __init__(self):
        

    def push(self, x: int) -> None:
        

    def pop(self) -> int:
        

    def peek(self) -> int:
        

    def empty(self) -> bool:
        

# Your MyQueue object will be instantiated and called as such:
# obj = MyQueue()
# obj.push(x)
# param_2 = obj.pop()
# param_3 = obj.peek()
# param_4 = obj.empty()
```

# Hints

1. A stack reverses order. What happens if you reverse twice?
2. Push into `inbox`. For pop/peek, if `outbox` is empty, move everything from inbox to outbox (reversing it), then use outbox's top.

# Key points

- two stacks: in for pushes, out for pops
- refill out only when it's empty → each element moves once
- amortized O(1) per operation

# Solution: double-stack · Double Stack · amortized O(1) · O(n) · reference

We use two stacks, where `stk1` is used for enqueue, and another stack `stk2` is used for dequeue.

When enqueueing, we directly push the element into `stk1`. The time complexity is O(1).

When dequeueing, we first check whether `stk2` is empty. If it is empty, we pop all elements from `stk1` and push them into `stk2`, and then pop an element from `stk2`. If `stk2` is not empty, we directly pop an element from `stk2`. The amortized time complexity is O(1).

When getting the front element, we first check whether `stk2` is empty. If it is empty, we pop all elements from `stk1` and push them into `stk2`, and then get the top element from `stk2`. If `stk2` is not empty, we directly get the top element from `stk2`. The amortized time complexity is O(1).

When checking whether the queue is empty, we only need to check whether both stacks are empty. The time complexity is O(1).

```python
class MyQueue:
    def __init__(self):
        self.stk1 = []
        self.stk2 = []

    def push(self, x: int) -> None:
        self.stk1.append(x)

    def pop(self) -> int:
        self.move()
        return self.stk2.pop()

    def peek(self) -> int:
        self.move()
        return self.stk2[-1]

    def empty(self) -> bool:
        return not self.stk1 and not self.stk2

    def move(self):
        if not self.stk2:
            while self.stk1:
                self.stk2.append(self.stk1.pop())

# Your MyQueue object will be instantiated and called as such:
# obj = MyQueue()
# obj.push(x)
# param_2 = obj.pop()
# param_3 = obj.peek()
# param_4 = obj.empty()
```

# Tests

```python
def ops(rng, n):
    o, a, size = ["MyQueue"], [[]], 0
    for _ in range(n):
        op = rng.choice(["push", "push", "pop", "peek", "empty"]) if size else rng.choice(["push", "empty"])
        o.append(op)
        a.append([rng.randint(1, 9)] if op == "push" else [])
        size += {"push": 1, "pop": -1}.get(op, 0)
    return [o, a]

def edge():
    return [[["MyQueue", "push", "push", "peek", "pop", "empty"], [[], [1], [2], [], [], []]],
            [["MyQueue", "empty", "push", "pop", "empty"], [[], [], [5], [], []]]]

def random_case(rng):
    return ops(rng, rng.randint(1, 15))
```
