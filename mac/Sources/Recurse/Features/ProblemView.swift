import SwiftUI

struct ProblemView: View {
    @Environment(Store.self) private var store
    @Environment(Activity.self) private var activity
    @Environment(Nav.self) private var nav
    let pid: String

    @State private var p: Problem?
    @State private var code = ""
    @State private var custom = ""
    @State private var busy: String?
    @State private var output: (kind: String, res: JudgeResult, outcome: Outcome?)?
    @State private var tab = "statement"
    @State private var consoleTab = "result"
    @State private var saveTask: Task<Void, Never>?
    @FocusState private var tutorFocused: Bool // ⌘↵ sends to the tutor instead of running

    var body: some View {
        Group {
            if let p {
                let a = store.latestAttempt(pid)
                HSplitView {
                    DescriptionPane(p: p, a: a, tab: $tab, tutorFocused: $tutorFocused, code: { code })
                        .frame(minWidth: 340, idealWidth: 480)
                    VSplitView {
                        VStack(spacing: 0) {
                            EditorBar(starter: p.starter, code: $code)
                            CodeEditor(text: $code)
                        }
                        .frame(minHeight: 200)
                        .background(Color.canvas)
                            .onChange(of: code) { _, c in autosave(c) }
                        ConsolePane(p: p, a: a, custom: $custom, tab: $consoleTab, busy: busy, output: output)
                            .frame(minHeight: 160, idealHeight: 260)
                    }
                    .frame(minWidth: 420)
                }
                .toolbar { toolbar(p, a) }
                .navigationTitle(p.title)
                .navigationSubtitle(Content.problemHome(pid)?.topic.title ?? "")
            } else {
                ProgressView()
            }
        }
        .task {
            store.startProblem(pid)
            p = Content.problem(pid)
            code = store.latestAttempt(pid)?.code ?? p?.starter ?? ""
            if let t = DevSnapshots.problemTab { tab = t }
        }
        .onDisappear {
            saveTask?.cancel()
            store.saveCode(pid, code: code)
        }
    }

    @ToolbarContentBuilder
    private func toolbar(_ p: Problem, _ a: Attempt?) -> some ToolbarContent {
        let boss = a.flatMap { store.activeBossRun(attemptId: $0.id) }
        ToolbarItemGroup(placement: .primaryAction) {
            if let boss {
                if a?.finished == true {
                    Button { nav.go(.boss(boss.moduleId)) } label: { Label("Finish the boss fight", systemImage: "figure.fencing") }
                        .buttonStyle(.glassProminent)
                } else {
                    BossCountdown(deadline: boss.deadline)
                }
            } else if let a, a.finished {
                Label(a.outcome?.label ?? "Solved", systemImage: "checkmark.circle.fill").foregroundStyle(.success).labelStyle(.titleAndIcon)
                    .font(.callout.weight(.medium)).fixedSize().padding(.horizontal, 12)
                Button {
                    store.startProblem(pid, fresh: true)
                    code = p.starter
                    output = nil
                } label: { Label("Solve Again", systemImage: "arrow.counterclockwise") }
                .help("Start a fresh attempt")
            } else if let a {
                AttemptClock(pid: pid, base: a.activeSeconds)
            }
        }
        ToolbarSpacer(.fixed, placement: .primaryAction)
        ToolbarItemGroup(placement: .primaryAction) {
            Button { judge("run") } label: {
                if busy == "run" { ProgressView().controlSize(.small) } else { Label("Run", systemImage: "play.fill") }
            }
            .keyboardShortcut(tutorFocused ? nil : KeyboardShortcut(.return, modifiers: .command))
            .help("Run against the examples (⌘↵)")
            .disabled(busy != nil)
            Button { judge("submit") } label: {
                if busy == "submit" { ProgressView().controlSize(.small) } else { Label("Submit", systemImage: "paperplane.fill").labelStyle(.titleAndIcon) }
            }
            .keyboardShortcut(.return, modifiers: [.command, .shift])
            .help("Submit against all tests (⌘⇧↵)")
            .buttonStyle(.glassProminent)
            .disabled(busy != nil)
        }
    }

