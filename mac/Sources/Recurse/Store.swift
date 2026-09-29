// The Mac app's "server": web/server/{index,progress}.ts over the same SQLite schema.
import Foundation
import Observation

struct Me {
    var username: String
    var xp: Int
    var level: Level
    var streak: StreakState
    var reviewsDue: Int
}

struct TopicStatus {
    var lessonDone: Bool
    var quizBest: Double?
    var hasQuiz, explained: Bool
    var solved, required: Int
    var complete: Bool
}

struct TopicProblem: Identifiable, Hashable {
    let id, title: String
    let role: Role
    let difficulty: Difficulty?
    let lc: Int?
    let available: Bool
    let status: String // new | in-progress | solved | hinted | assisted
}

struct TopicState: Identifiable {
    let topic: Topic
    let status: TopicStatus
    let problems: [TopicProblem]
    var id: String { topic.id }
}

struct ModuleView: Identifiable {
    let module: Module
    let topics: [TopicState]
    var complete: Bool { topics.allSatisfy(\.status.complete) }
    var unlocked = false
    var id: String { module.id }
}

enum Route: Hashable {
    case today, review, course, chests
    case topic(String)
    case boss(String)
    case problem(String)
}

struct NextAction {
    enum Kind { case review, learn, solve, finish, browse }
    let kind: Kind
    let title, context: String
    let route: Route
}

struct Attempt {
    let id: Int
    let activeSeconds, hintsUsed: Int
    let solutionViewed: Bool
    let code: String?
    let finished: Bool
    let outcome: Outcome?
    let explain: String

    init(_ r: Row) {
        id = r.int("id")!
        activeSeconds = r.int("active_seconds") ?? 0
        hintsUsed = r.int("hints_used") ?? 0
        solutionViewed = (r.int("solution_viewed") ?? 0) != 0
        code = r.str("code")
        finished = r.str("finished_at") != nil
        outcome = r.str("outcome").flatMap(Outcome.init)
        explain = r.str("explain") ?? ""
    }
}

struct Submission: Identifiable {
    let id: Int
    let ts, kind, verdict: String
    let passed, total: Int
}

struct ReviewItem: Identifiable {
    let type, itemId, title, prompt: String
    let difficulty: Difficulty?
    let interval, passNext, failNext: Int
    let keyPoints: [String]
    let reference: Solution?
    var id: String { "\(type):\(itemId)" }
}

@MainActor @Observable
final class Store {
    static let quizPass = 0.7

    /// Bumped by every write; reads go through `db`, which touches it, so views re-render after changes.
    private(set) var tick = 0
    let _db: DB
    var db: DB { _ = tick; return _db }
    var toast: String?
    var error: String?
    /// Chests just earned; the root view shows the opening sheet for the first one.
    var chestQueue: [Int] = []

    init(db: DB) { _db = db }

    func changed() { tick += 1 }

    func flashXP(_ xp: Int) { if xp > 0 { toast = "+\(xp) XP" } }

    @discardableResult
    func addXp(_ amount: Int, _ reason: String, _ ref: String? = nil) -> Int {
        if amount > 0 { _db.run("INSERT INTO xp_events (ts, amount, reason, ref) VALUES (?, ?, ?, ?)", Dates.iso(), amount, reason, ref) }
        return amount
    }

    // MARK: progress

    var username: String {
        // settings values are JSON; username is a JSON string
        guard let raw = db.one("SELECT value FROM settings WHERE key = 'username'")?.str("value"),
              let s = try? JSONDecoder().decode(String.self, from: Data(raw.utf8)) else { return "akdevv" }
        return s
    }

    func activityMap() -> [String: Int] {
        Dictionary(uniqueKeysWithValues: db.all("SELECT date, seconds FROM activity").map { ($0.str("date")!, $0.int("seconds")!) })
    }

    /// Streak freezes from opened mystery chests, by local date.
    func bonusFreezes() -> [String: Int] {
        var out: [String: Int] = [:]
        for r in db.all("SELECT opened_at FROM chests WHERE reward LIKE '%\"freeze\"%' AND opened_at IS NOT NULL") {
            if let d = r.str("opened_at").flatMap(Dates.fromIso) { out[Dates.local(d), default: 0] += 1 }
        }
        return out
    }

    var reviewsDue: Int { db.one("SELECT COUNT(*) AS n FROM reviews WHERE due <= ?", Dates.local())?.int("n") ?? 0 }

