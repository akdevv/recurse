import SwiftUI

struct HomeView: View {
    @Environment(Store.self) private var store
    @Environment(Activity.self) private var activity
    @Environment(Nav.self) private var nav

    var body: some View {
        let me = store.me()
        let next = store.nextAction(store.moduleViews())
        let secs = me.streak.todaySeconds + activity.pending
        let goal = Streak.dailyGoal
        let pct = Double(secs) / Double(goal)

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                        .font(.callout).foregroundStyle(.secondary)
                    Text("\(greeting), \(me.username)").font(.largeTitle.weight(.semibold))
                }

                HStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Ring(pct: pct)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Today").font(.caption).foregroundStyle(.secondary)
                            (Text("\(secs / 60)").font(.title.weight(.semibold)) + Text(" / \(goal / 60) min").foregroundStyle(.secondary))
                                .monospacedDigit()
                            Text(pct >= 1 ? "Goal reached" : "\(goal / 60 - secs / 60) min to go").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .card(padding: 18)
                    .frame(width: 250)

                    UpNext(next: next)
                }
                .fixedSize(horizontal: false, vertical: true)

                HStack(alignment: .top, spacing: 16) {
                    Stat(icon: "flame.fill", tint: .orange, label: "Weekly streak",
                         value: "\(me.streak.weekStreak)", unit: me.streak.weekStreak == 1 ? "week" : "weeks") {
                        WeekStrip(days: me.streak.thisWeek)
                    } note: {
                        Text("\(min(Streak.daysPerWeek, me.streak.thisWeekDays)) / \(Streak.daysPerWeek) days this week")
                        Spacer()
                        Label("\(me.streak.freezes)", systemImage: "snowflake").help("Streak freezes")
                    }
                    Stat(icon: "sparkles", tint: .accentColor, label: "Level", value: "\(me.level.level)", unit: me.level.title) {
                        ProgressView(value: Double(me.level.into), total: Double(me.level.need)).frame(height: 22)
                    } note: {
                        Text("\(me.level.need - me.level.into) XP to level \(me.level.level + 1)")
                        Spacer()
                        Text("\(me.xp) XP")
                    }
                    Button { nav.go(.review) } label: {
                        Stat(icon: "arrow.counterclockwise", tint: .green, label: "Reviews due", value: "\(me.reviewsDue)", unit: "due today") {
                            Text(me.reviewsDue > 0 ? "Clear these before starting new work." : "All caught up.")
                                .font(.caption).foregroundStyle(.secondary).frame(height: 22)
                        } note: {
                            Text("Open review queue")
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                    }
                    .buttonStyle(.plain)
                }
                .fixedSize(horizontal: false, vertical: true)

                Heatmap(activity: store.activityMap())
            }
            .padding(28)
            .frame(maxWidth: 920)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Today")
    }

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: .now)
        return h < 5 ? "Late night" : h < 12 ? "Good morning" : h < 18 ? "Good afternoon" : "Good evening"
    }
}

private struct UpNext: View {
    @Environment(Nav.self) private var nav
    let next: NextAction

    var body: some View {
        let (label, cta, icon): (String, String, String) = switch next.kind {
        case .review: ("Review", "Start review", "arrow.counterclockwise")
        case .learn: ("Learn", "Start lesson", "book")
        case .solve: ("Solve", "Open problem", "chevron.left.forwardslash.chevron.right")
        case .finish: ("Finish topic", "Continue", "flag.checkered")
        case .browse: ("Explore", "Open course", "map")
        }
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Label("Up next · \(label)", systemImage: icon).font(.caption.weight(.medium)).foregroundStyle(Color.accentColor)
                Text(next.title).font(.title2.weight(.semibold)).lineLimit(1)
                if !next.context.isEmpty { Text(next.context).font(.caption).foregroundStyle(.secondary).lineLimit(1) }
            }
            Spacer()
            Button { nav.go(next.route) } label: { Label(cta, systemImage: "arrow.right").labelStyle(.titleAndIcon) }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
        }
        .card(padding: 18)
        .background(LinearGradient(colors: [Color.accentColor.opacity(0.10), .clear], startPoint: .leading, endPoint: .trailing),
                    in: .rect(cornerRadius: 12))
    }
}

private struct Stat<Middle: View, Note: View>: View {
    let icon: String
    let tint: Color
    let label, value, unit: String
    @ViewBuilder let middle: Middle
    @ViewBuilder let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: icon).font(.caption.weight(.medium)).foregroundStyle(tint)
            (Text(value).font(.title.weight(.semibold)) + Text(" \(unit)").foregroundStyle(.secondary)).monospacedDigit().lineLimit(1)
            middle
            HStack(spacing: 4) { note }.font(.caption).foregroundStyle(.secondary).monospacedDigit()
        }
        .card()
        .contentShape(.rect)
    }
}