    private func autosave(_ c: String) {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: .milliseconds(800))
            if !Task.isCancelled { store.saveCode(pid, code: c) }
        }
    }

    private func judge(_ kind: String) {
        guard busy == nil else { return }
        busy = kind
        consoleTab = "result"
        let c = code, inputs = custom.trimmingCharacters(in: .whitespacesAndNewlines)
        Task {
            if kind == "run" {
                output = (kind, await store.run(pid, code: c, custom: inputs.isEmpty ? [] : [inputs]), nil)
            } else {
                let (r, o) = await store.submit(pid, code: c)
                output = (kind, r, o)
            }
            busy = nil
        }
    }
}

/// Strip above the editor: the file, the language and a reset to the starter code.
private struct EditorBar: View {
    let starter: String
    @Binding var code: String
    @State private var confirmReset = false

    var body: some View {
        HStack(spacing: 10) {
            Label("solution.py", systemImage: "doc.text").font(.caption.weight(.medium)).foregroundStyle(.secondary)
            Text("Python 3").font(.caption).foregroundStyle(.muted)
                .padding(.horizontal, 7).padding(.vertical, 2).background(.raised, in: .capsule)
            Spacer()
            Button { confirmReset = true } label: { Label("Reset", systemImage: "arrow.counterclockwise").font(.caption) }
                .buttonStyle(.borderless).foregroundStyle(.muted)
                .disabled(code == starter)
                .help("Replace your code with the starter code")
                .confirmationDialog("Reset to the starter code?", isPresented: $confirmReset) {
                    Button("Reset", role: .destructive) { code = starter }
                } message: { Text("Your current code will be replaced.") }
        }
        .padding(.horizontal, 14).frame(height: 34)
        .overlay(alignment: .bottom) { Divider() }
    }
}

private struct AttemptClock: View {
    @Environment(Activity.self) private var activity
    let pid: String
    let base: Int
    var body: some View {
        Label(fmtClock(base + activity.pending(for: pid)), systemImage: "timer")
            .labelStyle(.titleAndIcon)
            .fixedSize()
            .padding(.horizontal, 12)
            .font(.callout.monospacedDigit())
            .foregroundStyle(.secondary)
            .help("Active time on this attempt")
    }
}

// MARK: left pane

private struct DescriptionPane: View {
    @Environment(Store.self) private var store
    let p: Problem
    let a: Attempt?
    @Binding var tab: String
    var tutorFocused: FocusState<Bool>.Binding
    let code: () -> String

    var body: some View {
        let revealed = a.map { $0.finished ? p.hints.count : $0.hintsUsed } ?? 0
        let boss = a.map { store.inBoss($0.id) } ?? false
        let solutions = store.showSolutions(p.id, a)
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                GlassTabs(selection: $tab, tabs: [
                    .init(id: "statement", title: "Description", icon: "doc.text"),
                    .init(id: "hints", title: "Hints \(revealed)/\(p.hints.count)", icon: "lightbulb"),
                    .init(id: "tutor", title: "Tutor", icon: (a?.hintsUsed ?? 0) >= 1 && !boss ? "bubble.left" : "lock"),
                    .init(id: "solutions", title: "Solutions", icon: solutions ? "flask" : "lock"),
                    .init(id: "submissions", title: "Submissions", icon: "clock.arrow.circlepath"),
                ])
                .padding(.horizontal, 10).padding(.vertical, 8)
            }
            Divider()

            ScrollView {
                Group {
                    switch tab {
                    case "hints": HintsTab(p: p, a: a, boss: boss)
                    case "tutor": TutorTab(p: p, a: a, boss: boss, focused: tutorFocused, code: code) { tab = "hints" }
                    case "solutions": SolutionsTab(p: p, a: a, show: solutions)
                    case "submissions": SubmissionsTab(a: a)
                    default: statement
                    }
                }
                .padding(.horizontal, 24).padding(.vertical, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color.surface)
    }

