## Core idea

**A stack is last in, first out (LIFO): you only ever touch the top.** Use one whenever the thing you need next is the *most recent* thing you haven't dealt with yet: the last unmatched bracket, the last number waiting for an operator, the last character that might be cancelled.

## Intuition

A stack of plates. You put plates on top and take them off the top. You'd never pull one from the middle.

Undo in a text editor works the same way: the last action is the first one undone. And every time a function calls another function, the computer pushes a frame onto the **call stack**, which is why recursion and stacks are two views of the same thing.

## Visualization

Matching brackets: each closer must match the most recent opener that's still open.

```viz
brackets
```

Reverse Polish notation: an operator always applies to the two most recent values.

```viz
rpn
```

## Template code

```python
stack = []                    # a Python list is a perfect stack
stack.append(x)               # push, O(1)
top = stack[-1]               # peek, O(1)
stack.pop()                   # pop, O(1)
if not stack: ...             # empty?

# Matching pairs
pairs = {")": "(", "]": "[", "}": "{"}
for c in s:
    if c in pairs:
        if not stack or stack.pop() != pairs[c]:
            return False
    else:
        stack.append(c)
return not stack

# Cancel adjacent duplicates / backspaces
for c in s:
    if stack and stack[-1] == c:
        stack.pop()
    else:
        stack.append(c)

# Min stack: store the running minimum with each value
stack.append((x, min(x, stack[-1][1] if stack else x)))

# Nested structure (Decode String): push the outer context at "[", pop at "]"
```

## Complexity

| Operation | Cost |
|---|---|
| push / pop / peek on a Python list | O(1) (amortized for push) |
| processing a string of n characters with a stack | O(n) time, O(n) space |
| getMin with a min-stack | O(1) |

## When to use it

- **Matching pairs, nesting, "valid parentheses"** → push openers, pop on closers
- **"Most recent" / undo / cancel the previous** → stack
- **Expression evaluation, RPN, calculators** → operand stack (plus operator stack for infix)
- **Nested encodings like `3[a2[c]]`** → push the outer state when a level opens
- **O(1) minimum alongside push/pop** → store the minimum with each entry
- **Queue from stacks** → two stacks, move items only when the out-stack is empty
- **Recursion you want to make iterative** → an explicit stack

## Common traps

- Popping or peeking an empty stack: check `if stack` first
- Returning True at the end without checking the stack is empty (`"(("` is invalid)
- RPN operand order: the first pop is the *right* operand (`a - b`, not `b - a`)
- Division in RPN must truncate toward zero: `int(a / b)`, not `a // b`
- Multi-digit numbers in parsing: build them with `num = num * 10 + d`
