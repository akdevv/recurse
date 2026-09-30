import Foundation

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
            let title = kind == "problem" ? Content.problem(ref)?.title : kind == "boss" ? Content.module(ref)?.title : Content.topic(ref)?.title
            return (kind, title ?? ref, g.str("ts")!, g.int("score")!)
        }
        let modules = moduleViews().map { m in
            let probs = m.topics.flatMap(\.problems).uniqued(by: \.id)
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

    func patterns() -> [PatternView] {
        let catalog = Content.patterns()
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