    private var statement: some View {
        let home = Content.problemHome(p.id)
        return VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    if let lc = p.lc { Text("#\(String(format: "%04d", lc))").font(.title3.monospacedDigit()).foregroundStyle(.muted) }
                    Text(p.title).font(.title2.weight(.semibold))
                }
                HStack(spacing: 8) {
                    DifficultyBadge(d: p.difficulty)
                    if let role = home?.role, role != .core { Chip(text: role.rawValue.capitalized) }
                    if let topic = home?.topic.title { Chip(text: topic, icon: "book") }
                }
            }
            Divider()
            MarkdownView(text: p.statement, compact: true)
        }
    }
}

private struct Chip: View {
    let text: String
    var icon: String?
    var body: some View {
        HStack(spacing: 4) {
            if let icon { Image(systemName: icon).font(.system(size: 9, weight: .semibold)) }
            Text(text)
        }
        .font(.caption.weight(.medium)).foregroundStyle(.muted)
        .padding(.horizontal, 8).padding(.vertical, 2)
        .background(.raised, in: .capsule)
    }
}

private struct HintsTab: View {
    @Environment(Store.self) private var store
    @Environment(Activity.self) private var activity
    let p: Problem
    let a: Attempt?
    let boss: Bool

    var body: some View {
        let open = a.map { !$0.finished } ?? false
        let shown = a.map { $0.finished ? p.hints.count : $0.hintsUsed } ?? 0
        let active = (a?.activeSeconds ?? 0) + activity.pending(for: p.id)
        let u = store.unlocks(a, hintCount: p.hints.count)
        let ready = u.hintsAvailable > shown || (u.nextHintAt.map { active >= $0 } ?? false)
        VStack(alignment: .leading, spacing: 12) {
            if !boss {
                Text("Hints unlock with active time on this attempt. Each one you reveal costs 25% of the XP, so try first.")
                    .font(.callout).foregroundStyle(.secondary)
            }
            ForEach(0..<shown, id: \.self) { i in
                VStack(alignment: .leading, spacing: 6) {
                    Label("Hint \(i + 1)", systemImage: "lightbulb.fill").font(.caption.weight(.medium)).foregroundStyle(.warning)
                    Text(MD.inline(p.hints[i]))
                }
                .card(padding: 12)
            }
            if open && !boss && shown < p.hints.count {
                HStack {
                    Label("Hint \(shown + 1)", systemImage: "lock").foregroundStyle(.secondary)
                    if !ready, let at = u.nextHintAt {
                        Text("· unlocks in \(fmtClock(at - active))").font(.callout.monospacedDigit()).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if ready {
                        Button("Reveal hint \(shown + 1)") {
                            activity.flush() // unlocks are decided from recorded time
                            store.revealHint(p.id)
                        }.buttonStyle(.glass)
                    }
                }
                .padding(12)
                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4])).foregroundStyle(.separator))
            }
            if shown == 0 && (!open || boss) {
                ContentUnavailableView(boss ? "No hints in a boss fight" : "No hints used on this attempt", systemImage: "lightbulb")
            }
        }
    }
}

private struct SolutionsTab: View {
    @Environment(Store.self) private var store
    @Environment(Activity.self) private var activity
    let p: Problem
    let a: Attempt?
    let show: Bool

