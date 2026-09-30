import Foundation

struct BossRun: Identifiable {
    let id, attemptId, limitS: Int
    let moduleId, problemId, startedAt: String
    let solvedAt, finishedAt: String?
    let score: Int?
    let passed: Bool?

    init(_ r: Row) {
        id = r.int("id")!
        attemptId = r.int("attempt_id")!
        limitS = r.int("limit_s")!
        moduleId = r.str("module_id")!
        problemId = r.str("problem_id")!
        startedAt = r.str("started_at")!
        solvedAt = r.str("solved_at")
        finishedAt = r.str("finished_at")
        score = r.int("score")
        passed = r.int("passed").map { $0 != 0 }
    }

    var started: Date { Dates.fromIso(startedAt) ?? .now }
    /// Wall clock: an interview doesn't pause when you look away.
    var deadline: Date { started.addingTimeInterval(TimeInterval(limitS)) }
    var solvedIn: Int? { solvedAt.flatMap(Dates.fromIso).map { Int($0.timeIntervalSince(started).rounded()) } }
    var finished: Bool { finishedAt != nil }
    @MainActor var problemTitle: String { Content.problem(problemId)?.title ?? problemId }
}

struct BossResult {
    let run: BossRun
    let grade: Grade
    let inTime: Bool
    let xp: Int
}

extension Store {
    static let bossXP = 100
    static let bossPassScore = 3

    func bossRuns(_ moduleId: String) -> [BossRun] {
        db.all("SELECT * FROM boss_runs WHERE module_id = ? ORDER BY id DESC LIMIT 10", moduleId).map(BossRun.init)
    }

    func bossWon(_ moduleId: String) -> Bool {
        db.one("SELECT 1 AS x FROM boss_runs WHERE module_id = ? AND passed = 1", moduleId) != nil
    }

    func activeBossRun(attemptId: Int) -> BossRun? {
        db.one("SELECT * FROM boss_runs WHERE attempt_id = ? AND finished_at IS NULL", attemptId).map(BossRun.init)
    }

    /// The module's playable core/guided problems: the unsolved ones, or all once every one is solved.
    func bossCandidates(_ moduleId: String) -> [String] {
        let statuses = problemStatuses()
        let ids = (Content.module(moduleId)?.topics ?? []).flatMap { Content.topic($0)?.problems ?? [] }
            .filter { $0.role != .optional && Content.hasProblem($0.id) }.map(\.id)
            .uniqued { $0 }
        let fresh = ids.filter { !Store.isSolved(statuses[$0]) }
        return fresh.isEmpty ? ids : fresh
    }

    /// Starts a run on a random candidate (abandoning any open one) and returns its problem id.
    func startBoss(_ moduleId: String) -> String? {
        guard let m = Content.module(moduleId), let pid = bossCandidates(moduleId).randomElement() else { return nil }
        let now = Dates.iso()
        _db.run("UPDATE boss_runs SET finished_at = ?, passed = 0 WHERE module_id = ? AND finished_at IS NULL", now, moduleId)
        let aid = _db.run("INSERT INTO attempts (problem_id, started_at) VALUES (?, ?)", pid, now)
        _db.run("INSERT INTO boss_runs (module_id, problem_id, attempt_id, started_at, limit_s) VALUES (?, ?, ?, ?, ?)",
                moduleId, pid, aid, now, m.boss.timeLimitMin * 60)
        changed()
        return pid
    }

    func abandonBoss(_ id: Int) {
        _db.run("UPDATE boss_runs SET finished_at = ?, passed = 0 WHERE id = ? AND finished_at IS NULL", Dates.iso(), id)
        changed()
    }

    func finishBoss(_ id: Int, text: String) async throws -> BossResult {
        guard let r = _db.one("SELECT * FROM boss_runs WHERE id = ?", id).map(BossRun.init), !r.finished else {
            throw Proc.AIError(errorDescription: "This boss fight is already over.")
        }
        guard let solvedIn = r.solvedIn, let p = Content.problem(r.problemId) else {
            throw Proc.AIError(errorDescription: "Solve the problem first.")
        }
        let grade: Grade
        do {
            grade = try await Proc.gradeExplain(
                question: "You just solved \"\(p.title)\" in a timed interview. Walk me through it: the approach, why it's correct, and the time and space complexity.",
                keyPoints: p.keyPoints, answer: text)
        } catch {
            print("boss grading failed:", error)
            throw Proc.AIError(errorDescription: "AI grading is unavailable right now. Try again in a minute.")
        }
        let inTime = solvedIn <= r.limitS
        let passed = inTime && grade.score >= Store.bossPassScore
        let firstWin = passed && !bossWon(r.moduleId)
        _db.run("UPDATE boss_runs SET finished_at = ?, score = ?, passed = ? WHERE id = ?", Dates.iso(), grade.score, passed, id)
        saveGrade("boss", r.moduleId, grade)
        let xp = firstWin ? addXp(Store.bossXP, "boss", r.moduleId) : 0
        flashXP(xp)
        // one chest per module per day, so re-running a boss can't farm them
        let today = Dates.local()
        let chestToday = _db.all("SELECT ts FROM chests WHERE source = 'boss' AND ref = ?", r.moduleId)
            .contains { $0.str("ts").flatMap(Dates.fromIso).map(Dates.local) == today }
        if passed && !chestToday { earnChest("boss", r.moduleId) }
        changed()
        return BossResult(run: _db.one("SELECT * FROM boss_runs WHERE id = ?", id).map(BossRun.init)!, grade: grade, inTime: inTime, xp: xp)
    }
}
