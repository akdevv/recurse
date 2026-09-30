import SwiftUI

struct HomeView: View {
    @Environment(Store.self) private var store
    @Environment(Activity.self) private var activity
    @Environment(Nav.self) private var nav

    var body: some View {
        let me = store.me()
        let next = store.nextAction(store.moduleViews())
        let secs = me.today(pending: activity.pending).secs
        let goal = Streak.dailyGoal

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 16) {
                    Avatar(size: 48, image: me.avatar)
                        .padding(3)
                        .overlay(Circle().strokeBorder(.white.opacity(0.14), lineWidth: 1))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                            .font(.caption.weight(.medium)).foregroundStyle(.muted)
                        Text("\(greeting), \(me.name.split(separator: " ").first ?? "")").font(.title.weight(.semibold))
                    }
                }
                .padding(.top, 8)

                Hero(secs: secs, goal: goal, next: next)

                HStack(alignment: .top, spacing: 16) {
                    Stat(icon: "flame.fill", tint: .warning, label: "Weekly streak",
                         value: "\(me.streak.weekStreak)", unit: me.streak.weekStreak == 1 ? "week" : "weeks") {
                        WeekStrip(days: me.streak.thisWeek)
                    } note: {
                        Text("\(min(Streak.daysPerWeek, me.streak.thisWeekDays)) / \(Streak.daysPerWeek) days this week")
                        Spacer()
                        Label("\(me.streak.freezes)", systemImage: "snowflake").help("Streak freezes")
                    }
                    Stat(icon: "sparkles", tint: .brand, label: "Level", value: "\(me.level.level)", unit: me.level.title) {
                        ProgressView(value: Double(me.level.into), total: Double(me.level.need)).frame(height: 22)
                    } note: {
                        Text("\(me.level.need - me.level.into) XP to level \(me.level.level + 1)")
                        Spacer()
                        Text("\(me.xp) XP")
                    }
                    Button { nav.go(.review) } label: {
                        Stat(icon: "arrow.counterclockwise", tint: .success, label: "Reviews due", value: "\(me.reviewsDue)", unit: "due today") {
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

private struct Hero: View {
    @Environment(Nav.self) private var nav
    let secs, goal: Int
    let next: NextAction

    var body: some View {
        let pct = Double(secs) / Double(goal)
        let (label, cta, icon): (String, String, String) = switch next.kind {
        case .review: ("Review", "Start review", "arrow.counterclockwise")
        case .learn: ("Learn", "Start lesson", "book")
        case .solve: ("Solve", "Open problem", "chevron.left.forwardslash.chevron.right")
        case .finish: ("Finish topic", "Continue", "flag.checkered")
        case .browse: ("Explore", "Open course", "map")
        }
        HStack(spacing: 24) {
            HStack(spacing: 18) {
                Ring(pct: pct, size: 88, lineWidth: 8)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today").font(.caption.weight(.medium)).foregroundStyle(.secondary)
                    Text("\(Text("\(secs / 60)").font(.system(size: 34, weight: .bold, design: .rounded)))\(Text(" / \(goal / 60) min").font(.title3).foregroundStyle(.secondary))")
                        .monospacedDigit().lineLimit(1).fixedSize()
                    Text(pct >= 1 ? "Goal reached" : "\(goal / 60 - secs / 60) min to go").font(.callout).foregroundStyle(pct >= 1 ? .success : .secondary)
                }
            }
            .fixedSize() // ring + minutes keep their natural width; "Up next" takes what's left
            Divider().frame(height: 72).opacity(0.6)
            VStack(alignment: .leading, spacing: 5) {
                Label("Up next · \(label)", systemImage: icon).font(.caption.weight(.semibold)).foregroundStyle(Color.brand)
                Text(next.title).font(.title2.weight(.semibold)).lineLimit(1)
                if !next.context.isEmpty { Text(next.context).font(.callout).foregroundStyle(.secondary).lineLimit(1) }
            }
            Spacer(minLength: 12)
            Button { nav.go(next.route) } label: { Label(cta, systemImage: "arrow.right").labelStyle(.titleAndIcon).padding(.horizontal, 4) }
                .buttonStyle(.glassProminent)
                .controlSize(.extraLarge)
                .keyboardShortcut(.defaultAction)
        }
        .padding(22)
        .glassEffect(.regular.tint(Color.brand.opacity(0.08)), in: .rect(cornerRadius: 28, style: .continuous))
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
            Text("\(Text(value).font(.system(size: 28, weight: .bold, design: .rounded)))\(Text(" \(unit)").foregroundStyle(.secondary))").monospacedDigit().lineLimit(1)
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
                    .foregroundStyle(d.qualifies ? Color.success : d.seconds > 0 ? Color.brand : .secondary)
                    .background(d.qualifies ? Color.success.opacity(0.18) : d.seconds > 0 ? Color.brand.opacity(0.12) : Color.raised,
                                in: .rect(cornerRadius: 5, style: .continuous))
                    .opacity(d.date > today ? 0.4 : 1)
                    .help("\(d.date): \(d.seconds / 60) min")
            }
        }
    }
}

