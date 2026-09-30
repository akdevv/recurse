// Real-world reward path (unlocked by finishing parts of the course) and tiered trophies.
import SwiftUI

struct RewardDef {
    let id, label, title, note, icon: String
    let size: Size
    var topics: [String] = []
    var modules: [String] = []
    var boss: String?
    enum Size { case small, medium, big }

    static let path: [RewardDef] = [
        RewardDef(id: "coffee-1", label: "Your first two topics", title: "Coffee", note: "A quick first win", icon: "coffee",
                  size: .small, topics: ["python-for-dsa", "complexity-analysis"]),
        RewardDef(id: "coffee-2", label: "Foundations", title: "Coffee", note: "", icon: "coffee-cappuccino", size: .small, modules: ["foundations"]),
        RewardDef(id: "coffee-3", label: "Arrays & Strings", title: "Coffee", note: "", icon: "coffee-iced", size: .small, modules: ["arrays-strings"]),
        RewardDef(id: "coffee-4", label: "Hashing", title: "Coffee", note: "", icon: "coffee-espresso", size: .small, modules: ["hashing"]),
        RewardDef(id: "meal", label: "Two Pointers & Windows", title: "A nice meal", note: "Somewhere you've wanted to try", icon: "meal",
                  size: .small, modules: ["two-pointers-sliding-window"]),
        RewardDef(id: "coffee-5", label: "Sorting & Searching", title: "Coffee", note: "Binary search conquered", icon: "coffee-togo",
                  size: .small, modules: ["sorting-searching"]),
        RewardDef(id: "tshirt", label: "Linked Lists & Stacks", title: "A T-shirt", note: "One you actually like", icon: "shirt",
                  size: .medium, modules: ["linked-lists", "stacks-queues"]),
        RewardDef(id: "movie", label: "Recursion", title: "Movie night", note: "Big screen, snacks included", icon: "movie",
                  size: .medium, modules: ["recursion-backtracking"]),
        RewardDef(id: "shoes", label: "Trees", title: "New shoes", note: "Halfway there", icon: "shoes", size: .medium, modules: ["trees"]),
        RewardDef(id: "book", label: "Heaps", title: "A book", note: "Any book, not a DSA one", icon: "book", size: .medium, modules: ["heaps"]),
        RewardDef(id: "gear", label: "Graphs", title: "Headphones", note: "Or a game, your call", icon: "headphones", size: .medium, modules: ["graphs"]),
        RewardDef(id: "grand", label: "Everything + the DP boss", title: "The big one: ₹10,000", note: "Anything you want within the budget",
                  icon: "gift", size: .big,
                  modules: ["greedy-intervals", "dynamic-programming", "tries", "bit-manipulation", "advanced-structures"],
                  boss: "dynamic-programming"),
    ]
}

struct RewardState: Identifiable {
    enum Status { case locked, unlocked, availed }
    let def: RewardDef
    let requires: [String]
    let done, total: Int
    let status: Status
    let availedAt: String?
    var id: String { def.id }
}

struct Badge: Identifiable {
    let id, name, desc, icon: String
    let value: Int
    let tiers: [Int] // one entry = single achievement, three = bronze/silver/gold

    var tier: Int { tiers.filter { value >= $0 }.count }
    var single: Bool { tiers.count == 1 }
    var next: Int? { tiers[safe: tier] }
    var medal: Medal.Metal { tier == 0 ? .locked : single ? .jade : [.bronze, .silver, .gold][tier - 1] }

    static func metal(_ tier: Int, single: Bool) -> Color {
        if tier == 0 { return .secondary }
        if single { return .success }
        return [Color(red: 0.79, green: 0.53, blue: 0.32), Color(red: 0.81, green: 0.84, blue: 0.86), Color(red: 0.95, green: 0.76, blue: 0.31)][tier - 1]
    }
    static let metalName = ["Locked", "Bronze", "Silver", "Gold"]
}

extension Store {
    func rewardPath() -> [RewardState] {
        let views = moduleViews()
        let topicDone = Set(views.flatMap(\.topics).filter(\.status.complete).map(\.id))
        let topicsOf = { (mid: String) in views.first { $0.id == mid }?.topics.map(\.id) ?? [] }
        let claims = Dictionary(uniqueKeysWithValues: db.all("SELECT id, claimed_at FROM reward_claims").map { ($0.str("id")!, $0.str("claimed_at")!) })
        return RewardDef.path.map { r in
            // the finale needs the whole course, not just its listed modules
            let mods = r.size == .big ? views.map(\.id) : r.modules
            let needed = r.topics + mods.flatMap(topicsOf)
            let done = needed.filter(topicDone.contains).count
            let bossWon = r.boss.map { db.one("SELECT 1 AS x FROM boss_runs WHERE module_id = ? AND passed = 1", $0) != nil } ?? true
            let requires = r.topics.map { Content.topic($0)?.title ?? $0 }
                + (r.size == .big ? ["every module"] : r.modules.map { Content.module($0).title })
                + (r.boss.map { ["\(Content.module($0).title) boss fight"] } ?? [])
            return RewardState(def: r, requires: requires, done: done, total: needed.count,
                               status: claims[r.id] != nil ? .availed : done == needed.count && bossWon ? .unlocked : .locked,
                               availedAt: claims[r.id])
        }
    }

