import SwiftUI

extension Difficulty {
    var color: Color {
        switch self {
        case .easy: .success
        case .medium: .warning
        case .hard: .danger
        }
    }
    var short: String { self == .medium ? "Med" : rawValue }
}

struct DifficultyBadge: View {
    let d: Difficulty?
    var body: some View {
        if let d {
            Text(d.rawValue).font(.caption.weight(.medium)).foregroundStyle(d.color)
                .padding(.horizontal, 7).padding(.vertical, 2)
                .background(d.color.opacity(0.12), in: .capsule)
        }
    }
}

/// done / started / new, from a problem status string.
struct StatusIcon: View {
    let status: String
    var body: some View {
        let done = Store.isSolved(status), started = status == "in-progress"
        Image(systemName: done ? "checkmark.circle.fill" : started ? "circle.dashed" : "circle")
            .foregroundStyle(done ? Color.success : started ? Color.brand : Color.secondary.opacity(0.5))
    }
}

struct Ring: View {
    let pct: Double
    var size: CGFloat = 64
    var lineWidth: CGFloat = 5
    var label = true
    var body: some View {
        let done = pct >= 1
        ZStack {
            Circle().stroke(.quaternary, lineWidth: lineWidth)
            Circle().trim(from: 0, to: min(1, pct))
                .stroke(AngularGradient(colors: done ? [.success.opacity(0.75), .success, .success.opacity(0.75)] : [.brand.opacity(0.55), .brand, Color(hex: 0x7ad6c9), .brand.opacity(0.55)], center: .center),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            if !label {} else if done { Image(systemName: "checkmark").font(.system(size: size * 0.28, weight: .bold)).foregroundStyle(.success) }
            else { Text("\(Int(pct * 100))%").font(.system(size: size * 0.22, weight: .semibold, design: .rounded).monospacedDigit()) }
        }
        .frame(width: size, height: size)
        .animation(.easeOut, value: pct)
    }
}

extension View {
    /// Content surface. Content stays solid and calm; glass is kept for the controls floating above it.
    func card(padding: CGFloat = 16) -> some View {
        self.padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.surface, in: .rect(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(.hairline))
    }

    /// Soft tinted glow behind a page header; extends under the glass sidebar.
    func backdrop(_ tint: Color, height: CGFloat = 320) -> some View {
        background(alignment: .top) {
            Backdrop(tint: tint).frame(height: height).ignoresSafeArea().backgroundExtensionEffect()
        }
    }
}

private struct Backdrop: View {
    let tint: Color
    var body: some View {
        MeshGradient(width: 3, height: 2, points: [[0, 0], [0.5, 0], [1, 0], [0, 1], [0.6, 1], [1, 1]], colors: [
            tint.opacity(0.22), tint.opacity(0.1), Color(hex: 0x7aa2f7).opacity(0.1),
            .clear, .clear, .clear,
        ])
        .mask(LinearGradient(colors: [.black, .black.opacity(0)], startPoint: .top, endPoint: .bottom))
        .allowsHitTesting(false)
    }
}

/// A row of tabs on glass; the selected pill morphs from tab to tab.
struct GlassTabs: View {
    struct Tab: Identifiable {
        let id, title: String
        var icon: String?
    }
    @Binding var selection: String
    let tabs: [Tab]
    @Namespace private var ns

    var body: some View {
        GlassEffectContainer(spacing: 4) {
            HStack(spacing: 2) {
                ForEach(tabs) { t in
                    let on = selection == t.id
                    Button { withAnimation(.bouncy(duration: 0.35)) { selection = t.id } } label: {
                        Group {
                            if let icon = t.icon { Label(t.title, systemImage: icon) } else { Text(t.title) }
                        }
                        .font(.callout.weight(on ? .semibold : .regular))
                        .foregroundStyle(on ? .primary : .secondary)
                        .padding(.horizontal, 11).padding(.vertical, 6)
                        .contentShape(.capsule)
                    }
                    .buttonStyle(.plain)
                    .fixedSize()
                    .background {
                        if on { Capsule().fill(.clear).glassEffect(.regular.interactive(), in: .capsule).glassEffectID("pill", in: ns) }
                    }
                }
            }
            .padding(3)
        }
    }
}

struct SectionHeader: View {
    let n: Int
    let title: String
    let done: Bool
    var subtitle: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(done ? Color.success.opacity(0.15) : Color.primary.opacity(0.06))
                    if done { Image(systemName: "checkmark").font(.caption.bold()).foregroundStyle(.success) }
                    else { Text("\(n)").font(.caption.weight(.semibold).monospacedDigit()).foregroundStyle(.secondary) }
                }
                .frame(width: 24, height: 24)
                Text(title).font(.title2.weight(.semibold))
            }
            if let subtitle { Text(subtitle).font(.callout).foregroundStyle(.secondary).padding(.leading, 34) }
        }
    }
}

