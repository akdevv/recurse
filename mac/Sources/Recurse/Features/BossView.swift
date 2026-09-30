import SwiftUI

struct BossCountdown: View {
    let deadline: Date
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { ctx in
            let left = max(0, Int(deadline.timeIntervalSince(ctx.date)))
            Label(left == 0 ? "Time's up" : fmtClock(left), systemImage: "figure.fencing")
                .labelStyle(.titleAndIcon)
                .fixedSize()
                .padding(.horizontal, 12)
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
                    HStack(spacing: 14) {
                        Medal(icon: "figure.fencing", metal: .gold, size: 52)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Fight in progress").font(.caption.weight(.medium)).foregroundStyle(.warning)
                            Text(active.problemTitle).font(.headline)
                        }
                        Spacer()
                        BossCountdown(deadline: active.deadline)
                        Button("Give Up") { store.abandonBoss(active.id) }.buttonStyle(.glass).tint(.raised)
                        Button { nav.go(.problem(active.problemId)) } label: { Label("Back to the Problem", systemImage: "arrow.right") }
                            .buttonStyle(.glassProminent)
                    }
                    .buttonBorderShape(.capsule)
                    .card(padding: 18)
                } else {
                    intro(m, beaten: beaten, topicsLeft: topicsLeft, available: available)
                }

                let past = runs.filter(\.finished)
                if !past.isEmpty {
                    Text("Past attempts").font(.headline).padding(.top, 8)
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
                            .padding(.horizontal, 16).frame(height: 40)
                            if i < past.count - 1 { Divider() }
                        }
                    }
                    .surface(clip: true)
                }
            }
            .padding(28)
            .frame(maxWidth: 680)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Boss fight")
        .navigationSubtitle(m.title)
    }

    private func intro(_ m: Module, beaten: Bool, topicsLeft: Int, available: Bool) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Medal(icon: "figure.fencing", metal: beaten ? .jade : .gold, size: 108)
                    .background { Circle().fill((beaten ? Color.success : .warning).opacity(0.16)).blur(radius: 24) }
                    .padding(.bottom, 4)
                Text("Module \(m.number) · Boss fight" + (beaten ? " · beaten" : "")).font(.caption.weight(.semibold))
                    .textCase(.uppercase).tracking(1).foregroundStyle(beaten ? Color.success : .warning)
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
                Label(err.isEmpty ? "\(topicsLeft) \(topicsLeft == 1 ? "topic" : "topics") left in this module. You can still try, but it's meant for the end." : err,
                      systemImage: err.isEmpty ? "info.circle" : "exclamationmark.triangle.fill")
                    .font(.callout).foregroundStyle(err.isEmpty ? Color.muted : .danger)
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20).padding(.vertical, 12)
            }
            Divider()
            HStack {
                if beaten { Text("Beaten before. Replays are for practice.").font(.callout).foregroundStyle(.muted) }
                else { Text("\(Text("+\(Store.bossXP) XP").foregroundStyle(.warning).fontWeight(.semibold))\(Text(" on your first win, and a chest every win").foregroundStyle(.muted))").font(.callout) }
                Spacer()
                Button {
                    if let pid = store.startBoss(moduleId) { nav.go(.problem(pid)) } else { err = "This module has no problems yet." }
                } label: { Label(available ? "Start the Fight" : "No Problems Yet", systemImage: "figure.fencing") }
                    .buttonStyle(.glassProminent).buttonBorderShape(.capsule).controlSize(.large)
                    .disabled(!available)
            }
            .padding(.horizontal, 20).padding(.vertical, 16)
        }
        .surface()
    }

    private func fact(_ value: String, _ label: String, _ hint: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(.title2, design: .rounded).weight(.semibold)).monospacedDigit()
            Text(label).font(.caption.weight(.semibold))
            Text(hint).font(.caption).foregroundStyle(.muted)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 18)
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
            Label("Solved \(run.problemTitle) in \(fmtClock(run.solvedIn ?? 0))", systemImage: "checkmark.circle.fill")
                .font(.callout.weight(.medium).monospacedDigit()).foregroundStyle(.success)
            Text("Nice. Now walk me through it: your approach, why it's correct, and the time and space complexity.")
                .font(.title3).lineSpacing(3).fixedSize(horizontal: false, vertical: true)
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
                    if busy { ProgressView().controlSize(.small) } else { Text("Submit to Interviewer") }
                }
                .buttonStyle(.glassProminent).buttonBorderShape(.capsule).controlSize(.large)
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
                Medal(icon: passed ? "figure.fencing" : "xmark", metal: passed ? .jade : .locked, size: 96)
                Text(passed ? "Boss defeated" : "Not this time").font(.title2.weight(.semibold))
                Text("Solved in \(fmtClock(r.run.solvedIn ?? 0))" + (r.inTime ? "" : " (over time)") + " · explanation \(r.grade.score)/5"
                     + (r.xp > 0 ? " · +\(r.xp) XP" : ""))
                    .font(.callout.monospacedDigit()).foregroundStyle(.secondary)
            }
            .padding(24)
            Divider()
            VStack(alignment: .leading, spacing: 10) {
                Text("Interviewer's notes").font(.headline)
                Text(r.grade.feedback).foregroundStyle(.primary.opacity(0.85)).fixedSize(horizontal: false, vertical: true)
                if !r.grade.followUp.isEmpty {
                    Text("\(Text("Follow-up  ").foregroundStyle(.muted).fontWeight(.medium))\(Text(r.grade.followUp))")
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.leading, 10)
                        .overlay(alignment: .leading) { Capsule().fill(.hairline).frame(width: 2) }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(20)
            Divider()
            HStack {
                Spacer()
                Button("Review the Solution") { nav.go(.problem(r.run.problemId)) }.buttonStyle(.glass).tint(.raised)
                Button(passed ? "Done" : "Try Again", action: again).buttonStyle(.glassProminent)
            }
            .buttonBorderShape(.capsule).controlSize(.large)
            .padding(16)
        }
        .surface()
    }
}
