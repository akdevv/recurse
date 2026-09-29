import SwiftUI

extension Difficulty {
    var color: Color {
        switch self {
        case .easy: .green
        case .medium: .orange
        case .hard: .red
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
            .foregroundStyle(done ? Color.green : started ? Color.accentColor : Color.secondary.opacity(0.5))
    }
}

struct Ring: View {
    let pct: Double
    var size: CGFloat = 64
    var label = true
    var body: some View {
        ZStack {
            Circle().stroke(.quaternary, lineWidth: 5)
            Circle().trim(from: 0, to: min(1, pct))
                .stroke(pct >= 1 ? Color.green : Color.accentColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            if !label {} else if pct >= 1 { Image(systemName: "checkmark").font(.title3.bold()).foregroundStyle(.green) }
            else { Text("\(Int(pct * 100))%").font(.callout.weight(.semibold).monospacedDigit()) }
        }
        .frame(width: size, height: size)
        .animation(.easeOut, value: pct)
    }
}

extension View {
    /// Grouped content surface.
    func card(padding: CGFloat = 16) -> some View {
        self.padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background.secondary, in: .rect(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(.separator.opacity(0.6)))
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
                    Circle().fill(done ? Color.green.opacity(0.15) : Color.primary.opacity(0.06))
                    if done { Image(systemName: "checkmark").font(.caption.bold()).foregroundStyle(.green) }
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
                                Image(systemName: on ? "checkmark.circle.fill" : "circle").foregroundStyle(on ? Color.green : .secondary)
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
                    .font(.caption).foregroundStyle(err.isEmpty ? Color.secondary : Color.red)
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
                .disabled(busy || answer.trimmingCharacters(in: .whitespacesAndNewlines).count < 20)
            }
        }
    }
}

private struct GradeCard: View {
    let g: Grade
    var body: some View {
        let (label, tone): (String, Color) = g.score >= 5 ? ("Interview-ready", .green) : g.score >= 4 ? ("Strong", .green)
            : g.score >= 3 ? ("Getting there", .orange) : ("Needs work", .red)
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
                (Text("Follow-up: ").foregroundStyle(.secondary) + Text(g.followUp)).font(.callout)
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