private struct Heatmap: View {
    let activity: [String: Int]
    private let weeks = 52
    private let gap: CGFloat = 3
    private let labelWidth: CGFloat = 26
    @State private var width: CGFloat = 0

    var body: some View {
        let goal = Streak.dailyGoal
        let today = Dates.local()
        let start = Dates.add(Dates.weekStart(today), -(weeks - 1) * 7)
        let cols = (0..<weeks).map { w in (0..<7).map { Dates.add(start, w * 7 + $0) } }
        let all = cols.flatMap { $0 }.filter { $0 <= today }
        let total = all.reduce(0) { $0 + (activity[$1] ?? 0) }
        let goalDays = all.filter { (activity[$0] ?? 0) >= goal }.count
        let activeDays = all.filter { (activity[$0] ?? 0) > 0 }.count
        // cells grow to fill the card (capped so a wide window doesn't make blocks)
        let cell = max(8, min(16, (width - labelWidth - gap * CGFloat(weeks)) / CGFloat(weeks)))

        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Label("Activity", systemImage: "square.grid.3x3.fill").font(.callout.weight(.semibold))
                    .foregroundStyle(.primary).labelStyle(TintedIcon())
                Spacer()
                HStack(spacing: 14) {
                    summary("\(total / 3600)h", "focused")
                    summary("\(goalDays)", "goal days")
                    summary("\(activeDays)", "active days")
                }
            }

            HStack(alignment: .top, spacing: gap) {
                VStack(alignment: .leading, spacing: gap) {
                    Text(" ").frame(height: 14)
                    ForEach(Array(["", "Mon", "", "Wed", "", "Fri", ""].enumerated()), id: \.offset) {
                        Text($0.element).frame(height: cell)
                    }
                }
                .font(.system(size: 9, weight: .medium)).foregroundStyle(.muted)
                .frame(width: labelWidth, alignment: .leading)
                ForEach(cols.indices, id: \.self) { w in
                    VStack(spacing: gap) {
                        let first = cols[w][0]
                        let newMonth = w == 0 || first.dropLast(3) != cols[w - 1][0].dropLast(3)
                        Text(newMonth && w < weeks - 2 ? Dates.parse(first).formatted(.dateTime.month(.abbreviated)) : " ")
                            .font(.system(size: 9, weight: .medium)).foregroundStyle(.muted)
                            .fixedSize().frame(width: cell, height: 14, alignment: .leading)
                        ForEach(cols[w], id: \.self) { d in
                            let s = activity[d] ?? 0
                            RoundedRectangle(cornerRadius: cell * 0.28, style: .continuous)
                                .fill(d > today ? Color.clear : shade(s))
                                .frame(width: cell, height: cell)
                                .help(d > today ? "" : "\(Dates.parse(d).formatted(.dateTime.weekday().day().month())) · \(s / 60) min")
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onGeometryChange(for: CGFloat.self, of: \.size.width) { width = $0 }

            HStack(spacing: 4) {
                Text("Only focused, active time counts.")
                Spacer()
                Text("Less").padding(.trailing, 3)
                ForEach([0, 1, goal, goal * 2, goal * 4], id: \.self) { s in
                    RoundedRectangle(cornerRadius: 2.5, style: .continuous).fill(shade(s)).frame(width: 10, height: 10)
                }
                Text("More").padding(.leading, 3)
            }
            .font(.caption2).foregroundStyle(.muted)
        }
        .card(padding: 18)
    }

    /// Levels are relative to the daily goal: touched, goal, 2x, 4x.
    private func shade(_ s: Int) -> Color {
        let goal = Streak.dailyGoal
        return s >= goal * 4 ? .brand : s >= goal * 2 ? .brand.opacity(0.7) : s >= goal ? .brand.opacity(0.45)
            : s > 0 ? .brand.opacity(0.2) : .raised
    }

    private func summary(_ value: String, _ label: String) -> some View {
        Text("\(Text(value).fontWeight(.semibold).foregroundStyle(.primary)) \(Text(label).foregroundStyle(.muted))")
            .font(.caption).monospacedDigit()
    }
}

struct TintedIcon: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 7) { configuration.icon.foregroundStyle(.brand); configuration.title }
    }
}
