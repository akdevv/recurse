import SwiftUI

struct TopicView: View {
    @Environment(Store.self) private var store
    let topicId: String

    var body: some View {
        if let t = Content.topic(topicId), let m = Content.modules().first(where: { $0.topics.contains(topicId) }) {
            TopicPage(t: t, m: m, status: store.topicStatus(t, store.problemStatuses()),
                      problems: store.topicProblems(t, store.problemStatuses()))
        } else {
            ContentUnavailableView("Topic not found", systemImage: "questionmark.folder")
        }
    }
}

private struct Step: Identifiable {
    let id, label, detail, icon: String
    let done, started: Bool
}

private struct TopicPage: View {
    @Environment(Store.self) private var store
    let t: Topic
    let m: Module
    let status: TopicStatus
    let problems: [TopicProblem]

    // lesson and quiz are read once per page (content edits show up on reopen)
    @State private var lesson: (markdown: String, viz: [String: VizTrace])?
    @State private var quiz: [QuizQ] = []
    @State private var tracker = SectionTracker()

    private var steps: [Step] {
        let st = status
        var s = [Step(id: "lesson", label: "Lesson", detail: st.lessonDone ? "Read" : "Read the lesson", icon: "book",
                      done: st.lessonDone, started: false)]
        if st.hasQuiz {
            s.append(Step(id: "quiz", label: "Quiz", detail: st.quizBest.map { "Best \(Int(($0 * 100).rounded()))%" } ?? "Score 70% to pass",
                          icon: "checklist", done: (st.quizBest ?? 0) >= Store.quizPass, started: st.quizBest != nil))
        }
        if st.required > 0 {
            s.append(Step(id: "problems", label: "Problems", detail: "\(st.solved) of \(st.required) solved",
                          icon: "chevron.left.forwardslash.chevron.right", done: st.solved == st.required, started: st.solved > 0))
        }
        s.append(Step(id: "explain", label: "Explain", detail: st.explained ? "Submitted" : "Teach it back", icon: "mic",
                      done: st.explained, started: false))
        return s
    }

    private var headings: [String] {
        (lesson?.markdown ?? "").split(separator: "\n").filter { $0.hasPrefix("## ") }.map { String($0.dropFirst(3)).trimmingCharacters(in: .whitespaces) }
    }

