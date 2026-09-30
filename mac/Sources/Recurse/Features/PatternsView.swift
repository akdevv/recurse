import SwiftUI

struct PatternsView: View {
    @Environment(Store.self) private var store
    @State private var query = ""
    @State private var filter = "all"

    var body: some View {
        let all = store.patterns()
        let needle = query.trimmingCharacters(in: .whitespaces).lowercased()
        let shown = all.filter { p in
            (filter == "all" || (filter == "practiced") == (p.solved > 0))
                && (needle.isEmpty || p.def.name.lowercased().contains(needle) || p.def.signals.lowercased().contains(needle))
        }
        // grouped by the module that first teaches each pattern; untaught ones last
        let groups = Dictionary(grouping: shown) { $0.topics.first?.module.number ?? Int.max }.sorted { $0.key < $1.key }

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                summary(all)
                HStack(spacing: 10) {
                    FilterField(text: $query, prompt: "Search by name or signal").frame(maxWidth: 360)
                    if !needle.isEmpty || filter != "all" { ClearFiltersButton { query = ""; filter = "all" } }
                    Spacer()
                    Text("\(shown.count) of \(all.count)").font(.callout.monospacedDigit()).foregroundStyle(.muted)
                    Segments(selection: $filter, options: [("all", "All"), ("practiced", "Practiced"), ("new", "Not started")])
                }

                VStack(spacing: 0) {
                    PatternColumns {
                        Text("Pattern")
                    } complexity: {
                        Text("Complexity")
                    } solved: {
                        Text("Solved")
                    }
                    .font(.caption.weight(.medium)).foregroundStyle(.muted)
                    .padding(.vertical, 10)
                    ForEach(groups, id: \.key) { key, items in
                        Divider()
                        HStack(spacing: 10) {
                            Text(key == Int.max ? "··" : String(format: "%02d", key))
                                .font(.caption.monospacedDigit()).foregroundStyle(.muted)
                                .frame(minWidth: 26, minHeight: 22).background(.raised, in: .rect(cornerRadius: 6, style: .continuous))
                            Text(items[0].topics.first?.module.title ?? "Later in the course").font(.callout.weight(.medium))
                            Spacer()
                            Text("\(items.filter { $0.solved > 0 }.count)/\(items.count) practiced").font(.caption.monospacedDigit()).foregroundStyle(.muted)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 9)
                        .background(Color.canvas.opacity(0.4))
                        ForEach(items) { p in
                            Divider()
                            PatternRow(p: p)
                        }
                    }
                    if shown.isEmpty {
                        Divider()
                        ContentUnavailableView {
                            Label("No matching patterns", systemImage: "magnifyingglass")
                        } actions: {
                            ClearFiltersButton { query = ""; filter = "all" }
                        }
                        .padding(.vertical, 30)
                    }
                }
                .surface(clip: true)
            }
            .padding(28)
            .frame(maxWidth: 1000)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Patterns")
    }

    private func summary(_ all: [PatternView]) -> some View {
        let practiced = all.filter { $0.solved > 0 }.count
        let mastered = all.filter { !$0.problems.isEmpty && $0.solved == $0.problems.count }.count
        let next = all.first { p in p.topics.contains { $0.topic.topic.ready } && !(p.solved > 0 && p.solved == p.problems.count) }
        return HStack(spacing: 12) {
            StatCard(label: "Practiced", tint: .brand, value: practiced, total: all.count)
            StatCard(label: "Mastered", tint: .success, value: mastered, total: all.count)
            UpNext(p: next)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

/// Pattern · complexity · solved · learn, shared by the header and rows so the columns line up.
private struct PatternColumns<A: View, B: View, C: View>: View {
    var hover = false
    var expandable = false
    var open = false
    @ViewBuilder let pattern: A
    @ViewBuilder let complexity: B
    @ViewBuilder let solved: C

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            pattern.frame(maxWidth: .infinity, alignment: .leading)
            complexity.frame(width: 200, alignment: .leading)
            solved.frame(width: 80, alignment: .leading)
            Image(systemName: "chevron.right").font(.system(size: 11, weight: .semibold))
                .foregroundStyle(hover || open ? Color.primary : Color.muted.opacity(0.6))
                .rotationEffect(.degrees(open ? 90 : 0))
                .opacity(expandable ? 1 : 0).frame(width: 14)
        }
        .padding(.horizontal, 16)
    }
}

