// Pure logic, free of DB and UI; covered by EngineTests.
import Foundation

// MARK: dates: local calendar dates as "YYYY-MM-DD" strings, weeks start on Monday

enum Dates {
    static let cal = Calendar(identifier: .gregorian)

    static func local(_ d: Date = .now) -> String {
        let c = cal.dateComponents(in: .current, from: d)
        return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!)
    }

    static func parse(_ s: String) -> Date {
        let p = s.split(separator: "-").map { Int($0)! }
        return cal.date(from: DateComponents(timeZone: .current, year: p[0], month: p[1], day: p[2]))!
    }

    static func add(_ s: String, _ n: Int) -> String { local(cal.date(byAdding: .day, value: n, to: parse(s))!) }

    static func weekStart(_ s: String) -> String {
        let day = (cal.component(.weekday, from: parse(s)) + 5) % 7 // Mon = 0
        return add(s, -day)
    }

    static func iso(_ d: Date = .now) -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.string(from: d)
    }

    static func fromIso(_ s: String) -> Date? {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.date(from: s) ?? ISO8601DateFormatter().date(from: s)
    }
}

// MARK: streak

struct StreakState: Equatable {
    struct Day: Equatable { let date: String; let seconds: Int; let qualifies: Bool }
    var weekStreak: Int
    var dayStreak: Int
    var thisWeekDays: Int
    var thisWeek: [Day]
    var freezes: Int
    var todaySeconds: Int
    var todayDone: Bool
}

enum Streak {
    static let dailyGoal = 30 * 60
    static let daysPerWeek = 5
    static let freezeDay = 3 * 60 * 60
    static let maxFreezes = 2

    /// Derived purely from daily activity. Per finished week: earn freezes from long days (cap 2), then cover
    /// any shortfall below 5 days with freezes; if the shortfall can't be covered, the streak resets.
    static func compute(_ activity: [String: Int], today: String, bonusFreezes: [String: Int] = [:]) -> StreakState {
        let qualifies = { (d: String) in (activity[d] ?? 0) >= dailyGoal }
        let dates = activity.filter { $0.value > 0 }.keys.sorted()
        let currentWeek = Dates.weekStart(today)
        let earned = { (days: [String]) in
            days.filter { (activity[$0] ?? 0) >= freezeDay }.count + days.reduce(0) { $0 + (bonusFreezes[$1] ?? 0) }
        }
        let weekDays = { (ws: String) in (0..<7).map { Dates.add(ws, $0) } }
        var streak = 0, freezes = 0

        if let first = dates.first {
            var ws = Dates.weekStart(first)
            while ws < currentWeek {
                let days = weekDays(ws)
                freezes = min(maxFreezes, freezes + earned(days))
                let shortfall = max(0, daysPerWeek - days.filter(qualifies).count)
                if shortfall <= freezes {
                    freezes -= shortfall
                    streak += 1
                } else {
                    streak = 0
                }
                ws = Dates.add(ws, 7)
            }
        }

        let thisWeek = weekDays(currentWeek).map { StreakState.Day(date: $0, seconds: activity[$0] ?? 0, qualifies: qualifies($0)) }
        let thisWeekDays = thisWeek.filter(\.qualifies).count
        freezes = min(maxFreezes, freezes + earned(thisWeek.map(\.date))) // this week's freezes are usable now too
        let todaySeconds = activity[today] ?? 0
        var day = qualifies(today) ? today : Dates.add(today, -1)
        var dayStreak = 0
        while qualifies(day) { // freezes only protect the weekly streak
            dayStreak += 1
            day = Dates.add(day, -1)
        }
        return StreakState(
            weekStreak: streak + (thisWeekDays >= daysPerWeek ? 1 : 0), dayStreak: dayStreak,
            thisWeekDays: thisWeekDays, thisWeek: thisWeek, freezes: freezes,
            todaySeconds: todaySeconds, todayDone: todaySeconds >= dailyGoal)
    }
}

// MARK: xp

enum Outcome: String, CaseIterable {
    case solved, hinted, assisted
    var rank: Int { [.solved: 3, .hinted: 2, .assisted: 1][self]! }
    var label: String {
        switch self {
        case .solved: "Solved clean"
        case .hinted: "Solved with hints"
        case .assisted: "Solved after viewing the solution"
        }
    }
}

struct Level: Equatable { let level, xp, into, need: Int; let title: String }

enum XP {
    static let quizPerCorrect = 5
    static let explain = 15
    static let review = 10
    static let gradePerPoint = 5

    static func outcome(hints: Int, solutionViewed: Bool) -> Outcome {
        solutionViewed ? .assisted : hints > 0 ? .hinted : .solved
    }

