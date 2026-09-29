// Daily nudges as native notifications. Port of web/server/notify.ts: one pending timer, recomputed after
// every send or relevant change, no polling. Only fires while the app runs (it stays open in the Dock and
// can start at login), so it replaces the web app's launchd server + web push.
import AppKit
import ServiceManagement
import UserNotifications

@MainActor @Observable
final class Reminders: NSObject, UNUserNotificationCenterDelegate {
    static let activeGrace: TimeInterval = 5 * 60 // no nudges while you're in the app
    static let stale: TimeInterval = 10 * 60 // woke from sleep long after it was due: skip it

    @ObservationIgnored private let store: Store
    @ObservationIgnored private let activity: Activity
    @ObservationIgnored private let nav: Nav
    @ObservationIgnored private var timer: Timer?
    private(set) var snoozeUntil = Date.distantPast
    private(set) var nextAt: Date?

    /// UNUserNotificationCenter needs a real app bundle; `swift run` / tests have none.
    private var center: UNUserNotificationCenter? { Bundle.main.bundleIdentifier == nil ? nil : .current() }

    init(store: Store, activity: Activity, nav: Nav) {
        self.store = store
        self.activity = activity
        self.nav = nav
        super.init()
        center?.delegate = self
        NotificationCenter.default.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.schedule() }
        }
    }

    func requestPermission() async -> Bool {
        (try? await center?.requestAuthorization(options: [.alert, .sound])) ?? false
    }

    private func sentToday() -> [Date] {
        let start = Calendar.current.startOfDay(for: .now)
        return store.db.all("SELECT ts FROM notifications WHERE kind IN ('reminder', 'skipped') AND ts >= ? ORDER BY ts", Dates.iso(start))
            .compactMap { $0.str("ts").flatMap(Dates.fromIso) }
    }

    func schedule() {
        timer?.invalidate()
        nextAt = nil
        let s = store.settings()
        guard s.reminders, center != nil else { return }
        let now = Date.now
        let sent = sentToday()
        let me = store.me()
        let dow = (Calendar.current.component(.weekday, from: now) + 5) % 7 // Mon = 0
        let planned = s.plannedDays.contains(dow)
        let short = Streak.daysPerWeek - me.streak.thisWeekDays
        var t = ReminderTiming.next(
            now: now, window: (s.window.start, s.window.end), plannedDay: planned,
            // an unplanned day still gets nudges while the week can reach its target
            catchUp: !planned && short > 0 && short <= 7 - dow,
            todayDone: me.streak.todayDone, sentToday: sent.count, lastSentAt: sent.last)
        if let x = t, x < snoozeUntil { t = snoozeUntil }
        guard let t else {
            let tomorrow = Calendar.current.startOfDay(for: now).addingTimeInterval(24 * 3600 + 60)
            timer = Timer.scheduledTimer(withTimeInterval: tomorrow.timeIntervalSince(now), repeats: false) { [weak self] _ in
                MainActor.assumeIsolated { self?.schedule() }
            }
            return
        }
        nextAt = t
        timer = Timer.scheduledTimer(withTimeInterval: max(1, t.timeIntervalSince(now)), repeats: false) { [weak self] _ in
            MainActor.assumeIsolated { self?.fire(due: t) }
        }
    }

    private func fire(due: Date) {
        let late = Date.now.timeIntervalSince(due) > Self.stale
        let busy = Date.now.timeIntervalSince(activity.lastActiveAt) < Self.activeGrace
        // goal reached since this was scheduled: nothing to nudge about
        if !late && !busy && !store.me().streak.todayDone { send("reminder", copy()) }
        // being in the app counts as "reminded": wait a full gap before the next one
        if busy { store._db.run("INSERT INTO notifications (ts, kind, title, body) VALUES (?, 'skipped', '', '')", Dates.iso()) }
        schedule()
    }

    func snooze() {
        snoozeUntil = .now.addingTimeInterval(3600)
        schedule()
    }

    func sendTest() {
        send("test", (title: "Reminders are on", body: "This is what a nudge looks like. Click to open Recurse.", route: "today"))
    }

    private func copy() -> (title: String, body: String, route: String) {
        let me = store.me()
        let done = me.streak.todaySeconds / 60, goal = Streak.dailyGoal / 60
        let leftMin = ReminderTiming.at(.now, store.settings().window.end).timeIntervalSinceNow / 60
        let next = store.nextAction(store.moduleViews())
        let route = Self.encode(next.route)
        if leftMin < 75 { return ("Last call", "A 10-minute review sprint still saves the day.", "review") }
        if leftMin < 150 { return ("\(Int(leftMin / 60)) hrs left today", "\(done)/\(goal) min so far. The weekly streak needs today.", route) }
        if done > 0 { return ("\(done)/\(goal) min", "\(goal - done) to go. Next up: \(next.title).", route) }
        return ("\(next.title) is waiting", "\(goal) focused minutes today?" + (me.reviewsDue > 0 ? " \(me.reviewsDue) reviews are due." : ""), route)
    }

    private func send(_ kind: String, _ msg: (title: String, body: String, route: String)) {
        store._db.run("INSERT INTO notifications (ts, kind, title, body) VALUES (?, ?, ?, ?)", Dates.iso(), kind, msg.title, msg.body)
        let c = UNMutableNotificationContent()
        c.title = msg.title
        c.body = msg.body
        c.sound = .default
        c.userInfo = ["route": msg.route]
        center?.add(UNNotificationRequest(identifier: UUID().uuidString, content: c, trigger: nil))
    }

    // MARK: routes in notifications ("today", "review", "topic:<id>", "problem:<id>")

    static func encode(_ r: Route) -> String {
        switch r {
        case .review: "review"
        case .topic(let id): "topic:\(id)"
        case .problem(let id): "problem:\(id)"
        case .course: "course"
        default: "today"
        }
    }

    static func decode(_ s: String) -> Route {
        let p = s.split(separator: ":", maxSplits: 1).map(String.init)
        switch p[0] {
        case "review": return .review
        case "course": return .course
        case "topic" where p.count > 1: return .topic(p[1])
        case "problem" where p.count > 1: return .problem(p[1])
        default: return .today
        }
    }

    /// Clicking a nudge opens the app where it points.
    nonisolated func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let route = response.notification.request.content.userInfo["route"] as? String ?? "today"
        await MainActor.run {
            NSApp.activate()
            NSApp.windows.first { $0.identifier?.rawValue == "main" || $0.title == "Recurse" }?.makeKeyAndOrderFront(nil)
            let r = Self.decode(route)
            if case .problem = r { nav.go(.today) }
            nav.go(r)
        }
    }

    /// Show nudges even when Recurse is frontmost (fire() already skips them while you're active).
    nonisolated func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    // MARK: open at login

    static var openAtLogin: Bool {
        get { SMAppService.mainApp.status == .enabled }
        set { try? newValue ? SMAppService.mainApp.register() : SMAppService.mainApp.unregister() }
    }
}
