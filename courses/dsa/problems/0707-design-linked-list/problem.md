---
lc: 707
title: "Design Linked List"
difficulty: "Medium"
patterns: ["list-reversal"]
lcTags: ["linked-list", "design"]
entry: {"method": "MyLinkedList", "design": true, "params": [{"name": "operations", "type": "string[]"}, {"name": "arguments", "type": "list"}], "returns": "list", "voids": ["addAtHead", "addAtTail", "addAtIndex", "deleteAtIndex"]}
examples: ["[\"MyLinkedList\",\"addAtHead\",\"deleteAtIndex\",\"addAtTail\",\"get\"]\n[[],[1],[0],[2],[0]]"]
---

Design your implementation of the linked list. You can choose to use a singly or doubly linked list.<br> A node in a singly linked list should have two attributes: `val` and `next`. `val` is the value of the current node, and `next` is a pointer/reference to the next node.<br> If you want to use the doubly linked list, you will need one more attribute `prev` to indicate the previous node in the linked list. Assume all nodes in the linked list are **0-indexed**.

Implement the `MyLinkedList` class:

- `MyLinkedList()` Initializes the `MyLinkedList` object.
- `int get(int index)` Get the value of the `indexᵗʰ` node in the linked list. If the index is invalid, return `-1`.
- `void addAtHead(int val)` Add a node of value `val` before the first element of the linked list. After the insertion, the new node will be the first node of the linked list.
- `void addAtTail(int val)` Append a node of value `val` as the last element of the linked list.
- `void addAtIndex(int index, int val)` Add a node of value `val` before the `indexᵗʰ` node in the linked list. If `index` equals the length of the linked list, the node will be appended to the end of the linked list. If `index` is greater than the length, the node **will not be inserted**.
- `void deleteAtIndex(int index)` Delete the `indexᵗʰ` node in the linked list, if the index is valid.

**Example 1:**

```
Input
["MyLinkedList", "addAtHead", "addAtTail", "addAtIndex", "get", "deleteAtIndex", "get"]
[[], [1], [3], [1, 2], [1], [1], [1]]
Output
[null, null, null, null, 2, null, 3]

Explanation
MyLinkedList myLinkedList = new MyLinkedList();
myLinkedList.addAtHead(1);
myLinkedList.addAtTail(3);
myLinkedList.addAtIndex(1, 2);    // linked list becomes 1->2->3
myLinkedList.get(1);              // return 2
myLinkedList.deleteAtIndex(1);    // now the linked list is 1->3
myLinkedList.get(1);              // return 3
```

**Constraints:**

- `0 <= index, val <= 1000`
- Please do not use the built-in LinkedList library.
- At most `2000` calls will be made to `get`, `addAtHead`, `addAtTail`, `addAtIndex` and `deleteAtIndex`.

# Starter

```python
class MyLinkedList:

    def __init__(self):
        

    def get(self, index: int) -> int:
        

    def addAtHead(self, val: int) -> None:
        

    def addAtTail(self, val: int) -> None:
        

    def addAtIndex(self, index: int, val: int) -> None:
        

    def deleteAtIndex(self, index: int) -> None:
        

# Your MyLinkedList object will be instantiated and called as such:
# obj = MyLinkedList()
# param_1 = obj.get(index)
# obj.addAtHead(val)
# obj.addAtTail(val)
# obj.addAtIndex(index,val)
# obj.deleteAtIndex(index)
```

# Hints

1. Store a size counter so you can reject bad indexes quickly. Which operations become the same thing?
2. With a dummy head, addAtHead is addAtIndex(0) and addAtTail is addAtIndex(size). To act at index i, walk i steps from the dummy to reach the node before position i.

# Key points

- a dummy head node + size counter
- addAtHead / addAtTail are addAtIndex(0) / addAtIndex(size)
- walk to the node *before* the index to insert or delete
- invalid index: get returns -1, add/delete do nothing
- O(index) per operation

# Solution: solution-1 · Dummy node + size · O(index) per operation · O(n) · reference

## Idea
A dummy head plus a size counter. Every operation walks from the dummy to the node before the target position; head and tail inserts are just `addAtIndex(0)` and `addAtIndex(size)`. Out-of-range indexes are ignored or return −1.

## Complexity
- **Time: O(index) per operation**
- **Space: O(n)**

