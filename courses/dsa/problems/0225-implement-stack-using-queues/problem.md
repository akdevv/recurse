---
lc: 225
title: "Implement Stack using Queues"
difficulty: "Easy"
patterns: ["stack"]
lcTags: ["stack", "design", "queue"]
entry: {"method": "MyStack", "design": true, "params": [{"name": "operations", "type": "string[]"}, {"name": "arguments", "type": "list"}], "returns": "list"}
examples: ["[\"MyStack\",\"push\",\"push\",\"top\",\"pop\",\"empty\"]\n[[],[1],[2],[],[],[]]"]
---

Implement a last-in-first-out (LIFO) stack using only two queues. The implemented stack should support all the functions of a normal stack (`push`, `top`, `pop`, and `empty`).

Implement the `MyStack` class:

- `void push(int x)` Pushes element x to the top of the stack.
- `int pop()` Removes the element on the top of the stack and returns it.
- `int top()` Returns the element on the top of the stack.
- `boolean empty()` Returns `true` if the stack is empty, `false` otherwise.

**Notes:**

- You must use **only** standard operations of a queue, which means that only `push to back`, `peek/pop from front`, `size` and `is empty` operations are valid.
- Depending on your language, the queue may not be supported natively. You may simulate a queue using a list or deque (double-ended queue) as long as you use only a queue's standard operations.

**Example 1:**

```
Input
["MyStack", "push", "push", "top", "pop", "empty"]
[[], [1], [2], [], [], []]
Output
[null, null, null, 2, 2, false]

Explanation
MyStack myStack = new MyStack();
myStack.push(1);
myStack.push(2);
myStack.top(); // return 2
myStack.pop(); // return 2
myStack.empty(); // return False
```

**Constraints:**

- `1 <= x <= 9`
- At most `100` calls will be made to `push`, `pop`, `top`, and `empty`.
- All the calls to `pop` and `top` are valid.

**Follow-up:** Can you implement the stack using only one queue?

# Starter

```python
class MyStack:

    def __init__(self):
        

    def push(self, x: int) -> None:
        

    def pop(self) -> int:
        

    def top(self) -> int:
        

    def empty(self) -> bool:
        

# Your MyStack object will be instantiated and called as such:
# obj = MyStack()
# obj.push(x)
# param_2 = obj.pop()
# param_3 = obj.top()
# param_4 = obj.empty()
```

# Hints

1. A queue only gives you the oldest element. How can you make the newest element the oldest?
2. After pushing x, rotate the queue: pop from the front and push to the back size − 1 times. Now x is at the front, so pop/top are O(1).

# Key points

- one queue: after each push, rotate the older elements behind the new one
- push O(n), pop/top/empty O(1)
- use collections.deque with append / popleft only

# Solution: two-queues · Two Queues · O(n) · O(n) · reference

We use two queues q_1 and q_2, where q_1 is used to store the elements in the stack, and q_2 is used to assist in implementing the stack operations.

- `push` operation: Push the element into q_2, then pop the elements in q_1 one by one and push them into q_2, finally swap the references of q_1 and q_2. The time complexity is O(n).
- `pop` operation: Directly pop the front element of q_1. The time complexity is O(1).
- `top` operation: Directly return the front element of q_1. The time complexity is O(1).
- `empty` operation: Check whether q_1 is empty. The time complexity is O(1).

The space complexity is O(n), where n is the number of elements in the stack.

```python
class MyStack:
    def __init__(self):
        self.q1 = deque()
        self.q2 = deque()

    def push(self, x: int) -> None:
        self.q2.append(x)
        while self.q1:
            self.q2.append(self.q1.popleft())
        self.q1, self.q2 = self.q2, self.q1

    def pop(self) -> int:
        return self.q1.popleft()

    def top(self) -> int:
        return self.q1[0]

    def empty(self) -> bool:
        return len(self.q1) == 0

# Your MyStack object will be instantiated and called as such:
# obj = MyStack()
# obj.push(x)
# param_2 = obj.pop()
# param_3 = obj.top()
# param_4 = obj.empty()
```

# Tests

```python
def ops(rng, n):
    o, a, size = ["MyStack"], [[]], 0
    for _ in range(n):
        op = rng.choice(["push", "push", "pop", "top", "empty"]) if size else rng.choice(["push", "empty"])
        o.append(op)
        a.append([rng.randint(1, 9)] if op == "push" else [])
        size += {"push": 1, "pop": -1}.get(op, 0)
    return [o, a]

def edge():
    return [[["MyStack", "push", "push", "top", "pop", "empty"], [[], [1], [2], [], [], []]],
            [["MyStack", "empty", "push", "pop", "empty"], [[], [], [3], [], []]]]

def random_case(rng):
    return ops(rng, rng.randint(1, 15))
```
