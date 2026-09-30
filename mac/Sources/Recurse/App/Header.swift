import SwiftUI

extension View {
    /// `workspace`: problem pages. Nothing scrolls under their header (no fade), their toolbar holds the clock and
    /// Run/Submit instead of the search field, and the breadcrumbs replace the back button.
    func pageChrome(workspace: Bool = false) -> some View {
        overlay(alignment: .top) { if !workspace { HeaderFade() } } // in the page's own layer, so it covers its content
            .toolbar(removing: .title)
            .scrollEdgeEffectStyle(.soft, for: .top)
            .toolbar {
                ToolbarItemGroup(placement: .navigation) { BackForward() } // its own glass capsule, like Finder's
                // own pill, set apart from back/forward (a fixed ToolbarSpacer collapses in the navigation area)
                ToolbarItem(placement: .navigation) { Breadcrumbs() }.sharedBackgroundVisibility(.hidden)
                ToolbarSpacer(.flexible) // pushes page actions and the search field to the right end
            }
            .navigationBarBackButtonHidden() // ours (BackForward) follows the whole history, not just this stack
            .modifier(HeaderSearch(enabled: !workspace))
    }
}

private struct HeaderSearch: ViewModifier {
    @Environment(Store.self) private var store
    @Environment(Nav.self) private var nav
    let enabled: Bool
    @FocusState private var focused: Bool

    func body(content: Self.Content) -> some View { // Self.: the app has its own `Content` (course loader)
        @Bindable var nav = nav
        if enabled {
            content
                .searchable(text: $nav.query, placement: .toolbar, prompt: "Search topics, problems…")
                .searchSuggestions {
                    ForEach(store.search(nav.query)) { i in
                        Label { Text("\(i.title)  \(Text(i.detail).foregroundStyle(.secondary))") } icon: { Image(systemName: i.icon) }
                            .searchCompletion(i.token)
                    }
                }
                .searchFocused($focused)
                .onSubmit(of: .search) { if let i = store.search(nav.query).first { open(i) } }
                .onChange(of: nav.query) { _, q in if let i = store.searchItems().first(where: { $0.token == q }) { open(i) } }
                .onChange(of: nav.searching, initial: true) { _, on in if on { focused = true; nav.searching = false } }
        } else {
            content
        }
    }

    private func open(_ i: SearchItem) {
        nav.query = ""
        focused = false
        nav.go(i.route)
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
        HStack(spacing: 8) {
            ForEach(Array(crumbs.enumerated()), id: \.offset) { i, c in
                let last = i == crumbs.count - 1
                if i > 0 { Image(systemName: "chevron.right").font(.system(size: 10, weight: .semibold)).foregroundStyle(.muted.opacity(0.5)) }
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
        .font(.system(size: 13))
        .padding(.horizontal, 14)
        .frame(height: 36)
        .glassEffect(.regular, in: .capsule)
        .padding(.leading, 8)
        .fixedSize()
    }

    private func label(_ text: String, icon: String?) -> some View {
        HStack(spacing: 7) {
            if let icon { Image(systemName: icon).font(.system(size: 12, weight: .semibold)).foregroundStyle(.brand) }
            Text(text)
        }
        .contentShape(.rect)
    }

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

/// Progressive blur under the header, like Apple's: real blur (system material) that's full strength through the
/// header row and fades out just below it, with a light canvas tint for legibility on this dark theme.
struct HeaderFade: View {
    static let header: CGFloat = 52 // macOS 26 toolbar height
    static let trail: CGFloat = 14 // fade-out below it

    var body: some View {
        let edge = Self.header / (Self.header + Self.trail)
        ZStack {
            Rectangle().fill(.ultraThinMaterial)
            LinearGradient(colors: [Color.canvas.opacity(0.55), Color.canvas.opacity(0.15)], startPoint: .top, endPoint: .bottom)
        }
        .mask {
            LinearGradient(stops: [
                .init(color: .black, location: 0),
                .init(color: .black, location: edge * 0.8),
                .init(color: .clear, location: 1),
            ], startPoint: .top, endPoint: .bottom)
        }
        .frame(height: Self.header + Self.trail)
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(false)
    }
}

/// Back / forward as plain toolbar buttons, so the system draws them: a shared glass capsule, hover and press states.
private struct BackForward: View {
    @Environment(Nav.self) private var nav

    var body: some View {
        Button("Back", systemImage: "chevron.left") { nav.back() }
            .disabled(!nav.canGoBack)
            .help("Back (⌘[)")
        Button("Forward", systemImage: "chevron.right") { nav.forward() }
            .disabled(!nav.canGoForward)
            .help("Forward (⌘])")
    }
}
