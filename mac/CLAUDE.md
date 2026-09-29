# Recurse Mac app

Native SwiftUI port of the web app (SwiftPM, macOS 15+, no dependencies). Run commands from `mac/`.

## Run

- `swift build && swift run`: debug build (opens in Xcode too: `open Package.swift`)
- `./build-app.sh [--open]`: release `build/Recurse.app` (icon from `web/public/icon-512.png`, ad-hoc signed)
- `swift test`: engine checks (mirror `web/server/engine/selfcheck.ts`), problem.md parser over every problem, judge + solve/boss/chest/reward flows on a temp DB (boss AI grading isn't covered), every viz step renders
- Throwaway DB: `DB_PATH=/tmp/x.db swift run`. Screenshots without Screen Recording permission: `open -n -W --env DB_PATH=… --env RECURSE_SNAPSHOT=<dir> --env RECURSE_ROUTES="today,review,course,rewards:<path|trophies|chests>,boss:<module>,topic:<id>,problem:<id>" build/Recurse.app` writes one PNG per route, then quits
- `VIZ_OUT=<dir> swift test --filter everyVizRenders`: PNG of every viz trace's middle step

## Data

- Own DB at `~/Library/Application Support/Recurse/recurse.db`. First launch seeds it from `data/learn.db` (read-only `VACUUM INTO`); after that the two apps don't sync
- Schema is read from `web/server/schema.sql` at launch, so both DBs stay interchangeable. Never edit the schema in only one place
- Repo root comes from `#filePath` (this checkout), `RECURSE_ROOT` overrides it. Content is read live from `courses/dsa`

## Layout (`Sources/Recurse`)

- `Engine.swift`: pure logic, 1:1 port of `web/server/engine` (dates, streak, xp, srs, hints). Change both or neither
- `Content.swift`: course/topic/quiz/viz loaders + the problem.md parser (keep in sync with `pyjudge.load_problem` and `web/server/content.ts`). Problems cached by mtime
- `Store.swift`: the "server" (`web/server/{index,progress}.ts`). `@Observable`; every read goes through `db`, which touches `tick`, and every write bumps it, so views re-render after changes
- `Proc.swift`: child processes, `scripts/pyjudge.py` and `claude -p` (same prompts/models as `web/server/ai.ts`). PATH gets `~/.local/bin` and Homebrew added since GUI apps start with a bare PATH
- `Activity.swift`: active time: only on topic/problem/review/boss, app frontmost, system input within 90 s (or a playing viz). Flushes every 60 s
- `Boss.swift` (runs, wall-clock countdown, AI-graded finish, +100 XP first win, one boss chest per module per day) and `Chests.swift` (earn/roll/open, collectibles; reward JSON matches the web). `Rewards.swift` (real-world reward path + claims, tiered trophies; one Rewards screen with Path / Trophies / Chests tabs). All three are `Store` extensions plus their views
- Views: `App.swift` (split view, sidebar = course tree, `Nav`), `HomeView`, `CourseView`, `TopicView` (lesson, quiz, explain), `ProblemView` (tabs | editor + console), `ReviewView`, `Markdown.swift` (block renderer + Python highlighter), `VizView.swift`, `CodeEditor.swift` (NSTextView)

## Not ported yet

Stats, patterns, settings, reminders, topic Wrapped card, editor line numbers. Web-only for now.

## Rules

Same as the web app: rewards only for effort, active time only while focused and in use, never test on real data.
