import Foundation

struct ProblemListRow: Identifiable {
    let p: TopicProblem
    let topic: Topic
    let module: Module
    var id: String { p.id }
    var title: String { p.title }
    var statusRank: Int { Store.isSolved(p.status) ? 2 : p.status == "in-progress" ? 1 : 0 }
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

extension Store {
    func searchItems() -> [SearchItem] {
        let pages = [
            SearchItem(id: "p:today", title: "Today", detail: "Page", icon: "house", route: .today),
            SearchItem(id: "p:course", title: "Course", detail: "Page", icon: "map", route: .course),
            SearchItem(id: "p:review", title: "Review", detail: "Page", icon: "arrow.counterclockwise", route: .review),
            SearchItem(id: "p:problems", title: "Problems", detail: "Page", icon: "checklist", route: .problems),
            SearchItem(id: "p:patterns", title: "Patterns", detail: "Page", icon: "square.on.circle", route: .patterns),
            SearchItem(id: "p:stats", title: "Stats", detail: "Page", icon: "chart.bar", route: .stats),
            SearchItem(id: "p:rewards", title: "Rewards", detail: "Page", icon: "gift", route: .rewards),
        ]
        let modules = Content.modules()
        let topics = modules.flatMap { m in m.topics.compactMap(Content.topic).map {
            SearchItem(id: "t:\($0.id)", title: $0.title, detail: "Topic · \(m.title)", icon: "book", route: .topic($0.id))
        } }
        let bosses = modules.map { SearchItem(id: "b:\($0.id)", title: "\($0.title) boss fight", detail: "Boss", icon: "figure.fencing", route: .boss($0.id)) }
        let problems = allProblems().filter(\.p.available).map {
            SearchItem(id: "q:\($0.id)", title: $0.title, detail: ($0.p.lc.map { "#\($0) · " } ?? "") + $0.topic.title,
                       icon: "chevron.left.forwardslash.chevron.right", route: .problem($0.id))
        }
        return pages + topics + bosses + problems
    }

    /// Every word must match the title or detail; empty query lists the pages.
    func search(_ query: String) -> [SearchItem] {
        let words = query.lowercased().split(separator: " ")
        let all = searchItems()
        if words.isEmpty { return all.filter { $0.detail == "Page" } }
        return Array(all.filter { i in words.allSatisfy { (i.title + " " + i.detail).lowercased().contains($0) } }.prefix(12))
    }
}

struct SearchItem: Identifiable {
    let id, title, detail, icon: String
    let route: Route
    /// What the search field shows when a suggestion is picked; picking one navigates.
    var token: String { "\(title) — \(detail)" }
}
