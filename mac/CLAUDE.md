# Recurse Mac app

Native SwiftUI app (SwiftPM, macOS 26+, no dependencies). Run commands from `mac/`. It replaced the web app, which is archived on the `web-archive` branch.

## Run

- `swift build && swift run`: debug build (opens in Xcode too: `open Package.swift`)
- `./build-app.sh [--open]`: release `build/Recurse.app`, version from `VERSION`, with the committed `courses/dsa` and `scripts/pyjudge.py` copied into Resources (icon from `AppIcon.png`, teal accent from `Assets.xcassets` via `actool`; with an Apple Development identity it's signed with it and gets the widget in `PlugIns/`, otherwise ad-hoc and no widget)
- `swift test`: engine checks, problem.md parser over every problem, judge + solve/boss/chest/reward/settings/stats flows, reminder timing on a temp DB (boss AI grading isn't covered), every viz step renders
- `./release.sh`: publishes `build/Recurse.app` zipped as GitHub release `v$(cat VERSION)` (bump `VERSION`, commit and push first). Unnotarized: users click Open Anyway once. The in-app update check reads the public releases API, so the repo (or its releases) must be public
- Throwaway DB: `DB_PATH=/tmp/x.db swift run`
- Real screenshots (no Screen Recording permission needed; `DevSnapshots.swift` captures the app's own window with ScreenCaptureKit): `open -n -W --env DB_PATH=… --env RECURSE_SNAPSHOT=<dir> --env RECURSE_ROUTES="today,today@scroll,rewards:trophies,problems,stats,patterns,boss:<module>,topic:<id>,problem:<id>,settings:reminders" build/Recurse.app` writes `<n>-<route>.png` plus `<n>-<route>-toolbar.txt` (header items and frames) per route, then quits. `@scroll` (or `@y<offset>`) scrolls the page first, `@reveal` presses ⌘↵ first (e.g. Review's Show answer), `problem:<id>:tutor` opens a problem on that tab, `menubar` renders the status item in a mock menu bar (`<n>-menubar-item.png`; its menu can't be captured, it tracks modally), `swipe:0.4` freezes a back swipe that far along, `chest` shows the chest dialog and `chest@open` opens it (the run then has to be killed; the sheet blocks quitting). `--env RECURSE_SIZE=1300x860` enlarges the window and opens the sidebar. Keep screenshots for the user in `mac/screenshots/<page>/{before,after}/` (gitignored). SwiftUI trap: a `Spacer` inside a toolbar item makes it count as flexible space and it silently disappears
- `VIZ_OUT=<dir> swift test --filter everyVizRenders`: PNG of every viz trace's middle step

## Data

- The one real DB: `~/Library/Application Support/Recurse/recurse.db` (it was seeded once from the web app's `data/learn.db`; the Mac app is the only app in use now). Covered by Time Machine; never test on it
- Schema is embedded in `DB.swift` (`DB.schema`), same tables and JSON shapes as the web's `schema.sql`, so an old `learn.db` still opens with `DB_PATH`
- Needs only `courses/`, `scripts/pyjudge.py`, `python3` and (for AI) the `claude` CLI
- Repo root comes from `#filePath` (this checkout, so content edits show up live), falling back to the app's Resources on other Macs; `RECURSE_ROOT` overrides both
- First launch shows `WelcomeView` until a name is saved (`Store.enrolled`); DevSnapshots enrolls throwaway DBs unless the routes start with `welcome`. Then `TourView` (five how-it-works pages on a Liquid Glass card centered over `AmbientBackdrop`: a `GradientFamily` base, top light, glow, vignette and film grain) shows once via `Store.tourPending`, a DB setting so snapshot runs never leave it on in the real app; Help › How Recurse Works reopens it (snapshot route `tour`)
- Reward path: milestones (`RewardDef.path`) are fixed; what each one rewards is the user's pick (`RewardItem` preset or custom, which uses the "custom" art), stored under the `rewards` settings key and edited only in Settings › Rewards; claims stay keyed by milestone
- Backups (Settings › Data) are `VACUUM INTO` copies; import restores in place with the SQLite backup API after saving the current data to `Backups/` next to the DB. Updates (Settings › Updates, `Core/Updates.swift`) download the release zip and swap the .app after quitting; data is never inside the app

## Layout (`Sources/Recurse`)

- `App/`: `App.swift` (scenes, `RootView` split view, `Nav`), `Header.swift` (breadcrumbs, header blur, the system search field; problem pages drop search; back/forward are plain toolbar buttons in their own glass group), `Sidebar.swift`, `MenuBar.swift` (`MenuBarExtra` status item: today's ring, minutes and day streak; a plain system menu: today, streak, the next step, due reviews, open/settings/quit; hidden via Settings › General), `SwipeBack.swift` (Safari-style two-finger swipe for back/forward over `Nav`'s history, run on page snapshots; `PageCamera` retakes the current page with ScreenCaptureKit shortly after it settles, since `cacheDisplay`/`layer.render` draw SwiftUI blank), `Theme.swift` (palette; page tops use `Backdrop(family:)`, a top-weighted take on the `GradientFamily` look that fades into the canvas), `DevSnapshots.swift`
- `Core/`: models, persistence and logic; no views
  - `Engine.swift`: pure logic (dates, streak, xp, srs, hints, reminder timing)
  - `Content.swift`: course/topic/quiz/viz loaders + the problem.md parser (keep in sync with `pyjudge.load_problem`). JSON and problems cached by mtime
  - `Store.swift`: `@Observable` app state; every read goes through `db`, which touches `tick`, and every write bumps it, so views re-render after changes. `Rewards`, `Chests`, `Boss`, `Insights`, `Catalog` (problem list, search items) are `Store` extensions
  - `DB.swift` (SQLite + embedded schema, `Paths`), `Proc.swift` (`scripts/pyjudge.py` and `claude -p`; PATH gets `~/.local/bin` and Homebrew since GUI apps start with a bare PATH), `Activity.swift` (active time: learning screens only, app frontmost, input within 90 s or a playing viz; flushes every 60 s), `Reminders.swift` (local notifications; needs the .app bundle, so `swift run` sends none), `Updates.swift` (GitHub release check and in-place install)
- `Widget/RecurseWidget.swift`: WidgetKit extension (small: today's ring, minutes, day streak; medium adds the week), built by `build-app.sh` with `swiftc` (not SwiftPM) together with `Core/WidgetSnapshot.swift` and `App/Theme.swift`. The app writes `WidgetSnapshot` to the App Group `L63A6B5UJ9.dev.akdevv.recurse` (team-prefixed, so no provisioning profile; the team is the certificate's OU) after every write (`App/WidgetSync.swift`); the widget rolls the day over at midnight itself. The container is off-limits to other processes; DevSnapshots dumps what the widget reads to `widget.json`
- `Features/`: one file per screen (`HomeView`, `CourseView`, `TopicView`, `ProblemView`, `ReviewView`, `ProblemsView`, `PatternsView`, `StatsView`, `RewardsView`, `ChestsView`, `BossView`, `SettingsView` with General/Reminders/Rewards/Data/Updates tabs, `WelcomeView` and `TourView` for first launch) plus `ExplainFeedback` (key points + AI grading, shared by topic, problem and review)
- `UI/`: shared building blocks. `Components.swift` (badges, rings, `.surface()`/`.card()`, `ProblemRow`, formatting helpers), `Controls.swift` (`Segments`, `GlassTabs`, `FilterField`, `TextArea`, `HoverButton`…), `Art.swift` (SVG illustrations, `Medal`, `Avatar`, `PhotoButtons`), `Backdrops.swift` (`GradientFamily`, the page-top `Backdrop`, the full-window `AmbientBackdrop`, film `Grain`), `Markdown.swift`, `CodeEditor.swift` (NSTextView), `VizView.swift`

## UI rules

Prefer Apple's built-ins over custom UI: system toolbar glass, `.searchable`, scroll edge effects, glass button styles. Custom views only where no built-in exists.

## Differences from the archived web app

Dictation is the system's (Fn Fn) instead of a mic button; reminders are local notifications from the running app instead of web push from the launchd server; tutor sends with ⌘↵ only while its text box is focused (⌘↵ runs code otherwise).

## Rules

Rewards only for effort, active time only while focused and in use, never test on real data.