private struct PatternRow: View {
    @Environment(Nav.self) private var nav
    let p: PatternView
    @State private var open = false

    var body: some View {
        let topic = p.topics.first { $0.topic.topic.ready }
        let total = p.problems.count
        let expandable = topic != nil || total > 0
        VStack(spacing: 0) {
            HoverButton(enabled: expandable) { withAnimation(.snappy(duration: 0.25)) { open.toggle() } } label: { hover in
                PatternColumns(hover: hover, expandable: expandable, open: open) {
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        StatusIcon(status: total > 0 && p.solved == total ? "solved" : p.solved > 0 ? "in-progress" : "new").font(.system(size: 13))
                        VStack(alignment: .leading, spacing: 3) {
                            Text(p.def.name).fontWeight(.medium)
                            Text(p.def.signals).font(.callout).foregroundStyle(.muted).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                } complexity: {
                    Text(p.def.complexity).font(.callout).foregroundStyle(.secondary).lineLimit(2)
                } solved: {
                    if total > 0 {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(p.solved)\(Text(" / \(total)").foregroundStyle(.muted))").font(.caption.monospacedDigit())
                            ProgressView(value: Double(p.solved), total: Double(total)).tint(p.solved == total ? .success : .brand)
                        }
                    } else {
                        Text("—").font(.caption).foregroundStyle(.muted)
                    }
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(hover || open ? Color.hover.opacity(open ? 0.35 : 0.6) : .clear, in: .rect)
                .opacity(expandable ? 1 : 0.7)
            }
            if open {
                VStack(alignment: .leading, spacing: 10) {
                    if let topic {
                        Button { nav.go(.topic(topic.topic.id)) } label: {
                            Label("Learn it in \(topic.topic.topic.title)", systemImage: "book")
                                .font(.callout.weight(.medium)).foregroundStyle(.brand).contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                    }
                    if total > 0 {
                        VStack(spacing: 2) { ForEach(p.problems) { ProblemRow(p: $0) } }
                            .padding(6)
                            .background(Color.canvas.opacity(0.45), in: .rect(cornerRadius: 10, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(.hairline))
                    }
                }
                .padding(.leading, 41).padding(.trailing, 16).padding(.bottom, 14).padding(.top, 2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.hover.opacity(0.35))
                .transition(.opacity)
            }
        }
        .help(topic.map { "Taught in \($0.topic.topic.title)" } ?? "Not taught yet")
    }
}

private struct UpNext: View {
    @Environment(Nav.self) private var nav
    let p: PatternView?

    var body: some View {
        let topic = p?.topics.first { $0.topic.topic.ready }
        HoverButton(enabled: topic != nil) { if let topic { nav.go(.topic(topic.topic.id)) } } label: { hover in
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Up next").font(.callout.weight(.medium)).foregroundStyle(.secondary)
                    Spacer()
                    if let p { Text("\(p.solved)/\(p.problems.count) solved").font(.caption.monospacedDigit()).foregroundStyle(.muted) }
                }
                HStack {
                    Text(p?.def.name ?? "All caught up").font(.system(.title3, design: .rounded).weight(.semibold)).lineLimit(1)
                    Spacer()
                    if p != nil {
                        Image(systemName: "arrow.right").font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(hover ? Color.brand : Color.primary)
                            .frame(width: 30, height: 30)
                            .glassEffect(.regular.interactive(), in: .circle)
                    }
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(hover ? Color.hover.opacity(0.5) : Color.surface, in: .rect(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(.hairline))
        }
    }
}
