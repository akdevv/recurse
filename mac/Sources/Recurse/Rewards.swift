// Real-world reward path (unlocked by finishing parts of the course) and tiered trophies.
// Port of web/server/rewards.ts; claims live in the shared reward_claims table.
import SwiftUI

struct RewardDef {
    let id, label, title, note, icon: String
    let size: Size
    var topics: [String] = []
    var modules: [String] = []
    var boss: String?
    enum Size { case small, medium, big }

    static let path: [RewardDef] = [
        RewardDef(id: "coffee-1", label: "Your first two topics", title: "Coffee", note: "A quick first win", icon: "cup.and.saucer.fill",
                  size: .small, topics: ["python-for-dsa", "complexity-analysis"]),
        RewardDef(id: "coffee-2", label: "Foundations", title: "Coffee", note: "", icon: "cup.and.saucer.fill", size: .small, modules: ["foundations"]),
        RewardDef(id: "coffee-3", label: "Arrays & Strings", title: "Coffee", note: "", icon: "cup.and.saucer.fill", size: .small, modules: ["arrays-strings"]),
        RewardDef(id: "coffee-4", label: "Hashing", title: "Coffee", note: "", icon: "cup.and.saucer.fill", size: .small, modules: ["hashing"]),
        RewardDef(id: "meal", label: "Two Pointers & Windows", title: "A nice meal", note: "Somewhere you've wanted to try", icon: "fork.knife",
                  size: .small, modules: ["two-pointers-sliding-window"]),
        RewardDef(id: "coffee-5", label: "Sorting & Searching", title: "Coffee", note: "Binary search conquered", icon: "cup.and.saucer.fill",
                  size: .small, modules: ["sorting-searching"]),
        RewardDef(id: "tshirt", label: "Linked Lists & Stacks", title: "A T-shirt", note: "One you actually like", icon: "tshirt.fill",
                  size: .medium, modules: ["linked-lists", "stacks-queues"]),
        RewardDef(id: "movie", label: "Recursion", title: "Movie night", note: "Big screen, snacks included", icon: "popcorn.fill",
                  size: .medium, modules: ["recursion-backtracking"]),
        RewardDef(id: "shoes", label: "Trees", title: "New shoes", note: "Halfway there", icon: "shoeprints.fill", size: .medium, modules: ["trees"]),
        RewardDef(id: "book", label: "Heaps", title: "A book", note: "Any book, not a DSA one", icon: "book.closed.fill", size: .medium, modules: ["heaps"]),
        RewardDef(id: "gear", label: "Graphs", title: "Headphones", note: "Or a game, your call", icon: "headphones", size: .medium, modules: ["graphs"]),
        RewardDef(id: "grand", label: "Everything + the DP boss", title: "The big one: ₹10,000", note: "Anything you want within the budget",
                  icon: "gift.fill", size: .big,
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
    var metal: Color { Badge.metal(tier, single: single) }

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

    /// Unopened chests + unlocked rewards not yet availed: things waiting on you in Rewards.
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

// MARK: views

struct RewardsView: View {
    @Environment(Store.self) private var store
    @AppStorage("rewardsTab") private var tab = "path"

    var body: some View {
        let path = store.rewardPath()
        let badges = store.badges()
        Group {
            switch tab {
            case "trophies": TrophiesTab(badges: badges)
            case "chests": ChestsView()
            default: PathTab(path: path)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            GlassTabs(selection: $tab, tabs: [
                .init(id: "path", title: "Path \(path.filter { $0.status != .locked }.count)/\(path.count)", icon: "flag.pattern.checkered"),
                .init(id: "trophies", title: "Trophies \(badges.reduce(0) { $0 + $1.tier })/\(badges.reduce(0) { $0 + $1.tiers.count })", icon: "trophy"),
                .init(id: "chests", title: store.chestsWaiting > 0 ? "Chests · \(store.chestsWaiting) new" : "Chests", icon: "shippingbox"),
            ])
            .padding(.vertical, 8)
        }
        .navigationTitle("Rewards")
    }
}

private struct PathTab: View {
    @Environment(Store.self) private var store
    let path: [RewardState]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                NextReward(path: path)
                phase("Early wins", "Small treats, often, while the habit forms", path.filter { $0.def.size == .small }, longHaul: false)
                phase("The climb", "Fewer, bigger rewards for the harder modules", path.filter { $0.def.size == .medium }, longHaul: true)
                if let big = path.first(where: { $0.def.size == .big }) { Finale(x: big) }
            }
            .padding(28)
            .frame(maxWidth: 920)
            .frame(maxWidth: .infinity)
        }
    }

    private func phase(_ title: String, _ desc: String, _ items: [RewardState], longHaul: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(title).font(.headline)
                Text(desc).font(.caption).foregroundStyle(.secondary)
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 12)], spacing: 12) {
                ForEach(items) { RewardCard(x: $0) }
                if longHaul {
                    VStack(spacing: 6) {
                        Image(systemName: "mountain.2").font(.title2).foregroundStyle(.tertiary)
                        Text("The long haul").font(.caption.weight(.medium)).foregroundStyle(.secondary)
                        Text("Greedy, DP, Tries, Bits. No gifts on purpose.").font(.caption2).foregroundStyle(.tertiary).multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity).padding(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4])).foregroundStyle(.separator))
                }
            }
        }
    }
}

