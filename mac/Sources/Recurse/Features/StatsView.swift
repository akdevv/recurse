import Charts
import SwiftUI

struct StatsView: View {
    @Environment(Store.self) private var store

    var body: some View {
        let s = store.stats()
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 12) {
                    Tile(icon: "clock", label: "Active time", value: hours(s.activeSeconds)) {
                        Text("Focused, in-use time only")
                    }
                    Tile(icon: "calendar.badge.checkmark", label: "Goal days", value: "\(s.goalDays)") {
                        Text("\(s.activeDays) active days in total")
                    }
                    Tile(icon: "chevron.left.forwardslash.chevron.right", label: "Problems solved", value: "\(s.solved + s.hinted + s.assisted)") {
                        OutcomeBar(clean: s.solved, hinted: s.hinted, assisted: s.assisted)
                    }
                    Tile(icon: "text.bubble", label: "Avg explain score", value: s.explainAvg.map { String(format: "%.1f/5", $0) } ?? "—") {
                        Text("Quiz average \(s.quizAvg.map { "\(Int(($0 * 100).rounded()))%" } ?? "—")")
                    }
                }
                .fixedSize(horizontal: false, vertical: true)

                ActivityPanel(days: s.days, weeks: s.weeks)

                HStack(alignment: .top, spacing: 20) {
                    Panel(title: "Module progress") {
                        VStack(spacing: 0) {
                            ForEach(Array(s.modules.enumerated()), id: \.offset) { i, m in
                                if i > 0 { Divider() }
                                HStack(spacing: 12) {
                                    Text(String(format: "%02d", m.module.number)).font(.caption.monospacedDigit()).foregroundStyle(.muted)
                                        .frame(width: 22, alignment: .leading)
                                    Text(m.module.title).lineLimit(1).frame(maxWidth: .infinity, alignment: .leading)
                                    ProgressView(value: Double(m.topicsDone), total: Double(max(1, m.topics)))
                                        .tint(m.topics > 0 && m.topicsDone == m.topics ? .success : .brand).frame(width: 90)
                                        .help("\(m.topicsDone)/\(m.topics) topics")
                                    Text("\(m.solved)/\(m.problems)").font(.caption.monospacedDigit()).foregroundStyle(.muted)
                                        .frame(width: 44, alignment: .trailing)
                                }
                                .padding(.horizontal, 16).frame(height: 38)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    ExplainPanel(grades: s.grades).frame(width: 340)
                }
            }
            .padding(28)
            .frame(maxWidth: 1000)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Stats")
    }
}

private func hours(_ s: Int) -> String { s >= 3600 ? String(format: "%.1fh", Double(s) / 3600) : "\(s / 60)m" }

private struct Panel<Action: View, Content: View>: View {
    let title: String
    @ViewBuilder var action: Action
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title).font(.callout.weight(.semibold))
                Spacer()
                action
            }
            .padding(.horizontal, 16).frame(height: 46)
            Divider()
            content
        }
        .surface(clip: true)
    }
}

extension Panel where Action == EmptyView {
    init(title: String, @ViewBuilder content: () -> Content) { self.init(title: title, action: { EmptyView() }, content: content) }
}

private struct Tile<Note: View>: View {
    let icon, label, value: String
    @ViewBuilder let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: icon).font(.caption.weight(.medium)).foregroundStyle(.secondary)
            Text(value).font(.system(size: 24, weight: .semibold, design: .rounded)).monospacedDigit()
            note.font(.caption).foregroundStyle(.muted).lineLimit(1)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .surface()
    }
}

private struct OutcomeBar: View {
    let clean, hinted, assisted: Int
    var body: some View {
        let all = clean + hinted + assisted
        if all == 0 {
            Text("No solves yet")
        } else {
            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { g in
                    HStack(spacing: 2) {
                        ForEach([(clean, Color.success), (hinted, .warning), (assisted, .danger)].filter { $0.0 > 0 }, id: \.1) { n, c in
                            Capsule().fill(c).frame(width: max(4, (g.size.width - 4) * Double(n) / Double(all)))
                        }
                    }
                }
                .frame(height: 4)
                Text("\(clean) clean · \(hinted) hinted · \(assisted) assisted")
            }
        }
    }
}

private struct ActivityPanel: View {
    let days, weeks: [Bucket]
    @AppStorage("statsRange") private var range = "day"
    @AppStorage("statsMetric") private var metric = "minutes"
    @State private var picked: Date?

