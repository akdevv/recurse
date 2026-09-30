import Foundation
import Testing
import SwiftUI
@testable import Recurse

private func days(_ start: String, _ n: Int, _ s: Int = Streak.dailyGoal) -> [String: Int] {
    Dictionary(uniqueKeysWithValues: (0..<n).map { (Dates.add(start, $0), s) })
}

@Test func dates() {
    // 2026-09-28 is a Monday
    #expect(Dates.weekStart("2026-09-28") == "2026-09-28")
    #expect(Dates.weekStart("2026-10-04") == "2026-09-28")
    #expect(Dates.add("2026-09-30", 2) == "2026-10-02")
}

@Test func weekStreak() {
    // two full weeks of Mon–Fri → 2; current week with 3 days doesn't break it
    let a = days("2026-09-14", 5).merging(days("2026-09-21", 5)) { $1 }.merging(days("2026-09-28", 3)) { $1 }
    let s = Streak.compute(a, today: "2026-09-30")
    #expect(s.weekStreak == 2 && s.thisWeekDays == 3)

    // a 4-day week breaks it without freezes
    let short = days("2026-09-14", 5).merging(days("2026-09-21", 4)) { $1 }
    #expect(Streak.compute(short, today: "2026-09-28").weekStreak == 0)

    // a 4-day week with one 3h+ day is covered by the freeze it earned
    var frozen = days("2026-09-14", 5).merging(days("2026-09-21", 3)) { $1 }
    frozen["2026-09-24"] = Streak.freezeDay
    let f = Streak.compute(frozen, today: "2026-09-28")
    #expect(f.weekStreak == 2 && f.freezes == 0)

    // current week reaching 5 counts immediately
    var cur = days("2026-09-28", 5)
    cur["2026-10-02"] = 600 + Streak.dailyGoal
    let c = Streak.compute(cur, today: "2026-10-02")
    #expect(c.weekStreak == 1 && c.todayDone)

    // chest freezes cover a short week; bonus freezes still cap at 2
    #expect(Streak.compute(short, today: "2026-09-28", bonusFreezes: ["2026-09-22": 1]).weekStreak == 2)
    #expect(Streak.compute([:], today: "2026-09-28", bonusFreezes: ["2026-09-28": 5]).freezes == 2)
    #expect(Streak.compute([:], today: "2026-09-28").weekStreak == 0)
}

@Test func dayStreak() {
    let g = Streak.dailyGoal
    var a = ["2026-09-25": g, "2026-09-26": g, "2026-09-27": g, "2026-09-28": 60]
    #expect(Streak.compute(a, today: "2026-09-28").dayStreak == 3)
    #expect(Streak.compute(a, today: "2026-09-29").dayStreak == 0)
    a["2026-09-28"] = g
    #expect(Streak.compute(a, today: "2026-09-28").dayStreak == 4)
}

@Test func xp() {
    #expect(XP.solve(.easy, hints: 0, solutionViewed: false, optional: false) == 20)
    #expect(XP.solve(.medium, hints: 1, solutionViewed: false, optional: false) == 30)
    #expect(XP.solve(.medium, hints: 0, solutionViewed: true, optional: false) == 8)
    #expect(XP.outcome(hints: 0, solutionViewed: false) == .solved)
    #expect(XP.outcome(hints: 2, solutionViewed: false) == .hinted)
    #expect(XP.outcome(hints: 0, solutionViewed: true) == .assisted)
    #expect([0, 99, 100, 300].map { XP.level($0).level } == [1, 1, 2, 3])
}

@Test func srs() {
    #expect(SRS.first(.solved, today: "2026-09-28") == (1, "2026-10-01"))
    #expect(SRS.first(.assisted, today: "2026-09-28") == (0, "2026-09-29"))
    #expect(SRS.next(1, passed: true, today: "2026-09-28") == (2, "2026-10-05"))
    #expect(SRS.next(4, passed: true, today: "2026-09-28").idx == 4)
    #expect(SRS.next(3, passed: false, today: "2026-09-28") == (0, "2026-09-29"))
}