    func me() -> Me {
        let xp = db.one("SELECT COALESCE(SUM(amount), 0) AS xp FROM xp_events")?.int("xp") ?? 0
        return Me(username: username, xp: xp, level: XP.level(xp),
                  streak: Streak.compute(activityMap(), today: Dates.local(), bonusFreezes: bonusFreezes()),
                  reviewsDue: reviewsDue)
    }

    static func isSolved(_ s: String?) -> Bool { s.flatMap(Outcome.init) != nil }

    func problemStatuses() -> [String: String] {
        var out: [String: String] = [:]
        // opening a problem isn't starting it: "in-progress" needs real work
        for r in db.all("SELECT problem_id, outcome, active_seconds > 0 OR approach != '' AS worked FROM attempts") {
            let pid = r.str("problem_id")!, cur = out[pid]
            guard let o = r.str("outcome").flatMap(Outcome.init) else {
                if cur == nil && r.int("worked") == 1 { out[pid] = "in-progress" }
                continue
            }
            if let c = cur.flatMap(Outcome.init), c.rank >= o.rank { continue }
            out[pid] = o.rawValue
        }
        return out
    }

    func topicStatus(_ t: Topic, _ statuses: [String: String]) -> TopicStatus {
        let row = db.one("SELECT * FROM topic_progress WHERE topic_id = ?", t.id)
        let required = t.problems.filter { $0.role != .optional }
        let solved = required.filter { Store.isSolved(statuses[$0.id]) }.count
        let hasQuiz = t.ready && !Content.quiz(t.id).isEmpty
        let lessonDone = row?.str("lesson_done_at") != nil
        let quizBest = row?.real("quiz_best")
        let explained = !(row?.str("explain") ?? "").isEmpty
        let complete = t.ready && lessonDone && explained && solved == required.count
            && (!hasQuiz || (quizBest ?? 0) >= Store.quizPass)
        return TopicStatus(lessonDone: lessonDone, quizBest: quizBest, hasQuiz: hasQuiz, explained: explained,
                           solved: solved, required: required.count, complete: complete)
    }

    func topicProblems(_ t: Topic, _ statuses: [String: String]) -> [TopicProblem] {
        t.problems.map { ref in
            if Content.hasProblem(ref.id), let p = Content.problem(ref.id) {
                return TopicProblem(id: ref.id, title: p.title, role: ref.role, difficulty: p.difficulty, lc: p.lc,
                                    available: true, status: statuses[ref.id] ?? "new")
            }
            return TopicProblem(id: ref.id, title: ref.title ?? ref.id, role: ref.role, difficulty: ref.difficulty,
                                lc: ref.lc, available: false, status: "new")
        }
    }

    func moduleViews() -> [ModuleView] {
        let statuses = problemStatuses()
        var views = Content.modules().map { m in
            ModuleView(module: m, topics: m.topics.compactMap(Content.topic).map {
                TopicState(topic: $0, status: topicStatus($0, statuses), problems: topicProblems($0, statuses))
            })
        }
        let done = Set(views.filter(\.complete).map(\.id))
        for i in views.indices { views[i].unlocked = views[i].module.prereqs.allSatisfy(done.contains) }
        return views
    }

    /// Due reviews first, then the first unfinished step in course order.
    func nextAction(_ modules: [ModuleView]) -> NextAction {
        let due = reviewsDue
        if due > 0 { return NextAction(kind: .review, title: "\(due) review\(due == 1 ? "" : "s") due", context: "Spaced repetition", route: .review) }
        for m in modules where m.unlocked {
            for tv in m.topics where tv.topic.ready && !tv.status.complete {
                let context = "Module \(m.module.number) · \(m.module.title)"
                if !tv.status.lessonDone { return NextAction(kind: .learn, title: tv.topic.title, context: context, route: .topic(tv.id)) }
                if let p = tv.problems.first(where: { $0.role != .optional && !Store.isSolved($0.status) }), p.available {
                    return NextAction(kind: .solve, title: p.title, context: tv.topic.title, route: .problem(p.id))
                }
                return NextAction(kind: .finish, title: tv.topic.title, context: context, route: .topic(tv.id))
            }
        }
        return NextAction(kind: .browse, title: "Browse the course", context: "", route: .course)
    }

    // MARK: activity

    func addActivity(seconds: Int, problemId: String?) {
        let s = max(0, min(120, seconds))
        guard s > 0 else { return }
        _db.run("INSERT INTO activity (date, seconds) VALUES (?, ?) ON CONFLICT(date) DO UPDATE SET seconds = seconds + excluded.seconds",
                Dates.local(), s)
        if let problemId {
            _db.run("UPDATE attempts SET active_seconds = active_seconds + ? WHERE problem_id = ? AND finished_at IS NULL", s, problemId)
        }
        changed()
    }

