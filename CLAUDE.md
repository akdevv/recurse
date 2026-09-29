# Recurse (rcx): personal DSA learning tool (single user: akdevv)

The curriculum (16 modules, 51 topics, 235 problems) lives in `courses/dsa/`; it is the source of truth.

## Run

- `npm run dev`: API (node --watch, :3001) + Vite (:5173, proxies /api and /content)
- Daily use: the launchd agent runs the built app on http://localhost:3000 (installed PWA lives there). After changing app code: `npm run build`, then `launchctl kickstart -k gui/$(id -u)/dev.akdevv.rcx`
- `npm run build && npm start`: the same daily-use server by hand, on :3001 (use `PORT=3000` if the agent is stopped)
- Only production servers send reminders (`REMINDERS=1` forces them on in dev), so dev + the agent never double-notify
- `npm run check`: tsc + eslint + engine selfcheck + content validation
- `npm run content`: rebuild viz traces + tests.json, then validate
- Test against a throwaway DB: `DB_PATH=/tmp/x.db PORT=3998 node server/index.ts` (never test on `data/learn.db`, that's real progress)

## Layout

- `src/`: React 19 + react-router 8 + Tailwind v4 (dark only, shadcn-style tokens in `index.css`), icons from `react-icons/lu`. Pages in `src/pages`, layout and shared UI (`stat-cell`, `segmented`, `search-input`, `button`…) in `src/components/common`, the active-time tracker in `src/lib/activity.ts`, global state via `store()` in `src/lib/ui-state.ts`, difficulty colors in `src/lib/difficulty.ts`
  - Imports use `@/…` (src) and `@shared/…`, never `../..`. File names are kebab-case (`sidebar-layout.tsx`)
- `server/`: Hono on Node 24 (runs .ts directly, so imports need the `.ts` extension; no enums/param properties)
  - `engine/`: pure logic (streak, xp, srs, hints) + `selfcheck.ts`. Keep it free of DB/HTTP
  - `content.ts`: reads `courses/` from disk on every call (no restart needed after content edits)
  - `progress.ts`: completion / unlock / "me" derived from DB + content
  - `ai.ts`: every AI call (`claude -p`) goes through here: explain-back grading (Opus, `AI_MODEL`), Socratic tutor chat (Sonnet, `AI_TUTOR_MODEL`)
  - `chests.ts`: mystery chests (earned by boss wins / clean first solves, never bought), rewards incl. streak freezes passed to `computeStreak` as bonus freezes
  - `boss.ts` (module boss fights), `rewards.ts` (real-world reward path unlocked by finishing modules, tiered trophies), `stats.ts` (stats + patterns), `settings.ts` (settings table, defaults)
  - `notify.ts`: web-push reminder loop (one setTimeout, timing in `engine/reminders.ts`); VAPID keys in `data/vapid.json`
  - `judge/pyjudge.py`: Python judge core (used live and by scripts); `judge.ts` spawns it
  - `schema.sql`: SQLite via `node:sqlite`, DB at `data/learn.db` (gitignored)
- `shared/types.ts`: content + API types
- `public/`: `sw.js` (push + notification clicks; caches hashed `/assets` and shows `offline.html` when the server is down; never caches `/api` or `/content`), `manifest.webmanifest` (icons, maskable icons, shortcuts, screenshots), icon PNGs (Liquid Glass render of the Recurse icon), `avatar.svg`
- `launchd/`: agent that runs the built app at login on :3000 so reminders fire with the browser closed (logs: `data/server.log`). Install: `npm run build`, copy the plist to `~/Library/LaunchAgents/`, `launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/dev.akdevv.rcx.plist`
- `courses/dsa/`: all course content (format below)
- `scripts/`: python content tooling (`import_lc.py`, `gen_tests.py`, `build_viz.py`, `validate.py`; shared CLI/paths in `common.py`). `gen_tests` runs problems in parallel with `PYTHONHASHSEED=0`, so tests.json is reproducible

## Content format (courses/dsa)

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
  - Parsed by `pyjudge.load_problem` (Python) and `loadProblem` in `server/content.ts`; keep the two in sync
  - Exactly one solution is `reference`; `slow` = expected to fail perf tests. Compare modes: exact, unordered, groups (order-free at both levels), float (also lists), check (custom). Design problems (LRU cache, …): `entry.design`, `entry.method` = class name; void methods' return values are ignored like on LeetCode
  - Empty `# Tests` block → `scripts/autogen.py` builds inputs from `entry` types + the Constraints list; it refuses (gen_tests prints MANUAL) when a constraint promises structure (sorted, unique, BST, valid, graph…), then write the block by hand
  - `# Tests` code doubles as judge hooks (loaded when compare is "check" or `entry.interactive`): `check(args, got, expected)`, `prepare(args) -> (call_args, globals)` for cycles/shared nodes/APIs like isBadVersion, optional `output(ret)`
  - The judge pre-imports what LeetCode's Python does (collections, heapq, bisect, math, itertools, functools, operator, string, random); no numpy/sortedcontainers
  - A problem is playable once `tests.json` exists; imported-but-unauthored ones are listed but locked
- Adding a problem: `python3 scripts/import_lc.py <slug>` (or `--all` for every topic ref) → `python3 scripts/import_solutions.py <slug>` (solutions + explanations from doocs/leetcode, CC-BY-SA; uses `gh api` when available) → write hints, key points, and `# Tests` if autogen can't → `python3 scripts/gen_tests.py <slug>` → reference it in a topic.json
- Expected outputs always come from the reference solution, never written by hand

## Rules

- Every reward is tied to effort (solves, quiz improvement, explanations, reviews), never to time alone
- Active time counts only when the window is visible + focused + used; no timers while idle
- Never run prettier on `courses/` (it splits problem.md frontmatter, which must stay one `key: <json>` per line)
