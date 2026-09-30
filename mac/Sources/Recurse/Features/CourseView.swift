import SwiftUI

struct CourseView: View {
    @Environment(Store.self) private var store
    @State private var open: Set<String>?

    var body: some View {
        let modules = store.moduleViews()
        let current = modules.first { !$0.complete }
        let expanded = open ?? Set(current.map { [$0.id] } ?? [])

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Summary(modules: modules, current: current) { id in
                    withAnimation(.snappy) { open = expanded.union([id]) }
                }
                VStack(spacing: 12) {
                    ForEach(modules) { m in
                        ModuleCard(m: m, isOpen: expanded.contains(m.id)) {
                            withAnimation(.snappy(duration: 0.25)) {
                                open = expanded.contains(m.id) ? expanded.subtracting([m.id]) : expanded.union([m.id])
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 32).padding(.vertical, 28)
            .frame(maxWidth: 900)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Course")
    }
}

// MARK: summary

private struct Summary: View {
    let modules: [ModuleView]
    let current: ModuleView?
    let jump: (String) -> Void

    var body: some View {
        let topics = modules.flatMap(\.topics)
        let done = topics.filter(\.status.complete).count
        var seen = Set<String>()
        let problems = topics.flatMap(\.problems).filter { seen.insert($0.id).inserted }
        let solved = problems.filter { Store.isSolved($0.status) }.count
        let nextTopic = current?.topics.first { !$0.status.complete }

        HStack(spacing: 14) {
            SummaryCard(icon: "book", label: "Topics complete", tint: .brand, value: "\(done)", caption: "of \(topics.count)") {
                GaugeRing(value: done, total: topics.count, tint: .brand)
            }
            SummaryCard(icon: "chevron.left.forwardslash.chevron.right", label: "Problems solved", tint: .success,
                        value: "\(solved)", caption: "of \(problems.count)") {
                GaugeRing(value: solved, total: problems.count, tint: .success)
            }
            if let current {
                HoverButton { jump(current.id) } label: { hover in
                    SummaryCard(icon: "play", label: "Continue", tint: .brand, value: current.module.title,
                                caption: nextTopic.map { "Next up: \($0.topic.title)" } ?? "All topics done", hover: hover) {
                        Image(systemName: "arrow.right").font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(hover ? Color.brand : Color.muted)
                            .frame(width: 30, height: 30)
                            .overlay(Circle().strokeBorder(hover ? Color.brand.opacity(0.5) : Color.hairline))
                    }
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true) // all three as tall as the tallest
    }
}

private struct SummaryCard<Accessory: View>: View {
    let icon, label: String
    let tint: Color
    let value, caption: String
    var hover = false
    @ViewBuilder let accessory: Accessory

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 6) {
                    Image(systemName: icon).font(.system(size: 11, weight: .semibold)).foregroundStyle(tint).frame(width: 14)
                    Text(label).font(.caption.weight(.medium)).foregroundStyle(.muted)
                }
                Text(value).font(.system(size: 24, weight: .semibold, design: .rounded)).monospacedDigit().lineLimit(1)
                    .frame(height: 34, alignment: .bottomLeading)
                Text(caption).font(.caption).foregroundStyle(.muted).lineLimit(1)
            }
            Spacer(minLength: 0)
            accessory
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(hover ? Color.hover.opacity(0.5) : Color.surface, in: .rect(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(.hairline))
    }
}

private struct GaugeRing: View {
    let value, total: Int
    let tint: Color

    var body: some View {
        Gauge(value: Double(value), in: 0...Double(max(1, total))) {
            EmptyView()
        } currentValueLabel: {
            Text("\(Int((Double(value) / Double(max(1, total)) * 100).rounded()))%").font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.muted)
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .tint(tint)
        .scaleEffect(0.85)
    }
}

// MARK: module card

private struct ModuleCard: View {
    let m: ModuleView
    let isOpen: Bool
    let toggle: () -> Void

    var body: some View {
        let done = m.topics.filter(\.status.complete).count
        let started = m.topics.contains { $0.status.complete || $0.status.lessonDone || $0.status.solved > 0 }
        let lit = m.complete || started
        let tone: Color = m.complete ? .success : started ? .brand : .muted

        VStack(spacing: 0) {
            HoverButton(action: toggle) { hover in
                HStack(spacing: 16) {
                    Text(String(format: "%02d", m.module.number))
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundStyle(tone)
                        .frame(width: 40, height: 40)
                        .background(lit ? tone.opacity(0.1) : Color.raised, in: .rect(cornerRadius: 10, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(lit ? tone.opacity(0.2) : Color.hairline))
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(m.module.title).font(.system(size: 15, weight: .semibold))
                            if !m.unlocked { Image(systemName: "lock.fill").font(.system(size: 9)).foregroundStyle(.muted) }
                        }
                        Text(m.module.summary).font(.callout).foregroundStyle(.muted).lineLimit(1)
                    }
                    Spacer(minLength: 12)
                    HStack(spacing: 10) {
                        Text("\(done)/\(m.topics.count)").font(.caption.monospacedDigit()).foregroundStyle(.muted)
                        HStack(spacing: 2) {
                            ForEach(m.topics) { t in Capsule().fill(t.status.complete ? Color.success : Color.primary.opacity(0.1)).frame(height: 4) }
                        }
                        .frame(width: 80)
                    }
                    .help("\(done) of \(m.topics.count) topics complete")
                    Image(systemName: "chevron.down").font(.system(size: 12, weight: .semibold)).foregroundStyle(.muted)
                        .rotationEffect(.degrees(isOpen ? 180 : 0))
                }
                .padding(.horizontal, 20).padding(.vertical, 16)
                .background(hover ? Color.hover.opacity(0.4) : .clear)
            }

            if isOpen {
                Divider()
                VStack(spacing: 0) {
                    ForEach(Array(m.topics.enumerated()), id: \.element.id) { i, t in
                        if i > 0 { Divider() }
                        TopicSection(t: t)
                    }
                    Divider()
                    BossRow(m: m, topicsLeft: m.topics.count - done)
                }
                .transition(.opacity)
            }
        }
        .surface(clip: true)
    }
}

private struct TopicSection: View {
    @Environment(Nav.self) private var nav
    let t: TopicState

    var body: some View {
        let st = t.status
        var steps = [st.lessonDone]
        if st.hasQuiz { steps.append((st.quizBest ?? 0) >= Store.quizPass) }
        if st.required > 0 { steps.append(st.solved == st.required) }
        steps.append(st.explained)
        let started = steps.contains(true)

        return VStack(alignment: .leading, spacing: 4) {
            HoverButton(enabled: t.topic.ready) { nav.go(.topic(t.id)) } label: { hover in
                HStack(spacing: 12) {
                    Image(systemName: st.complete ? "checkmark.circle.fill" : started ? "circle.dashed" : "circle")
                        .font(.system(size: 14))
                        .foregroundStyle(st.complete ? Color.success : started ? .brand : Color.muted.opacity(0.5))
                    Text(t.topic.title).font(.system(size: 13, weight: .medium)).lineLimit(1)
                        .foregroundStyle(t.topic.ready ? .primary : Color.muted)
                    if !t.topic.ready { Text("Soon").font(.caption2.weight(.medium)).foregroundStyle(.muted) }
                    Spacer(minLength: 8)
                    if t.topic.ready {
                        HStack(spacing: 2) {
                            ForEach(steps.indices, id: \.self) { i in
                                Capsule().fill(steps[i] ? (st.complete ? Color.success : .brand) : Color.primary.opacity(0.1)).frame(height: 4)
                            }
                        }
                        .frame(width: 56)
                        .help("Lesson · quiz · problems · explain")
                    }
                    Image(systemName: "chevron.right").font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(hover ? .primary : Color.muted.opacity(0.5))
                        .offset(x: hover ? 2 : 0)
                        .opacity(t.topic.ready ? 1 : 0)
                }
                .padding(.horizontal, 8).frame(height: 34)
                .background(hover ? Color.hover : .clear, in: .rect(cornerRadius: 8, style: .continuous))
            }

            if t.problems.isEmpty {
                Text("Concepts and quiz, no problems").font(.caption).foregroundStyle(.muted).padding(.leading, 34).padding(.bottom, 2)
            } else {
                VStack(spacing: 0) { ForEach(t.problems) { ProblemRow(p: $0) } }
                    .padding(.leading, 26)
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 12)
    }
}

private struct BossRow: View {
    @Environment(Nav.self) private var nav
    let m: ModuleView
    let topicsLeft: Int

    var body: some View {
        let ready = topicsLeft == 0
        HStack(spacing: 16) {
            Image(systemName: "figure.fencing").font(.system(size: 14))
                .foregroundStyle(ready ? Color.warning : .muted)
                .frame(width: 40, height: 40)
                .background(ready ? Color.warning.opacity(0.1) : Color.raised, in: .rect(cornerRadius: 10, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(ready ? Color.warning.opacity(0.2) : Color.hairline))
            VStack(alignment: .leading, spacing: 2) {
                Text("Boss fight").font(.system(size: 13, weight: .medium))
                Text("Mock interview · \(m.module.boss.timeLimitMin) min · one problem, explained out loud").font(.caption).foregroundStyle(.muted)
            }
            Spacer()
            if ready {
                Button("Start") { nav.go(.boss(m.id)) }.buttonStyle(.glassProminent).controlSize(.small)
            } else {
                Button { nav.go(.boss(m.id)) } label: {
                    Text("\(topicsLeft) \(topicsLeft == 1 ? "topic" : "topics") to go").font(.caption.monospacedDigit())
                }
                .buttonStyle(.plain).foregroundStyle(.muted)
            }
        }
        .padding(.horizontal, 20).padding(.vertical, 16)
        .background(Color.canvas.opacity(0.4))
    }
}