    var body: some View {
        if show {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(Array(p.solutions.enumerated()), id: \.offset) { i, s in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Text("\(i + 1).").foregroundStyle(.secondary)
                            Text(s.title).font(.headline)
                            if s.reference {
                                Text("Optimal").font(.caption.weight(.medium)).foregroundStyle(.success)
                                    .padding(.horizontal, 7).padding(.vertical, 2).background(Color.success.opacity(0.12), in: .capsule)
                            }
                            Spacer()
                            Text("\(s.time) time · \(s.space) space").font(.caption.monospaced()).foregroundStyle(.secondary)
                        }
                        MarkdownView(text: s.notes + "\n\n```python\n" + s.code + "```", compact: true)
                    }
                    if i < p.solutions.count - 1 { Divider() }
                }
            }
        } else {
            let open = a.map { !$0.finished } ?? false
            let active = (a?.activeSeconds ?? 0) + activity.pending(for: p.id)
            let u = store.unlocks(a, hintCount: p.hints.count)
            let ready = u.solutionAvailable || (u.solutionAt > 0 && active >= u.solutionAt)
            VStack(spacing: 8) {
                Image(systemName: "lock").font(.title2).foregroundStyle(.secondary)
                Text("\(p.solutions.count) solution\(p.solutions.count == 1 ? "" : "s"), brute force to optimal").fontWeight(.medium)
                Text("Unlocks when you solve it, or after 30 min of active work.").font(.callout).foregroundStyle(.secondary)
                if open && u.solutionAt > 0 {
                    if ready {
                        Button("Show solutions (XP drops to 20%)") {
                            activity.flush()
                            store.revealSolution(p.id)
                        }.buttonStyle(.glass)
                        .padding(.top, 6)
                    } else {
                        Text("Available in \(fmtClock(u.solutionAt - active))").font(.caption.monospacedDigit())
                            .padding(.horizontal, 10).padding(.vertical, 4).background(.quaternary, in: .capsule)
                    }
                }
            }
            .frame(maxWidth: .infinity).padding(.vertical, 40)
        }
    }
}

private struct SubmissionsTab: View {
    @Environment(Store.self) private var store
    let a: Attempt?

    var body: some View {
        let subs = a.map { store.submissions($0.id) } ?? []
        if subs.isEmpty {
            ContentUnavailableView("No runs yet", systemImage: "clock.arrow.circlepath", description: Text("Your runs and submissions show up here."))
        } else {
            VStack(spacing: 0) {
                ForEach(subs) { s in
                    let ok = s.verdict == "Accepted" || s.verdict == "Ran"
                    HStack(spacing: 10) {
                        Image(systemName: ok ? "checkmark.circle.fill" : "xmark.circle.fill").foregroundStyle(ok ? .success : .danger)
                        Text(s.verdict).fontWeight(.medium).foregroundStyle(ok ? .success : .danger)
                        Text(s.kind.capitalized).font(.caption).foregroundStyle(.secondary)
                            .padding(.horizontal, 6).padding(.vertical, 1).background(.quaternary, in: .rect(cornerRadius: 4))
                        Text("\(s.passed)/\(s.total) tests").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                        Spacer()
                        Text(Dates.fromIso(s.ts)?.formatted(.dateTime.day().month().hour().minute()) ?? "")
                            .font(.caption.monospacedDigit()).foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 8)
                    Divider()
                }
            }
        }
    }
}

private struct TutorTab: View {
    @Environment(Store.self) private var store
    let p: Problem
    let a: Attempt?
    let boss: Bool
    var focused: FocusState<Bool>.Binding
    let code: () -> String
    let openHints: () -> Void

    @State private var draft = ""
    @State private var busy = false
    @State private var err = ""

    private static let starters = ["I have an idea but it's too slow", "I don't know where to start", "My code fails a test and I can't see why"]