```python
class MyLinkedList:
    def __init__(self):
        self.dummy = ListNode()
        self.cnt = 0

    def get(self, index: int) -> int:
        if index < 0 or index >= self.cnt:
            return -1
        cur = self.dummy.next
        for _ in range(index):
            cur = cur.next
        return cur.val

    def addAtHead(self, val: int) -> None:
        self.addAtIndex(0, val)

    def addAtTail(self, val: int) -> None:
        self.addAtIndex(self.cnt, val)

    def addAtIndex(self, index: int, val: int) -> None:
        if index > self.cnt:
            return
        pre = self.dummy
        for _ in range(index):
            pre = pre.next
        pre.next = ListNode(val, pre.next)
        self.cnt += 1

    def deleteAtIndex(self, index: int) -> None:
        if index >= self.cnt:
            return
        pre = self.dummy
        for _ in range(index):
            pre = pre.next
        t = pre.next
        pre.next = t.next
        t.next = None
        self.cnt -= 1

# Your MyLinkedList object will be instantiated and called as such:
# obj = MyLinkedList()
# param_1 = obj.get(index)
# obj.addAtHead(val)
# obj.addAtTail(val)
# obj.addAtIndex(index,val)
# obj.deleteAtIndex(index)
```

# Solution: solution-2 · Static arrays as a linked list · O(index) per operation · O(n)

## Idea
Simulates a linked list with arrays: `e[i]` holds a value and `ne[i]` the index of the next node, with `head` pointing to the first one. Operations walk the `ne` links exactly like pointers.

## Complexity
- **Time: O(index) per operation**
- **Space: O(n)**

```python
class MyLinkedList:
    def __init__(self):
        self.e = [0] * 1010
        self.ne = [0] * 1010
        self.idx = 0
        self.head = -1
        self.cnt = 0

    def get(self, index: int) -> int:
        if index < 0 or index >= self.cnt:
            return -1
        i = self.head
        for _ in range(index):
            i = self.ne[i]
        return self.e[i]

    def addAtHead(self, val: int) -> None:
        self.e[self.idx] = val
        self.ne[self.idx] = self.head
        self.head = self.idx
        self.idx += 1
        self.cnt += 1

    def addAtTail(self, val: int) -> None:
        self.addAtIndex(self.cnt, val)

    def addAtIndex(self, index: int, val: int) -> None:
        if index > self.cnt:
            return
        if index <= 0:
            self.addAtHead(val)
            return
        i = self.head
        for _ in range(index - 1):
            i = self.ne[i]
        self.e[self.idx] = val
        self.ne[self.idx] = self.ne[i]
        self.ne[i] = self.idx
        self.idx += 1
        self.cnt += 1

    def deleteAtIndex(self, index: int) -> None:
        if index < 0 or index >= self.cnt:
            return -1
        self.cnt -= 1
        if index == 0:
            self.head = self.ne[self.head]
            return
        i = self.head
        for _ in range(index - 1):
            i = self.ne[i]
        self.ne[i] = self.ne[self.ne[i]]

# Your MyLinkedList object will be instantiated and called as such:
# obj = MyLinkedList()
# param_1 = obj.get(index)
# obj.addAtHead(val)
# obj.addAtTail(val)
# obj.addAtIndex(index,val)
# obj.deleteAtIndex(index)
```

# Tests

```python
def edge():
    return [[["MyLinkedList", "addAtHead", "addAtTail", "addAtIndex", "get", "deleteAtIndex", "get"],
             [[], [1], [3], [1, 2], [1], [1], [1]]],
            [["MyLinkedList", "get", "deleteAtIndex", "addAtIndex", "get"], [[], [0], [0], [1, 5], [0]]]]

def random_case(rng):
    ops, args, size = ["MyLinkedList"], [[]], 0
    for _ in range(rng.randint(1, 15)):
        op = rng.choice(["get", "addAtHead", "addAtTail", "addAtIndex", "deleteAtIndex"])
        i = rng.randint(0, size + 1)
        if op == "get":
            args.append([i])
        elif op in ("addAtHead", "addAtTail"):
            args.append([rng.randint(0, 20)])
            size += 1
        elif op == "addAtIndex":
            args.append([i, rng.randint(0, 20)])
            size += i <= size
        else:
            args.append([i])
            size -= i < size
        ops.append(op)
    return [ops, args]

def perf(rng):
    ops, args = ["MyLinkedList"], [[]]
    for k in range(1000):
        ops += ["addAtTail", "get"]
        args += [[k], [k // 2]]
    return [[ops, args]]
```