    func setAvailed(_ id: String, _ availed: Bool) {
        guard let r = rewardPath().first(where: { $0.id == id }), r.status != .locked else {
            error = "That reward is still locked."
            return
        }
        if availed {
            _db.run("INSERT OR IGNORE INTO reward_claims (id, claimed_at) VALUES (?, ?)", id, Dates.iso())
            toast = "Enjoy it: \(r.def.title)"
        } else {
            _db.run("DELETE FROM reward_claims WHERE id = ?", id)
        }
        changed()
    }

    var rewardsWaiting: Int { chestsWaiting + rewardPath().filter { $0.status == .unlocked }.count }

    /// Counted from recorded effort, so once earned they can't be lost.
    func badges() -> [Badge] {
        let activity = activityMap()
        let dates = activity.keys.sorted()
        let goal = { (d: String) in (activity[d] ?? 0) >= Streak.dailyGoal }
        let count = { (sql: String) in self.db.one(sql)?.int("n") ?? 0 }
        let attempts = db.all("SELECT problem_id, outcome, active_seconds FROM attempts WHERE outcome IS NOT NULL")
        let difficulty = { (pid: String) in Content.hasProblem(pid) ? Content.problem(pid)?.difficulty : nil }
        let ids = { (rows: [Row]) in Set(rows.map { $0.str("problem_id")! }).count }
        let clean = attempts.filter { $0.str("outcome") == "solved" }
        let views = moduleViews()
        let perfectWeeks = Set(dates.map(Dates.weekStart)).filter { ws in (0..<7).map { Dates.add(ws, $0) }.filter(goal).count >= Streak.daysPerWeek }.count

        return [
            Badge(id: "first-solve", name: "First Accepted", desc: "problems solved", icon: "checkmark.seal.fill", value: ids(attempts), tiers: [1]),
            Badge(id: "solver", name: "Problem Solver", desc: "problems solved", icon: "chevron.left.forwardslash.chevron.right", value: ids(attempts), tiers: [25, 75, 150]),
            Badge(id: "no-hints", name: "No Hints Needed", desc: "solved hint-free", icon: "lightbulb.fill", value: ids(clean), tiers: [10, 40, 100]),
            Badge(id: "stretch", name: "Stretch Goals", desc: "Medium/Hard solved", icon: "mountain.2.fill",
                  value: ids(attempts.filter { difficulty($0.str("problem_id")!).map { $0 != .easy } ?? false }), tiers: [1, 15, 50]),
            Badge(id: "speedrun", name: "Speedrun", desc: "Easy clean under 10 min", icon: "bolt.fill",
                  value: ids(clean.filter { ($0.int("active_seconds") ?? 0) < 600 && difficulty($0.str("problem_id")!) == .easy }), tiers: [1, 10, 30]),
            Badge(id: "explainer", name: "Clear Explainer", desc: "4/5+ explanations", icon: "text.bubble.fill",
                  value: count("SELECT COUNT(*) AS n FROM grades WHERE score >= 4"), tiers: [1, 15, 50]),
            Badge(id: "perfect", name: "Perfect Score", desc: "5/5 explanations", icon: "star.fill",
                  value: count("SELECT COUNT(*) AS n FROM grades WHERE score = 5"), tiers: [1]),
            Badge(id: "quiz-ace", name: "Quiz Ace", desc: "perfect quizzes", icon: "target",
                  value: count("SELECT COUNT(*) AS n FROM topic_progress WHERE quiz_best >= 1"), tiers: [1, 10, 30]),
            Badge(id: "reviewer", name: "Spaced Out", desc: "reviews done", icon: "rectangle.stack.fill",
                  value: count("SELECT COUNT(*) AS n FROM xp_events WHERE reason = 'review'"), tiers: [10, 50, 200]),
            Badge(id: "perfect-week", name: "Full Week", desc: "5-goal-day weeks", icon: "calendar", value: perfectWeeks, tiers: [1, 4, 12]),
            Badge(id: "marathon", name: "Deep Work", desc: "3h+ focus days", icon: "hourglass",
                  value: dates.filter { activity[$0]! >= Streak.freezeDay }.count, tiers: [1, 5, 15]),
            Badge(id: "comeback", name: "Comeback", desc: "comebacks", icon: "arrow.uturn.up",
                  value: dates.filter { goal($0) && !goal(Dates.add($0, -1)) && goal(Dates.add($0, -2)) }.count, tiers: [1]),
            Badge(id: "topics", name: "Topic Master", desc: "topics completed", icon: "book.fill",
                  value: views.flatMap(\.topics).filter(\.status.complete).count, tiers: [1, 10, 40]),
            Badge(id: "boss", name: "Boss Slayer", desc: "bosses defeated", icon: "figure.fencing",
                  value: count("SELECT COUNT(DISTINCT module_id) AS n FROM boss_runs WHERE passed = 1"), tiers: [1, 5, 12]),
            Badge(id: "modules", name: "Module Master", desc: "modules completed", icon: "laurel.leading",
                  value: views.filter { $0.complete && !$0.topics.isEmpty }.count, tiers: [1, 5, 16]),
        ]
    }
}