@Test func hints() {
    #expect(Hints.unlocks(active: 0, hintCount: 2).hintsAvailable == 0)
    #expect(Hints.unlocks(active: 600, hintCount: 2).hintsAvailable == 1)
    #expect(Hints.unlocks(active: 1300, hintCount: 2).hintsAvailable == 2)
    #expect(Hints.unlocks(active: 1300, hintCount: 1).hintsAvailable == 1)
    #expect(!Hints.unlocks(active: 1799, hintCount: 2).solutionAvailable)
    #expect(Hints.unlocks(active: 1800, hintCount: 2).solutionAvailable)
}

@MainActor @Test func problemParser() throws {
    let p = try #require(Content.problem("two-sum"))
    #expect(p.title == "Two Sum" && p.lc == 1 && p.difficulty == .easy)
    #expect(p.params == ["nums", "target"])
    #expect(p.starter.hasPrefix("class Solution:"))
    #expect(!p.hints.isEmpty && !p.keyPoints.isEmpty)
    #expect(p.solutions.filter(\.reference).count == 1)
    #expect(p.solutions.allSatisfy { !$0.code.isEmpty })
}

@MainActor @Test func everyProblemParses() {
    let dir = Paths.course.appending(path: "problems")
    let ids = (try? FileManager.default.contentsOfDirectory(atPath: dir.path))?.map { $0.replacing(/^\d+-/, with: "") } ?? []
    #expect(ids.count > 200)
    for id in ids where Content.hasProblem(id) {
        let p = Content.problem(id)
        #expect(p != nil && p!.solutions.filter(\.reference).count == 1, "\(id)")
    }
}

@MainActor @Test func judgeRunsReferenceSolution() async throws {
    let p = try #require(Content.problem("two-sum"))
    let ref = try #require(p.solutions.first { $0.reference })
    let dir = Content.problemDir("two-sum")
    let ok = await Proc.judge(problemDir: dir, code: ref.code, mode: "submit")
    #expect(ok.verdict == "Accepted", "\(ok.error ?? "")")
    let bad = await Proc.judge(problemDir: dir, code: p.starter + "        return []\n", mode: "run", custom: ["[1,2]\n3"])
    #expect(bad.verdict != "Accepted" && bad.results.contains { $0.kind == "custom" })
}

@MainActor @Test func solveFlow() async throws {
    let url = FileManager.default.temporaryDirectory.appending(path: "recurse-test-\(UUID()).db")
    defer { try? FileManager.default.removeItem(at: url) }
    let store = Store(db: try DB(path: url))
    let p = try #require(Content.problem("two-sum"))
    let ref = try #require(p.solutions.first { $0.reference })

    store.startProblem("two-sum")
    #expect(store.problemStatuses()["two-sum"] == nil) // opening isn't starting
    store.addActivity(seconds: 60, problemId: "two-sum")
    #expect(store.latestAttempt("two-sum")?.activeSeconds == 60)
    #expect(store.problemStatuses()["two-sum"] == "in-progress")

    let (r, o) = await store.submit("two-sum", code: ref.code)
    #expect(r.verdict == "Accepted" && o == .solved)
    #expect(store.me().xp == 20)
    #expect(store.problemStatuses()["two-sum"] == "solved")
    #expect(store.upcomingReviews().first?.due == Dates.add(Dates.local(), 3))

    // a second Accepted on the finished attempt gives nothing
    let (_, again) = await store.submit("two-sum", code: ref.code)
    #expect(again == nil && store.me().xp == 20)

    // quiz: XP only for beating your best
    let quiz = Content.quiz("union-find")
    _ = store.submitQuiz("union-find", answers: quiz.map(\.answer))
    let xp = store.me().xp
    #expect(xp == 20 + quiz.count * XP.quizPerCorrect)
    _ = store.submitQuiz("union-find", answers: quiz.map(\.answer))
    #expect(store.me().xp == xp)
}