    var body: some View {
        if boss || (a?.hintsUsed ?? 0) < 1 {
            locked
        } else {
            let msgs = a.map { store.tutorMessages($0.id) } ?? []
            let open = a?.finished == false
            VStack(alignment: .leading, spacing: 16) {
                header
                VStack(alignment: .leading, spacing: 12) {
                    TutorBubble(role: "tutor", text: "I won't give you the answer, but I'll ask questions that get you there. What's your idea so far, and where does it break?")
                    ForEach(Array(msgs.enumerated()), id: \.offset) { _, m in TutorBubble(role: m.role, text: m.text) }
                    if busy { TutorBubble(role: "tutor", text: nil) }
                }
                if open {
                    if msgs.isEmpty && draft.isEmpty && !busy {
                        // conversation starters: one row when they fit, stacked when the pane is narrow
                        ViewThatFits {
                            HStack(spacing: 6) { starters }
                            VStack(alignment: .leading, spacing: 6) { starters }
                        }
                    }
                    composer
                } else {
                    Label("This attempt is finished. The conversation is kept for reference.", systemImage: "archivebox")
                        .font(.callout).foregroundStyle(.muted)
                        .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.canvas.opacity(0.45), in: .rect(cornerRadius: 10, style: .continuous))
                }
            }
        }
    }

    private var starters: some View {
        ForEach(Self.starters, id: \.self) { s in
            Button(s) { draft = s + ": "; focused.wrappedValue = true }
                .buttonStyle(.plain).font(.caption).foregroundStyle(.secondary).fixedSize()
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Color.raised, in: .capsule)
                .overlay(Capsule().strokeBorder(.hairline))
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            TutorAvatar(size: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text("Socratic tutor").font(.headline)
                Text("Asks questions, never hands you the answer. It sees your current code.").font(.caption).foregroundStyle(.muted)
            }
        }
    }

    private var locked: some View {
        VStack(spacing: 14) {
            TutorAvatar(size: 56, locked: true)
            VStack(spacing: 6) {
                Text(boss ? "No tutor in a boss fight" : "The tutor opens after hint 1").font(.headline)
                Text(boss ? "It's a mock interview: you're on your own until you explain your solution."
                          : "Struggle with it first. That's where the learning happens. Once you've revealed a hint, the tutor can help you reason it through.")
                    .font(.callout).foregroundStyle(.secondary).multilineTextAlignment(.center).frame(maxWidth: 340)
            }
            if !boss {
                Button("Go to Hints", systemImage: "lightbulb", action: openHints)
                    .buttonStyle(.glass).tint(.raised).buttonBorderShape(.capsule)
            }
        }
        .frame(maxWidth: .infinity).padding(.vertical, 40)
    }

    private var composer: some View {
        let empty = draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return VStack(alignment: .trailing, spacing: 6) {
            HStack(alignment: .bottom, spacing: 8) {
                TextField("Where are you stuck? Describe your idea, not just “help”.", text: $draft, axis: .vertical)
                    .textFieldStyle(.plain).lineLimit(1...6)
                    .focused(focused)
                    .padding(.vertical, 6)
                Button { send() } label: {
                    Image(systemName: "arrow.up").font(.system(size: 13, weight: .bold)).frame(width: 18, height: 18)
                }
                .buttonStyle(.glassProminent).buttonBorderShape(.circle)
                .keyboardShortcut(focused.wrappedValue ? KeyboardShortcut(.return, modifiers: .command) : nil)
                .disabled(busy || empty)
                .help("Send (⌘↵)")
            }
            .padding(.leading, 14).padding(.trailing, 6).padding(.vertical, 6)
            .background(Color.canvas.opacity(0.55), in: .rect(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(focused.wrappedValue ? Color.brand.opacity(0.5) : Color.hairline))
            Text(err.isEmpty ? "⌘↵ to send" : err).font(.caption).foregroundStyle(err.isEmpty ? Color.muted : .danger)
                .padding(.trailing, 6)
        }
    }

    private func send() {
        let text = draft
        busy = true
        err = ""
        draft = ""
        Task {
            do { try await store.askTutor(p.id, message: text, code: code()) } catch {
                err = error.localizedDescription
                draft = text
            }
            busy = false
        }
    }
}

private struct TutorAvatar: View {
    var size: CGFloat = 28
    var locked = false
    var body: some View {
        Image(systemName: locked ? "lock.fill" : "graduationcap.fill")
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(locked ? Color.muted : Color.brand)
            .frame(width: size, height: size)
            .background(Circle().fill(locked ? Color.raised : Color.brand.opacity(0.14)))
            .overlay(Circle().strokeBorder(locked ? Color.hairline : Color.brand.opacity(0.3)))
    }
}

