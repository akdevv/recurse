// All problems in one table, and ⌘K to jump anywhere. Port of pages/problems.tsx + command-palette.tsx.
import SwiftUI

struct ProblemListRow: Identifiable {
    let p: TopicProblem
    let topic: Topic
    let module: Module
    var id: String { p.id }
    // sortable keys
    var title: String { p.title }
    var lc: Int { p.lc ?? Int.max }
    var difficultyRank: Int { p.difficulty.map { [.easy: 0, .medium: 1, .hard: 2][$0]! } ?? 3 }
    var statusRank: Int { Store.isSolved(p.status) ? 2 : p.status == "in-progress" ? 1 : 0 }
    var order: Int { module.number * 1000 }
}

extension Store {
    /// Every problem once, under its first topic in course order.
    func allProblems() -> [ProblemListRow] {
        var seen = Set<String>()
        return moduleViews().flatMap { m in
            m.topics.flatMap { t in t.problems.filter { seen.insert($0.id).inserted }.map { ProblemListRow(p: $0, topic: t.topic, module: m.module) } }
        }
    }
}

struct ProblemsView: View {
    @Environment(Store.self) private var store
    @Environment(Nav.self) private var nav
    @State private var query = ""
    @State private var difficulty = "all"
    @State private var status = "all"
    @State private var module = "all"
    @State private var sort: [KeyPathComparator<ProblemListRow>] = []
    @State private var selection: String?

    var body: some View {
        let rows = store.allProblems()
        let needle = query.trimmingCharacters(in: .whitespaces).lowercased().replacing(/^#/, with: "")
        var shown = rows.filter { r in
            (difficulty == "all" || r.p.difficulty?.rawValue == difficulty)
                && (status == "all" || ["new": 0, "started": 1, "done": 2][status] == r.statusRank)
                && (module == "all" || r.module.id == module)
                && (needle.isEmpty || r.title.lowercased().contains(needle) || r.topic.title.lowercased().contains(needle)
                    || r.p.lc.map { String($0).hasPrefix(needle) || String(format: "%04d", $0).hasPrefix(needle) } == true)
        }
        if !sort.isEmpty { shown.sort(using: sort) }
        let solved = rows.filter { $0.statusRank == 2 }.count

        return VStack(spacing: 0) {
            HStack(spacing: 10) {
                Picker("Difficulty", selection: $difficulty) {
                    Text("Any difficulty").tag("all")
                    ForEach(["Easy", "Medium", "Hard"], id: \.self) { Text($0).tag($0) }
                }
                Picker("Status", selection: $status) {
                    Text("Any status").tag("all"); Text("To do").tag("new"); Text("In progress").tag("started"); Text("Solved").tag("done")
                }
                Picker("Module", selection: $module) {
                    Text("All modules").tag("all")
                    ForEach(Content.modules()) { Text("\($0.number). \($0.title)").tag($0.id) }
                }
                .frame(maxWidth: 240)
                if difficulty != "all" || status != "all" || module != "all" || !query.isEmpty {
                    Button("Clear") { query = ""; difficulty = "all"; status = "all"; module = "all" }.buttonStyle(.link)
                }
                Spacer()
                Text("\(shown.count) shown · \(solved)/\(rows.count) solved").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            }
            .labelsHidden()
            .padding(.horizontal, 14).padding(.vertical, 8)
            Divider()

            Table(shown, selection: $selection, sortOrder: $sort) {
                TableColumn("", value: \.statusRank) { StatusIcon(status: $0.p.status) }.width(22)
                TableColumn("Title", value: \.title) { r in
                    HStack(spacing: 6) {
                        Text(r.title).foregroundStyle(r.p.available ? .primary : .secondary)
                        if r.p.role != .core { Text(r.p.role.rawValue.capitalized).font(.caption2).foregroundStyle(.secondary) }
                        if !r.p.available { Image(systemName: "lock").font(.caption2).foregroundStyle(.tertiary) }
                    }
                }
                TableColumn("Topic", value: \.order) { r in
                    Text("\(r.module.number) · \(r.topic.title)").foregroundStyle(.secondary).lineLimit(1)
                }
                TableColumn("Difficulty", value: \.difficultyRank) { r in
                    if let d = r.p.difficulty { Text(d.rawValue).foregroundStyle(d.color) }
                }
                .width(80)
                TableColumn("LC", value: \.lc) { r in Text(r.p.lc.map { String(format: "%04d", $0) } ?? "").monospacedDigit().foregroundStyle(.secondary) }
                    .width(50)
            }
            .contextMenu(forSelectionType: String.self) { _ in } primaryAction: { ids in
                if let id = ids.first, rows.first(where: { $0.id == id })?.p.available == true { nav.go(.problem(id)) }
            }
            .overlay { if shown.isEmpty { ContentUnavailableView.search(text: query) } }
        }
        .searchable(text: $query, placement: .toolbar, prompt: "Title, topic or LeetCode #")
        .navigationTitle("Problems")
    }
}

// MARK: ⌘K

struct CommandPalette: View {
    @Environment(Store.self) private var store
    @Environment(Nav.self) private var nav
    @State private var query = ""
    @State private var sel = 0
    @FocusState private var focused: Bool

