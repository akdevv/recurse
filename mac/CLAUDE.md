# Recurse Mac app

Native SwiftUI port of the web app (SwiftPM, macOS 15+, no dependencies). Run commands from `mac/`.

## Run

- `swift build && swift run`: debug build (opens in Xcode too: `open Package.swift`)
- `./build-app.sh [--open]`: release `build/Recurse.app` (icon from `AppIcon.png`, ad-hoc signed)
- `swift test`: engine checks (mirror `web/server/engine/selfcheck.ts`), problem.md parser over every problem, judge + solve/boss/chest/reward/settings/stats flows, reminder timing (same PRNG as the web) on a temp DB (boss AI grading isn't covered), every viz step renders
- Throwaway DB: `DB_PATH=/tmp/x.db swift run`. Screenshots without Screen Recording permission: `open -n -W --env DB_PATH=… --env RECURSE_SNAPSHOT=<dir> --env RECURSE_ROUTES="today,review,course,rewards:<path|trophies|chests>,problems,stats,patterns,boss:<module>,topic:<id>,problem:<id>" build/Recurse.app` writes one PNG per route, then quits
- `VIZ_OUT=<dir> swift test --filter everyVizRenders`: PNG of every viz trace's middle step

## Data

- The one real DB: `~/Library/Application Support/Recurse/recurse.db` (it was seeded once from the web app's `data/learn.db`; the Mac app is the only app in use now). Covered by Time Machine; never test on it
- Schema is embedded in `DB.swift` (`DB.schema`), same tables and JSON shapes as the web's `schema.sql`, so an old `learn.db` still opens with `DB_PATH`
- Independent of `web/`: it needs only `courses/`, `scripts/pyjudge.py`, `python3` and (for AI) the `claude` CLI
- Repo root comes from `#filePath` (this checkout), `RECURSE_ROOT` overrides it. Content is read live from `courses/dsa`

## Layout (`Sources/Recurse`)

- `Engine.swift`: pure logic, 1:1 port of `web/server/engine` (dates, streak, xp, srs, hints). Change both or neither
- `Content.swift`: course/topic/quiz/viz loaders + the problem.md parser (keep in sync with `pyjudge.load_problem` and `web/server/content.ts`). Problems cached by mtime
- `Store.swift`: the "server" (`web/server/{index,progress}.ts`). `@Observable`; every read goes through `db`, which touches `tick`, and every write bumps it, so views re-render after changes
- `Proc.swift`: child processes, `scripts/pyjudge.py` and `claude -p` (same prompts/models as `web/server/ai.ts`). PATH gets `~/.local/bin` and Homebrew added since GUI apps start with a bare PATH
- `Activity.swift`: active time: only on topic/problem/review/boss, app frontmost, system input within 90 s (or a playing viz). Flushes every 60 s
- `Boss.swift` (runs, wall-clock countdown, AI-graded finish, +100 XP first win, one boss chest per module per day) and `Chests.swift` (earn/roll/open, collectibles; reward JSON matches the web). `Rewards.swift` (real-world reward path + claims, tiered trophies; one Rewards screen with Path / Trophies / Chests tabs). All three are `Store` extensions plus their views
- `Browse.swift` (Problems table, ⌘K palette), `Insights.swift` (Stats with Swift Charts, Patterns), `SettingsView.swift` (⌘, window: same `settings` keys as the web), `Reminders.swift` (native notifications, timing from `ReminderTiming` in Engine = `engine/reminders.ts`; needs the .app bundle, so `swift run` sends none). The app keeps running with its window closed so reminders fire; Settings can register it as a login item
- Views: `App.swift` (split view, sidebar = course tree, `Nav`), `HomeView`, `CourseView`, `TopicView` (lesson, quiz, explain), `ProblemView` (tabs | editor + console), `ReviewView`, `Markdown.swift` (block renderer + Python highlighter), `VizView.swift`, `CodeEditor.swift` (NSTextView)

## Differences from the web

Everything is ported. Mac-specific: dictation is the system's (Fn Fn) instead of a mic button; reminders are local notifications from the running app instead of web push from the launchd server; tutor sends with ⌘↵ only while its text box is focused (⌘↵ runs code otherwise).

## Rules

Same as the web app: rewards only for effort, active time only while focused and in use, never test on real data.
