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
        moduleViews().flatMap { m in
            m.topics.flatMap { t in t.problems.map { ProblemListRow(p: $0, topic: t.topic, module: m.module) } }
        }
        .uniqued(by: \.id)
    }
}

extension Store {
    func searchItems() -> [SearchItem] {
        let pages = Route.pages.map { SearchItem(id: "p:\($0.title)", title: $0.title, detail: "Page", icon: $0.icon, route: $0) }
        let modules = Content.modules()
        let topics = modules.flatMap { m in m.topics.compactMap(Content.topic).map {
            SearchItem(id: "t:\($0.id)", title: $0.title, detail: "Topic · \(m.title)", icon: "book", route: .topic($0.id))
        } }
        let bosses = modules.map { SearchItem(id: "b:\($0.id)", title: "\($0.title) boss fight", detail: "Boss", icon: "figure.fencing", route: .boss($0.id)) }
        let problems = allProblems().filter(\.p.available).map {
            SearchItem(id: "q:\($0.id)", title: $0.title, detail: ($0.p.lc.map { "#\($0) · " } ?? "") + $0.topic.title,
                       icon: Route.problem($0.id).icon, route: .problem($0.id))
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