    var body: some View {
        let steps = steps
        let n = { (id: String) in (steps.firstIndex { $0.id == id } ?? 0) + 1 }
        let done = { (id: String) in steps.first { $0.id == id }?.done ?? false }

        ScrollViewReader { proxy in
            GeometryReader { geo in
                HStack(alignment: .top, spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 44) {
                            VStack(alignment: .leading, spacing: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("\(m.title) · Topic \((m.topics.firstIndex(of: t.id) ?? 0) + 1) of \(m.topics.count)")
                                        .font(.callout.weight(.medium)).foregroundStyle(.muted)
                                    Text(t.title).font(.largeTitle.weight(.semibold))
                                }
                                if status.complete {
                                    WrappedCard(title: t.title, w: store.topicWrapped(t))
                                } else {
                                    StepsCard(steps: steps) { id in withAnimation { proxy.scrollTo(id, anchor: .top) } }
                                }
                                if let hook = t.hook { HookCallout(text: hook) }
                            }

                            VStack(alignment: .leading, spacing: 18) {
                                SectionHeader(n: n("lesson"), title: "Lesson", done: status.lessonDone)
                                if !t.ready {
                                    Label("The lesson for this topic hasn't been written yet. Its problems are listed below.", systemImage: "book")
                                        .foregroundStyle(.secondary).card()
                                } else if let lesson {
                                    MarkdownView(text: lesson.markdown, viz: lesson.viz)
                                    LessonDone(t: t, done: status.lessonDone, hasQuiz: !quiz.isEmpty) { proxy.scrollTo("quiz", anchor: .top) }
                                }
                            }
                            .id("lesson").trackSection("lesson")

                            if !quiz.isEmpty {
                                VStack(alignment: .leading, spacing: 18) {
                                    SectionHeader(n: n("quiz"), title: "Quiz", done: done("quiz"),
                                                  subtitle: "\(quiz.count) quick questions. Score 70% or more to pass. Retakes only earn XP for beating your best.")
                                    QuizView(topicId: t.id, quiz: quiz, best: status.quizBest)
                                }
                                .id("quiz").trackSection("quiz")
                            }

                            if !problems.isEmpty {
                                VStack(alignment: .leading, spacing: 18) {
                                    SectionHeader(n: n("problems"), title: "Problems", done: done("problems"),
                                                  subtitle: "Start with the guided one. Optional problems are extra practice for bonus XP.")
                                    VStack(spacing: 10) { ForEach(problems) { ProblemRow(p: $0) } }.card()
                                }
                                .id("problems").trackSection("problems")
                            }

                            VStack(alignment: .leading, spacing: 18) {
                                SectionHeader(n: n("explain"), title: "Explain it back", done: status.explained,
                                              subtitle: "The interview skill: explain the idea clearly, without notes.")
                                TopicExplain(t: t)
                            }
                            .id("explain").trackSection("explain")
                        }
                        .padding(.horizontal, 36).padding(.vertical, 32)
                        .frame(maxWidth: 780)
                        .frame(maxWidth: .infinity)
                    }
                    .scrollIndicators(.never)
                    .coordinateSpace(.named("topic"))
                    .environment(tracker)
                    if geo.size.width > 1100 {
                        OnThisPage(headings: headings, hasQuiz: !quiz.isEmpty, hasProblems: !problems.isEmpty, tracker: tracker, proxy: proxy)
                    }
                }
            }
        }
        .navigationTitle(t.title)
        .task {
            if t.ready { lesson = Content.lesson(t.id) }
            quiz = t.ready ? Content.quiz(t.id) : []
        }
    }
}

private struct LessonDone: View {
    @Environment(Store.self) private var store
    let t: Topic
    let done, hasQuiz: Bool
    let toQuiz: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: done ? "checkmark.circle.fill" : "book.fill")
                .font(.title2).foregroundStyle(done ? Color.success : Color.brand)
            VStack(alignment: .leading, spacing: 2) {
                Text(done ? "Lesson complete" : "Finished the lesson?").fontWeight(.medium)
                Text(done ? "Step 1 is done. Test what stuck with the quiz." : "Mark it as read to complete step 1.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if !done {
                Button("Mark as Read") { store.markLessonDone(t.id) }.buttonStyle(.glassProminent)
            } else if hasQuiz {
                Button("Go to Quiz", action: toQuiz).buttonStyle(.glass).tint(.raised)
            }
        }
        .buttonBorderShape(.capsule).controlSize(.large)
        .padding(16)
        .background((done ? Color.success : Color.brand).opacity(0.07), in: .rect(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder((done ? Color.success : Color.brand).opacity(0.25)))
    }
}

private struct QuizView: View {
    @Environment(Store.self) private var store
    let topicId: String
    let quiz: [QuizQ]
    let best: Double?

    @State private var answers: [Int?] = []
    @State private var idx = 0
    @State private var result: [Bool]?

    var body: some View {
        Group {
            if let result { results(result) } else if answers.count == quiz.count { question } else { Color.clear }
        }
        .onAppear { if answers.count != quiz.count { answers = Array(repeating: nil, count: quiz.count) } }
    }

    private var question: some View {
        let q = quiz[idx]
        let answered = answers.compactMap { $0 }.count
        return VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button { idx -= 1 } label: { Label("Prev", systemImage: "chevron.left") }.disabled(idx == 0)
                Spacer()
                Text("Question \(idx + 1) of \(quiz.count)").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                Spacer()
                Button { idx += 1 } label: { Label("Next", systemImage: "chevron.right").labelStyle(TrailingIcon()) }
                    .disabled(idx == quiz.count - 1)
            }
            .buttonStyle(.borderless)
            .padding(.horizontal, 16).padding(.vertical, 10)
            Divider()

