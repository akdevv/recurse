import SwiftUI

struct ProblemsView: View {
    @Environment(Store.self) private var store
    @State private var query = ""
    @State private var difficulty = "all"
    @State private var status = "all"
    @State private var module = "all"
    @State private var sort: (key: SortKey, ascending: Bool)?

    enum SortKey { case status, title, topic, difficulty, lc }

    var body: some View {
        let rows = store.allProblems()
        let needle = query.trimmingCharacters(in: .whitespaces).lowercased().replacing(/^#/, with: "")
        let matches = rows.filter { r in
            (difficulty == "all" || r.p.difficulty?.rawValue == difficulty)
                && (status == "all" || ["new": 0, "started": 1, "done": 2][status] == r.statusRank)
                && (module == "all" || r.module.id == module)
                && (needle.isEmpty || r.title.lowercased().contains(needle) || r.topic.title.lowercased().contains(needle)
                    || r.p.lc.map { String($0).hasPrefix(needle) || String(format: "%04d", $0).hasPrefix(needle) } == true)
        }
        let shown = sorted(filtered: matches)
        let filtered = difficulty != "all" || status != "all" || module != "all" || !needle.isEmpty

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                stats(rows)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        FilterField(text: $query, prompt: "Search by title, topic or LeetCode #")
                        Menu {
                            Picker("Module", selection: $module) {
                                Text("All modules").tag("all")
                                ForEach(Content.modules()) { Text("\($0.number). \($0.title)").tag($0.id) }
                            }
                            .pickerStyle(.inline)
                        } label: {
                            HStack(spacing: 10) {
                                Text(module == "all" ? "All modules" : Content.module(module).title).lineLimit(1).frame(maxWidth: 200)
                                Image(systemName: "chevron.down").font(.caption.weight(.semibold)).foregroundStyle(.muted)
                            }
                            .padding(.horizontal, 16).frame(height: 36)
                            .glassEffect(.regular.interactive(), in: .capsule)
                            .contentShape(.capsule)
                        }
                        .menuStyle(.button).buttonStyle(.plain).menuIndicator(.hidden)
                        .fixedSize()
                    }
                    HStack(spacing: 10) {
                        Segments(selection: $difficulty, options: [("all", "Any"), ("Easy", "Easy"), ("Medium", "Medium"), ("Hard", "Hard")])
                        Segments(selection: $status, options: [("all", "All"), ("new", "To do"), ("started", "In progress"), ("done", "Solved")])
                        if filtered { ClearFiltersButton { clear() } }
                        Spacer()
                        Text("\(shown.count) of \(rows.count)").font(.callout.monospacedDigit()).foregroundStyle(.muted)
                    }
                }

