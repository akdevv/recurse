---
lc: 190
title: "Reverse Bits"
difficulty: "Easy"
patterns: ["bit-manipulation"]
lcTags: ["divide-and-conquer", "bit-manipulation"]
entry: {"method": "reverseBits", "params": [{"name": "n", "type": "integer"}], "returns": "integer"}
examples: ["43261596", "2147483644"]
---

Reverse bits of a given 32 bits signed integer.

**Example 1:**

**Input:** n = 43261596

**Output:** 964176192

**Explanation:**

<table>
	<tbody>
		<tr>
			<th>Integer</th>
			<th>Binary</th>
		</tr>
		<tr>
			<td>43261596</td>
			<td>00000010100101000001111010011100</td>
		</tr>
		<tr>
			<td>964176192</td>
			<td>00111001011110000010100101000000</td>
		</tr>
	</tbody>
</table>

**Example 2:**

**Input:** n = 2147483644

**Output:** 1073741822

**Explanation:**

<table>
	<tbody>
		<tr>
			<th>Integer</th>
			<th>Binary</th>
		</tr>
		<tr>
			<td>2147483644</td>
			<td>01111111111111111111111111111100</td>
		</tr>
		<tr>
			<td>1073741822</td>
			<td>00111111111111111111111111111110</td>
		</tr>
	</tbody>
</table>

**Constraints:**

- `0 <= n <= 2³¹ - 2`
- `n` is even.

**Follow up:** If this function is called many times, how would you optimize it?

# Starter

```python
class Solution:
    def reverseBits(self, n: int) -> int:
        
```

# Hints

1. Build the result bit by bit: take the lowest bit of n and push it into the result from the right.
2. Repeat 32 times: res = (res << 1) | (n & 1); n >>= 1.

# Key points

- 32 iterations, shift result left, add n's lowest bit, shift n right
- exactly 32 bits, including leading zeros
- O(1) time

# Solution: bit-manipulation · Bit Manipulation · O(log n) · O(1) · reference

We can extract each bit of n from the lowest bit to the highest bit, and then place it at the corresponding position of ans.

For example, for the i-th bit, we can extract the i-th bit of n and place it at the `(31 - i)`-th bit of ans by `(n & 1) \ll (31 - i)`, and then right shift n by one bit.

The time complexity is O(log n), and the space complexity is O(1).

```python
class Solution:
    def reverseBits(self, n: int) -> int:
        ans = 0
        for i in range(32):
            ans |= (n & 1) << (31 - i)
            n >>= 1
        return ans
```

# Tests

```python
def edge():
    return [[0], [2], [43261596], [2147483644], [2**31 - 2]]

def random_case(rng):
    return [rng.randint(0, 2**30 - 1) * 2]
```
