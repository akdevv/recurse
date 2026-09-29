import SwiftUI

/// Course map: overall progress, then every module with its topics and problems.
struct CourseView: View {
    @Environment(Store.self) private var store
    @Environment(Nav.self) private var nav

    var body: some View {
        let modules = store.moduleViews()
        let topics = modules.flatMap(\.topics)
        var seen = Set<String>()
        let problems = topics.flatMap(\.problems).filter { seen.insert($0.id).inserted }
        let solved = problems.filter { Store.isSolved($0.status) }.count
        let current = modules.first { !$0.complete }

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    Summary(label: "Topics complete", value: topics.filter(\.status.complete).count, total: topics.count)
                    Summary(label: "Problems solved", value: solved, total: problems.count)
                    if let current {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Continue", systemImage: "play.fill").font(.caption.weight(.medium)).foregroundStyle(Color.brand)
                            Text(current.module.title).font(.title3.weight(.semibold)).lineLimit(1)
                            Text(current.topics.first { !$0.status.complete }.map { "Next up: \($0.topic.title)" } ?? "All topics done")
                                .font(.caption).foregroundStyle(.secondary).lineLimit(1)
                        }
                        .card()
                    }
                }
                .fixedSize(horizontal: false, vertical: true)

                ForEach(modules) { m in ModuleCard(m: m) }
            }
            .padding(28)
            .frame(maxWidth: 920)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Course map")
    }
}

private struct Summary: View {
    let label: String
    let value, total: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.caption.weight(.medium)).foregroundStyle(.secondary)
            Text("\(Text("\(value)").font(.title.weight(.semibold)))\(Text(" / \(total)").foregroundStyle(.secondary))").monospacedDigit()
            ProgressView(value: Double(value), total: Double(max(1, total)))
        }
        .card()
    }
}

private struct ModuleCard: View {
    @Environment(Nav.self) private var nav
    let m: ModuleView

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text(String(format: "%02d", m.module.number))
                    .font(.callout.monospacedDigit().weight(.semibold))
                    .foregroundStyle(m.complete ? Color.success : m.unlocked ? Color.brand : .secondary)
                    .frame(width: 36, height: 36)
                    .background((m.complete ? Color.success : m.unlocked ? Color.brand : Color.primary).opacity(0.1), in: .rect(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 2) {
                    Text(m.module.title).font(.headline)
                    Text(m.module.summary).font(.callout).foregroundStyle(.secondary).lineLimit(2)
                }
                Spacer()
                if !m.unlocked { Label("Locked", systemImage: "lock.fill").font(.caption).foregroundStyle(.secondary) }
                Text("\(m.topics.filter(\.status.complete).count)/\(m.topics.count)").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            }
            Divider()
            ForEach(m.topics) { t in
                VStack(alignment: .leading, spacing: 4) {
                    Button { nav.go(.topic(t.id)) } label: {
                        HStack {
                            Image(systemName: t.status.complete ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(t.status.complete ? Color.success : .secondary)
                            Text(t.topic.title).fontWeight(.medium)
                            if !t.topic.ready { Text("Soon").font(.caption2).foregroundStyle(.secondary) }
                            Spacer()
                            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    ForEach(t.problems) { p in ProblemRow(p: p).padding(.leading, 24) }
                }
                .padding(.vertical, 2)
            }
            Divider()
            Button { nav.go(.boss(m.id)) } label: {
                HStack {
                    Image(systemName: "figure.fencing").foregroundStyle(m.complete ? Color.warning : .secondary)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Boss fight").fontWeight(.medium)
                        Text("Mock interview · \(m.module.boss.timeLimitMin) min · one problem, explained out loud")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    let left = m.topics.filter { !$0.status.complete }.count
                    Text(left == 0 ? "Ready" : "\(left) \(left == 1 ? "topic" : "topics") to go")
                        .font(.caption).foregroundStyle(left == 0 ? Color.warning : .secondary)
                    Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
        .card()
    }
}

struct ProblemRow: View {
    @Environment(Nav.self) private var nav
    let p: TopicProblem

    var body: some View {
        Button { nav.go(.problem(p.id)) } label: {
            HStack(spacing: 8) {
                StatusIcon(status: p.status).font(.caption)
                Text(p.title).foregroundStyle(p.available ? .primary : .secondary)
                if p.role != .core { Text(p.role.rawValue.capitalized).font(.caption2).foregroundStyle(.secondary) }
                Spacer()
                if let d = p.difficulty { Text(d.short).font(.caption.weight(.medium)).foregroundStyle(d.color) }
                if !p.available { Image(systemName: "lock").font(.caption2).foregroundStyle(.tertiary) }
            }
            .font(.callout)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(!p.available)
    }
}
