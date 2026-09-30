import WidgetKit

extension Store {
    /// Hands today's numbers to the widget whenever they change (called after every write, and at launch).
    func publishWidget() {
        let me = me(), today = me.today(pending: 0)
        let snap = WidgetSnapshot(day: Dates.local(), seconds: today.secs, goal: Streak.dailyGoal, streak: today.streak,
                                  week: me.streak.thisWeek.map(\.seconds))
        guard snap != WidgetSync.last, snap.save() else { return }
        WidgetSync.last = snap
        WidgetCenter.shared.reloadAllTimelines()
    }
}

@MainActor
enum WidgetSync {
    static var last: WidgetSnapshot?
}
