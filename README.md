<p align="center">
  <img src="public/icon-192.png" width="96" alt="Recurse icon" />
</p>

<h1 align="center">Recurse</h1>

<p align="center">A personal, local-first app for learning data structures and algorithms in Python, one focused half hour a day.</p>

---

## What's inside

- **A full course:** 16 modules, 51 topics and 235 LeetCode problems, from Python basics through graphs and dynamic programming. Each topic has a short lesson, step-through visualizations and a quiz.
- **A local judge:** solve problems in the browser. Your Python runs against generated tests, with timing limits that catch slow solutions.
- **Learning that sticks:** a ladder of hints, spaced-repetition reviews, explain-back answers graded by Claude, and a Socratic tutor that asks questions instead of giving answers.
- **Honest progress:** time counts only while you're actively learning on a lesson or problem. A 30-minute daily goal feeds a day streak and a weekly streak, the weekly one with earned freezes.
- **Rewards for effort only:** XP and levels, boss fights at the end of each module, mystery chests, topic "Wrapped" cards, and real-world rewards unlocked by finishing modules.
- **Installable PWA:** app shortcuts, push reminders that pick their timing around your day, and a clear offline page when the local server is down.

## Stack

React 19, React Router and Tailwind v4 on the front end. Hono on Node 24 (running TypeScript directly) with SQLite (`node:sqlite`) on the back end. A Python judge, plus the `claude` CLI for AI grading and the tutor.

## Getting started

Requirements: Node 24+, Python 3 (the judge runs your code with it), and optionally the [`claude` CLI](https://claude.com/claude-code) for AI grading and the tutor.

```sh
npm install
npm run dev        # API on :3001 + Vite on :5173
```

Open http://localhost:5173.

### Daily use

For the installed PWA and reminders that arrive with the browser closed, run the built app all the time with the launchd agent. The plist has this machine's paths (project folder, Homebrew `node@24`, `~/.local/bin` for `claude`), so edit them first if yours differ.

```sh
npm run build
cp launchd/dev.akdevv.rcx.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/dev.akdevv.rcx.plist
```

It serves http://localhost:3000 and logs to `data/server.log`. Install the PWA from there and turn on reminders in Settings.

```sh
npm run build && launchctl kickstart -k gui/$(id -u)/dev.akdevv.rcx   # after changing app code
launchctl bootout gui/$(id -u)/dev.akdevv.rcx                          # stop it
```

Only this production server sends reminders, so running `npm run dev` alongside it never doubles them (`REMINDERS=1` forces them on in dev).

## Scripts

| Command           | What it does                                            |
| ----------------- | ------------------------------------------------------- |
| `npm run dev`     | Dev servers with hot reload                             |
| `npm run build`   | Production build into `dist/`                           |
| `npm start`       | Serve the built app (`PORT=3000` to match the agent)    |
| `npm run check`   | Type-check, lint, engine self-check, content validation |
| `npm run content` | Rebuild visualization traces and tests, then validate   |
| `npm run format`  | Prettier, except `courses/` (it would break problem.md) |

## Project layout

```
src/          React app (pages, components, activity tracker)
server/       Hono API, SQLite, engine (streaks, XP, spaced review), judge, AI, reminders
shared/       Types shared by client and server
courses/dsa/  The course: modules → topics (lesson, quiz, viz) → problems
scripts/      Content tooling: import problems and solutions, generate tests, build viz, validate
public/       Service worker, manifest, icons, offline page
launchd/      macOS agent that keeps the app running
```

Problems live in `courses/dsa/problems/<id>-<slug>/`, as a `problem.md` (statement, starter, hints, solutions, test generator) and a generated `tests.json`. See [`CLAUDE.md`](CLAUDE.md) for the full content format and conventions.

## Notes

- Everything runs locally, and progress is stored in `data/learn.db`, which git ignores.
- Problem statements are copied from LeetCode for personal study, and some solutions and explanations come from [doocs/leetcode](https://github.com/doocs/leetcode) (CC BY-SA 4.0). Keep this repo private.