    // MARK: topics

    private func upsertTopic(_ tid: String, _ col: String, _ val: any SQLBindable) {
        _db.run("INSERT INTO topic_progress (topic_id, \(col)) VALUES (?, ?) ON CONFLICT(topic_id) DO UPDATE SET \(col) = excluded.\(col)", tid, val)
    }

    func topicExplain(_ tid: String) -> String {
        db.one("SELECT explain FROM topic_progress WHERE topic_id = ?", tid)?.str("explain") ?? ""
    }

    func markLessonDone(_ tid: String) {
        upsertTopic(tid, "lesson_done_at", Dates.iso())
        changed()
    }

    /// XP only for beating your best, so re-taking can't be farmed.
    func submitQuiz(_ tid: String, answers: [Int?]) -> [Bool] {
        let quiz = Content.quiz(tid)
        let correct = quiz.enumerated().map { answers[$0] == $1.answer }
        let score = correct.filter { $0 }.count
        let prev = _db.one("SELECT quiz_best FROM topic_progress WHERE topic_id = ?", tid)?.real("quiz_best") ?? 0
        flashXP(addXp(max(0, score - Int((prev * Double(quiz.count)).rounded())) * XP.quizPerCorrect, "quiz", tid))
        let pct = Double(score) / Double(max(1, quiz.count))
        if pct > prev { upsertTopic(tid, "quiz_best", pct) }
        changed()
        return correct
    }

    func submitTopicExplain(_ tid: String, text: String) {
        let first = topicExplain(tid).isEmpty
        _db.run("""
            INSERT INTO topic_progress (topic_id, explain, explain_at) VALUES (?, ?, ?)
            ON CONFLICT(topic_id) DO UPDATE SET explain = excluded.explain, explain_at = excluded.explain_at
            """, tid, text, Dates.iso())
        if first {
            addReview("topic", tid, .solved)
            flashXP(addXp(XP.explain, "explain", tid))
        }
        changed()
    }

    func addReview(_ type: String, _ id: String, _ o: Outcome) {
        let r = SRS.first(o, today: Dates.local())
        _db.run("INSERT OR IGNORE INTO reviews (item_type, item_id, interval_idx, due) VALUES (?, ?, ?, ?)", type, id, r.idx, r.due)
    }

    // MARK: grades

    func latestGrade(_ kind: String, _ ref: String) -> Grade? {
        db.one("SELECT json FROM grades WHERE kind = ? AND ref = ? ORDER BY id DESC LIMIT 1", kind, ref)?.str("json")
            .flatMap { try? JSONDecoder().decode(Grade.self, from: Data($0.utf8)) }
    }

    private func rubric(_ kind: String, _ id: String) -> (question: String, keyPoints: [String])? {
        if kind == "topic", let t = Content.topic(id) { return (t.explain.prompt, t.explain.keyPoints) }
        if kind == "problem", let p = Content.problem(id) {
            return ("Walk me through your solution to \"\(p.title)\": the approach, why it works, and its time and space complexity.", p.keyPoints)
        }
        return nil
    }

    func grade(_ kind: String, _ id: String, answer: String) async throws -> Grade {
        guard let r = rubric(kind, id) else { throw Proc.AIError(errorDescription: "Nothing to grade against.") }
        let g: Grade
        do { g = try await Proc.gradeExplain(question: r.question, keyPoints: r.keyPoints, answer: answer) } catch {
            print("grade failed:", error)
            throw Proc.AIError(errorDescription: "AI grading is unavailable right now. Use the checklist.")
        }
        let best = _db.one("SELECT MAX(score) AS s FROM grades WHERE kind = ? AND ref = ?", kind, id)?.int("s") ?? 0
        _db.run("INSERT INTO grades (kind, ref, ts, score, json) VALUES (?, ?, ?, ?, ?)", kind, id, Dates.iso(), g.score,
                String(decoding: try JSONEncoder().encode(g), as: UTF8.self))
        flashXP(addXp(max(0, g.score - best) * XP.gradePerPoint, "grade", "\(kind):\(id)"))
        changed()
        return g
    }

    // MARK: problems

    func latestAttempt(_ pid: String) -> Attempt? {
        db.one("SELECT * FROM attempts WHERE problem_id = ? ORDER BY id DESC LIMIT 1", pid).map(Attempt.init)
    }

    private func everSolved(_ pid: String) -> Bool {
        db.one("SELECT 1 AS x FROM attempts WHERE problem_id = ? AND outcome IS NOT NULL", pid) != nil
    }