            VStack(alignment: .leading, spacing: 14) {
                Text(MD.inline(q.q)).font(.title3.weight(.medium)).lineSpacing(3)
                if let code = q.code { CodeBlock(code: code) }
                ForEach(q.options.indices, id: \.self) { oi in
                    let on = answers[idx] == oi
                    Button { answers[idx] = oi } label: {
                        HStack(spacing: 10) {
                            Text(String(UnicodeScalar(65 + oi)!)).font(.caption.weight(.semibold))
                                .frame(width: 24, height: 24)
                                .background(on ? Color.brand : Color.raised, in: .circle)
                                .foregroundStyle(on ? Color.brandInk : .secondary)
                            Text(MD.inline(q.options[oi])).multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .background(on ? Color.brand.opacity(0.1) : Color.canvas.opacity(0.35), in: .rect(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(on ? Color.brand.opacity(0.6) : Color.hairline))
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
            Divider()

            HStack {
                Text("\(answered) of \(quiz.count) answered" + (best.map { " · best \(Int(($0 * 100).rounded()))%" } ?? ""))
                    .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                Spacer()
                Text("1–4 to answer · ← → to move").font(.caption).foregroundStyle(.muted)
                Button("Check Answers") { result = store.submitQuiz(topicId, answers: answers) }
                    .buttonStyle(.glassProminent).buttonBorderShape(.capsule)
                    .disabled(answered < quiz.count)
            }
            .padding(.horizontal, 20).padding(.vertical, 12)
        }
        .surface()
        .focusable()
        .focusEffectDisabled()
        .onKeyPress { key in
            if let n = Int(key.characters), (1...q.options.count).contains(n) { answers[idx] = n - 1; return .handled }
            if key.key == .leftArrow, idx > 0 { idx -= 1; return .handled }
            if key.key == .rightArrow, idx < quiz.count - 1 { idx += 1; return .handled }
            return .ignored
        }
    }

    private func results(_ correct: [Bool]) -> some View {
        let score = correct.filter { $0 }.count
        let passed = Double(score) / Double(quiz.count) >= Store.quizPass
        return VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(score) of \(quiz.count) correct").font(.title3.weight(.semibold))
                        Text(passed ? "Passed" : "Not passed").font(.caption.weight(.medium))
                            .foregroundStyle(passed ? .success : .warning)
                            .padding(.horizontal, 8).padding(.vertical, 2)
                            .background((passed ? Color.success : .warning).opacity(0.14), in: .capsule)
                    }
                    Text(passed ? "Nice work. Move on to the problems."
                                : "You need \(Int((Double(quiz.count) * Store.quizPass).rounded(.up))) to pass. Check what you missed, then retake.")
                        .font(.callout).foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    answers = Array(repeating: nil, count: quiz.count)
                    idx = 0
                    result = nil
                } label: { Label("Retake", systemImage: "arrow.counterclockwise") }.buttonStyle(.glass).tint(.raised).buttonBorderShape(.capsule)
            }
            .padding(20)
            ForEach(quiz.indices, id: \.self) { i in
                Divider()
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Image(systemName: correct[i] ? "checkmark" : "xmark").foregroundStyle(correct[i] ? .success : .danger)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(MD.inline(quiz[i].q))
                        if !correct[i] {
                            HStack(spacing: 6) {
                                if let a = answers[i] { Text(MD.inline(quiz[i].options[a])).strikethrough().foregroundStyle(.secondary); Text("→") }
                                Text(MD.inline(quiz[i].options[quiz[i].answer])).foregroundStyle(.success).fontWeight(.medium)
                            }
                            .font(.callout)
                            Text(MD.inline(quiz[i].why)).font(.callout).foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 20).padding(.vertical, 12)
            }
        }
        .surface()
    }
}

