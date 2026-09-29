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
                            VStack(alignment: .leading, spacing: 18) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Module \(m.number) · \(m.title)  /  Topic \((m.topics.firstIndex(of: t.id) ?? 0) + 1) of \(m.topics.count)")
                                        .font(.callout).foregroundStyle(.secondary)
                                    Text(t.title).font(.largeTitle.weight(.semibold))
                                }
                                if status.complete {
                                    WrappedCard(title: t.title, w: store.topicWrapped(t))
                                } else {
                                    HStack(spacing: 12) {
                                        ForEach(steps) { s in
                                            Button { withAnimation { proxy.scrollTo(s.id, anchor: .top) } } label: {
                                                VStack(alignment: .leading, spacing: 6) {
                                                    Capsule().fill(s.done ? Color.success : s.started ? Color.brand : Color.primary.opacity(0.1)).frame(height: 4)
                                                    Label(s.label, systemImage: s.icon).font(.callout.weight(.medium))
                                                        .foregroundStyle(s.done || s.started ? .primary : .secondary)
                                                    Text(s.detail).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .contentShape(.rect)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                }
                                }
                                if let hook = t.hook {
                                    Text("\(Text("Why this matters. ").fontWeight(.semibold).foregroundStyle(.warning))\(Text(MD.inline(hook)))")
                                        .font(.callout).lineSpacing(3)
                                        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.warning.opacity(0.07), in: .rect(cornerRadius: 16, style: .continuous))
                                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.warning.opacity(0.2)))
                                }
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
                            .id("lesson")

                            if !quiz.isEmpty {
                                VStack(alignment: .leading, spacing: 18) {
                                    SectionHeader(n: n("quiz"), title: "Quiz", done: done("quiz"),
                                                  subtitle: "\(quiz.count) quick questions. Score 70% or more to pass. Retakes only earn XP for beating your best.")
                                    QuizView(topicId: t.id, quiz: quiz, best: status.quizBest)
                                }
                                .id("quiz")
                            }

                            if !problems.isEmpty {
                                VStack(alignment: .leading, spacing: 18) {
                                    SectionHeader(n: n("problems"), title: "Problems", done: done("problems"),
                                                  subtitle: "Start with the guided one. Optional problems are extra practice for bonus XP.")
                                    VStack(spacing: 10) { ForEach(problems) { ProblemRow(p: $0) } }.card()
                                }
                                .id("problems")
                            }

                            VStack(alignment: .leading, spacing: 18) {
                                SectionHeader(n: n("explain"), title: "Explain it back", done: status.explained,
                                              subtitle: "The interview skill: explain the idea clearly, without notes.")
                                TopicExplain(t: t)
                            }
                            .id("explain")
                        }
                        .padding(.horizontal, 36).padding(.vertical, 32)
                        .frame(maxWidth: 780)
                        .frame(maxWidth: .infinity)
                        .backdrop(status.complete ? .success : .brand, height: 300)
                    }
                    if geo.size.width > 1100 { OnThisPage(headings: headings, hasQuiz: !quiz.isEmpty, hasProblems: !problems.isEmpty, proxy: proxy) }
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
                Button("Mark as read") { store.markLessonDone(t.id) }.buttonStyle(.glassProminent)
            } else if hasQuiz {
                Button("Go to quiz", action: toQuiz).buttonStyle(.glass)
            }
        }
        .padding(16)
        .background((done ? Color.success : Color.brand).opacity(0.07), in: .rect(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder((done ? Color.success : Color.brand).opacity(0.25)))
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
                            Text(String(UnicodeScalar(65 + oi)!)).font(.caption.monospaced().weight(.medium))
                                .frame(width: 20, height: 20)
                                .background(on ? Color.brand : Color.primary.opacity(0.08), in: .rect(cornerRadius: 4))
                                .foregroundStyle(on ? .white : .secondary)
                            Text(MD.inline(q.options[oi])).multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(10)
                        .background(on ? Color.brand.opacity(0.1) : .clear, in: .rect(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(on ? Color.brand.opacity(0.6) : Color.primary.opacity(0.12)))
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
                Text("Click the quiz, then 1–4 to answer, ← → to move").font(.caption2).foregroundStyle(.tertiary)
                Button("Check answers") { result = store.submitQuiz(topicId, answers: answers) }
                    .buttonStyle(.glassProminent)
                    .disabled(answered < quiz.count)
            }
            .padding(.horizontal, 20).padding(.vertical, 12)
        }
        .background(.surface, in: .rect(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(.hairline))
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
                } label: { Label("Retake", systemImage: "arrow.counterclockwise") }.buttonStyle(.glass)
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
        .background(.surface, in: .rect(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(.hairline))
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
            Label("Interviewer", systemImage: "quote.bubble").font(.caption).foregroundStyle(.secondary)
            Text(t.explain.prompt).font(.title3.weight(.medium))
            TextArea(text: $text, placeholder: "Say it out loud first, then write it down: the idea, why it works, and its complexity.", minHeight: 160)
            HStack {
                Text(remaining > 0 ? "\(remaining) more characters" : !saved.isEmpty && !changed ? "Saved" : "\(text.count) characters")
                    .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                Spacer()
                Button(saved.isEmpty ? "Submit" : "Update") { store.submitTopicExplain(t.id, text: text) }
                    .buttonStyle(.glassProminent)
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

private struct OnThisPage: View {
    let headings: [String]
    let hasQuiz, hasProblems: Bool
    let proxy: ScrollViewProxy

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("On this page").font(.caption.weight(.semibold)).foregroundStyle(.secondary).padding(.bottom, 4)
            link("Lesson", "lesson")
            ForEach(headings, id: \.self) { link($0, "h:" + $0, sub: true) }
            if hasQuiz { link("Quiz", "quiz") }
            if hasProblems { link("Problems", "problems") }
            link("Explain it back", "explain")
        }
        .frame(width: 200, alignment: .leading)
        .padding(.top, 40).padding(.trailing, 20)
    }

    private func link(_ title: String, _ id: String, sub: Bool = false) -> some View {
        Button { withAnimation { proxy.scrollTo(id, anchor: .top) } } label: {
            Text(MD.inline(title)).font(sub ? .caption : .callout).foregroundStyle(sub ? .secondary : .primary)
                .lineLimit(1).padding(.leading, sub ? 12 : 0).contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

/// Shown once a topic is mastered: what it took, in numbers.
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
                Image(systemName: "rosette").font(.title2).foregroundStyle(.success)
                    .frame(width: 44, height: 44).background(Color.success.opacity(0.14), in: .rect(cornerRadius: 11))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Topic mastered" + (w.masteredAt.flatMap(Dates.fromIso).map { " · \($0.formatted(date: .abbreviated, time: .omitted))" } ?? ""))
                        .font(.caption.weight(.medium)).foregroundStyle(.success)
                    Text("\(title), wrapped").font(.title3.weight(.semibold))
                    Text(line).font(.callout).foregroundStyle(.secondary)
                }
            }
            .padding(18)
            Divider()
            HStack(spacing: 0) {
                stat("Focused time", time)
                stat("Problems solved", "\(w.solved)/\(w.total)" + (w.optional > 0 ? " +\(w.optional)" : ""))
                stat("Hint-free", w.solved > 0 ? pct(w.hintFree) : "–")
                stat("Quiz best", w.quizBest.map(pct) ?? "–")
                stat("Best explanation", w.bestExplain < 0 ? "–" : "\(w.bestExplain)/5")
            }
        }
        .background(LinearGradient(colors: [Color.success.opacity(0.1), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.success.opacity(0.25)))
    }

    private func stat(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title3.weight(.semibold)).monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 18).padding(.vertical, 12)
    }
}
