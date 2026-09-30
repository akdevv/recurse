import Foundation

/// Today's progress for the widget. The app writes it to the shared App Group container, the widget reads it.
/// Compiled into both (see build-app.sh), so it stays Foundation-only.
struct WidgetSnapshot: Codable, Equatable {
    var day: String // local YYYY-MM-DD it describes
    var seconds: Int // active today
    var goal: Int // daily goal, seconds
    var streak: Int // day streak, today included once the goal is met
    var week: [Int] // active seconds per day, Monday first

    static let group = "L63A6B5UJ9.dev.akdevv.recurse" // team-prefixed (the signing certificate's OU; also in build-app.sh), so no provisioning profile is needed

    private static var url: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group)?.appending(path: "today.json")
    }

    static func load() -> WidgetSnapshot? {
        url.flatMap { try? Data(contentsOf: $0) }.flatMap { try? JSONDecoder().decode(Self.self, from: $0) }
    }

    /// False without the App Group entitlement (e.g. `swift run`).
    func save() -> Bool {
        guard let url = Self.url, let data = try? JSONEncoder().encode(self) else { return false }
        return (try? data.write(to: url, options: .atomic)) != nil
    }

    /// What it becomes at the next midnight, before the app has written anything new: nothing done yet, and the
    /// streak lives on only if today counted (a week starts afresh on Monday).
    func rolledOver(to day: String, monday: Bool) -> WidgetSnapshot {
        WidgetSnapshot(day: day, seconds: 0, goal: goal, streak: seconds >= goal ? streak : 0,
                       week: monday ? Array(repeating: 0, count: 7) : week)
    }
}