/// Renders every step of every viz trace (catches crashes on odd shapes). VIZ_OUT=<dir> also writes each trace's middle step as PNG.
@MainActor @Test func everyVizRenders() throws {
    let out = ProcessInfo.processInfo.environment["VIZ_OUT"]
    var traces = 0
    for m in Content.modules() {
        for tid in m.topics {
            for (name, t) in Content.lesson(tid).viz {
                traces += 1
                for i in t.steps.indices where i == t.steps.count / 2 || out == nil {
                    let r = ImageRenderer(content: VizStage(view: t.view, step: t.steps[i]).padding().background(.white))
                    r.scale = 2
                    let img = try #require(r.nsImage, "\(tid)/\(name) step \(i)")
                    if let out, let tiff = img.tiffRepresentation, let png = NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:]) {
                        try png.write(to: URL(fileURLWithPath: out).appending(path: "\(tid)-\(name).png"))
                    }
                }
            }
        }
    }
    #expect(traces > 50)
}

@MainActor private func tempStore() throws -> Store {
    Store(db: try DB(path: FileManager.default.temporaryDirectory.appending(path: "recurse-test-\(UUID()).db")))
}

@MainActor @Test func bossFlow() async throws {
    let store = try tempStore()
    let mid = "hashing"
    let pid = try #require(store.startBoss(mid))
    #expect(store.bossCandidates(mid).contains(pid))
    let a = try #require(store.latestAttempt(pid))
    let run = try #require(store.activeBossRun(attemptId: a.id))
    #expect(run.limitS == Content.module(mid)!.boss.timeLimitMin * 60)
    // a mock interview: nothing unlocks, however long you work
    store.addActivity(seconds: 120, problemId: pid)
    #expect(store.unlocks(store.latestAttempt(pid), hintCount: 2) == .none)
    #expect(!store.showSolutions(pid, store.latestAttempt(pid)))

    let ref = try #require(Content.problem(pid)?.solutions.first { $0.reference })
    let (r, o) = await store.submit(pid, code: ref.code)
    #expect(r.verdict == "Accepted" && o == .solved)
    #expect(store.activeBossRun(attemptId: a.id)?.solvedIn != nil) // solved, still waiting for the explanation
    #expect(store.chests().isEmpty) // boss solves never drop a solve chest

    // starting again abandons the open run
    _ = store.startBoss(mid)
    #expect(store.bossRuns(mid).filter { !$0.finished }.count == 1)
    #expect(store.bossRuns(mid).last?.passed == false)
}

@MainActor @Test func chests() throws {
    // same JSON as the web app
    #expect(String(decoding: try JSONEncoder().encode(ChestReward.freeze), as: UTF8.self) == #"{"kind":"freeze"}"#)
    let web = #"{"kind":"collectible","id":"xor-coin","name":"XOR Coin","desc":"Flip it twice, it cancels out."}"#
    #expect(try JSONDecoder().decode(ChestReward.self, from: Data(web.utf8)) == .collectible(id: "xor-coin", name: "XOR Coin", desc: "Flip it twice, it cancels out."))

    let store = try tempStore()
    var xp = 0, ids: [String] = []
    for _ in 0..<40 {
        let id = store.earnChest("boss", "hashing")
        switch try #require(store.openChest(id)) {
        case .xp(let n): xp += n; #expect((50...120).contains(n))
        case .collectible(let cid, _, _): ids.append(cid)
        case .freeze: break
        }
        #expect(store.openChest(id) != nil) // re-opening returns the same reward, no second roll
    }
    #expect(Set(ids).count == ids.count) // never a duplicate collectible
    #expect(store.me().xp == xp)
    #expect(store.me().streak.freezes <= Streak.maxFreezes)
    #expect(store.chestsWaiting == 0 && store.chestQueue.count == 40)
}

/// Marks a topic complete the way the app records it: lesson read, quiz passed, explained, required problems solved.
@MainActor private func complete(_ store: Store, _ tid: String) throws {
    let t = try #require(Content.topic(tid))
    store.markLessonDone(tid)
    _ = store.submitQuiz(tid, answers: Content.quiz(tid).map(\.answer))
    store.submitTopicExplain(tid, text: String(repeating: "explained ", count: 5))
    for p in t.problems where p.role != .optional {
        store._db.run("INSERT INTO attempts (problem_id, started_at, finished_at, outcome) VALUES (?, ?, ?, 'solved')", p.id, Dates.iso(), Dates.iso())
    }
    store.changed()
}