    var body: some View {
        let data = range == "day" ? days : weeks
        let value = { (b: Bucket) in metric == "xp" ? b.xp : b.minutes }
        let active = data.filter { value($0) > 0 }
        let unit = range == "day" ? "day" : "week"
        // goal lines only make sense for time: 30 min a day, 5 × 30 min a week
        let goal = metric == "minutes" ? (range == "day" ? 30 : 150) : nil
        let fmt = { (v: Int) in metric == "xp" ? "\(v) XP" : hours(v * 60) }
        let hit = picked.flatMap { p in data.last { Dates.parse($0.start) <= p } }

        Panel(title: "Activity") {
            HStack(spacing: 8) {
                Segments(selection: $range, options: [("day", "Day"), ("week", "Week")], small: true)
                Segments(selection: $metric, options: [("minutes", "Time"), ("xp", "XP")], small: true)
            }
        } content: {
            HStack(spacing: 0) {
                figure("Total", fmt(data.reduce(0) { $0 + value($1) }))
                Divider()
                figure("Avg per active \(unit)", active.isEmpty ? "—" : fmt(active.reduce(0) { $0 + value($1) } / active.count))
                Divider()
                if let goal { figure("Goal \(unit)s", "\(data.filter { $0.minutes >= goal }.count) / \(data.count)") }
                else { figure("Active \(unit)s", "\(active.count) / \(data.count)") }
            }
            .fixedSize(horizontal: false, vertical: true)
            Divider()
            Chart {
                ForEach(data) { b in
                    let v = value(b)
                    BarMark(x: .value(unit, Dates.parse(b.start), unit: range == "day" ? .day : .weekOfYear),
                            y: .value(metric == "xp" ? "XP" : "Minutes", v))
                        .foregroundStyle(goal.map { v >= $0 } == true ? Color.success.opacity(0.8) : Color.brand.opacity(0.65))
                        .opacity(hit == nil || hit?.start == b.start ? 1 : 0.45)
                        .cornerRadius(3)
                }
                if let goal {
                    RuleMark(y: .value("Goal", goal))
                        .foregroundStyle(Color.warning.opacity(0.7)).lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("goal \(fmt(goal))").font(.caption2).foregroundStyle(Color.warning.opacity(0.9))
                        }
                }
                if let hit {
                    RuleMark(x: .value(unit, Dates.parse(hit.start), unit: range == "day" ? .day : .weekOfYear))
                        .foregroundStyle(.clear)
                        .annotation(position: .top, spacing: 4, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            HStack(spacing: 8) {
                                Text("\(range == "week" ? "Week of " : "")\(Dates.parse(hit.start).formatted(.dateTime.month(.abbreviated).day()))")
                                    .foregroundStyle(.muted)
                                Text(fmt(value(hit))).fontWeight(.semibold).monospacedDigit()
                            }
                            .font(.caption)
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .glassEffect(.regular, in: .capsule)
                        }
                }
            }
            .chartXSelection(value: $picked)
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { v in
                    AxisGridLine().foregroundStyle(Color.hairline)
                    AxisValueLabel { if let n = v.as(Int.self) { Text(metric == "xp" ? "\(n)" : hours(n * 60)) } }
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 6)) { _ in
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
            .frame(height: 220)
            .padding(16)
            .animation(.snappy, value: range + metric)
        }
    }

    private func figure(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(.caption).foregroundStyle(.muted)
            Text(value).font(.system(size: 17, weight: .semibold, design: .rounded)).monospacedDigit()
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ExplainPanel: View {
    let grades: [(kind: String, title: String, ts: String, score: Int)]

    var body: some View {
        Panel(title: "Explain scores") {
            if grades.isEmpty {
                Text("Grade an explanation with AI and your scores show up here.")
                    .font(.callout).foregroundStyle(.muted).multilineTextAlignment(.center)
                    .padding(.horizontal, 24).padding(.vertical, 40).frame(maxWidth: .infinity)
            } else {
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(Array(grades.enumerated()), id: \.offset) { _, g in
                        UnevenRoundedRectangle(topLeadingRadius: 3, topTrailingRadius: 3)
                            .fill(scoreTone(g.score).opacity(0.75))
                            .frame(maxWidth: 18).frame(height: max(Double(g.score), 0.3) / 5 * 64)
                            .help("\(g.title): \(g.score)/5")
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 64, alignment: .bottomLeading)
                .padding(16)
                Divider()
                VStack(spacing: 0) {
                    ForEach(Array(grades.suffix(6).reversed().enumerated()), id: \.offset) { i, g in
                        if i > 0 { Divider() }
                        HStack(spacing: 10) {
                            Text(g.title).lineLimit(1).frame(maxWidth: .infinity, alignment: .leading)
                            Text(g.kind.capitalized).font(.caption).foregroundStyle(.muted)
                            Text("\(g.score)/5").font(.caption.weight(.semibold).monospacedDigit()).foregroundStyle(scoreTone(g.score))
                                .frame(width: 38, height: 20).background(scoreTone(g.score).opacity(0.12), in: .capsule)
                        }
                        .padding(.horizontal, 16).frame(height: 38)
                    }
                }
            }
        }
    }
}
