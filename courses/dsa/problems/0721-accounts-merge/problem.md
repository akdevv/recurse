---
lc: 721
title: "Accounts Merge"
difficulty: "Medium"
patterns: ["union-find"]
lcTags: ["array", "hash-table", "string", "depth-first-search", "breadth-first-search", "union-find", "sorting"]
compare: "unordered"
entry: {"method": "accountsMerge", "params": [{"name": "accounts", "type": "list<list<string>>"}], "returns": "list<list<string>>"}
examples: ["[[\"John\",\"johnsmith@mail.com\",\"john_newyork@mail.com\"],[\"John\",\"johnsmith@mail.com\",\"john00@mail.com\"],[\"Mary\",\"mary@mail.com\"],[\"John\",\"johnnybravo@mail.com\"]]", "[[\"Gabe\",\"Gabe0@m.co\",\"Gabe3@m.co\",\"Gabe1@m.co\"],[\"Kevin\",\"Kevin3@m.co\",\"Kevin5@m.co\",\"Kevin0@m.co\"],[\"Ethan\",\"Ethan5@m.co\",\"Ethan4@m.co\",\"Ethan0@m.co\"],[\"Hanzo\",\"Hanzo3@m.co\",\"Hanzo1@m.co\",\"Hanzo0@m.co\"],[\"Fern\",\"Fern5@m.co\",\"Fern1@m.co\",\"Fern0@m.co\"]]"]
lcHints: ["For every pair of emails in the same account, draw an edge between those emails.  The problem is about enumerating the connected components of this graph."]
---

Given a list of `accounts` where each element `accounts[i]` is a list of strings, where the first element `accounts[i][0]` is a name, and the rest of the elements are **emails** representing emails of the account.

Now, we would like to merge these accounts. Two accounts definitely belong to the same person if there is some common email to both accounts. Note that even if two accounts have the same name, they may belong to different people as people could have the same name. A person can have any number of accounts initially, but all of their accounts definitely have the same name.

After merging the accounts, return the accounts in the following format: the first element of each account is the name, and the rest of the elements are emails **in sorted order**. The accounts themselves can be returned in **any order**.

**Example 1:**

```
Input: accounts = [["John","johnsmith@mail.com","john_newyork@mail.com"],["John","johnsmith@mail.com","john00@mail.com"],["Mary","mary@mail.com"],["John","johnnybravo@mail.com"]]
Output: [["John","john00@mail.com","john_newyork@mail.com","johnsmith@mail.com"],["Mary","mary@mail.com"],["John","johnnybravo@mail.com"]]
Explanation:
The first and second John's are the same person as they have the common email "johnsmith@mail.com".
The third John and Mary are different people as none of their email addresses are used by other accounts.
We could return these lists in any order, for example the answer [['Mary', 'mary@mail.com'], ['John', 'johnnybravo@mail.com'],
['John', 'john00@mail.com', 'john_newyork@mail.com', 'johnsmith@mail.com']] would still be accepted.
```

**Example 2:**

```
Input: accounts = [["Gabe","Gabe0@m.co","Gabe3@m.co","Gabe1@m.co"],["Kevin","Kevin3@m.co","Kevin5@m.co","Kevin0@m.co"],["Ethan","Ethan5@m.co","Ethan4@m.co","Ethan0@m.co"],["Hanzo","Hanzo3@m.co","Hanzo1@m.co","Hanzo0@m.co"],["Fern","Fern5@m.co","Fern1@m.co","Fern0@m.co"]]
Output: [["Ethan","Ethan0@m.co","Ethan4@m.co","Ethan5@m.co"],["Gabe","Gabe0@m.co","Gabe1@m.co","Gabe3@m.co"],["Hanzo","Hanzo0@m.co","Hanzo1@m.co","Hanzo3@m.co"],["Kevin","Kevin0@m.co","Kevin3@m.co","Kevin5@m.co"],["Fern","Fern0@m.co","Fern1@m.co","Fern5@m.co"]]
```

**Constraints:**

- `1 <= accounts.length <= 1000`
- `2 <= accounts[i].length <= 10`
- `1 <= accounts[i][j].length <= 30`
- `accounts[i][0]` consists of English letters.
- `accounts[i][j] (for j > 0)` is a valid email.

# Starter

```python
class Solution:
    def accountsMerge(self, accounts: list[list[str]]) -> list[list[str]]:
        
```

# Hints

1. Two accounts belong to the same person if they share an email. That's connected components over emails.
2. Union-find over emails: union all emails of each account with its first email. Then group emails by root, sort each group, and prefix the owner's name.

# Key points

- union-find (or DFS) over emails, not names (names can repeat)
- map email → name to label each group
- sort the emails inside each account
- O(N log N) for the sorting, N = total emails

# Solution: union-find-hash-table · Union-Find + Hash Table · O(n × log n) · O(n) · reference

Based on the problem description, we can use a union-find data structure to merge accounts with the same email address. The specific steps are as follows:

First, we iterate through all the accounts. For the ith account, we iterate through all its email addresses. If an email address appears in the hash table d, we use the union-find to merge the account's index i with the previously appeared account's index; otherwise, we map this email address to the account's index i.

Next, we iterate through all the accounts again. For the ith account, we use the union-find to find its root node, and then add all the email addresses of that account to the hash table g, where the key is the root node, and the value is the account's email addresses.

The time complexity is O(n × log n), and the space complexity is O(n). Here, n is the number of accounts.

```python
class UnionFind:
    def __init__(self, n):
        self.p = list(range(n))
        self.size = [1] * n

    def find(self, x):
        if self.p[x] != x:
            self.p[x] = self.find(self.p[x])
        return self.p[x]

    def union(self, a, b):
        pa, pb = self.find(a), self.find(b)
        if pa == pb:
            return False
        if self.size[pa] > self.size[pb]:
            self.p[pb] = pa
            self.size[pa] += self.size[pb]
        else:
            self.p[pa] = pb
            self.size[pb] += self.size[pa]
        return True

class Solution:
    def accountsMerge(self, accounts: List[List[str]]) -> List[List[str]]:
        uf = UnionFind(len(accounts))
        d = {}
        for i, (_, *emails) in enumerate(accounts):
            for email in emails:
                if email in d:
                    uf.union(i, d[email])
                else:
                    d[email] = i
        g = defaultdict(set)
        for i, (_, *emails) in enumerate(accounts):
            root = uf.find(i)
            g[root].update(emails)
        return [[accounts[root][0]] + sorted(emails) for root, emails in g.items()]
```

# Tests

```python
def edge():
    return [[[["John", "johnsmith@mail.com", "john_newyork@mail.com"], ["John", "johnsmith@mail.com", "john00@mail.com"], ["Mary", "mary@mail.com"], ["John", "johnnybravo@mail.com"]]],
            [[["A", "a@m.co"]]], [[["A", "a@m.co"], ["A", "b@m.co"], ["A", "c@m.co", "a@m.co", "b@m.co"]]]]

def random_case(rng):
    people = rng.randint(1, 3)
    accts = []
    for p in range(people):
        pool = [f"p{p}e{i}@m.co" for i in range(4)]
        for _ in range(rng.randint(1, 3)):
            accts.append([f"N{p}"] + rng.sample(pool, rng.randint(1, 3)))
    rng.shuffle(accts)
    return [accts]

def perf(rng):
    return [[[["N" + str(i % 50), f"e{i}@m.co", f"e{i + 1}@m.co"] for i in range(1000)]]]
```