@MainActor @Test func rewardPath() throws {
    let store = try tempStore()
    let coffee = { store.rewardPath().first { $0.id == "coffee-1" }! }
    #expect(coffee().status == .locked && coffee().total == 2)

    store.setAvailed("coffee-1", true) // locked: refused
    #expect(coffee().status == .locked && store.error != nil)

    try complete(store, "python-for-dsa")
    #expect(coffee().done == 1 && coffee().status == .locked)
    try complete(store, "complexity-analysis")
    #expect(coffee().status == .unlocked)
    #expect(store.rewardsWaiting == 1)

    store.setAvailed("coffee-1", true)
    #expect(coffee().status == .availed && coffee().availedAt != nil && store.rewardsWaiting == 0)
    store.setAvailed("coffee-1", false)
    #expect(coffee().status == .unlocked)

    // the finale needs every module and the DP boss
    let grand = try #require(store.rewardPath().first { $0.id == "grand" })
    #expect(grand.total == store.moduleViews().flatMap(\.topics).count && grand.requires.last == "Dynamic Programming boss fight")

    let b = Dictionary(uniqueKeysWithValues: store.badges().map { ($0.id, $0) })
    #expect(b["topics"]?.value == 2 && b["topics"]?.tier == 1)
    #expect(b["first-solve"]?.tier == 1 && b["quiz-ace"]!.value == 2)
    #expect(b["boss"]?.tier == 0 && b["solver"]?.next == 25)
}

@Test func reminderTiming() {
    let cal = Calendar.current
    let d = { (h: Int, m: Int) in cal.date(from: DateComponents(year: 2026, month: 9, day: 28, hour: h, minute: m))! }
    let next = { (now: Date, planned: Bool, catchUp: Bool, done: Bool, sent: Int, last: Date?) in
        ReminderTiming.next(now: now, window: ("10:00", "23:00"), plannedDay: planned, catchUp: catchUp, todayDone: done, sentToday: sent, lastSentAt: last)
    }
    // first one late morning, reproducible
    let first = next(d(9, 0), true, false, false, 0, nil)!
    #expect(cal.component(.hour, from: first) == 11 && cal.component(.minute, from: first) <= 30)
    #expect(next(d(9, 0), true, false, false, 0, nil) == first)
    // gaps shrink as the window runs out
    let g1 = next(d(12, 0), true, false, false, 1, d(12, 0))!.timeIntervalSince(d(12, 0))
    let g2 = next(d(21, 0), true, false, false, 1, d(21, 0))!.timeIntervalSince(d(21, 0))
    #expect(g2 < g1)
    #expect(next(d(12, 0), true, false, true, 0, nil) == nil)
    #expect(next(d(23, 30), true, false, false, 0, nil) == nil)
    #expect(next(d(12, 0), true, false, false, ReminderTiming.capPlanned, d(12, 0)) == nil)
    #expect(next(d(12, 0), false, false, false, 0, nil) == nil)
    #expect(next(d(12, 0), false, true, false, 0, nil) != nil)
    // same PRNG as the web (mulberry32): value for seed 0 computed in node
    #expect(abs(ReminderTiming.rand(0) - 0.26642920868471265) < 1e-12)
}

