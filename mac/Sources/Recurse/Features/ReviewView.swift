import SwiftUI

struct ReviewView: View {
    @Environment(Store.self) private var store
    @State private var done = 0

    var body: some View {
        let items = store.dueReviews()
        let upcoming = store.upcomingReviews()
        let total = items.count + done

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let it = items.first {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Today's review").font(.title.weight(.semibold))
                            Spacer()
                            Text("\(done + 1) of \(total)").font(.callout.monospacedDigit()).foregroundStyle(.muted)
                        }
                        ProgressView(value: Double(done + 1), total: Double(total)).progressViewStyle(.linear)
                    }
                    Card(it: it) { passed in
                        store.gradeReview(it, passed: passed)
                        done += 1
                    }
                    .id(it.id)
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: done > 0 ? "party.popper.fill" : "checkmark.circle.fill").font(.largeTitle).foregroundStyle(.success)
                        Text(done > 0 ? "Session done: \(done) review\(done == 1 ? "" : "s")" : "All caught up").font(.title2.weight(.semibold))
                        Text("Solved problems and finished topics come back here after 1, 3, 7, 21 and 60 days. Recalling them right before you'd forget is what makes them stick.")
                            .multilineTextAlignment(.center).foregroundStyle(.secondary).frame(maxWidth: 440)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 40).card()
                }

                if !upcoming.isEmpty {
                    Label("Coming up", systemImage: "calendar").font(.caption.weight(.medium)).foregroundStyle(.secondary)
                    VStack(spacing: 0) {
                        ForEach(Array(upcoming.enumerated()), id: \.offset) { i, u in
                            HStack {
                                Image(systemName: u.type == "problem" ? "chevron.left.forwardslash.chevron.right" : "book").foregroundStyle(.secondary).frame(width: 20)
                                Text(u.title)
                                Spacer()
                                Text(u.type.capitalized).font(.caption).foregroundStyle(.secondary)
                                Text(when(u.due)).font(.caption.monospacedDigit()).foregroundStyle(.secondary).frame(width: 80, alignment: .trailing)
                            }
                            .padding(.vertical, 9)
                            if i < upcoming.count - 1 { Divider() }
                        }
                    }
                    .card(padding: 14)
                }
            }
            .padding(28)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Review")
    }

    private func when(_ due: String) -> String {
        let n = Dates.cal.dateComponents([.day], from: Dates.parse(Dates.local()), to: Dates.parse(due)).day ?? 0
        return n <= 1 ? "Tomorrow" : "In \(n) days"
    }
}

private struct Card: View {
    @Environment(Nav.self) private var nav
    let it: ReviewItem
    let grade: (Bool) -> Void

    @State private var notes = ""
    @State private var revealed = false
    @State private var showRef = false

    var body: some View {
        VStack(spacing: 0) {
            content.padding(24)
            Divider()
            footer.padding(.horizontal, 24).padding(.vertical, 16)
        }
        .surface()
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(it.title).font(.title2.weight(.semibold))
                    Spacer()
                    DifficultyBadge(d: it.difficulty)
                }
                Text("\(it.type == "problem" ? "Problem" : "Topic") · last seen \(days(it.interval)) ago").font(.subheadline).foregroundStyle(.muted)
            }
            Text(it.prompt).font(.title3).lineSpacing(3).fixedSize(horizontal: false, vertical: true)
            TextArea(text: $notes, placeholder: "Write your answer (optional)", minHeight: 110)

            if revealed {
                Divider()
                ExplainFeedback(kind: it.type, refId: it.itemId, answer: notes, keyPoints: it.keyPoints)
                if let ref = it.reference {
                    Divider()
                    DisclosureGroup(isExpanded: $showRef) {
                        MarkdownView(text: ref.notes + "\n\n```python\n" + ref.code + "```", compact: true).padding(.top, 10)
                    } label: {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Reference solution").font(.headline)
                            Spacer()
                            Text("\(ref.title) · \(ref.time) time, \(ref.space) space").font(.subheadline).foregroundStyle(.muted)
                        }
                        .contentShape(.rect)
                        .onTapGesture { withAnimation(.snappy) { showRef.toggle() } }
                    }
                }
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 10) {
            if it.type == "problem" {
                Button("Re-solve", systemImage: "arrow.counterclockwise") { nav.go(.problem(it.itemId)) }
                    .buttonStyle(.glass).tint(.raised)
            }
            Spacer()
            if revealed {
                Button { grade(false) } label: { gradeLabel("Forgot", it.failNext) }
                    .buttonStyle(.glass).tint(.raised)
                    .keyboardShortcut("1", modifiers: .command)
                    .help("Forgot: see it again \(it.failNext == 1 ? "tomorrow" : "in \(days(it.failNext))") (⌘1)")
                Button { grade(true) } label: { gradeLabel("Got It", it.passNext) }
                    .buttonStyle(.glassProminent)
                    .keyboardShortcut("2", modifiers: .command)
                    .help("Got it: next review in \(days(it.passNext)) (⌘2)")
            } else {
                Button { revealed = true } label: { Text("Show Answer").frame(minWidth: 120) }
                    .buttonStyle(.glassProminent)
                    .keyboardShortcut(.return, modifiers: .command)
                    .help("Show answer (⌘↵)")
            }
        }
        .buttonBorderShape(.capsule)
        .controlSize(.extraLarge)
    }

    private func gradeLabel(_ title: String, _ n: Int) -> some View {
        HStack(spacing: 8) {
            Text(title)
            Text("\(n)d").monospacedDigit().opacity(0.75)
        }
        .frame(minWidth: 100)
    }
}
