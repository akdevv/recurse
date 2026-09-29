// Boss fights: a timed mock interview closing each module. Port of web/server/boss.ts.
import SwiftUI

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

    func activeBossRun(attemptId: Int) -> BossRun? {
        db.one("SELECT * FROM boss_runs WHERE attempt_id = ? AND finished_at IS NULL", attemptId).map(BossRun.init)
    }

    /// The module's playable core/guided problems: the unsolved ones, or all once every one is solved.
    func bossCandidates(_ moduleId: String) -> [String] {
        let statuses = problemStatuses()
        var seen = Set<String>()
        let ids = Content.module(moduleId).topics.flatMap { Content.topic($0)?.problems ?? [] }
            .filter { $0.role != .optional && Content.hasProblem($0.id) }.map(\.id)
            .filter { seen.insert($0).inserted }
        let fresh = ids.filter { !Store.isSolved(statuses[$0]) }
        return fresh.isEmpty ? ids : fresh
    }

    /// Starts a run on a random candidate (abandoning any open one) and returns its problem id.
    func startBoss(_ moduleId: String) -> String? {
        guard let pid = bossCandidates(moduleId).randomElement() else { return nil }
        let now = Dates.iso()
        _db.run("UPDATE boss_runs SET finished_at = ?, passed = 0 WHERE module_id = ? AND finished_at IS NULL", now, moduleId)
        let aid = _db.run("INSERT INTO attempts (problem_id, started_at) VALUES (?, ?)", pid, now)
        _db.run("INSERT INTO boss_runs (module_id, problem_id, attempt_id, started_at, limit_s) VALUES (?, ?, ?, ?, ?)",
                moduleId, pid, aid, now, Content.module(moduleId).boss.timeLimitMin * 60)
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
        let firstWin = passed && _db.one("SELECT 1 AS x FROM boss_runs WHERE module_id = ? AND passed = 1", r.moduleId) == nil
        _db.run("UPDATE boss_runs SET finished_at = ?, score = ?, passed = ? WHERE id = ?", Dates.iso(), grade.score, passed, id)
        _db.run("INSERT INTO grades (kind, ref, ts, score, json) VALUES ('boss', ?, ?, ?, ?)", r.moduleId, Dates.iso(), grade.score,
                String(decoding: try JSONEncoder().encode(grade), as: UTF8.self))
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

// MARK: views

struct BossCountdown: View {
    let deadline: Date
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { ctx in
            let left = max(0, Int(deadline.timeIntervalSince(ctx.date)))
            Label(left == 0 ? "Time's up" : fmtClock(left), systemImage: "figure.fencing")
                .labelStyle(.titleAndIcon)
                .font(.callout.weight(.medium).monospacedDigit())
                .foregroundStyle(left < 300 ? .danger : .warning)
                .help("Boss fight: time left")
        }
    }
}

struct BossView: View {
    @Environment(Store.self) private var store
    @Environment(Nav.self) private var nav
    let moduleId: String
    @State private var result: BossResult?
    @State private var err = ""

