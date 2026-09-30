# Course content

`courses/dsa/` is the curriculum and the source of truth. Run the tooling from the repo root:

- `python3 scripts/build_viz.py && python3 scripts/gen_tests.py && python3 scripts/validate.py`: rebuild viz traces and tests.json, then validate
- `gen_tests` runs problems in parallel with `PYTHONHASHSEED=0`, so tests.json is reproducible
- Never run prettier here (it splits problem.md frontmatter, which must stay one `key: <json>` per line)

## Format

- IDs are slugs and are **never renamed** (progress is keyed by them). Order lives in parent lists, not folder names
- `course.json` → `modules/<id>/module.json` (prereqs, ordered topics) → `topics/<id>/topic.json`
- Topic `status`: `stub` (skeleton only) | `ready` (needs lesson.md, quiz.json, problems exist)
- `lesson.md` sections: Core idea, Intuition, Visualization, Template code, Complexity, When to use it, Common traps.
  Embed a viz with a fenced block: ` ```viz\n<name>\n``` ` → `viz/<name>.py` prints a trace JSON → `scripts/build_viz.py` writes `viz/<name>.json`.
  Views: `array` (array, pointers, highlight, dim, vars; optional `stack` + `stackLabel` drawn beside it), `stack` (stack, stackLabel),
  `tree` (nodes {id, label, parent, hidden?}, active, highlight, values: shown inline for call labels like `fib(3)`, else as a tag under the node; `highlight` wins over values for styling),
  `grid` (grid, highlight/dim as [r, c], pointers name → [r, c]; `compact: true` for small cells; a "█" cell renders filled, for timelines),
  `list` (nodes = values, links[i] = next index or null, pointers, highlight, dim; cycles are listed below the row),
  `graph` (nodes {id, label?, x, y} in grid units, edges {from, to, w?}, directed, active, highlight, dim, edgeHighlight [[from, to]], values: tag at a node's top-right)
  Tree viz scripts can import `courses/dsa/vizlib.py` (build a tree from LeetCode level order, lay it out with hidden placeholders)
- Problems live in a shared pool `problems/<lc id>-<slug>/` (e.g. `0001-two-sum/`); the problem id is the slug. Referenced by topics with a role (guided|core|optional). Two files:
  - `problem.md`: frontmatter (`key: <json>` per line: lc, title, difficulty, patterns, lcTags, entry, examples, optional compare/timeLimitMs/lcHints), then the statement (markdown), then `# Starter`, `# Hints` (numbered), `# Key points` (bullets), one `# Solution: <id> · <title> · <time> · <space> · [reference] [slow]` per solution (explanation, then the code as the last ```python block), `# Tests` (python: `edge()`, `random_case(rng)`, optional `perf(rng)`)
  - `tests.json`: generated, never edited
  - Parsed by `pyjudge.load_problem` (Python) and the parser in `mac/Sources/Recurse/Core/Content.swift`; keep the two in sync
  - Exactly one solution is `reference`; `slow` = expected to fail perf tests. Compare modes: exact, unordered, groups (order-free at both levels), float (also lists), check (custom). Design problems (LRU cache, …): `entry.design`, `entry.method` = class name; void methods' return values are ignored like on LeetCode
  - Empty `# Tests` block → `scripts/autogen.py` builds inputs from `entry` types + the Constraints list; it refuses (gen_tests prints MANUAL) when a constraint promises structure (sorted, unique, BST, valid, graph…), then write the block by hand
  - `# Tests` code doubles as judge hooks (loaded when compare is "check" or `entry.interactive`): `check(args, got, expected)`, `prepare(args) -> (call_args, globals)` for cycles/shared nodes/APIs like isBadVersion, optional `output(ret)`
  - The judge pre-imports what LeetCode's Python does (collections, heapq, bisect, math, itertools, functools, operator, string, random); no numpy/sortedcontainers
  - A problem is playable once `tests.json` exists; imported-but-unauthored ones are listed but locked
- Adding a problem: `python3 scripts/import_lc.py <slug>` (or `--all` for every topic ref) → `python3 scripts/import_solutions.py <slug>` (solutions + explanations from doocs/leetcode, CC-BY-SA; uses `gh api` when available) → write hints, key points, and `# Tests` if autogen can't → `python3 scripts/gen_tests.py <slug>` → reference it in a topic.json
- Expected outputs always come from the reference solution, never written by hand