/// One chat message; `text == nil` is the tutor typing.
private struct TutorBubble: View {
    let role: String
    let text: String?
    @State private var phase = false

    var body: some View {
        let mine = role == "user"
        HStack(alignment: .bottom, spacing: 8) {
            if mine { Spacer(minLength: 48) } else { TutorAvatar(size: 26) }
            Group {
                if let text {
                    Text(text).textSelection(.enabled).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                } else {
                    HStack(spacing: 4) {
                        ForEach(0..<3) { i in
                            Circle().fill(Color.muted).frame(width: 6, height: 6)
                                .opacity(phase ? 1 : 0.3)
                                .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.15), value: phase)
                        }
                    }
                    .padding(.vertical, 4)
                    .onAppear { phase = true }
                }
            }
            .padding(.horizontal, 13).padding(.vertical, 9)
            .background(mine ? Color.brand.opacity(0.16) : Color.raised,
                        in: UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: mine ? 16 : 4,
                                                   bottomTrailingRadius: mine ? 4 : 16, topTrailingRadius: 16, style: .continuous))
            if !mine { Spacer(minLength: 32) }
        }
    }
}

// MARK: console

private struct ConsolePane: View {
    @Environment(Store.self) private var store
    let p: Problem
    let a: Attempt?
    @Binding var custom: String
    @Binding var tab: String
    let busy: String?
    let output: (kind: String, res: JudgeResult, outcome: Outcome?)?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                GlassTabs(selection: $tab, tabs: [
                    .init(id: "result", title: "Result", icon: "terminal"),
                    .init(id: "input", title: custom.isEmpty ? "Custom input" : "Custom input •", icon: "character.cursor.ibeam"),
                ])
                Spacer()
                if busy != nil { ProgressView().controlSize(.small) }
            }
            .padding(10)
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if tab == "input" {
                        TextEditor(text: $custom)
                            .font(.system(size: 12.5, design: .monospaced))
                            .writingToolsBehavior(.disabled)
                            .frame(minHeight: 90)
                            .scrollContentBackground(.hidden)
                            .padding(8)
                            .background(Color.canvas.opacity(0.55), in: .rect(cornerRadius: 10, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(.hairline))
                        Text("One JSON value per line, in order: \(p.params.joined(separator: ", ")). Run uses it alongside the examples; leave it empty to skip.")
                            .font(.caption).foregroundStyle(.secondary)
                    } else if let output {
                        Results(kind: output.kind, res: output.res, outcome: output.outcome, params: p.params).id(output.res.results.count + output.res.passed)
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "terminal").font(.title2).foregroundStyle(.muted)
                            Text("Run your code against the examples, then submit.").foregroundStyle(.secondary)
                            HStack(spacing: 14) {
                                Label("⌘↵ Run", systemImage: "play.fill")
                                Label("⌘⇧↵ Submit", systemImage: "paperplane.fill")
                            }
                            .font(.caption).foregroundStyle(.muted)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 28)
                    }
                    if tab == "result", let a, a.finished, !store.inBoss(a.id) {
                        ProblemExplain(p: p, initial: a.explain)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color.surface)
    }
}

private struct Results: View {
    let kind: String
    let res: JudgeResult
    let outcome: Outcome?
    let params: [String]
    @State private var sel = 0

    private static let pass: Set<String> = ["Accepted", "Ran"]

