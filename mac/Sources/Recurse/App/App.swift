import AppKit
import SwiftUI

@main
struct RecurseApp: App {
    @NSApplicationDelegateAdaptor private var delegate: AppDelegate
    @State private var store: Store
    @State private var activity: Activity
    @State private var nav: Nav
    @State private var reminders: Reminders
    @AppStorage("menuBar") private var menuBar = true

    init() {
        let db: DB
        do { db = try DB() } catch { fatalError("Can't open the database: \(error)") }
        let store = Store(db: db), activity = Activity(store: store), nav = Nav()
        _store = State(initialValue: store)
        _activity = State(initialValue: activity)
        _nav = State(initialValue: nav)
        let reminders = Reminders(store: store, activity: activity, nav: nav)
        _reminders = State(initialValue: reminders)
        reminders.schedule()
        store.publishWidget()
    }

    var body: some Scene {
        Window("Recurse", id: "main") {
            RootView()
                .environment(store)
                .environment(activity)
                .environment(nav)
                .environment(reminders)
                .frame(minWidth: 980, minHeight: 640)
                .preferredColorScheme(.dark)
                .tint(.brand)
                .containerBackground(.canvas, for: .window)
        }
        .commands {
            CommandMenu("Go") {
                Button("Search…") { nav.searching = true }.keyboardShortcut("k")
                Divider()
                Button("Today") { nav.go(.today) }.keyboardShortcut("t", modifiers: [.command, .shift])
                Button("Review") { nav.go(.review) }.keyboardShortcut("r", modifiers: [.command, .shift])
                Button("Course map") { nav.go(.course) }.keyboardShortcut("m", modifiers: [.command, .shift])
                Button("Problems") { nav.go(.problems) }.keyboardShortcut("p", modifiers: [.command, .shift])
                Button("Stats") { nav.go(.stats) }
                Button("Patterns") { nav.go(.patterns) }
                Button("Rewards") { nav.go(.rewards) }
                Divider()
                Button("Back") { nav.back() }.keyboardShortcut("[").disabled(!nav.canGoBack)
                Button("Forward") { nav.forward() }.keyboardShortcut("]").disabled(!nav.canGoForward)
            }
        }

        MenuBarExtra(isInserted: $menuBar) {
            MenuBarMenu().environment(store).environment(activity).environment(nav)
        } label: {
            MenuBarLabel().environment(store).environment(activity)
        }

        SwiftUI.Settings {
            SettingsView().environment(store).environment(reminders).preferredColorScheme(.dark).tint(.brand)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        // a bare SPM executable starts as a background process; make it a real app with a Dock icon
        NSApp.setActivationPolicy(.regular)
        NSApp.activate()
    }

    // keep running with the window closed so reminders still fire; the Dock icon brings the window back
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { false }
}

@MainActor @Observable
final class Nav {
    var selection: Route? = .today {
        didSet { if selection != oldValue { path = [] } } // sidebar clicks pop back to the root
    }
    var path: [Route] = []
    var searching = false
    var query = ""

    var current: Route? { path.last ?? selection }

    /// Browser-style history: every move is recorded, so Back (⌘[, the header button, a two-finger swipe right)
    /// retraces your steps across pages, not just out of a problem.
    struct Place: Hashable { let selection: Route?, path: [Route] }
    private var backStack: [Place] = []
    private var forwardStack: [Place] = []
    var canGoBack: Bool { !backStack.isEmpty }
    var canGoForward: Bool { !forwardStack.isEmpty }
    private var place: Place { Place(selection: selection, path: path) }

    /// What each page in the history looked like when you left it, for the swipe (see `SwipeBack`).
    @ObservationIgnored private var shots: [Place: PageShot] = [:]
    var backShot: PageShot? { backStack.last.flatMap { shots[$0] } }
    var forwardShot: PageShot? { forwardStack.last.flatMap { shots[$0] } }

    /// Top-level places select a sidebar row; problems push on top of wherever you are.
    func go(_ r: Route) {
        let before = place, shot = PageCamera.shared.latest
        if case .problem = r { path.append(r) } else {
            selection = r
            path = []
        }
        guard place != before else { return }
        backStack.append(before)
        if backStack.count > 100 { backStack.removeFirst() }
        forwardStack = []
        keep(shot, for: before)
    }

    func back() {
        guard let p = backStack.popLast() else { return }
        forwardStack.append(place)
        keep(PageCamera.shared.latest, for: place)
        restore(p)
    }

