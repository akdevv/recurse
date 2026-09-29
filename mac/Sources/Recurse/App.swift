import AppKit
import SwiftUI

@main
struct RecurseApp: App {
    @NSApplicationDelegateAdaptor private var delegate: AppDelegate
    @State private var store: Store
    @State private var activity: Activity
    @State private var nav: Nav
    @State private var reminders: Reminders

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
    }

    var body: some Scene {
        Window("Recurse", id: "main") {
            RootView()
                .environment(store)
                .environment(activity)
                .environment(nav)
                .environment(reminders)
                .frame(minWidth: 980, minHeight: 640)
                .preferredColorScheme(.dark) // the palette is the web's, which is dark only
                .tint(.brand)
                .containerBackground(.canvas, for: .window)
        }
        .commands {
            CommandMenu("Go") {
                Button("Search…") { withAnimation(.bouncy(duration: 0.3)) { nav.searching.toggle() } }.keyboardShortcut("k")
                Divider()
                Button("Today") { nav.go(.today) }.keyboardShortcut("t", modifiers: [.command, .shift])
                Button("Review") { nav.go(.review) }.keyboardShortcut("r", modifiers: [.command, .shift])
                Button("Course map") { nav.go(.course) }.keyboardShortcut("m", modifiers: [.command, .shift])
                Button("Problems") { nav.go(.problems) }.keyboardShortcut("p", modifiers: [.command, .shift])
                Button("Stats") { nav.go(.stats) }
                Button("Patterns") { nav.go(.patterns) }
                Button("Rewards") { nav.go(.rewards) }
                Divider()
                Button("Back") { nav.back() }.keyboardShortcut("[").disabled(nav.path.isEmpty)
            }
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
    /// ⌘K palette open
    var searching = false

    var current: Route? { path.last ?? selection }

    /// Top-level places select a sidebar row; problems push on top of wherever you are.
    func go(_ r: Route) {
        if case .problem = r { path.append(r) } else {
            selection = r
            path = []
        }
    }

    func back() { if !path.isEmpty { path.removeLast() } }
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
                page(nav.selection ?? .today).pageChrome()
                    .navigationDestination(for: Route.self) { page($0).pageChrome() }
            }
        }
        .onChange(of: nav.current, initial: true) { old, r in
            activity.route(r)
            // problems get the whole window; the sidebar comes back when you leave
            let isProblem = { (r: Route?) in if case .problem = r { true } else { false } }
            if isProblem(r) != isProblem(old) { withAnimation { columns = isProblem(r) ? .detailOnly : .automatic } }
        }
        .overlay(alignment: .top) { Toast() }
        .overlay(alignment: .top) {
            if nav.searching {
                ZStack(alignment: .top) {
                    // click anywhere outside to close
                    Color.black.opacity(0.12).ignoresSafeArea().onTapGesture { withAnimation { nav.searching = false } }
                    CommandPalette().padding(.top, 8) // opens where the header's search bar sits
                }
                .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
            }
        }
        .task { await snapshots() }
        .sheet(item: Binding(get: { store.chestQueue.first.map(SheetID.init) }, set: { if $0 == nil, !store.chestQueue.isEmpty { store.chestQueue.removeFirst() } })) {
            ChestSheet(id: $0.id)
        }
        .alert("Hold on", isPresented: Binding(get: { store.error != nil }, set: { if !$0 { store.error = nil } })) {
            Button("OK") {}
        } message: { Text(store.error ?? "") }
    }

    /// Dev check without Screen Recording permission: RECURSE_SNAPSHOT=<dir> RECURSE_ROUTES="today,topic:x,problem:y"
    /// renders each route's window to <dir>/<n>.png, then quits.
    private func snapshots() async {
        let env = ProcessInfo.processInfo.environment
        guard let dir = env["RECURSE_SNAPSHOT"] else { return }
        for (i, r) in (env["RECURSE_ROUTES"] ?? "today").split(separator: ",").enumerated() {
            let parts = r.split(separator: ":", maxSplits: 1).map(String.init)
            switch parts[0] {
            case "review": nav.go(.review)
            case "course": nav.go(.course)
            case "problems": nav.go(.problems)
            case "patterns": nav.go(.patterns)
            case "stats": nav.go(.stats)
            case "rewards":
                UserDefaults.standard.set(parts.count > 1 ? parts[1] : "path", forKey: "rewardsTab")
                nav.go(.rewards)
            case "boss": nav.go(.boss(parts[1]))
            case "topic": nav.go(.topic(parts[1]))
            case "problem": nav.go(.problem(parts[1]))
            default: nav.go(.today)
            }
            try? await Task.sleep(for: .seconds(2))
            guard let v = NSApp.windows.first(where: \.isVisible)?.contentView?.superview,
                  let rep = v.bitmapImageRepForCachingDisplay(in: v.bounds) else { continue }
            v.cacheDisplay(in: v.bounds, to: rep)
            try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: dir).appending(path: "\(i)-\(parts[0]).png"))
        }
        NSApp.terminate(nil)
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