@MainActor @Test func settingsRoundTrip() throws {
    let store = try tempStore()
    #expect(store.settings() == Settings())
    // written by the web app: JSON per key
    store._db.run("INSERT INTO settings (key, value) VALUES ('window', ?)", #"{"start":"09:30","end":"22:00"}"#)
    #expect(store.settings().window == .init(start: "09:30", end: "22:00"))
    var s = store.settings()
    s.username = "ak"; s.plannedDays = [4, 0]; s.reminders = false
    store.saveSettings(s)
    #expect(store.settings().plannedDays == [0, 4] && store.settings().username == "ak" && !store.settings().reminders)
    #expect(store._db.one("SELECT value FROM settings WHERE key = 'plannedDays'")?.str("value") == "[0,4]")
}

@MainActor @Test func browseStatsPatternsWrapped() throws {
    let store = try tempStore()
    let rows = store.allProblems()
    #expect(Set(rows.map(\.id)).count == rows.count && rows.count > 200)
    try complete(store, "python-for-dsa")
    let s = store.stats()
    #expect(s.days.count == 30 && s.weeks.count == 12 && s.solved > 0)
    #expect(s.days.last?.xp ?? 0 > 0) // today's quiz + explain XP lands in today's bucket
    let pats = store.patterns()
    #expect(pats.count > 20 && pats.contains { !$0.topics.isEmpty && !$0.problems.isEmpty })
    let t = try #require(Content.topic("python-for-dsa"))
    let w = store.topicWrapped(t)
    #expect(w.solved == t.problems.filter { $0.role != .optional }.count && w.hintFree == 1 && w.quizBest == 1 && w.masteredAt != nil)
    for r in [Route.today, .review, .course, .topic("x"), .problem("two-sum")] { #expect(Reminders.decode(Reminders.encode(r)) == r) }
}

/// Every trophy medal in each of its metals renders. `MEDALS_OUT=<dir>` also writes a preview sheet.
@MainActor @Test func medalsRender() throws {
    let trophies: [(String, String, Bool)] = [
        ("First Accepted", "checkmark.seal.fill", true), ("Problem Solver", "chevron.left.forwardslash.chevron.right", false),
        ("No Hints Needed", "lightbulb.fill", false), ("Stretch Goals", "mountain.2.fill", false), ("Speedrun", "bolt.fill", false),
        ("Clear Explainer", "text.bubble.fill", false), ("Perfect Score", "star.fill", true), ("Quiz Ace", "target", false),
        ("Spaced Out", "rectangle.stack.fill", false), ("Full Week", "calendar", false), ("Deep Work", "hourglass", false),
        ("Comeback", "arrow.uturn.up", true), ("Topic Master", "book.fill", false), ("Boss Slayer", "figure.fencing", false),
        ("Module Master", "laurel.leading", false),
    ]
    let sheet = LazyVGrid(columns: Array(repeating: GridItem(.fixed(400), spacing: 16), count: 3), spacing: 16) {
        ForEach(trophies, id: \.0) { name, icon, single in
            VStack(alignment: .leading, spacing: 10) {
                Text(name).font(.headline).foregroundStyle(.white)
                HStack(spacing: 12) {
                    ForEach(Array((single ? [Medal.Metal.locked, .jade] : [.locked, .bronze, .silver, .gold]).enumerated()), id: \.offset) { _, m in
                        Medal(icon: icon, metal: m, size: 80)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surface, in: .rect(cornerRadius: 14))
        }
    }
    .padding(24)
    .background(Color.canvas)
    .environment(\.colorScheme, .dark)
    let r = ImageRenderer(content: sheet)
    r.scale = 2
    let img = try #require(r.nsImage)
    if let out = ProcessInfo.processInfo.environment["MEDALS_OUT"], let tiff = img.tiffRepresentation,
       let png = NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:]) {
        try png.write(to: URL(fileURLWithPath: out).appending(path: "trophies-preview.png"))
    }
}

/// Back/forward retrace every move, like a browser; a new move drops the forward history.
@MainActor @Test func navHistory() {
    let nav = Nav()
    #expect(!nav.canGoBack)
    nav.go(.course)
    nav.go(.topic("python-for-dsa"))
    nav.go(.problem("fizz-buzz"))
    #expect(nav.current == .problem("fizz-buzz"))
    nav.back()
    #expect(nav.current == .topic("python-for-dsa") && nav.path.isEmpty)
    nav.back()
    #expect(nav.current == .course)
    nav.forward()
    #expect(nav.current == .topic("python-for-dsa") && nav.canGoForward)
    nav.go(.stats)
    #expect(!nav.canGoForward)
    nav.go(.stats) // same place: no new entry
    nav.back()
    #expect(nav.current == .topic("python-for-dsa"))
    nav.back(); nav.back(); nav.back()
    #expect(nav.current == .today && !nav.canGoBack)
}

@MainActor @Test func enrollAndBackupRoundTrip() throws {
    let dir = FileManager.default.temporaryDirectory.appending(path: "recurse-backup-\(UUID())")
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    let a = Store(db: try DB(path: dir.appending(path: "a.db")))
    #expect(!a.enrolled)
    var s = a.settings()
    s.name = "Ada Lovelace"; s.username = Settings.clean("Ada L!"); s.avatar = Data([1, 2, 3])
    a.saveSettings(s)
    #expect(a.enrolled && a.settings().username == "adal")
    a.addXp(40, "test")
    let file = dir.appending(path: "backup.recurse")
    try a.exportData(to: file)

    let b = Store(db: try DB(path: dir.appending(path: "b.db")))
    b.addXp(5, "test")
    try b.importData(from: file)
    #expect(b.settings() == a.settings() && b.me().xp == 40)
    // what it replaced was kept, and restores the old state
    let saved = try #require(try FileManager.default.contentsOfDirectory(at: b.backupsDir, includingPropertiesForKeys: nil).first)
    try b.importData(from: saved)
    #expect(b.me().xp == 5 && !b.enrolled)

    let junk = dir.appending(path: "junk.recurse")
    try Data("not a database".utf8).write(to: junk)
    #expect(throws: (any Error).self) { try b.importData(from: junk) }
    #expect(b.me().xp == 5)
}

@Test func versionOrder() {
    #expect(Updates.isNewer("0.10.0", than: "0.9.2"))
    #expect(Updates.isNewer("1.0", than: "0.9.9"))
    #expect(!Updates.isNewer("0.2.0", than: "0.2"))
    #expect(!Updates.isNewer("0.1.9", than: "0.2.0"))
}

@MainActor @Test func customRewards() throws {
    let store = try tempStore()
    let item = { (id: String) in store.rewardPath().first { $0.id == id }! }
    #expect(item("grand").item == RewardDef.path.last!.item && !item("grand").custom)
    store.setReward("grand", RewardItem(title: "  A trip to the mountains ", note: "Book it the day it unlocks"))
    #expect(item("grand").item == RewardItem(title: "A trip to the mountains", note: "Book it the day it unlocks", icon: "custom"))
    store.setReward("coffee-1", .preset("book"))
    #expect(item("coffee-1").item.icon == "book" && item("coffee-1").custom)
    try complete(store, "python-for-dsa")
    try complete(store, "complexity-analysis")
    store.setAvailed("coffee-1", true)
    store.setReward("coffee-1", nil) // back to the default; the claim stays with the milestone
    #expect(item("coffee-1").item == RewardDef.path[0].item && item("coffee-1").status == .availed)
    let file = FileManager.default.temporaryDirectory.appending(path: "rewards-\(UUID()).recurse")
    try store.exportData(to: file)
    let other = try tempStore()
    try other.importData(from: file)
    #expect(other.rewardPath().first { $0.id == "grand" }!.item.title == "A trip to the mountains")
    #expect(RewardItem.presets.allSatisfy { Art.image($0.icon) != nil } && Art.image("custom") != nil)
}

@Test func aiRequestsAndReplies() throws {
    func body(_ r: URLRequest) throws -> [String: Any] { try JSONSerialization.jsonObject(with: r.httpBody!) as! [String: Any] }
    let a = AI.request(.anthropic, model: "m", key: "k", prompt: "hi")
    #expect(a.url?.absoluteString == "https://api.anthropic.com/v1/messages" && a.value(forHTTPHeaderField: "x-api-key") == "k")
    #expect(try a.value(forHTTPHeaderField: "anthropic-version") != nil && body(a)["max_tokens"] != nil)
    let o = AI.request(.openai, model: "m", key: "k", prompt: "hi")
    #expect(o.url?.absoluteString == "https://api.openai.com/v1/chat/completions" && o.value(forHTTPHeaderField: "Authorization") == "Bearer k")
    let g = AI.request(.gemini, model: "gemini-x", key: "k", prompt: "hi")
    #expect(g.url?.absoluteString.hasSuffix("/models/gemini-x:generateContent") == true && g.value(forHTTPHeaderField: "x-goog-api-key") == "k")
    #expect(g.url?.query == nil) // the key goes in a header, never the URL
    for r in [a, o, g] { #expect(r.httpMethod == "POST" && String(decoding: r.httpBody!, as: UTF8.self).contains("hi")) }

    let reply = { (p: AIProvider, json: String) in try AI.parse(p, Data(json.utf8), status: 200) }
    #expect(try reply(.anthropic, #"{"content":[{"type":"thinking","thinking":"hmm"},{"type":"text","text":"OK"}]}"#) == "OK")
    #expect(try reply(.openai, #"{"choices":[{"message":{"role":"assistant","content":"OK"}}]}"#) == "OK")
    #expect(try reply(.gemini, #"{"candidates":[{"content":{"parts":[{"text":"hmm","thought":true},{"text":"O"},{"text":"K"}]}}]}"#) == "OK")
    #expect(throws: Proc.AIError.self) { try reply(.openai, #"{"choices":[]}"#) }
    #expect {
        try AI.parse(.openai, Data(#"{"error":{"message":"Incorrect API key provided"}}"#.utf8), status: 401)
    } throws: { $0.localizedDescription == "OpenAI API: Incorrect API key provided" }
    #expect { try AI.parse(.gemini, Data("<html>".utf8), status: 503) } throws: { $0.localizedDescription == "Google Gemini API: HTTP 503" }

    #expect(AI.Config().provider == .claudeCode && AI.Config(provider: .gemini).model(.tutor) == "gemini-flash-latest")
    #expect(AI.Config(provider: .openai, model: " gpt-x ").model(.grade) == "gpt-x")
}

@Test func keychainRoundTrip() {
    let account = "test-\(UUID())"
    defer { Keychain.delete(account) }
    #expect(Keychain.get(account) == nil)
    #expect(Keychain.set(account, "one") && Keychain.get(account) == "one")
    #expect(Keychain.set(account, "two") && Keychain.get(account) == "two")
    Keychain.delete(account)
    #expect(Keychain.get(account) == nil)
}

@MainActor @Test func aiSettingPersists() throws {
    let store = try tempStore()
    #expect(store.aiConfig() == AI.Config())
    store.putSetting("ai", AI.Config(provider: .gemini, model: "gemini-x"))
    #expect(store.aiConfig() == AI.Config(provider: .gemini, model: "gemini-x"))
}

/// Live calls, only when asked: `GEMINI_API_KEY=… swift test --filter liveGemini`, `RECURSE_LIVE_CLAUDE=1 swift test --filter liveClaude`.
@Test(.enabled(if: ProcessInfo.processInfo.environment["GEMINI_API_KEY"] != nil)) func liveGemini() async throws {
    let account = AIProvider.gemini.rawValue, before = Keychain.get(account)
    defer { if let before { Keychain.set(account, before) } else { Keychain.delete(account) } }
    Keychain.set(account, ProcessInfo.processInfo.environment["GEMINI_API_KEY"]!)
    let config = AI.Config(provider: .gemini)
    #expect(try await AI.ask("Reply with just the word OK.", config, .tutor).localizedCaseInsensitiveContains("ok"))
    let g = try await Proc.gradeExplain(question: "What does a hash map give you?", keyPoints: ["average O(1) lookup", "keys map to values"],
                                        answer: "It stores key-value pairs and looks keys up in O(1) on average by hashing them.", ai: config)
    #expect(g.score >= 3 && g.covered == [true, true] && !g.feedback.isEmpty)
    await #expect(throws: Proc.AIError.self) {
        Keychain.set(account, "not-a-key")
        _ = try await AI.ask("hi", config, .tutor)
    }
}

@Test(.enabled(if: ProcessInfo.processInfo.environment["RECURSE_LIVE_CLAUDE"] != nil)) func liveClaude() async throws {
    let reply = try await Proc.tutorReply(title: "Two Sum", statement: "Find two numbers that add up to target.", hints: [],
                                          code: "class Solution: pass", history: [("user", "Where do I start?")], ai: AI.Config())
    #expect(reply.contains("?"))
}
