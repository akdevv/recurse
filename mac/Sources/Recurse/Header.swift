// The window header on every page: breadcrumbs on the left, the ⌘K search bar in the middle,
// page actions (Run/Submit…) on the right. Like the web app's page-header.tsx, on Liquid Glass.
import SwiftUI

extension View {
    func pageChrome() -> some View {
        toolbar(removing: .title) // the breadcrumbs say where you are
            .toolbar {
                ToolbarItem(placement: .navigation) { Breadcrumbs() }
                ToolbarItem(placement: .principal) { SearchBar() }.sharedBackgroundVisibility(.hidden)
            }
    }
}

private struct Crumb {
    let label: String
    var route: Route?
}

private struct Breadcrumbs: View {
    @Environment(Nav.self) private var nav

    var body: some View {
        let (icon, crumbs) = trail(nav.current ?? .today)
        HStack(spacing: 6) {
            ForEach(Array(crumbs.enumerated()), id: \.offset) { i, c in
                let last = i == crumbs.count - 1
                if i > 0 { Image(systemName: "chevron.right").font(.system(size: 9, weight: .semibold)).foregroundStyle(.muted.opacity(0.6)) }
                Group {
                    if let r = c.route, !last {
                        Button { nav.go(r) } label: { label(c.label, icon: i == 0 ? icon : nil) }.buttonStyle(.plain)
                            .foregroundStyle(.muted)
                    } else {
                        label(c.label, icon: i == 0 ? icon : nil).foregroundStyle(last ? .primary : Color.muted)
                    }
                }
                .fontWeight(last ? .semibold : .regular)
                .lineLimit(1)
            }
        }
        .font(.callout)
        .padding(.horizontal, 6)
        .frame(maxWidth: 380, alignment: .leading)
    }

    private func label(_ text: String, icon: String?) -> some View {
        HStack(spacing: 6) {
            if let icon { Image(systemName: icon).foregroundStyle(.brand) }
            Text(text)
        }
        .contentShape(.rect)
    }

    /// Section icon + crumbs for a route, matching the sidebar's sections.
    private func trail(_ r: Route) -> (String, [Crumb]) {
        switch r {
        case .today: return ("house", [Crumb(label: "Today")])
        case .course: return ("map", [Crumb(label: "Course")])
        case .review: return ("arrow.counterclockwise", [Crumb(label: "Review")])
        case .problems: return ("checklist", [Crumb(label: "Problems")])
        case .patterns: return ("square.on.circle", [Crumb(label: "Patterns")])
        case .stats: return ("chart.bar", [Crumb(label: "Stats")])
        case .rewards: return ("gift", [Crumb(label: "Rewards")])
        case .topic(let id):
            let m = Content.modules().first { $0.topics.contains(id) }
            return ("map", [Crumb(label: "Course", route: .course), Crumb(label: m?.title ?? "", route: .course),
                            Crumb(label: Content.topic(id)?.title ?? id)])
        case .boss(let mid):
            return ("map", [Crumb(label: "Course", route: .course), Crumb(label: Content.module(mid).title, route: .course),
                            Crumb(label: "Boss fight")])
        case .problem(let pid):
            let title = Content.problem(pid)?.title ?? pid
            guard let home = Content.problemHome(pid) else { return ("checklist", [Crumb(label: "Problems", route: .problems), Crumb(label: title)]) }
            return ("map", [Crumb(label: home.topic.title, route: .topic(home.topic.id)), Crumb(label: title)])
        }
    }
}

/// Looks like a search field, opens the ⌘K palette (which drops open right where this sits).
private struct SearchBar: View {
    @Environment(Nav.self) private var nav
    @State private var hover = false

    var body: some View {
        Button { withAnimation(.bouncy(duration: 0.3)) { nav.searching = true } } label: {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                Text("Search topics, problems…").lineLimit(1)
                Spacer(minLength: 8)
                Text("⌘K").font(.system(size: 11, weight: .medium, design: .rounded))
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(.raised, in: .capsule)
            }
            .font(.callout)
            .foregroundStyle(hover ? .primary : Color.muted)
            .padding(.leading, 12).padding(.trailing, 6)
            .frame(width: 300, height: 32)
            .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .capsule)
        .onHover { hover = $0 }
        .opacity(nav.searching ? 0 : 1) // the palette takes its place
        .help("Search (⌘K)")
    }
}