    /// A boss fight (started in the web app) is a mock interview: no hints, solutions or tutor until explained.
    func inBoss(_ attemptId: Int) -> Bool { activeBossRun(attemptId: attemptId) != nil }

    /// Continue the latest attempt; `fresh` starts a new one after a finished attempt.
    func startProblem(_ pid: String, fresh: Bool = false) {
        let latest = latestAttempt(pid)
        if latest == nil || (fresh && latest!.finished) {
            _db.run("INSERT INTO attempts (problem_id, started_at) VALUES (?, ?)", pid, Dates.iso())
            changed()
        }
    }

    func unlocks(_ a: Attempt?, hintCount: Int) -> Unlocks {
        guard let a else { return Hints.unlocks(active: 0, hintCount: hintCount) }
        if inBoss(a.id) { return .none }
        return Hints.unlocks(active: a.finished ? 0 : a.activeSeconds, hintCount: hintCount)
    }

    func showSolutions(_ pid: String, _ a: Attempt?) -> Bool {
        guard let a else { return everSolved(pid) }
        return !inBoss(a.id) && (everSolved(pid) || a.solutionViewed)
    }

    func saveCode(_ pid: String, code: String) {
        guard let a = latestAttempt(pid), !a.finished else { return }
        _db.run("UPDATE attempts SET code = ? WHERE id = ?", code, a.id) // no changed(): typing shouldn't re-render the page
    }

    func saveProblemExplain(_ pid: String, text: String) {
        guard let a = latestAttempt(pid) else { return }
        _db.run("UPDATE attempts SET explain = ? WHERE id = ?", text, a.id)
        changed()
    }

    func revealHint(_ pid: String) {
        guard let a = latestAttempt(pid), !a.finished, let p = Content.problem(pid) else { return }
        guard a.hintsUsed < unlocks(a, hintCount: p.hints.count).hintsAvailable else {
            error = "Not unlocked yet. Keep struggling a bit longer."
            return
        }
        _db.run("UPDATE attempts SET hints_used = hints_used + 1 WHERE id = ?", a.id)
        changed()
    }

    func revealSolution(_ pid: String) {
        guard let a = latestAttempt(pid), !a.finished else { return }
        guard unlocks(a, hintCount: 0).solutionAvailable else {
            error = "Solutions unlock after 30 min of active work."
            return
        }
        _db.run("UPDATE attempts SET solution_viewed = 1 WHERE id = ?", a.id)
        changed()
    }

    func submissions(_ attemptId: Int) -> [Submission] {
        db.all("SELECT id, ts, kind, verdict, passed, total FROM submissions WHERE attempt_id = ? ORDER BY id DESC LIMIT 20", attemptId).map {
            Submission(id: $0.int("id")!, ts: $0.str("ts")!, kind: $0.str("kind")!, verdict: $0.str("verdict")!,
                       passed: $0.int("passed")!, total: $0.int("total")!)
        }
    }

    private func logSubmission(_ attemptId: Int, _ kind: String, _ r: JudgeResult, _ code: String) {
        _db.run("INSERT INTO submissions (attempt_id, ts, kind, verdict, passed, total, code) VALUES (?, ?, ?, ?, ?, ?, ?)",
                attemptId, Dates.iso(), kind, r.verdict, r.passed, r.total, code)
    }

    func run(_ pid: String, code: String, custom: [String]) async -> JudgeResult {
        let r = await Proc.judge(problemDir: Content.problemDir(pid), code: code, mode: "run", custom: custom)
        if let a = latestAttempt(pid) { logSubmission(a.id, "run", r, code) }
        changed()
        return r
    }

    /// Returns the outcome when this submit finished the attempt.
    func submit(_ pid: String, code: String) async -> (JudgeResult, Outcome?) {
        let r = await Proc.judge(problemDir: Content.problemDir(pid), code: code, mode: "submit")
        guard let a = latestAttempt(pid) else { return (r, nil) }
        logSubmission(a.id, "submit", r, code)
        var outcome: Outcome?
        if r.verdict == "Accepted" && !a.finished {
            let boss = inBoss(a.id) // boss wins drop their own chest
            _db.run("UPDATE boss_runs SET solved_at = ? WHERE attempt_id = ? AND solved_at IS NULL AND finished_at IS NULL", Dates.iso(), a.id)
            let o = XP.outcome(hints: a.hintsUsed, solutionViewed: a.solutionViewed)
            let firstSolve = !everSolved(pid)
            _db.run("UPDATE attempts SET finished_at = ?, outcome = ?, code = ? WHERE id = ?", Dates.iso(), o.rawValue, code, a.id)
            if firstSolve, let p = Content.problem(pid) {
                flashXP(addXp(XP.solve(p.difficulty, hints: a.hintsUsed, solutionViewed: a.solutionViewed,
                                       optional: Content.problemHome(pid)?.role == .optional), "solve", pid))
                addReview("problem", pid, o)
                if !boss { maybeSolveChest(pid, o) }
            }
            outcome = o
        }
        changed()
        return (r, outcome)
    }

