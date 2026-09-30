import SwiftUI
import WidgetKit

// Built into Recurse.app/Contents/PlugIns by build-app.sh; reads what the app writes (WidgetSnapshot).

struct Entry: TimelineEntry {
    let date: Date
    let snap: WidgetSnapshot
}

struct Provider: TimelineProvider {
    static let sample = WidgetSnapshot(day: day(.now), seconds: 18 * 60, goal: 30 * 60, streak: 6,
                                       week: [2140, 2610, 1980, 1110, 0, 0, 0])

    func placeholder(in _: Context) -> Entry { Entry(date: .now, snap: Self.sample) }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        completion(Entry(date: .now, snap: context.isPreview ? Self.sample : current(.now)))
    }

    /// Now, then midnight (the app may be closed then, so the widget rolls the day over itself).
    func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let now = Date.now, snap = current(now)
        let midnight = Calendar.current.startOfDay(for: now.addingTimeInterval(86_400))
        let next = snap.rolledOver(to: Self.day(midnight), monday: Calendar.current.component(.weekday, from: midnight) == 2)
        completion(Timeline(entries: [Entry(date: now, snap: snap), Entry(date: midnight, snap: next)], policy: .after(midnight)))
    }

    private func current(_ now: Date) -> WidgetSnapshot {
        let today = Self.day(now)
        guard let s = WidgetSnapshot.load() else { return WidgetSnapshot(day: today, seconds: 0, goal: 30 * 60, streak: 0, week: Array(repeating: 0, count: 7)) }
        guard s.day != today else { return s }
        let yesterday = Self.day(now.addingTimeInterval(-86_400))
        let sameWeek = Calendar(identifier: .iso8601).isDate(Self.date(s.day), equalTo: now, toGranularity: .weekOfYear)
        var r = s.rolledOver(to: today, monday: !sameWeek)
        if s.day != yesterday { r.streak = 0 } // a whole day went by without the app
        return r
    }

    static func day(_ d: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: d)
        return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!)
    }

    private static func date(_ s: String) -> Date {
        let p = s.split(separator: "-").compactMap { Int($0) }
        return Calendar.current.date(from: DateComponents(year: p[0], month: p[1], day: p[2])) ?? .now
    }
}

struct RecurseWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: Entry

    var body: some View {
        let s = entry.snap
        HStack(spacing: 18) {
            Today(snap: s)
            if family == .systemMedium { Week(snap: s, today: weekdayIndex(entry.date)) }
        }
        .containerBackground(for: .widget) { Color.canvas }
    }

    private func weekdayIndex(_ d: Date) -> Int { (Calendar.current.component(.weekday, from: d) + 5) % 7 } // Monday = 0
}

struct Today: View {
    let snap: WidgetSnapshot

    var body: some View {
        let mins = snap.seconds / 60, goal = snap.goal / 60, done = snap.seconds >= snap.goal
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                ZStack {
                    Circle().stroke(Color.white.opacity(0.1), lineWidth: 6)
                    Circle().trim(from: 0, to: min(1, Double(snap.seconds) / Double(max(1, snap.goal))))
                        .stroke(done ? Color.success : Color.brand, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .widgetAccentable()
                    if done {
                        Image(systemName: "checkmark").font(.system(size: 16, weight: .bold)).foregroundStyle(Color.success)
                    }
                }
                .frame(width: 50, height: 50)
                Spacer(minLength: 4)
                Label("\(snap.streak)", systemImage: "flame.fill")
                    .font(.system(size: 13, weight: .semibold, design: .rounded)).monospacedDigit()
                    .foregroundStyle(snap.streak > 0 ? Color.warning : Color.muted)
            }
            Spacer(minLength: 6)
            Text("\(Text("\(mins)").font(.system(size: 26, weight: .semibold, design: .rounded)))\(Text(" / \(goal) min").font(.system(size: 13)).foregroundStyle(.muted))")
                .monospacedDigit().lineLimit(1).minimumScaleFactor(0.8)
            Text(done ? "Goal done" : "\(goal - mins) min to go")
                .font(.system(size: 12)).foregroundStyle(done ? Color.success : Color.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct Week: View {
    let snap: WidgetSnapshot
    let today: Int

    var body: some View {
        let goalDays = snap.week.filter { $0 >= snap.goal }.count
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom, spacing: 7) {
                ForEach(0..<7, id: \.self) { i in
                    let secs = i < snap.week.count ? snap.week[i] : 0
                    VStack(spacing: 5) {
                        Capsule().fill(Color.white.opacity(0.08))
                            .overlay(alignment: .bottom) {
                                GeometryReader { g in
                                    Capsule()
                                        .fill(secs >= snap.goal ? Color.success : Color.brand.opacity(0.7))
                                        .frame(height: secs > 0 ? max(6, g.size.height * min(1, Double(secs) / Double(snap.goal))) : 0)
                                        .frame(maxHeight: .infinity, alignment: .bottom)
                                }
                            }
                            .opacity(i > today ? 0.5 : 1)
                        Text(["M", "T", "W", "T", "F", "S", "S"][i])
                            .font(.system(size: 10, weight: i == today ? .bold : .medium))
                            .foregroundStyle(i == today ? Color.brand : Color.muted)
                    }
                }
            }
            Text("\(Text("\(min(goalDays, 5))").foregroundStyle(.primary)) of 5 goal days")
                .font(.system(size: 12)).foregroundStyle(.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RecurseWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "today", provider: Provider()) { RecurseWidgetView(entry: $0) }
            .configurationDisplayName("Today")
            .description("Today's minutes, your day streak and the week.")
            .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#if !PREVIEW
@main
struct RecurseWidgets: WidgetBundle {
    var body: some Widget { RecurseWidget() }
}
#endif