                table(shown)
            }
            .padding(28)
            .frame(maxWidth: 1000)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Problems")
    }

    /// Click a column to sort by it, again to flip it, a third time to go back to course order.
    private func header(_ title: String, _ key: SortKey) -> some View {
        let on = sort?.key == key
        return Button {
            withAnimation(.snappy(duration: 0.2)) {
                sort = !on ? (key, true) : sort!.ascending ? (key, false) : nil
            }
        } label: {
            HStack(spacing: 3) {
                if key == .status { Image(systemName: "circle.dashed").font(.system(size: 10)) } else { Text(title) }
                if on { Image(systemName: sort!.ascending ? "chevron.up" : "chevron.down").font(.system(size: 8, weight: .bold)) }
            }
            .foregroundStyle(on ? Color.primary : Color.muted)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .help(key == .status ? "Sort by status" : "Sort by \(title.lowercased())")
    }

    private func sorted(filtered rows: [ProblemListRow]) -> [ProblemListRow] {
        guard let sort else { return rows }
        let rank: (ProblemListRow) -> (Int, String) = { r in
            switch sort.key {
            case .status: (r.statusRank, "")
            case .title: (0, r.title.lowercased())
            case .topic: (r.module.number, r.topic.title)
            case .difficulty: ([.easy: 0, .medium: 1, .hard: 2][r.p.difficulty ?? .medium] ?? 1, "")
            case .lc: (r.p.lc ?? .max, "")
            }
        }
        // stable: ties keep course order
        return rows.enumerated().sorted { a, b in
            let x = rank(a.element), y = rank(b.element)
            return x == y ? a.offset < b.offset : sort.ascending ? x < y : x > y
        }.map(\.element)
    }

    private func clear() { query = ""; difficulty = "all"; status = "all"; module = "all" }

    private func stats(_ rows: [ProblemListRow]) -> some View {
        let solved = { (rs: [ProblemListRow]) in rs.filter { $0.statusRank == 2 }.count }
        return HStack(spacing: 12) {
            StatCard(label: "Solved", tint: .brand, value: solved(rows), total: rows.count)
            ForEach([Difficulty.easy, .medium, .hard], id: \.self) { d in
                let all = rows.filter { $0.p.difficulty == d }
                StatCard(label: d.rawValue, tint: d.color, value: solved(all), total: all.count)
            }
        }
    }

    private func table(_ shown: [ProblemListRow]) -> some View {
        VStack(spacing: 0) {
            // same column widths as ProblemsListRow
            HStack(spacing: 14) {
                header("", .status).frame(width: 16)
                header("Title", .title).frame(maxWidth: .infinity, alignment: .leading)
                header("Topic", .topic).frame(width: 200, alignment: .leading)
                header("Difficulty", .difficulty).frame(width: 70, alignment: .leading)
                header("LC", .lc).frame(width: 56, alignment: .trailing)
            }
            .font(.caption.weight(.medium)).foregroundStyle(.muted)
            .padding(.horizontal, 16).padding(.vertical, 10)
            Divider()
            if shown.isEmpty {
                ContentUnavailableView {
                    Label("No matching problems", systemImage: "magnifyingglass")
                } actions: {
                    ClearFiltersButton { clear() }
                }
                .padding(.vertical, 30)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(Array(shown.enumerated()), id: \.element.id) { i, r in
                        if i > 0 { Divider() }
                        ProblemsListRow(r: r)
                    }
                }
            }
        }
        .surface(clip: true)
    }
}

private struct ProblemsListRow: View {
    @Environment(Nav.self) private var nav
    let r: ProblemListRow

    var body: some View {
        HoverButton(enabled: r.p.available) { nav.go(.problem(r.id)) } label: { hover in
            HStack(spacing: 14) {
                StatusIcon(status: r.p.status).font(.system(size: 13)).frame(width: 16)
                HStack(spacing: 8) {
                    Text(r.title).lineLimit(1).foregroundStyle(r.p.available ? Color.primary : Color.muted)
                    if r.p.role != .core {
                        Text(r.p.role.rawValue.capitalized).font(.caption2.weight(.medium)).foregroundStyle(.muted)
                            .padding(.horizontal, 6).padding(.vertical, 1).background(.raised, in: .capsule)
                    }
                    if !r.p.available { Image(systemName: "lock").font(.caption2).foregroundStyle(.muted) }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Text(r.topic.title).font(.callout).foregroundStyle(.muted).lineLimit(1)
                    .frame(width: 200, alignment: .leading).help("Module \(r.module.number) · \(r.module.title)")
                Text(r.p.difficulty?.rawValue ?? "—").font(.callout.weight(.medium)).foregroundStyle(r.p.difficulty?.color ?? .muted)
                    .frame(width: 70, alignment: .leading)
                Text(r.p.lc.map { "#\(String(format: "%04d", $0))" } ?? "—").font(.callout.monospacedDigit()).foregroundStyle(.muted)
                    .frame(width: 56, alignment: .trailing)
            }
            .padding(.horizontal, 16).frame(height: 40)
            .background(hover ? Color.hover.opacity(0.6) : .clear, in: .rect)
        }
        .help(r.p.available ? "" : "Not added yet")
    }
}