    /// Effort-based: unassisted > hinted > solution-viewed. Time spent alone never gives XP.
    static func solve(_ d: Difficulty, hints: Int, solutionViewed: Bool, optional: Bool) -> Int {
        var xp = Double([Difficulty.easy: 20, .medium: 40, .hard: 80][d]!)
        xp *= solutionViewed ? 0.2 : 1 - 0.25 * Double(min(hints, 2))
        if optional { xp *= 1.25 }
        return Int(xp.rounded())
    }

    /// Level L needs 50·L·(L-1) total XP: L2 = 100, L3 = 300, L4 = 600 …
    static func level(_ xp: Int) -> Level {
        var level = 1
        while 50 * (level + 1) * level <= xp { level += 1 }
        let floor = 50 * level * (level - 1), next = 50 * (level + 1) * level
        return Level(level: level, xp: xp, into: xp - floor, need: next - floor, title: titles[min(level - 1, titles.count - 1)])
    }

    static let titles = [
        "Novice", "Loop Learner", "Big-O Spotter", "Array Apprentice", "Hash Handler", "Pointer Pilot",
        "Window Walker", "Search Seeker", "List Linker", "Stack Stacker", "Recursion Rider", "Tree Climber",
        "Heap Keeper", "Graph Walker", "Greedy Gambler", "DP Initiate", "DP Adept", "Algorithm Artisan",
    ]
}

// MARK: srs

enum SRS {
    static let intervals = [1, 3, 7, 21, 60] // days

    static func first(_ o: Outcome, today: String) -> (idx: Int, due: String) {
        let idx = o == .solved ? 1 : 0
        return (idx, Dates.add(today, intervals[idx]))
    }

    static func next(_ idx: Int, passed: Bool, today: String) -> (idx: Int, due: String) {
        let n = passed ? min(idx + 1, intervals.count - 1) : 0
        return (n, Dates.add(today, intervals[n]))
    }
}

// MARK: hints

struct Unlocks: Equatable {
    var hintsAvailable: Int
    var nextHintAt: Int?
    var solutionAvailable: Bool
    var solutionAt: Int
    static let none = Unlocks(hintsAvailable: 0, nextHintAt: nil, solutionAvailable: false, solutionAt: 0)
}

enum Hints {
    static let unlockAt = [10 * 60, 20 * 60]
    static let solutionAt = 30 * 60

    static func unlocks(active: Int, hintCount: Int) -> Unlocks {
        let slots = unlockAt.prefix(hintCount)
        return Unlocks(
            hintsAvailable: slots.filter { active >= $0 }.count,
            nextHintAt: slots.first { active < $0 },
            solutionAvailable: active >= solutionAt, solutionAt: solutionAt)
    }
}

// MARK: reminders (Reminders.swift supplies the clock and settings)

enum ReminderTiming {
    static let minGap: TimeInterval = 20 * 60
    static let maxGap: TimeInterval = 150 * 60
    static let capPlanned = 8
    static let capCatchUp = 2 // unplanned day that can still save the weekly streak

    /// Deterministic 0..1 from a seed (mulberry32, same as the web), so a given day's schedule is reproducible.
    static func rand(_ seed: Int) -> Double {
        var t = UInt32(truncatingIfNeeded: seed &+ 0x6d2b79f5)
        t = (t ^ (t >> 15)) &* (t | 1)
        t ^= t &+ ((t ^ (t >> 7)) &* (t | 61))
        return Double(t ^ (t >> 14)) / 4294967296
    }

    static func at(_ day: Date, _ hhmm: String) -> Date {
        let p = hhmm.split(separator: ":").map { Int($0) ?? 0 }
        return Calendar.current.date(bySettingHour: p[0], minute: p[1], second: 0, of: day)!
    }

    static func next(now: Date, window: (start: String, end: String), plannedDay: Bool, catchUp: Bool,
                     todayDone: Bool, sentToday: Int, lastSentAt: Date?) -> Date? {
        let cap = plannedDay ? capPlanned : catchUp ? capCatchUp : 0
        if todayDone || sentToday >= cap { return nil }
        let start = at(now, window.start), end = at(now, window.end)
        if now >= end { return nil }
        let c = Calendar.current.dateComponents([.year, .month, .day], from: now)
        let seed = c.year! * 10000 + c.month! * 100 + c.day! + sentToday * 7919
        let soonest = now.addingTimeInterval(60)
        let t: Date
        if sentToday == 0 || lastSentAt == nil {
            let first = max(start, at(now, "11:00")).addingTimeInterval(rand(seed) * 30 * 60)
            t = max(first, soonest)
        } else {
            let left = end.timeIntervalSince(lastSentAt!)
            let gap = min(maxGap, max(minGap, left / 4)) * (0.7 + 0.6 * rand(seed))
            t = max(lastSentAt!.addingTimeInterval(gap), soonest)
        }
        return t < end ? t : nil
    }
}
