import SwiftUI

/// How Recurse works, in five pages: shown once after the welcome screen, and from Help › How Recurse Works.
struct TourView: View {
    @Environment(Store.self) private var store
    @State private var page = 0

    fileprivate struct Page {
        let icon: String
        let tint: Color
        let family: GradientFamily
        let title, body: String
        let points: [(icon: String, text: String)]
    }

    private static let pages = [
        Page(icon: "flame.fill", tint: .warning, family: .ember, title: "A little, most days",
             body: "Aim for 30 focused minutes a day, 5 days a week. Only real work counts: time on a lesson, problem or review while Recurse is in front.",
             points: [("circle.dashed", "The ring on Today fills as you go"), ("calendar", "5 goal days keep your weekly streak"),
                      ("bell", "Gentle reminders on your study days")]),
        Page(icon: "book.fill", tint: .brand, family: .ocean, title: "Every topic in four steps",
             body: "The course is a map of modules. Each topic takes you from first idea to explaining it like an interviewer would want.",
             points: [("book", "Read the lesson and step through its visualizations"), ("checklist", "Pass the quiz"),
                      ("chevron.left.forwardslash.chevron.right", "Solve its problems in Python"), ("mic", "Explain it back in your own words")]),
        Page(icon: "lightbulb.fill", tint: .warning, family: .gold, title: "Struggle first, then get help",
             body: "Problems run right here: Run checks the examples, Submit runs every test. Help unlocks as you put in active time, and solving on your own earns the most XP.",
             points: [("lightbulb", "Hints after 10 and 20 minutes"), ("graduationcap", "A Socratic tutor once you've taken a hint"),
                      ("lock.open", "Full solutions after 30 minutes")]),
        Page(icon: "arrow.counterclockwise", tint: .success, family: .meadow, title: "Make it stick",
             body: "What you solve comes back just before you'd forget it, and every module ends with an interview to prove it.",
             points: [("rectangle.stack", "Reviews after 1, 3, 7, 21 and 60 days"), ("figure.fencing", "Boss fights: one timed problem, then explain it"),
                      ("sparkles", "AI feedback on your explanations")]),
        Page(icon: "gift.fill", tint: Color(hex: 0x7aa2f7), family: .cobalt, title: "Rewards for real effort",
             body: "Finishing modules unlocks real treats you choose yourself. Pick them in Settings › Rewards, and make the last one worth the climb.",
             points: [("trophy", "Trophies for solves, streaks and explanations"), ("shippingbox", "Mystery chests from clean solves and boss wins"),
                      ("magnifyingglass", "⌘K searches every topic and problem")]),
    ]

    var body: some View {
        let p = Self.pages[page], last = page == Self.pages.count - 1
        VStack(spacing: 0) {
            TourPage(p: p, step: "Step \(page + 1) of \(Self.pages.count)")
                .id(page)
                .transition(.asymmetric(insertion: .opacity.combined(with: .offset(x: 30)), removal: .opacity.combined(with: .offset(x: -30))))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            Divider()
            HStack {
                HStack(spacing: 6) {
                    ForEach(Self.pages.indices, id: \.self) { i in
                        Capsule().fill(i == page ? p.tint : Color.primary.opacity(0.15)).frame(width: i == page ? 18 : 6, height: 6)
                    }
                }
                Spacer()
                if page > 0 { Button("Back") { go(-1) }.keyboardShortcut(.leftArrow, modifiers: []) }
                else { Button("Skip") { store.tourPending = false }.keyboardShortcut(.cancelAction) }
                Button(last ? "Start Learning" : "Next") {
                    if last { store.tourPending = false } else { go(1) }
                }
                    .buttonStyle(.glassProminent).keyboardShortcut(.defaultAction)
            }
            .buttonBorderShape(.capsule).controlSize(.large)
            .padding(.horizontal, 24).padding(.vertical, 16)
        }
        .frame(width: 560, height: 420)
        .clipShape(.rect(cornerRadius: 28, style: .continuous))
        .glassEffect(.regular, in: .rect(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.35), radius: 40, y: 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { AmbientBackdrop(family: p.family) }
        .toolbar(removing: .title)
    }

    private func go(_ d: Int) {
        withAnimation(.snappy(duration: 0.45)) { page = min(max(page + d, 0), Self.pages.count - 1) }
    }
}

private struct TourPage: View {
    let p: TourView.Page
    let step: String
    @State private var shown = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TourIcon(symbol: p.icon, tint: p.tint)
                .scaleEffect(shown ? 1 : 0.8)
                .opacity(shown ? 1 : 0)
            VStack(alignment: .leading, spacing: 8) {
                Text(step.uppercased()).font(.caption.weight(.semibold)).tracking(0.8).foregroundStyle(p.tint)
                Text(p.title).font(.title.weight(.semibold))
                Text(p.body).foregroundStyle(.primary.opacity(0.72)).fixedSize(horizontal: false, vertical: true)
            }
            .appear(shown, 0.06)
            VStack(alignment: .leading, spacing: 11) {
                ForEach(Array(p.points.enumerated()), id: \.offset) { i, point in
                    Label { Text(point.text) } icon: { Image(systemName: point.icon).foregroundStyle(p.tint).frame(width: 22) }
                        .appear(shown, 0.14 + 0.06 * Double(i))
                }
            }
        }
        .padding(32)
        .onAppear { withAnimation(.spring(duration: 0.5, bounce: 0.25)) { shown = true } }
    }
}

private struct TourIcon: View {
    let symbol: String
    let tint: Color

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 15, style: .continuous)
        Image(systemName: symbol)
            .font(.system(size: 23, weight: .semibold))
            .foregroundStyle(.white.opacity(0.95))
            .frame(width: 54, height: 54)
            .background {
                shape.fill(LinearGradient(colors: [tint.mix(with: .white, by: 0.08), tint.mix(with: .black, by: 0.2)],
                                          startPoint: .top, endPoint: .bottom))
                    .overlay(shape.strokeBorder(LinearGradient(colors: [.white.opacity(0.35), .white.opacity(0.04)], startPoint: .top, endPoint: .bottom), lineWidth: 0.75))
            }
            .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
    }
}

private extension View {
    func appear(_ shown: Bool, _ delay: Double) -> some View {
        opacity(shown ? 1 : 0).offset(y: shown ? 0 : 12)
            .animation(.spring(duration: 0.55, bounce: 0.2).delay(delay), value: shown)
    }
}