private struct RewardArt: View {
    let icon: String
    let status: RewardState.Status
    var size: CGFloat = 52
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: size * 0.5))
            .foregroundStyle(status == .locked ? AnyShapeStyle(.tertiary) : AnyShapeStyle(Color.warning.gradient))
            .frame(width: size * 1.4, height: size * 1.4)
            .background(RadialGradient(colors: [(status == .unlocked ? Color.warning : .primary).opacity(status == .unlocked ? 0.2 : 0.05), .clear],
                                       center: .center, startRadius: 0, endRadius: size))
            .overlay(alignment: .topTrailing) {
                if status == .availed { Image(systemName: "checkmark.circle.fill").foregroundStyle(.success) }
                else if status == .locked { Image(systemName: "lock.fill").font(.caption).foregroundStyle(.tertiary) }
            }
    }
}

private struct RewardCard: View {
    @Environment(Store.self) private var store
    let x: RewardState
    @State private var hover = false

    var body: some View {
        VStack(spacing: 6) {
            RewardArt(icon: x.def.icon, status: x.status)
            Text(x.def.title).font(.callout.weight(.medium)).foregroundStyle(x.status == .locked ? .secondary : .primary)
            Text(x.def.label).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
            Spacer(minLength: 4)
            switch x.status {
            case .locked:
                ProgressView(value: Double(x.done), total: Double(max(1, x.total))).tint(.warning)
                Text("\(x.done) of \(x.total) topics").font(.caption2.monospacedDigit()).foregroundStyle(.secondary)
            case .unlocked:
                Button("Mark availed") { store.setAvailed(x.id, true) }.buttonStyle(.glassProminent).controlSize(.small)
            case .availed:
                if hover { Button("Mark as pending") { store.setAvailed(x.id, false) }.buttonStyle(.link).font(.caption) }
                else { Text("Availed \(short(x.availedAt ?? ""))").font(.caption).foregroundStyle(.success) }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 190)
        .background(.surface, in: .rect(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(x.status == .unlocked ? Color.warning.opacity(0.5) : Color(nsColor: .separatorColor).opacity(0.6)))
        .help(x.def.note)
        .onHover { hover = $0 }
    }
}

private struct NextReward: View {
    @Environment(Store.self) private var store
    let path: [RewardState]

    var body: some View {
        let next = path.first { $0.status == .locked }
        let waiting = path.filter { $0.status == .unlocked }
        let unlocked = path.filter { $0.status != .locked }.count
        VStack(spacing: 0) {
            HStack(spacing: 18) {
                RewardArt(icon: next?.def.icon ?? "gift.fill", status: next == nil ? .unlocked : .locked, size: 60)
                VStack(alignment: .leading, spacing: 4) {
                    Text(next == nil ? "Every reward unlocked" : "Up next").font(.caption).foregroundStyle(.secondary)
                    Text(next?.def.title ?? "You finished the course").font(.title2.weight(.semibold))
                    if let next {
                        let left = next.total - next.done
                        Text("\(Text("Finish \(next.requires.joined(separator: " + ")) · "))\(Text("\(left) topic\(left == 1 ? "" : "s") to go").foregroundStyle(.primary))")
                            .font(.callout).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(Text("\(unlocked)").font(.title.weight(.semibold)))\(Text("/\(path.count)").foregroundStyle(.secondary))").monospacedDigit()
                    Text("unlocked").font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding(20)
            if let w = waiting.first {
                Divider()
                HStack {
                    Circle().fill(.warning).frame(width: 7, height: 7).shadow(color: .warning, radius: 4)
                    let more = waiting.count > 1 ? " (+\(waiting.count - 1) more)" : ""
                    Text("\(Text(w.def.title).fontWeight(.medium))\(Text(" is unlocked\(more). Enjoy it, then mark it as availed.").foregroundStyle(.secondary))")
                        .font(.callout)
                    Spacer()
                    Button("Mark as availed") { store.setAvailed(w.id, true) }.buttonStyle(.glassProminent)
                }
                .padding(.horizontal, 20).padding(.vertical, 12)
            } else if let next {
                ProgressView(value: Double(next.done), total: Double(max(1, next.total))).tint(.warning).padding(.horizontal, 20).padding(.bottom, 14)
            }
        }
        .background(.surface, in: .rect(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(.hairline))
    }
}

private struct Finale: View {
    @Environment(Store.self) private var store
    let x: RewardState

    var body: some View {
        let pct = x.total > 0 ? Double(x.done) / Double(x.total) : 0
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("The summit").font(.headline)
                Text("All of it, plus one mock interview").font(.caption).foregroundStyle(.secondary)
            }
            HStack(spacing: 20) {
                RewardArt(icon: x.def.icon, status: x.status, size: 72)
                VStack(alignment: .leading, spacing: 4) {
                    Text(x.def.title).font(.title2.weight(.semibold))
                    Text(x.def.note).foregroundStyle(.secondary)
                }
                Spacer()
                switch x.status {
                case .locked:
                    VStack(alignment: .trailing) {
                        Text("\(Int(pct * 100))%").font(.title.weight(.semibold).monospacedDigit())
                        Text(x.done == x.total ? "Now beat the DP boss" : "of the course done").font(.caption).foregroundStyle(.secondary)
                    }
                case .unlocked: Button("Mark as availed") { store.setAvailed(x.id, true) }.buttonStyle(.glassProminent)
                case .availed: Text("Availed \(short(x.availedAt ?? ""))").foregroundStyle(.success)
                }
            }
            .padding(16)
            .background(LinearGradient(colors: [Color.warning.opacity(0.08), .clear], startPoint: .leading, endPoint: .trailing), in: .rect(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.warning.opacity(0.3)))
        }
    }
}

private struct TrophiesTab: View {
    let badges: [Badge]
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 270), spacing: 12)], spacing: 12) {
                ForEach(badges) { TrophyCard(b: $0) }
            }
            .padding(28)
            .frame(maxWidth: 920)
            .frame(maxWidth: .infinity)
        }
    }
}