    var body: some View {
        let ok = res.verdict == "Accepted"
        let r = res.results[safe: min(sel, res.results.count - 1)]
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(res.verdict).font(.title3.weight(.semibold)).foregroundStyle(ok || res.verdict == "Ran" ? .success : .danger)
                Text("\(res.passed) / \(res.total) tests passed" + (kind == "submit" && res.slowestMs != nil ? " · slowest \(Int(res.slowestMs!)) ms" : ""))
                    .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            }
            if let outcome {
                Label("\(outcome.label). Now explain your solution below.", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.success).padding(10).frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.success.opacity(0.1), in: .rect(cornerRadius: 8))
            }
            if let e = res.error { ErrorBox(text: e) }
            if let r {
                if res.results.count > 1 {
                    HStack(spacing: 6) {
                        ForEach(res.results.indices, id: \.self) { i in
                            let c = res.results[i]
                            Button { sel = i } label: {
                                HStack(spacing: 5) {
                                    Circle().fill(Self.pass.contains(c.verdict) ? Color.success : .danger).frame(width: 6, height: 6)
                                    Text(c.kind == "custom" ? "Custom" : "Case \(i + 1)")
                                }
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 9).padding(.vertical, 4)
                                .background(sel == i ? Color.primary.opacity(0.1) : .clear, in: .rect(cornerRadius: 6))
                                .contentShape(.rect)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                if !Self.pass.contains(r.verdict) {
                    Text("\(r.verdict) · \(r.kind) test · \(Int(r.ms)) ms").font(.caption.weight(.medium)).foregroundStyle(.danger)
                }
                Field(label: "Input") {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(r.input.indices, id: \.self) { i in
                            Text("\(Text(r.input.count == params.count ? "\(params[i]) = " : "").foregroundStyle(.secondary))\(Text(r.input[i]))")
                        }
                    }
                }
                if let got = r.got { Field(label: "Output") { Text(got).foregroundStyle(Self.pass.contains(r.verdict) ? .primary : Color.danger) } }
                if let exp = r.expected { Field(label: "Expected") { Text(exp).foregroundStyle(.success) } }
                if !r.stdout.isEmpty { Field(label: "Stdout") { Text(r.stdout) } }
                if let e = r.error { ErrorBox(text: e) }
            }
        }
    }
}

private struct Field<C: View>: View {
    let label: String
    @ViewBuilder let content: C
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption.weight(.medium)).foregroundStyle(.secondary)
            content.font(.system(size: 12.5, design: .monospaced)).textSelection(.enabled)
                .padding(.horizontal, 12).padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.canvas.opacity(0.55), in: .rect(cornerRadius: 8, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(.hairline))
        }
    }
}

private struct ErrorBox: View {
    let text: String
    var body: some View {
        Text(text).font(.system(size: 11.5, design: .monospaced)).foregroundStyle(.danger).textSelection(.enabled)
            .padding(10).frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.danger.opacity(0.08), in: .rect(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Color.danger.opacity(0.2)))
    }
}

private struct ProblemExplain: View {
    @Environment(Store.self) private var store
    let p: Problem
    let initial: String
    @State private var text = ""
    @State private var saved = ""
    @State private var loaded = false

    var body: some View {
        let remaining = 20 - text.trimmingCharacters(in: .whitespacesAndNewlines).count
        let changed = text.trimmingCharacters(in: .whitespacesAndNewlines) != saved.trimmingCharacters(in: .whitespacesAndNewlines)
        VStack(alignment: .leading, spacing: 10) {
            Label("Explain your solution", systemImage: "checkmark.circle.fill").font(.caption.weight(.medium)).foregroundStyle(.success)
            Text("Walk me through your solution: the approach, why it works, and its time and space complexity.")
                .font(.callout.weight(.medium)).fixedSize(horizontal: false, vertical: true)
            TextArea(text: $text, placeholder: "Say it out loud first, then write it down.", minHeight: 90)
            HStack {
                Text(remaining > 0 ? "\(remaining) more characters" : !saved.isEmpty && !changed ? "Saved" : "\(text.count) characters")
                    .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                Spacer()
                Button(saved.isEmpty ? "Save" : "Update") {
                    store.saveProblemExplain(p.id, text: text)
                    saved = text
                }
                .buttonStyle(.glassProminent).buttonBorderShape(.capsule)
                .disabled(remaining > 0 || !changed)
            }
            if !saved.isEmpty {
                Divider()
                ExplainFeedback(kind: "problem", refId: p.id, answer: saved, keyPoints: p.keyPoints)
            }
        }
        .card(padding: 14)
        .onAppear { if !loaded { text = initial; saved = initial; loaded = true } }
    }
}
