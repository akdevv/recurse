// Stats and the pattern catalog. Port of web/server/stats.ts + pages/{stats,patterns}.tsx.
import Charts
import SwiftUI

struct Bucket: Identifiable {
    let start: String
    let minutes, xp: Int
    var id: String { start }
}

struct StatsData {
    var activeSeconds, activeDays, goalDays, solved, hinted, assisted: Int
    var quizAvg, explainAvg: Double?
    var weeks, days: [Bucket]
    var grades: [(kind: String, title: String, ts: String, score: Int)]
    var modules: [(module: Module, topics: Int, topicsDone: Int, problems: Int, solved: Int)]
}

struct PatternDef: Decodable, Identifiable {
    let id, name, signals, complexity: String
}

struct PatternView: Identifiable {
    let def: PatternDef
    let topics: [(topic: TopicState, module: Module)]
    let problems: [TopicProblem]
    var id: String { def.id }
    var solved: Int { problems.filter { Store.isSolved($0.status) }.count }
}

extension Store {
    func stats() -> StatsData {
        let today = Dates.local()
        let activity = activityMap()
        let statuses = Array(problemStatuses().values)
        let firstWeek = Dates.add(Dates.weekStart(today), -11 * 7)
        let firstDay = Dates.add(today, -29)
        let from = min(firstWeek, firstDay)
        var xpByDay: [String: Int] = [:]
        for r in db.all("SELECT ts, amount FROM xp_events WHERE ts >= ?", Dates.iso(Dates.parse(from))) {
            if let d = r.str("ts").flatMap(Dates.fromIso) { xpByDay[Dates.local(d), default: 0] += r.int("amount")! }
        }
        let bucket = { (start: String, n: Int) -> Bucket in
            let ds = (0..<n).map { Dates.add(start, $0) }
            return Bucket(start: start, minutes: Int((Double(ds.reduce(0) { $0 + (activity[$1] ?? 0) }) / 60).rounded()),
                          xp: ds.reduce(0) { $0 + (xpByDay[$1] ?? 0) })
        }
        let grades = db.all("SELECT kind, ref, ts, score FROM grades ORDER BY id DESC LIMIT 30").reversed().map { g in
            let kind = g.str("kind")!, ref = g.str("ref")!
            let title = kind == "problem" ? Content.problem(ref)?.title : kind == "boss" ? Content.module(ref).title : Content.topic(ref)?.title
            return (kind, title ?? ref, g.str("ts")!, g.int("score")!)
        }
        let modules = moduleViews().map { m in
            var seen = Set<String>()
            let probs = m.topics.flatMap(\.problems).filter { seen.insert($0.id).inserted }
            return (m.module, m.topics.count, m.topics.filter(\.status.complete).count, probs.count, probs.filter { Store.isSolved($0.status) }.count)
        }
        let days = Array(activity.values)
        return StatsData(
            activeSeconds: days.reduce(0, +), activeDays: days.filter { $0 > 0 }.count, goalDays: days.filter { $0 >= Streak.dailyGoal }.count,
            solved: statuses.filter { $0 == "solved" }.count, hinted: statuses.filter { $0 == "hinted" }.count,
            assisted: statuses.filter { $0 == "assisted" }.count,
            quizAvg: db.one("SELECT AVG(quiz_best) AS avg FROM topic_progress WHERE quiz_best IS NOT NULL")?.real("avg"),
            explainAvg: grades.isEmpty ? nil : Double(grades.reduce(0) { $0 + $1.3 }) / Double(grades.count),
            weeks: (0..<12).map { bucket(Dates.add(firstWeek, $0 * 7), 7) }, days: (0..<30).map { bucket(Dates.add(firstDay, $0), 1) },
            grades: grades, modules: modules)
    }

