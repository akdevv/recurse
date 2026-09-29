import json

k = 4
buf = ["·"] * k
head = count = 0
steps = [{"array": list(buf), "pointers": {"head": 0}, "highlight": [], "vars": {"count": 0},
          "caption": f"Circular queue of size {k}: a fixed array plus head and count. Indexes wrap around with % {k}."}]
def snap(cap, extra=None):
    tail = (head + count - 1) % k if count else None
    ptr = {"head": head, **({"tail": tail} if tail is not None else {})}
    hl = [(head + j) % k for j in range(count)]
    steps.append({"array": list(buf), "pointers": ptr, "highlight": hl, "vars": {"count": count, **(extra or {})}, "caption": cap})
for op, v in [("enq", 1), ("enq", 2), ("enq", 3), ("deq", None), ("deq", None), ("enq", 4), ("enq", 5), ("enq", 6)]:
    if op == "enq":
        if count == k:
            snap(f"enQueue({v}): count == {k}, the queue is full. Return False.")
            continue
        pos = (head + count) % k
        buf[pos] = v
        count += 1
        snap(f"enQueue({v}): write at (head + count) % {k} = {pos}." + (" It wrapped around to the front of the array." if pos < head else ""))
    else:
        out = buf[head]
        buf[head] = "·"
        head = (head + 1) % k
        count -= 1
        snap(f"deQueue(): remove {out} at the front, head = (head + 1) % {k} = {head}. Nothing shifts.")
print(json.dumps({"title": "A circular queue: fixed array, wrapping indexes", "view": "array", "steps": steps}))