    var body: some View {
        let m = Content.module(moduleId)
        let runs = store.bossRuns(moduleId)
        let active = runs.first { !$0.finished }
        let beaten = runs.contains { $0.passed == true }
        let topicsLeft = store.moduleViews().first { $0.id == moduleId }?.topics.filter { !$0.status.complete }.count ?? 0
        let available = !store.bossCandidates(moduleId).isEmpty

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let result {
                    ResultCard(r: result) { self.result = nil }
                } else if let active, active.solvedAt != nil {
                    ExplainStep(run: active) { result = $0 }
                } else if let active {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("In progress").font(.caption).foregroundStyle(.secondary)
                            Text(active.problemTitle).font(.headline)
                        }
                        Spacer()
                        BossCountdown(deadline: active.deadline)
                        Button("Give up") { store.abandonBoss(active.id) }.buttonStyle(.glass)
                        Button { nav.go(.problem(active.problemId)) } label: { Label("Back to the problem", systemImage: "arrow.right") }
                            .buttonStyle(.glassProminent)
                    }
                    .card(padding: 18)
                } else {
                    intro(m, beaten: beaten, topicsLeft: topicsLeft, available: available)
                }

                let past = runs.filter(\.finished)
                if !past.isEmpty {
                    Text("Past attempts").font(.caption.weight(.medium)).foregroundStyle(.secondary)
                    VStack(spacing: 0) {
                        ForEach(Array(past.enumerated()), id: \.element.id) { i, r in
                            HStack(spacing: 10) {
                                Image(systemName: r.passed == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(r.passed == true ? .success : .danger)
                                Text(r.problemTitle)
                                Spacer()
                                Text((r.solvedIn.map(fmtClock) ?? "unsolved") + (r.score.map { " · \($0)/5" } ?? ""))
                                    .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                                Text(short(r.startedAt)).font(.caption).foregroundStyle(.secondary).frame(width: 56, alignment: .trailing)
                            }
                            .padding(.vertical, 8)
                            if i < past.count - 1 { Divider() }
                        }
                    }
                    .card(padding: 14)
                }
            }
            .padding(28)
            .frame(maxWidth: 680)
            .frame(maxWidth: .infinity)
            .backdrop(beaten ? .success : .warning, height: 420)
        }
        .navigationTitle("Boss fight")
        .navigationSubtitle(m.title)
    }

    private func intro(_ m: Module, beaten: Bool, topicsLeft: Int, available: Bool) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Image(systemName: "figure.fencing").font(.system(size: 44)).foregroundStyle(beaten ? .success : .warning)
                    .frame(width: 96, height: 96)
                    .background(RadialGradient(colors: [(beaten ? Color.success : .warning).opacity(0.22), .clear], center: .center, startRadius: 0, endRadius: 60))
                Text("Module \(m.number) · Boss fight" + (beaten ? " · beaten" : "")).font(.caption.weight(.semibold))
                    .textCase(.uppercase).tracking(1).foregroundStyle(.warning)
                Text(m.title).font(.largeTitle.weight(.semibold))
                Text("A mock interview to close the module. One problem, a clock, and an interviewer waiting at the end.")
                    .foregroundStyle(.secondary).multilineTextAlignment(.center).frame(maxWidth: 420)
            }
            .padding(.vertical, 28).padding(.horizontal, 24)
            Divider()
            HStack(spacing: 0) {
                fact("1", "problem", "unseen ones first")
                Divider()
                fact("\(m.boss.timeLimitMin):00", "on the clock", "no pausing")
                Divider()
                fact("0", "hints", "no solutions either")
                Divider()
                fact("3/5", "to pass", "solve it, then explain it")
            }
            .fixedSize(horizontal: false, vertical: true)
            if topicsLeft > 0 || !err.isEmpty {
                Divider()
                Text(err.isEmpty ? "\(topicsLeft) \(topicsLeft == 1 ? "topic" : "topics") left in this module. You can still try, but it's meant for the end." : err)
                    .font(.caption).foregroundStyle(err.isEmpty ? Color.warning : .danger)
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20).padding(.vertical, 10)
            }
            Divider()
            HStack {
                if beaten { Text("Beaten before. Replays are for practice.").font(.caption).foregroundStyle(.secondary) }
                else { Text("\(Text("+\(Store.bossXP) XP").foregroundStyle(.warning).fontWeight(.medium))\(Text(" on your first win").foregroundStyle(.secondary))").font(.caption) }
                Spacer()
                Button {
                    if let pid = store.startBoss(moduleId) { nav.go(.problem(pid)) } else { err = "This module has no problems yet." }
                } label: { Label(available ? "Start the fight" : "No problems yet", systemImage: "figure.fencing") }
                    .buttonStyle(.glassProminent).controlSize(.large)
                    .disabled(!available)
            }
            .padding(16)
        }
        .background(.surface, in: .rect(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(.hairline))
    }

    private func fact(_ value: String, _ label: String, _ hint: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.title3.weight(.semibold).monospacedDigit())
            Text(label).font(.caption.weight(.medium))
            Text(hint).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
    }
}

private struct ExplainStep: View {
    @Environment(Store.self) private var store
    let run: BossRun
    let done: (BossResult) -> Void
    @State private var text = ""
    @State private var busy = false
    @State private var err = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Interviewer", systemImage: "quote.bubble").font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("Solved \(run.problemTitle) in \(fmtClock(run.solvedIn ?? 0))").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            }
            Text("Nice. Now walk me through it: your approach, why it's correct, and the time and space complexity.")
                .font(.title3.weight(.medium))
            TextArea(text: $text, placeholder: "Talk it through like you would in the room.", minHeight: 170)
            HStack {
                Text(err.isEmpty ? (busy ? "The interviewer is thinking…" : "Graded honestly, 0–5.") : err)
                    .font(.caption).foregroundStyle(err.isEmpty ? Color.secondary : .danger)
                Spacer()
                Button {
                    busy = true
                    err = ""
                    Task {
                        do { done(try await store.finishBoss(run.id, text: text)) } catch { err = error.localizedDescription }
                        busy = false
                    }
                } label: {
                    if busy { ProgressView().controlSize(.small) } else { Text("Submit to interviewer") }
                }
                .buttonStyle(.glassProminent)
                .disabled(busy || text.trimmingCharacters(in: .whitespacesAndNewlines).count < 40)
            }
        }
        .card(padding: 20)
    }
}

private struct ResultCard: View {
    @Environment(Nav.self) private var nav
    let r: BossResult
    let again: () -> Void

    var body: some View {
        let passed = r.run.passed == true
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Image(systemName: passed ? "checkmark.circle.fill" : "xmark.circle.fill").font(.system(size: 44))
                    .foregroundStyle(passed ? .success : .danger)
                Text(passed ? "Boss defeated" : "Not this time").font(.title2.weight(.semibold))
                Text("Solved in \(fmtClock(r.run.solvedIn ?? 0))" + (r.inTime ? "" : " (over time)") + " · explanation \(r.grade.score)/5"
                     + (r.xp > 0 ? " · +\(r.xp) XP" : ""))
                    .font(.callout.monospacedDigit()).foregroundStyle(.secondary)
            }
            .padding(24)
            Divider()
            VStack(alignment: .leading, spacing: 10) {
                Text(r.grade.feedback)
                if !r.grade.followUp.isEmpty { Text("\(Text("Follow-up: ").foregroundStyle(.secondary))\(Text(r.grade.followUp))") }
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(20)
            Divider()
            HStack {
                Spacer()
                Button(passed ? "Done" : "Try again", action: again).buttonStyle(.glass)
                Button("Review the solution") { nav.go(.problem(r.run.problemId)) }.buttonStyle(.glass)
            }
            .padding(14)
        }
        .background(.surface, in: .rect(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(.hairline))
    }
}
