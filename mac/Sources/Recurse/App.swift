import AppKit
import SwiftUI

@main
struct RecurseApp: App {
    @NSApplicationDelegateAdaptor private var delegate: AppDelegate
    @State private var store: Store
    @State private var activity: Activity
    @State private var nav = Nav()

    init() {
        let db: DB
        do { db = try DB() } catch { fatalError("Can't open the database: \(error)") }
        let store = Store(db: db)
        _store = State(initialValue: store)
        _activity = State(initialValue: Activity(store: store))
    }

    var body: some Scene {
        Window("Recurse", id: "main") {
            RootView()
                .environment(store)
                .environment(activity)
                .environment(nav)
                .frame(minWidth: 980, minHeight: 640)
        }
        .commands {
            CommandMenu("Go") {
                Button("Today") { nav.go(.today) }.keyboardShortcut("t", modifiers: [.command, .shift])
                Button("Review") { nav.go(.review) }.keyboardShortcut("r", modifiers: [.command, .shift])
                Button("Course map") { nav.go(.course) }.keyboardShortcut("m", modifiers: [.command, .shift])
                Divider()
                Button("Back") { nav.back() }.keyboardShortcut("[").disabled(nav.path.isEmpty)
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        // a bare SPM executable starts as a background process; make it a real app with a Dock icon
        NSApp.setActivationPolicy(.regular)
        NSApp.activate()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { true }
}

@MainActor @Observable
final class Nav {
    var selection: Route? = .today {
        didSet { if selection != oldValue { path = [] } } // sidebar clicks pop back to the root
    }
    var path: [Route] = []

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
                page(nav.selection ?? .today)
                    .navigationDestination(for: Route.self) { page($0) }
            }
        }
        .onChange(of: nav.current, initial: true) { old, r in
            activity.route(r)
            // problems get the whole window; the sidebar comes back when you leave
            let isProblem = { (r: Route?) in if case .problem = r { true } else { false } }
            if isProblem(r) != isProblem(old) { withAnimation { columns = isProblem(r) ? .detailOnly : .automatic } }
        }
        .overlay(alignment: .top) { Toast() }
        .task { await snapshots() }
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
        case .topic(let id): TopicView(topicId: id).id(id)
        case .problem(let id): ProblemView(pid: id).id(id)
        }
    }
}

struct Sidebar: View {
    @Environment(Store.self) private var store
    @Environment(Nav.self) private var nav
    @State private var expanded: Set<String> = []

    var body: some View {
        @Bindable var nav = nav
        let modules = store.moduleViews()
        let me = store.me()
        List(selection: $nav.selection) {
            Section {
                Label("Today", systemImage: "sun.max").tag(Route.today)
                Label("Review", systemImage: "arrow.counterclockwise")
                    .badge(me.reviewsDue)
                    .tag(Route.review)
                Label("Course map", systemImage: "map").tag(Route.course)
            }

            Section("Modules") {
                ForEach(modules) { m in
                    DisclosureGroup(isExpanded: Binding(
                        get: { expanded.contains(m.id) },
                        set: { if $0 { expanded.insert(m.id) } else { expanded.remove(m.id) } }
                    )) {
                        ForEach(m.topics) { t in
                            HStack(spacing: 6) {
                                Image(systemName: t.status.complete ? "checkmark.circle.fill"
                                      : t.status.lessonDone || t.status.solved > 0 ? "circle.dashed" : "circle")
                                    .foregroundStyle(t.status.complete ? Color.green : .secondary)
                                    .font(.caption)
                                Text(t.topic.title).lineLimit(1)
                            }
                            .foregroundStyle(t.topic.ready ? .primary : .secondary)
                            .tag(Route.topic(t.id))
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(String(format: "%02d", m.module.number))
                                .font(.caption.monospacedDigit().weight(.semibold))
                                .foregroundStyle(m.complete ? Color.green : m.unlocked ? Color.accentColor : .secondary)
                            Text(m.module.title).lineLimit(1)
                            Spacer()
                            if !m.unlocked { Image(systemName: "lock.fill").font(.caption2).foregroundStyle(.tertiary) }
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom) { SidebarFooter(me: me) }
        .onAppear {
            // open the module you're working in
            if expanded.isEmpty, let cur = modules.first(where: { $0.unlocked && !$0.complete }) { expanded = [cur.id] }
        }
        .onChange(of: nav.selection) { _, r in
            if case .topic(let tid) = r, let m = modules.first(where: { $0.module.topics.contains(tid) }) { expanded.insert(m.id) }
        }
    }
}

private struct SidebarFooter: View {
    @Environment(Activity.self) private var activity
    let me: Me

    var body: some View {
        let secs = me.streak.todaySeconds + activity.pending
        let goal = Streak.dailyGoal
        HStack(spacing: 10) {
            Ring(pct: Double(secs) / Double(goal), size: 26, label: false)
            VStack(alignment: .leading, spacing: 1) {
                Text("\(secs / 60) / \(goal / 60) min today").font(.caption.weight(.medium).monospacedDigit())
                Text("Level \(me.level.level) · \(me.streak.weekStreak)w streak").font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
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
                    .glassOrMaterial()
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

extension View {
    @ViewBuilder func glassOrMaterial() -> some View {
        if #available(macOS 26, *) { glassEffect(.regular, in: .capsule) }
        else { background(.regularMaterial, in: .capsule) }
    }
}
