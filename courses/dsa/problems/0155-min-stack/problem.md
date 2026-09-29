---
lc: 155
title: "Min Stack"
difficulty: "Medium"
patterns: ["stack"]
lcTags: ["stack", "design"]
entry: {"method": "MinStack", "design": true, "params": [{"name": "operations", "type": "string[]"}, {"name": "arguments", "type": "list"}], "returns": "list", "voids": ["push", "pop"]}
examples: ["[\"MinStack\",\"push\",\"push\",\"push\",\"getMin\",\"pop\",\"top\",\"getMin\"]\n[[],[-2],[0],[-3],[],[],[],[]]"]
lcHints: ["Consider each node in the stack having a minimum value. (Credits to @aakarshmadhavan)"]
---

Design a stack that supports push, pop, top, and retrieving the minimum element in constant time.

Implement the `MinStack` class:

- `MinStack()` initializes the stack object.
- `void push(int value)` pushes the element `value` onto the stack.
- `void pop()` removes the element on the top of the stack.
- `int top()` gets the top element of the stack.
- `int getMin()` retrieves the minimum element in the stack.

You must implement a solution with `O(1)` time complexity for each function.

**Example 1:**

```
Input
["MinStack","push","push","push","getMin","pop","top","getMin"]
[[],[-2],[0],[-3],[],[],[],[]]

Output
[null,null,null,null,-3,null,0,-2]

Explanation
MinStack minStack = new MinStack();
minStack.push(-2);
minStack.push(0);
minStack.push(-3);
minStack.getMin(); // return -3
minStack.pop();
minStack.top();    // return 0
minStack.getMin(); // return -2
```

**Constraints:**

- `-2³¹ <= val <= 2³¹ - 1`
- Methods `pop`, `top` and `getMin` operations will always be called on **non-empty** stacks.
- At most `3 * 10⁴` calls will be made to `push`, `pop`, `top`, and `getMin`.

# Starter

```python
class MinStack:

    def __init__(self):
        

    def push(self, value: int) -> None:
        

    def pop(self) -> None:
        

    def top(self) -> int:
        

    def getMin(self) -> int:
        

# Your MinStack object will be instantiated and called as such:
# obj = MinStack()
# obj.push(value)
# obj.pop()
# param_3 = obj.top()
# param_4 = obj.getMin()
```

# Hints

1. The minimum can change when you pop. What if every stack entry also remembered the minimum at that moment?
2. Push pairs (value, min so far) or keep a second stack of minimums. getMin reads the top's stored minimum.

# Key points

- store the running minimum alongside each value
- pop removes both, so the previous minimum comes back automatically
- every operation O(1)

# Solution: solution-1 · Auxiliary stack of minimums · O(1) per operation · O(n) · reference

## Idea
A second stack stores, for every level, the minimum of everything at or below it. Push stores `min(val, current min)`, pop removes from both, so `getMin` is always the top of the second stack.

## Complexity
- **Time: O(1) per operation**
- **Space: O(n)**

```python
class MinStack:
    def __init__(self):
        self.stk1 = []
        self.stk2 = [inf]

    def push(self, val: int) -> None:
        self.stk1.append(val)
        self.stk2.append(min(val, self.stk2[-1]))

    def pop(self) -> None:
        self.stk1.pop()
        self.stk2.pop()

    def top(self) -> int:
        return self.stk1[-1]

    def getMin(self) -> int:
        return self.stk2[-1]

# Your MinStack object will be instantiated and called as such:
# obj = MinStack()
# obj.push(val)
# obj.pop()
# param_3 = obj.top()
# param_4 = obj.getMin()
```

# Tests

```python
def ops(rng, n, lo, hi):
    o, a, size = ["MinStack"], [[]], 0
    for _ in range(n):
        op = rng.choice(["push", "push", "pop", "top", "getMin"]) if size else "push"
        o.append(op)
        a.append([rng.randint(lo, hi)] if op == "push" else [])
        size += {"push": 1, "pop": -1}.get(op, 0)
    return [o, a]

def edge():
    return [[["MinStack", "push", "push", "push", "getMin", "pop", "top", "getMin"], [[], [-2], [0], [-3], [], [], [], []]],
            [["MinStack", "push", "push", "getMin", "pop", "getMin"], [[], [1], [1], [], [], []]],
            [["MinStack", "push", "getMin", "top"], [[], [-2**31], [], []]]]

def random_case(rng):
    return ops(rng, rng.randint(1, 15), -5, 5)

def perf(rng):
    return [ops(rng, 30000, -2**31, 2**31 - 1)]
```