    func forward() {
        guard let p = forwardStack.popLast() else { return }
        backStack.append(place)
        keep(PageCamera.shared.latest, for: place)
        restore(p)
    }

    private func restore(_ p: Place) {
        selection = p.selection
        path = p.path
    }

    // ponytail: only the nearest pages keep a snapshot (~18 MB each at 2x); older ones swipe onto the plain canvas
    private func keep(_ shot: PageShot?, for p: Place) {
        shots[p] = shot
        let near = Set(backStack.suffix(3) + forwardStack.suffix(2))
        shots = shots.filter { near.contains($0.key) }
    }
}

struct RootView: View {
    @Environment(Store.self) private var store
    @Environment(Activity.self) private var activity
    @Environment(Nav.self) private var nav
    @State private var columns = NavigationSplitViewVisibility.automatic

    var body: some View {
        @Bindable var nav = nav
        NavigationSplitView(columnVisibility: $columns) {
            Sidebar()
                .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 340)
        } detail: {
            NavigationStack(path: $nav.path) {
                page(nav.selection ?? .today).pageChrome(workspace: isProblem(nav.selection))
                    .navigationDestination(for: Route.self) { page($0).pageChrome(workspace: isProblem($0)) }
            }
            .background { PageFrame().ignoresSafeArea(edges: .top) } // not .leading: the sidebar floats over that inset and stays put in a swipe
            .background(alignment: .top) {
                if let tint = glow(nav.current ?? .today) {
                    Backdrop(tint: tint).frame(height: 380).ignoresSafeArea().backgroundExtensionEffect()
                        .animation(.easeInOut(duration: 0.4), value: tint)
                }
            }
        }
        .onChange(of: nav.current, initial: true) { old, r in
            activity.route(r)
            PageCamera.shared.pageChanged()
            // problems get the whole window; the sidebar comes back when you leave
            let isProblem = { (r: Route?) in if case .problem = r { true } else { false } }
            if isProblem(r) != isProblem(old) { withAnimation { columns = isProblem(r) ? .detailOnly : .automatic } }
        }
        .overlay(alignment: .top) { Toast() }
        .overlay { SwipeBack() }
        .task { await DevSnapshots.run(nav: nav, store: store, activity: activity) }
        .sheet(item: Binding(get: { store.chestQueue.first.map(SheetID.init) }, set: { if $0 == nil, !store.chestQueue.isEmpty { store.chestQueue.removeFirst() } })) {
            ChestSheet(id: $0.id)
        }
        .alert("Hold on", isPresented: Binding(get: { store.error != nil }, set: { if !$0 { store.error = nil } })) {
            Button("OK") {}
        } message: { Text(store.error ?? "") }
    }

    private func isProblem(_ r: Route?) -> Bool { if case .problem = r { true } else { false } }

    private func glow(_ r: Route) -> Color? {
        switch r {
        case .today, .course: .brand
        case .review: .success
        case .stats: Color(hex: 0x7aa2f7)
        case .rewards: .warning
        case .boss(let mid): store.bossRuns(mid).contains { $0.passed == true } ? .success : .warning
        case .topic(let id): Content.topic(id).map { store.topicStatus($0, store.problemStatuses()).complete } == true ? .success : .brand
        case .problem, .problems, .patterns: nil
        }
    }

    @ViewBuilder
    private func page(_ r: Route) -> some View {
        switch r {
        case .today: HomeView()
        case .review: ReviewView()
        case .course: CourseView()
        case .rewards: RewardsView()
        case .problems: ProblemsView()
        case .patterns: PatternsView()
        case .stats: StatsView()
        case .boss(let id): BossView(moduleId: id).id(id)
        case .topic(let id): TopicView(topicId: id).id(id)
        case .problem(let id): ProblemView(pid: id).id(id)
        }
    }
}

private struct Toast: View {
    @Environment(Store.self) private var store
    var body: some View {
        Group {
            if let t = store.toast {
                Label(t, systemImage: "sparkles")
                    .font(.callout.weight(.semibold))
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .glassEffect(.regular.tint(.brand.opacity(0.25)), in: .capsule)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .task(id: t) {
                        try? await Task.sleep(for: .seconds(2.2))
                        store.toast = nil
                    }
            }
        }
        .padding(.top, 12)
        .animation(.spring(duration: 0.35), value: store.toast)
    }
}