    // MARK: tutor

    func tutorMessages(_ attemptId: Int) -> [(role: String, text: String)] {
        db.all("SELECT role, text FROM tutor_messages WHERE attempt_id = ? ORDER BY id", attemptId).map { ($0.str("role")!, $0.str("text")!) }
    }

    func askTutor(_ pid: String, message: String, code: String) async throws {
        guard let a = latestAttempt(pid), !a.finished, let p = Content.problem(pid) else { return }
        saveCode(pid, code: code)
        guard !inBoss(a.id) else { throw Proc.AIError(errorDescription: "No tutor in a boss fight.") }
        guard a.hintsUsed >= 1 else { throw Proc.AIError(errorDescription: "The tutor opens after you reveal hint 1.") }
        let text = String(message.trimmingCharacters(in: .whitespacesAndNewlines).prefix(1500))
        let reply: String
        do {
            reply = try await Proc.tutorReply(
                title: p.title, statement: p.statement, hints: Array(p.hints.prefix(a.hintsUsed)), code: code,
                history: tutorMessages(a.id) + [("user", text)])
        } catch {
            print("tutor failed:", error)
            throw Proc.AIError(errorDescription: "The tutor is unavailable right now. Try again in a minute.")
        }
        _db.run("INSERT INTO tutor_messages (attempt_id, ts, role, text) VALUES (?, ?, ?, ?)", a.id, Dates.iso(), "user", text)
        _db.run("INSERT INTO tutor_messages (attempt_id, ts, role, text) VALUES (?, ?, ?, ?)", a.id, Dates.iso(), "tutor", reply)
        changed()
    }

    // MARK: reviews

    func dueReviews() -> [ReviewItem] {
        db.all("SELECT * FROM reviews WHERE due <= ? ORDER BY due", Dates.local()).map { r in
            let type = r.str("item_type")!, id = r.str("item_id")!, idx = r.int("interval_idx")!
            let interval = SRS.intervals[idx], pass = SRS.intervals[min(idx + 1, SRS.intervals.count - 1)], fail = SRS.intervals[0]
            if type == "problem", Content.hasProblem(id), let p = Content.problem(id) {
                return ReviewItem(
                    type: type, itemId: id, title: p.title,
                    prompt: "Without looking: what's the approach, and its time/space complexity? Say it out loud or write it.",
                    difficulty: p.difficulty, interval: interval, passNext: pass, failNext: fail,
                    keyPoints: p.keyPoints, reference: p.solutions.first(where: \.reference))
            }
            let t = Content.topic(id)
            return ReviewItem(type: type, itemId: id, title: t?.title ?? id, prompt: t?.explain.prompt ?? "", difficulty: nil,
                              interval: interval, passNext: pass, failNext: fail, keyPoints: t?.explain.keyPoints ?? [], reference: nil)
        }
    }

    func upcomingReviews() -> [(type: String, id: String, title: String, due: String)] {
        db.all("SELECT item_type, item_id, due FROM reviews WHERE due > ? ORDER BY due LIMIT 10", Dates.local()).map {
            let type = $0.str("item_type")!, id = $0.str("item_id")!
            let title = type == "problem" ? Content.problem(id)?.title : Content.topic(id)?.title
            return (type, id, title ?? id, $0.str("due")!)
        }
    }

    /// Same XP either way, so admitting you forgot costs nothing.
    func gradeReview(_ item: ReviewItem, passed: Bool) {
        guard let row = _db.one("SELECT interval_idx FROM reviews WHERE item_type = ? AND item_id = ?", item.type, item.itemId) else { return }
        let n = SRS.next(row.int("interval_idx")!, passed: passed, today: Dates.local())
        _db.run("UPDATE reviews SET interval_idx = ?, due = ?, last_result = ? WHERE item_type = ? AND item_id = ?",
                n.idx, n.due, passed ? "pass" : "fail", item.type, item.itemId)
        flashXP(addXp(XP.review, "review", item.id))
        changed()
    }
}
