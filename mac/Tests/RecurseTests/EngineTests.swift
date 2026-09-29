// Mirrors web/server/engine/selfcheck.ts, so both apps agree on streaks, XP, reviews and unlocks.
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
    #expect(run.limitS == Content.module(mid).boss.timeLimitMin * 60)
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