struct TrailingIcon: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) { configuration.title; configuration.icon }
    }
}

private struct TopicExplain: View {
    @Environment(Store.self) private var store
    let t: Topic
    @State private var text = ""
    @State private var loaded = false
    private let minChars = 40

    var body: some View {
        let saved = store.topicExplain(t.id)
        let remaining = minChars - text.trimmingCharacters(in: .whitespacesAndNewlines).count
        let changed = text.trimmingCharacters(in: .whitespacesAndNewlines) != saved.trimmingCharacters(in: .whitespacesAndNewlines)
        VStack(alignment: .leading, spacing: 14) {
            Text(t.explain.prompt).font(.title3).lineSpacing(3).fixedSize(horizontal: false, vertical: true)
            TextArea(text: $text, placeholder: "Say it out loud first, then write it down: the idea, why it works, and its complexity.", minHeight: 160)
            HStack {
                Text(remaining > 0 ? "\(remaining) more characters" : !saved.isEmpty && !changed ? "Saved" : "\(text.count) characters")
                    .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                Spacer()
                Button(saved.isEmpty ? "Submit" : "Update") { store.submitTopicExplain(t.id, text: text) }
                    .buttonStyle(.glassProminent).buttonBorderShape(.capsule).controlSize(.large)
                    .disabled(remaining > 0 || (!saved.isEmpty && !changed))
            }
            if !saved.isEmpty {
                Divider()
                ExplainFeedback(kind: "topic", refId: t.id, answer: saved, keyPoints: t.explain.keyPoints)
            }
        }
        .card(padding: 20)
        .onAppear { if !loaded { text = saved; loaded = true } }
    }
}

/// Where each section sits in the scroll view, so the outline can highlight the one being read.
/// Offsets aren't observed (they change every frame); only `active` is, and only when it changes.
@MainActor @Observable
final class SectionTracker {
    var active = "lesson"
    @ObservationIgnored private var tops: [String: CGFloat] = [:]

    func report(_ id: String, top: CGFloat) {
        tops[id] = top
        // the last section whose top has scrolled above the reading line
        // the last section whose top has scrolled above the reading line; the final one can't scroll that far,
        // so it counts once it's in the top half
        let current = (tops["explain"] ?? .infinity) < 420 ? "explain"
            : tops.filter { $0.value < 140 }.max { $0.value < $1.value }?.key ?? "lesson"
        if current != active { active = current }
    }
}

extension View {
    func trackSection(_ id: String) -> some View { modifier(TrackSection(id: id)) }
}

private struct TrackSection: ViewModifier {
    @Environment(SectionTracker.self) private var tracker: SectionTracker?
    let id: String
    func body(content: Self.Content) -> some View {
        content.onGeometryChange(for: CGFloat.self) { $0.frame(in: .named("topic")).minY } action: { tracker?.report(id, top: $0) }
    }
}