private struct TrophyCard: View {
    let b: Badge
    var body: some View {
        let earned = b.tier > 0
        HStack(spacing: 14) {
            Image(systemName: b.icon).font(.system(size: 24)).foregroundStyle(earned ? AnyShapeStyle(b.metal.gradient) : AnyShapeStyle(.quaternary))
                .frame(width: 56, height: 56)
                .background(Circle().fill(b.metal.opacity(earned ? 0.16 : 0.06)))
                .overlay(Circle().strokeBorder(b.metal.opacity(earned ? 0.6 : 0.2), lineWidth: 2))
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(b.name).fontWeight(.semibold).foregroundStyle(earned ? .primary : .secondary).lineLimit(1)
                    Spacer()
                    if b.single {
                        Text(earned ? "Earned" : "Locked").font(.caption).foregroundStyle(earned ? Color.brand : .secondary)
                    } else {
                        HStack(spacing: 3) {
                            ForEach(1...3, id: \.self) { t in
                                Circle().fill(t <= b.tier ? Badge.metal(t, single: false) : Color.primary.opacity(0.1))
                                    .frame(width: 7, height: 7)
                            }
                        }
                        .help(Badge.metalName[b.tier])
                    }
                }
                ProgressView(value: b.next.map { Double(min(b.value, $0)) / Double($0) } ?? 1)
                    .tint(b.next == nil && !b.single ? .warning : .brand)
                HStack {
                    Text("\(Text(b.next.map { "\(min(b.value, $0))/\($0)" } ?? "\(b.value)").foregroundStyle(.primary))\(Text(" \(b.desc)"))")
                        .lineLimit(1)
                    Spacer()
                    if !b.single {
                        Text(b.next == nil ? "Complete" : "\(Badge.metalName[b.tier + 1]) next").foregroundStyle(b.next == nil ? Color.warning : .secondary)
                    }
                }
                .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            }
        }
        .card(padding: 14)
        .opacity(earned ? 1 : 0.85)
    }
}
