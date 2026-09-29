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
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Today's review").font(.title.weight(.semibold))
                            Text("Recall each one before you look. Forgetting costs no XP.").foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(Text("\(done + 1)").font(.title2.weight(.semibold)))\(Text(" / \(total)").foregroundStyle(.secondary))").monospacedDigit()
                    }
                    HStack(spacing: 5) {
                        ForEach(0..<total, id: \.self) { i in
                            Capsule().fill(i < done ? Color.success : i == done ? Color.brand : Color.primary.opacity(0.1)).frame(height: 5)
                        }
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
            .backdrop(.success)
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
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: it.type == "problem" ? "chevron.left.forwardslash.chevron.right" : "book")
                    .foregroundStyle(Color.brand).frame(width: 32, height: 32)
                    .background(Color.brand.opacity(0.1), in: .rect(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 2) {
                    Text(it.title).font(.headline)
                    Text("\(it.type == "problem" ? "Problem" : "Topic") · last seen \(days(it.interval)) ago").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                DifficultyBadge(d: it.difficulty)
            }
            Divider()
            Label("Interviewer", systemImage: "quote.bubble").font(.caption).foregroundStyle(.secondary)
            Text(it.prompt).font(.title3.weight(.medium))
            TextArea(text: $notes, placeholder: "Recall it from memory first. Writing it down is optional, but it helps.", minHeight: 120)

            if !revealed {
                HStack {
                    Spacer()
                    Button { revealed = true } label: { Label("Show answer", systemImage: "eye") }
                        .buttonStyle(.glassProminent)
                        .keyboardShortcut(.return, modifiers: .command)
                        .help("⌘↵")
                }
            } else {
                Divider()
                ExplainFeedback(kind: it.type, refId: it.itemId, answer: notes, keyPoints: it.keyPoints)
                if let ref = it.reference {
                    DisclosureGroup(isExpanded: $showRef) {
                        MarkdownView(text: ref.notes + "\n\n```python\n" + ref.code + "```", compact: true).padding(.top, 8)
                    } label: {
                        HStack {
                            Text("Reference solution").fontWeight(.medium)
                            Text(ref.title).font(.caption).foregroundStyle(.secondary)
                            Spacer()
                            Text("\(ref.time) time · \(ref.space) space").font(.caption.monospaced()).foregroundStyle(.secondary)
                        }
                    }
                }
                Divider()
                HStack {
                    if it.type == "problem" {
                        Button { nav.go(.problem(it.itemId)) } label: { Label("Re-solve it", systemImage: "arrow.counterclockwise") }
                            .buttonStyle(.borderless)
                    }
                    Spacer()
                    Button { grade(false) } label: { gradeLabel("Forgot", "again in \(days(it.failNext))") }.buttonStyle(.glass)
                        .keyboardShortcut("1", modifiers: .command)
                        .help("⌘1")
                    Button { grade(true) } label: { gradeLabel("Got it", "next in \(days(it.passNext))") }
                        .buttonStyle(.glassProminent)
                        .keyboardShortcut("2", modifiers: .command)
                        .help("⌘2")
                }
            }
        }
        .card(padding: 20)
    }

    private func gradeLabel(_ title: String, _ hint: String) -> some View {
        VStack(spacing: 0) {
            Text(title)
            Text(hint).font(.caption2).opacity(0.75)
        }
        .padding(.vertical, 2)
    }
}
