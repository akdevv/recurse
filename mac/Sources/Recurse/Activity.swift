// Counts time only on a learning screen (topic, problem, review) while the app is frontmost and in use.
// Port of web/src/lib/activity.ts.
import AppKit
import Observation

@MainActor @Observable
final class Activity {
    static let idle: TimeInterval = 90
    static let flushEvery = 60

    private let store: Store
    private(set) var pending = 0
    private var context: String?
    private var tracked = false
    private var holds = 0 // a playing viz keeps the session active without input
    private var timer: Timer?

    init(store: Store) {
        self.store = store
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        NotificationCenter.default.addObserver(forName: NSApplication.didResignActiveNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.flush() }
        }
        NotificationCenter.default.addObserver(forName: NSApplication.willTerminateNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.flush() }
        }
    }

    private var isActive: Bool {
        // system-wide idle time is fine: the app has to be frontmost anyway
        let sinceInput = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: CGEventType(rawValue: ~0)!)
        return tracked && NSApp.isActive && (holds > 0 || sinceInput < Self.idle)
    }

    private func tick() {
        guard isActive else { return }
        pending += 1
        if pending >= Self.flushEvery { flush() }
    }

    func flush() {
        guard pending > 0 else { return }
        store.addActivity(seconds: pending, problemId: context)
        pending = 0
    }

    /// Only learning screens count; browsing home or the course map doesn't.
    func route(_ r: Route?) {
        let problem: String? = if case .problem(let id) = r { id } else { nil }
        let learning = switch r {
        case .topic, .problem, .review: true
        default: false
        }
        if problem != context || learning != tracked { flush() }
        context = problem
        tracked = learning
    }

    func hold() -> () -> Void {
        holds += 1
        return { [weak self] in self?.holds -= 1 }
    }

    /// Pending seconds for the problem currently being tracked (hint unlocks count them live).
    func pending(for pid: String) -> Int { context == pid ? pending : 0 }
}