    private struct Item: Identifiable {
        let id, title, detail, icon: String
        let route: Route
    }

    private var items: [Item] {
        let pages = [
            Item(id: "p:today", title: "Today", detail: "Page", icon: "sun.max", route: .today),
            Item(id: "p:review", title: "Review", detail: "Page", icon: "arrow.counterclockwise", route: .review),
            Item(id: "p:course", title: "Course map", detail: "Page", icon: "map", route: .course),
            Item(id: "p:problems", title: "Problems", detail: "Page", icon: "list.bullet", route: .problems),
            Item(id: "p:patterns", title: "Patterns", detail: "Page", icon: "square.grid.3x3", route: .patterns),
            Item(id: "p:stats", title: "Stats", detail: "Page", icon: "chart.bar", route: .stats),
            Item(id: "p:rewards", title: "Rewards", detail: "Page", icon: "gift", route: .rewards),
        ]
        let modules = Content.modules()
        let topics = modules.flatMap { m in m.topics.compactMap(Content.topic).map {
            Item(id: "t:\($0.id)", title: $0.title, detail: "Topic · \(m.title)", icon: "book", route: .topic($0.id))
        } }
        let bosses = modules.map { Item(id: "b:\($0.id)", title: "\($0.title) boss fight", detail: "Boss", icon: "figure.fencing", route: .boss($0.id)) }
        let problems = store.allProblems().filter(\.p.available).map {
            Item(id: "q:\($0.id)", title: $0.title, detail: ($0.p.lc.map { "#\($0) · " } ?? "") + $0.topic.title,
                 icon: "chevron.left.forwardslash.chevron.right", route: .problem($0.id))
        }
        return pages + topics + bosses + problems
    }

    var body: some View {
        let words = query.lowercased().split(separator: " ")
        let shown = Array((words.isEmpty ? items.prefix(7) : items.filter { i in
            words.allSatisfy { (i.title + " " + i.detail).lowercased().contains($0) }
        }[...]).prefix(40))
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Jump to a page, topic or problem", text: $query)
                    .textFieldStyle(.plain).font(.title3).focused($focused)
                    .onSubmit { go(shown[safe: sel]) }
            }
            .padding(.horizontal, 18).padding(.vertical, 15)
            if !shown.isEmpty { Divider().opacity(0.5) }
            ScrollViewReader { proxy in
                List(Array(shown.enumerated()), id: \.element.id) { i, item in
                    HStack(spacing: 10) {
                        Image(systemName: item.icon).foregroundStyle(.secondary).frame(width: 18)
                        Text(item.title).lineLimit(1)
                        Spacer()
                        Text(item.detail).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                    }
                    .padding(.vertical, 3)
                    .contentShape(.rect)
                    .listRowBackground(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(i == sel ? Color.brand.opacity(0.22) : .clear).padding(.horizontal, 6))
                    .onTapGesture { go(item) }
                    .id(i)
                }
                .listStyle(.plain)
                .onChange(of: sel) { proxy.scrollTo(sel) }
            }
            .scrollContentBackground(.hidden)
            .frame(height: shown.isEmpty ? 0 : min(340, CGFloat(shown.count) * 34 + 10))
        }
        .frame(width: 580)
        .glassEffect(.regular, in: .rect(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 30, y: 12)
        .onAppear { focused = true }
        .onChange(of: query) { sel = 0 }
        .onKeyPress(.downArrow) { sel = min(sel + 1, max(0, shown.count - 1)); return .handled }
        .onKeyPress(.upArrow) { sel = max(sel - 1, 0); return .handled }
        .onExitCommand { close() }
    }

    private func close() { withAnimation(.bouncy(duration: 0.3)) { nav.searching = false } }

    private func go(_ item: Item?) {
        guard let item else { return }
        close()
        nav.go(item.route)
    }
}
