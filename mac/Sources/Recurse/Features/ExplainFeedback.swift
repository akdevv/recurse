import SwiftUI

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
        let tooShort = answer.trimmingCharacters(in: .whitespacesAndNewlines).count < 20
        VStack(alignment: .leading, spacing: 20) {
            if let g = grade { GradeSummary(g: g) }

            if !keyPoints.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Key points").font(.headline)
                        Spacer()
                        Text("\(covered.count) of \(keyPoints.count) covered").font(.caption).foregroundStyle(.muted).monospacedDigit()
                    }
                    ForEach(keyPoints.indices, id: \.self) { i in
                        Toggle(isOn: Binding(
                            get: { covered.contains(i) },
                            set: { on in manual = on ? covered.union([i]) : covered.subtracting([i]) }
                        )) {
                            Text(keyPoints[i]).foregroundStyle(covered.contains(i) ? .primary : .secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .toggleStyle(.checkbox)
                    }
                }
            }

            HStack(spacing: 12) {
                Text(!err.isEmpty ? err
                     : busy ? "Reading your answer…"
                     : tooShort ? "Write a few sentences above to have the AI grade it."
                     : "Get a 0–5 score, what you missed and a follow-up question.")
                    .font(.subheadline).foregroundStyle(err.isEmpty ? Color.muted : Color.danger)
                Spacer(minLength: 12)
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
                    Label(grade == nil ? "Grade with AI" : "Grade Again", systemImage: "sparkles").opacity(busy ? 0 : 1)
                        .overlay { if busy { ProgressView().controlSize(.small) } }
                }
                .buttonStyle(.glass).tint(.raised)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .disabled(busy || tooShort)
            }
        }
    }
}

private struct GradeSummary: View {
    let g: Grade
    var body: some View {
        let label = g.score >= 5 ? "Interview-ready" : g.score >= 4 ? "Strong" : g.score >= 3 ? "Getting there" : "Needs work"
        let tone = scoreTone(g.score)
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 0) {
                Text("\(g.score)").font(.system(size: 28, weight: .semibold, design: .rounded)).foregroundStyle(tone)
                Text("of 5").font(.caption2).foregroundStyle(.muted)
            }
            .frame(width: 48)
            VStack(alignment: .leading, spacing: 8) {
                Text(label).font(.headline)
                Text(g.feedback).font(.callout).foregroundStyle(.primary.opacity(0.85)).fixedSize(horizontal: false, vertical: true)
                FollowUp(text: g.followUp).font(.callout)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.canvas.opacity(0.45), in: .rect(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(.hairline))
    }
}

struct FollowUp: View {
    let text: String
    var body: some View {
        if !text.isEmpty {
            Text("\(Text("Follow-up  ").foregroundStyle(.muted).fontWeight(.medium))\(Text(text))")
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 10)
                .overlay(alignment: .leading) { Capsule().fill(.hairline).frame(width: 2) }
        }
    }
}