// MARK: explain-back feedback

/// Key-point checklist plus AI grading of an explanation. `answer` is what gets graded.
struct ExplainFeedback: View {
    @Environment(Store.self) private var store
    let kind: String
    let refId: String
    let answer: String
    let keyPoints: [String]

    @State private var fresh: Grade?
    @State private var manual: Set<Int>?
    @State private var busy = false
    @State private var err = ""

    var body: some View {
        let grade = fresh ?? store.latestGrade(kind, refId)
        let covered = manual ?? Set(keyPoints.indices.filter { grade?.covered[safe: $0] == true })
        VStack(alignment: .leading, spacing: 14) {
            if let g = grade { GradeCard(g: g) }

            if !keyPoints.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Did you cover these?").font(.callout.weight(.medium))
                        Spacer()
                        Text("\(covered.count)/\(keyPoints.count)").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                    }
                    ForEach(keyPoints.indices, id: \.self) { i in
                        let on = covered.contains(i)
                        Button {
                            var next = covered
                            if on { next.remove(i) } else { next.insert(i) }
                            manual = next
                        } label: {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Image(systemName: on ? "checkmark.circle.fill" : "circle").foregroundStyle(on ? Color.success : .secondary)
                                Text(keyPoints[i]).foregroundStyle(on ? .primary : .secondary).multilineTextAlignment(.leading)
                            }
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            HStack {
                Text(err.isEmpty ? (busy ? "The interviewer is reading your answer…" : "Get an honest score, what you missed and a follow-up question.") : err)
                    .font(.caption).foregroundStyle(err.isEmpty ? Color.secondary : Color.danger)
                Spacer()
                Button {
                    Task {
                        busy = true
                        err = ""
                        do {
                            fresh = try await store.grade(kind, refId, answer: answer)
                            manual = nil
                        } catch { err = error.localizedDescription }
                        busy = false
                    }
                } label: {
                    if busy { ProgressView().controlSize(.small) } else { Label(grade == nil ? "Grade with AI" : "Grade again", systemImage: "sparkles") }
                }
                .buttonStyle(.glass)
                .disabled(busy || answer.trimmingCharacters(in: .whitespacesAndNewlines).count < 20)
            }
        }
    }
}

private struct GradeCard: View {
    let g: Grade
    var body: some View {
        let (label, tone): (String, Color) = g.score >= 5 ? ("Interview-ready", .success) : g.score >= 4 ? ("Strong", .success)
            : g.score >= 3 ? ("Getting there", .warning) : ("Needs work", .danger)
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("\(g.score)/5").font(.caption.weight(.bold).monospacedDigit()).foregroundStyle(tone)
                    .padding(.horizontal, 7).padding(.vertical, 2).background(tone.opacity(0.14), in: .capsule)
                Text(label).font(.callout.weight(.medium))
                Spacer()
                Label("AI interviewer", systemImage: "sparkles").font(.caption2).foregroundStyle(.secondary)
            }
            Text(g.feedback).font(.callout)
            if !g.followUp.isEmpty {
                Divider()
                Text("\(Text("Follow-up: ").foregroundStyle(.secondary))\(Text(g.followUp))").font(.callout)
            }
        }
        .card(padding: 12)
    }
}

extension Array {
    subscript(safe i: Int) -> Element? { indices.contains(i) ? self[i] : nil }
}

/// Multi-line text input with a placeholder, styled like the rest of the app.
struct TextArea: View {
    @Binding var text: String
    let placeholder: String
    var minHeight: CGFloat = 120
    var body: some View {
        TextEditor(text: $text)
            .font(.body)
            .scrollContentBackground(.hidden)
            .padding(8)
            .frame(minHeight: minHeight)
            .background(.background, in: .rect(cornerRadius: 8))
            .overlay(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder).foregroundStyle(.tertiary).padding(.horizontal, 13).padding(.vertical, 8).allowsHitTesting(false)
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(.separator))
    }
}

func fmtClock(_ s: Int) -> String {
    let s = max(0, s)
    return s >= 3600 ? String(format: "%d:%02d:%02d", s / 3600, s / 60 % 60, s % 60) : String(format: "%d:%02d", s / 60, s % 60)
}

func days(_ n: Int) -> String { n == 1 ? "1 day" : "\(n) days" }

/// In-page search/filter box.
struct FilterField: View {
    @Binding var text: String
    let prompt: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "line.3.horizontal.decrease").foregroundStyle(.muted)
            TextField(prompt, text: $text).textFieldStyle(.plain)
            if !text.isEmpty {
                Button { text = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.muted) }.buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10).frame(height: 28)
        .background(.surface, in: .rect(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(.hairline))
    }
}