private struct WeekStrip: View {
    let days: [StreakState.Day]
    var body: some View {
        let today = Dates.local()
        HStack(spacing: 4) {
            ForEach(Array(days.enumerated()), id: \.offset) { i, d in
                Text(["M", "T", "W", "T", "F", "S", "S"][i])
                    .font(.system(size: 10, weight: .medium))
                    .frame(maxWidth: .infinity, minHeight: 22)
                    .foregroundStyle(d.qualifies ? Color.green : d.seconds > 0 ? Color.accentColor : .secondary)
                    .background(d.qualifies ? Color.green.opacity(0.18) : d.seconds > 0 ? Color.accentColor.opacity(0.12) : Color.primary.opacity(0.06),
                                in: .rect(cornerRadius: 4))
                    .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(d.date == today ? Color.primary.opacity(0.4) : .clear))
                    .opacity(d.date > today ? 0.4 : 1)
                    .help("\(d.date): \(d.seconds / 60) min")
            }
        }
    }
}

private struct Heatmap: View {
    let activity: [String: Int]
    private let weeks = 52
    private let cell: CGFloat = 11, gap: CGFloat = 3

    var body: some View {
        let goal = Streak.dailyGoal
        let today = Dates.local()
        let start = Dates.add(Dates.weekStart(today), -(weeks - 1) * 7)
        let cols = (0..<weeks).map { w in (0..<7).map { Dates.add(start, w * 7 + $0) } }
        let all = cols.flatMap { $0 }.filter { $0 <= today }
        let total = all.reduce(0) { $0 + (activity[$1] ?? 0) }
        let goalDays = all.filter { (activity[$0] ?? 0) >= goal }.count
        // levels are relative to the daily goal: touched, goal, 2x, 4x
        let shade = { (s: Int) -> Color in
            s >= goal * 4 ? .accentColor : s >= goal * 2 ? .accentColor.opacity(0.65) : s >= goal ? .accentColor.opacity(0.4)
                : s > 0 ? .accentColor.opacity(0.15) : .primary.opacity(0.07)
        }

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Activity").font(.caption.weight(.medium)).foregroundStyle(.secondary)
                Spacer()
                (Text("\(total / 3600)h").fontWeight(.semibold) + Text(" in the last year · ").foregroundStyle(.secondary)
                    + Text("\(goalDays)").fontWeight(.semibold) + Text(" goal days").foregroundStyle(.secondary))
                    .font(.caption).monospacedDigit()
            }
            ViewThatFits(in: .horizontal) {
                grid(cols, today: today, shade: shade)
                ScrollView(.horizontal) { grid(cols, today: today, shade: shade) }.defaultScrollAnchor(.trailing)
            }
            .frame(maxWidth: .infinity)
            HStack(spacing: 3) {
                Text("Only focused, active time counts.")
                Spacer()
                Text("Less").padding(.trailing, 2)
                ForEach([0, 1, goal, goal * 2, goal * 4], id: \.self) { s in
                    RoundedRectangle(cornerRadius: 2).fill(shade(s)).frame(width: cell, height: cell)
                }
                Text("More").padding(.leading, 2)
            }
            .font(.caption2).foregroundStyle(.tertiary)
        }
        .card()
    }

    private func grid(_ cols: [[String]], today: String, shade: @escaping (Int) -> Color) -> some View {
        HStack(alignment: .top, spacing: gap) {
            VStack(alignment: .trailing, spacing: gap) {
                Text(" ").frame(height: 12)
                ForEach(Array(["", "Mon", "", "Wed", "", "Fri", ""].enumerated()), id: \.offset) { Text($0.element).frame(height: cell) }
            }
            .font(.system(size: 9)).foregroundStyle(.tertiary).padding(.trailing, 4)
            ForEach(cols.indices, id: \.self) { w in
                VStack(spacing: gap) {
                    let first = cols[w][0]
                    let newMonth = w == 0 || first.dropLast(3) != cols[w - 1][0].dropLast(3)
                    Text(newMonth ? Dates.parse(first).formatted(.dateTime.month(.abbreviated)) : " ")
                        .font(.system(size: 9)).foregroundStyle(.tertiary).fixedSize().frame(width: cell, height: 12, alignment: .leading)
                    ForEach(cols[w], id: \.self) { d in
                        let s = activity[d] ?? 0
                        RoundedRectangle(cornerRadius: 2)
                            .fill(d > today ? .clear : shade(s))
                            .overlay(RoundedRectangle(cornerRadius: 2).strokeBorder(d == today ? Color.primary.opacity(0.5) : .clear))
                            .frame(width: cell, height: cell)
                            .help(d > today ? "" : "\(Dates.parse(d).formatted(.dateTime.weekday().day().month())) · \(s / 60) min")
                    }
                }
            }
        }
    }
}
