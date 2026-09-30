import SwiftUI

/// What you get for a milestone: one of the presets, or a custom item (which always uses the "custom" illustration).
struct RewardItem: Codable, Equatable, Hashable {
    var title: String
    var note = ""
    var icon = "custom"

    static let presets = [
        RewardItem(title: "Coffee", note: "A quick first win", icon: "coffee"),
        RewardItem(title: "A cappuccino", note: "Sit down and enjoy it", icon: "coffee-cappuccino"),
        RewardItem(title: "An iced coffee", note: "Something cold and sweet", icon: "coffee-iced"),
        RewardItem(title: "An espresso", note: "Small and strong", icon: "coffee-espresso"),
        RewardItem(title: "Coffee to go", note: "Take a walk with it", icon: "coffee-togo"),
        RewardItem(title: "A nice meal", note: "Somewhere you've wanted to try", icon: "meal"),
        RewardItem(title: "Something to wear", note: "One you actually like", icon: "shirt"),
        RewardItem(title: "Movie night", note: "Big screen, snacks included", icon: "movie"),
        RewardItem(title: "New shoes", note: "For the second half of the climb", icon: "shoes"),
        RewardItem(title: "A book", note: "Any book, not a DSA one", icon: "book"),
        RewardItem(title: "Headphones", note: "Or a game, your call", icon: "headphones"),
        RewardItem(title: "The big one", note: "Something you really want. Make it yours.", icon: "gift"),
    ]

    static func preset(_ icon: String) -> RewardItem { presets.first { $0.icon == icon }! }
}

/// A point on the path: fixed by the course; what it rewards is the user's choice (`item`).
struct RewardDef {
    let id, label: String
    let size: Size
    var topics: [String] = []
    var modules: [String] = []
    var boss: String?
    let item: RewardItem
    enum Size { case small, medium, big }

    static let path: [RewardDef] = [
        RewardDef(id: "coffee-1", label: "Your first two topics", size: .small, topics: ["python-for-dsa", "complexity-analysis"], item: .preset("coffee")),
        RewardDef(id: "coffee-2", label: "Foundations", size: .small, modules: ["foundations"], item: .preset("coffee-cappuccino")),
        RewardDef(id: "coffee-3", label: "Arrays & Strings", size: .small, modules: ["arrays-strings"], item: .preset("coffee-iced")),
        RewardDef(id: "coffee-4", label: "Hashing", size: .small, modules: ["hashing"], item: .preset("coffee-espresso")),
        RewardDef(id: "meal", label: "Two Pointers & Windows", size: .small, modules: ["two-pointers-sliding-window"], item: .preset("meal")),
        RewardDef(id: "coffee-5", label: "Sorting & Searching", size: .small, modules: ["sorting-searching"], item: .preset("coffee-togo")),
        RewardDef(id: "tshirt", label: "Linked Lists & Stacks", size: .medium, modules: ["linked-lists", "stacks-queues"], item: .preset("shirt")),
        RewardDef(id: "movie", label: "Recursion", size: .medium, modules: ["recursion-backtracking"], item: .preset("movie")),
        RewardDef(id: "shoes", label: "Trees", size: .medium, modules: ["trees"], item: .preset("shoes")),
        RewardDef(id: "book", label: "Heaps", size: .medium, modules: ["heaps"], item: .preset("book")),
        RewardDef(id: "gear", label: "Graphs", size: .medium, modules: ["graphs"], item: .preset("headphones")),
        RewardDef(id: "grand", label: "Everything + the DP boss", size: .big,
                  modules: ["greedy-intervals", "dynamic-programming", "tries", "bit-manipulation", "advanced-structures"],
                  boss: "dynamic-programming", item: .preset("gift")),
    ]
}

struct RewardState: Identifiable {
    enum Status { case locked, unlocked, availed }
    let def: RewardDef
    let item: RewardItem
    var custom: Bool { item != def.item }
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
        let chosen = rewardItems()
        let claims = Dictionary(uniqueKeysWithValues: db.all("SELECT id, claimed_at FROM reward_claims").map { ($0.str("id")!, $0.str("claimed_at")!) })
        return RewardDef.path.map { r in
            // the finale needs the whole course, not just its listed modules
            let mods = r.size == .big ? views.map(\.id) : r.modules
            let needed = r.topics + mods.flatMap(topicsOf)
            let done = needed.filter(topicDone.contains).count
            let bossWon = r.boss.map(bossWon) ?? true
            let requires = r.topics.map { Content.topic($0)?.title ?? $0 }
                + (r.size == .big ? ["every module"] : r.modules.map { Content.module($0)?.title ?? $0 })
                + (r.boss.map { ["\(Content.module($0)?.title ?? $0) boss fight"] } ?? [])
            return RewardState(def: r, item: chosen[r.id] ?? r.item, requires: requires, done: done, total: needed.count,
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
            toast = "Enjoy it: \(r.item.title)"
        } else {
            _db.run("DELETE FROM reward_claims WHERE id = ?", id)
        }
        changed()
    }

    /// The user's picks by milestone id; missing ones use the default.
    func rewardItems() -> [String: RewardItem] {
        db.one("SELECT value FROM settings WHERE key = 'rewards'")?.json("value") ?? [:]
    }

    /// `nil` goes back to the default. Claims are kept: they belong to the milestone, not the item.
    func setReward(_ id: String, _ item: RewardItem?) {
        var all = rewardItems()
        all[id] = item.map { RewardItem(title: $0.title.trimmingCharacters(in: .whitespaces), note: $0.note.trimmingCharacters(in: .whitespaces), icon: $0.icon) }
        putSetting("rewards", all)
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