/// The page outline: a thin rail with the section being read marked in teal.
private struct OnThisPage: View {
    let headings: [String]
    let hasQuiz, hasProblems: Bool
    let tracker: SectionTracker
    let proxy: ScrollViewProxy

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("On this page").font(.caption.weight(.semibold)).foregroundStyle(.muted).padding(.leading, 14).padding(.bottom, 10)
            link("Lesson", "lesson")
            ForEach(headings, id: \.self) { link($0, "h:" + $0, sub: true) }
            if hasQuiz { link("Quiz", "quiz") }
            if hasProblems { link("Problems", "problems") }
            link("Explain it back", "explain")
        }
        .frame(width: 210, alignment: .leading)
        .padding(.top, 40).padding(.trailing, 20)
        .animation(.snappy(duration: 0.2), value: tracker.active)
    }

    private func link(_ title: String, _ id: String, sub: Bool = false) -> some View {
        let on = tracker.active == id
        return Button { withAnimation { proxy.scrollTo(id, anchor: .top) } } label: {
            Text(MD.inline(title))
                .font(sub ? .caption : .callout.weight(on ? .semibold : .regular))
                .foregroundStyle(on ? Color.brand : sub ? Color.muted : .secondary)
                .lineLimit(1)
                .padding(.leading, sub ? 24 : 14).padding(.vertical, sub ? 4 : 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .leading) {
                    Rectangle().fill(on ? Color.brand : Color.hairline).frame(width: on ? 2 : 1)
                }
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

private struct WrappedCard: View {
    let title: String
    let w: TopicWrapped

    var body: some View {
        let pct = { (x: Double) in "\(Int((x * 100).rounded()))%" }
        let time = w.seconds >= 3600 ? "\(w.seconds / 3600)h \(w.seconds % 3600 / 60)m" : "\(w.seconds / 60)m"
        let line = w.hintFree >= 0.999 ? "Every problem solved without a single hint."
            : w.hintFree >= 0.6 ? "\(pct(w.hintFree)) of it without hints." : "You pushed through the hard parts."
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 14) {
                Medal(icon: "star.fill", metal: .jade, size: 60)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Topic mastered" + (w.masteredAt.flatMap(Dates.fromIso).map { " · \($0.formatted(date: .abbreviated, time: .omitted))" } ?? ""))
                        .font(.caption.weight(.medium)).foregroundStyle(.success)
                    Text("\(title), wrapped").font(.title3.weight(.semibold))
                    Text(line).font(.callout).foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 18).padding(.vertical, 14)
            Divider()
            HStack(spacing: 0) {
                stat("Focused time", time)
                stat("Problems solved", "\(w.solved)/\(w.total)" + (w.optional > 0 ? " +\(w.optional)" : ""))
                stat("Hint-free", w.solved > 0 ? pct(w.hintFree) : "–")
                stat("Quiz best", w.quizBest.map(pct) ?? "–")
                stat("Best explanation", w.bestExplain < 0 ? "–" : "\(w.bestExplain)/5")
            }
        }
        .background(LinearGradient(colors: [Color.success.opacity(0.1), Color.surface], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: .rect(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.success.opacity(0.25)))
    }

    private func stat(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.system(.title3, design: .rounded).weight(.semibold)).monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 18).padding(.vertical, 12)
    }
}

/// The topic's four steps in one card; each cell jumps to its section.
private struct StepsCard: View {
    let steps: [Step]
    let jump: (String) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.element.id) { i, s in
                if i > 0 { Divider() }
                HoverButton { jump(s.id) } label: { hover in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(s.done ? Color.success.opacity(0.16) : s.started ? Color.brand.opacity(0.16) : Color.raised)
                            if s.done { Image(systemName: "checkmark").font(.system(size: 12, weight: .bold)).foregroundStyle(Color.success) }
                            else { Image(systemName: s.icon).font(.system(size: 12, weight: .semibold)).foregroundStyle(s.started ? Color.brand : Color.muted) }
                        }
                        .frame(width: 30, height: 30)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(s.label).font(.callout.weight(.semibold)).foregroundStyle(s.done || s.started ? .primary : .secondary)
                            Text(s.detail).font(.caption).foregroundStyle(.muted).lineLimit(1)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .background(hover ? Color.hover.opacity(0.5) : .clear)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .surface(clip: true)
    }
}

/// "Why this matters": the topic's hook.
private struct HookCallout: View {
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: "lightbulb.fill").font(.callout).foregroundStyle(.warning)
            VStack(alignment: .leading, spacing: 4) {
                Text("Why this matters").font(.callout.weight(.semibold)).foregroundStyle(.warning)
                Text(MD.inline(text)).font(.callout).lineSpacing(3).fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.warning.opacity(0.06), in: .rect(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.warning.opacity(0.18)))
    }
}