    /// Pattern catalog joined with the topics that teach each one and the problems that use it.
    func patterns() -> [PatternView] {
        let catalog: [PatternDef] = (try? JSONDecoder().decode([PatternDef].self, from: Data(contentsOf: Paths.course.appending(path: "patterns.json")))) ?? []
        let views = moduleViews()
        let topics = views.flatMap { m in m.topics.map { (topic: $0, module: m.module) } }
        return catalog.map { p in
            let tps = topics.filter { $0.topic.topic.patterns.contains(p.id) }
            var probs: [String: TopicProblem] = [:], order: [String] = []
            let add = { (q: TopicProblem) in if probs.updateValue(q, forKey: q.id) == nil { order.append(q.id) } }
            for t in tps { t.topic.problems.forEach(add) }
            for t in topics {
                for q in t.topic.problems where q.available && Content.problem(q.id)?.patterns.contains(p.id) == true { add(q) }
            }
            return PatternView(def: p, topics: tps, problems: order.map { probs[$0]! })
        }
    }
}

// MARK: stats view

struct StatsView: View {
    @Environment(Store.self) private var store
    @AppStorage("statsRange") private var range = "day"
    @AppStorage("statsMetric") private var metric = "minutes"

    var body: some View {
        let s = store.stats()
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                    tile("clock", "Active time", hours(s.activeSeconds), "\(s.activeDays) active days")
                    tile("calendar.badge.checkmark", "Goal days", "\(s.goalDays)", "30+ focused minutes")
                    tile("chevron.left.forwardslash.chevron.right", "Problems solved", "\(s.solved + s.hinted + s.assisted)",
                         "\(s.solved) clean · \(s.hinted) hinted · \(s.assisted) assisted")
                    tile("text.bubble", "Avg explain score", s.explainAvg.map { String(format: "%.1f/5", $0) } ?? "–",
                         s.quizAvg.map { "quiz avg \(Int(($0 * 100).rounded()))%" } ?? "no quizzes yet")
                }
                chart(s)
                if !s.grades.isEmpty { gradesCard(s) }
                modulesCard(s)
            }
            .padding(28)
            .frame(maxWidth: 920)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Stats")
    }

    private func hours(_ s: Int) -> String { s >= 3600 ? String(format: "%.1fh", Double(s) / 3600) : "\(s / 60)m" }

    private func tile(_ icon: String, _ label: String, _ value: String, _ note: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(label, systemImage: icon).font(.caption.weight(.medium)).foregroundStyle(.secondary)
            Text(value).font(.title.weight(.semibold)).monospacedDigit()
            Text(note).font(.caption).foregroundStyle(.secondary).lineLimit(1)
        }
        .card()
    }

    private func chart(_ s: StatsData) -> some View {
        let data = range == "day" ? s.days : s.weeks
        let value = { (b: Bucket) in metric == "xp" ? b.xp : b.minutes }
        let active = data.filter { value($0) > 0 }
        let unit = range == "day" ? "day" : "week"
        // goal lines only make sense for time: 30 min a day, 5 × 30 min a week
        let goal = metric == "minutes" ? (range == "day" ? 30 : 150) : nil
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(range == "day" ? "Last 30 days" : "Last 12 weeks").font(.headline)
                Spacer()
                Picker("", selection: $range) { Text("Day").tag("day"); Text("Week").tag("week") }.pickerStyle(.segmented).fixedSize()
                Picker("", selection: $metric) { Text("Time").tag("minutes"); Text("XP").tag("xp") }.pickerStyle(.segmented).fixedSize()
            }
            .labelsHidden()
            HStack(spacing: 28) {
                summary("Total", metric == "xp" ? "\(data.reduce(0) { $0 + $1.xp }) XP" : hours(data.reduce(0) { $0 + $1.minutes } * 60))
                summary("Average per active \(unit)", active.isEmpty ? "–"
                        : metric == "xp" ? "\(active.reduce(0) { $0 + $1.xp } / active.count) XP" : "\(active.reduce(0) { $0 + $1.minutes } / active.count) min")
                if let goal { summary("Goal \(unit)s", "\(data.filter { $0.minutes >= goal }.count)/\(data.count)") }
                else { summary("Active \(unit)s", "\(active.count)/\(data.count)") }
            }
            Chart {
                ForEach(data) { b in
                    BarMark(x: .value(unit, Dates.parse(b.start), unit: range == "day" ? .day : .weekOfYear),
                            y: .value(metric == "xp" ? "XP" : "Minutes", value(b)))
                        .foregroundStyle(goal.map { value(b) >= $0 ? Color.green : Color.accentColor } ?? Color.accentColor)
                        .cornerRadius(3)
                }
                if let goal { RuleMark(y: .value("Goal", goal)).foregroundStyle(.secondary).lineStyle(StrokeStyle(lineWidth: 1, dash: [4])) }
            }
            .frame(height: 200)
        }
        .card(padding: 18)
    }

    private func summary(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title3.weight(.semibold)).monospacedDigit()
        }
    }

    private func gradesCard(_ s: StatsData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Explain-back scores").font(.headline)
            Chart {
                ForEach(Array(s.grades.enumerated()), id: \.offset) { i, g in
                    LineMark(x: .value("Attempt", i + 1), y: .value("Score", g.score)).interpolationMethod(.monotone)
                    PointMark(x: .value("Attempt", i + 1), y: .value("Score", g.score))
                        .foregroundStyle(g.score >= 4 ? Color.green : g.score >= 3 ? .orange : .red)
                }
            }
            .chartYScale(domain: 0...5)
            .chartXAxis(.hidden)
            .frame(height: 140)
            if let last = s.grades.last {
                Text("Latest: \(last.title) (\(last.kind)) · \(last.score)/5").font(.caption).foregroundStyle(.secondary)
            }
        }
        .card(padding: 18)
    }

    private func modulesCard(_ s: StatsData) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("By module").font(.headline)
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                GridRow {
                    Text("Module"); Text("Topics"); Text("Problems").gridCellColumns(2)
                }
                .font(.caption.weight(.medium)).foregroundStyle(.secondary)
                ForEach(s.modules, id: \.module.id) { m in
                    GridRow {
                        Text("\(String(format: "%02d", m.module.number))  \(m.module.title)").lineLimit(1)
                        Text("\(m.topicsDone)/\(m.topics)").monospacedDigit().foregroundStyle(.secondary)
                        ProgressView(value: Double(m.solved), total: Double(max(1, m.problems))).frame(width: 140)
                        Text("\(m.solved)/\(m.problems)").monospacedDigit().foregroundStyle(.secondary)
                    }
                    .font(.callout)
                }
            }
        }
        .card(padding: 18)
    }
}

// MARK: patterns view

struct PatternsView: View {
    @Environment(Store.self) private var store
    @Environment(Nav.self) private var nav
    @State private var query = ""
    @State private var open: Set<String> = []

    var body: some View {
        let all = store.patterns()
        let q = query.lowercased()
        let shown = q.isEmpty ? all : all.filter { $0.def.name.lowercased().contains(q) || $0.def.signals.lowercased().contains(q) }
        List {
            ForEach(shown) { p in
                DisclosureGroup(isExpanded: Binding(get: { open.contains(p.id) }, set: { if $0 { open.insert(p.id) } else { open.remove(p.id) } })) {
                    VStack(alignment: .leading, spacing: 10) {
                        Label(p.def.complexity, systemImage: "gauge.with.dots.needle.33percent").font(.caption.monospaced()).foregroundStyle(.secondary)
                        if !p.topics.isEmpty {
                            Text("Taught in").font(.caption.weight(.medium)).foregroundStyle(.secondary)
                            ForEach(p.topics, id: \.topic.id) { t in
                                Button { nav.go(.topic(t.topic.id)) } label: {
                                    HStack {
                                        Image(systemName: t.topic.status.complete ? "checkmark.circle.fill" : "book").foregroundStyle(t.topic.status.complete ? .green : .secondary)
                                        Text(t.topic.topic.title)
                                        Text("Module \(t.module.number)").font(.caption).foregroundStyle(.secondary)
                                    }
                                    .contentShape(.rect)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        if !p.problems.isEmpty {
                            Text("Problems").font(.caption.weight(.medium)).foregroundStyle(.secondary)
                            ForEach(p.problems) { ProblemRow(p: $0) }
                        }
                    }
                    .padding(.vertical, 6)
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(p.def.name).fontWeight(.medium)
                            Text(p.def.signals).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                        }
                        Spacer()
                        if !p.problems.isEmpty {
                            Text("\(p.solved)/\(p.problems.count)").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                            ProgressView(value: Double(p.solved), total: Double(p.problems.count)).frame(width: 70)
                                .tint(p.solved == p.problems.count ? .green : .accentColor)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .searchable(text: $query, placement: .toolbar, prompt: "Search patterns or signals")
        .navigationTitle("Patterns")
    }
}
