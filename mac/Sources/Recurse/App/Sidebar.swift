import SwiftUI

struct Sidebar: View {
    @Environment(Store.self) private var store
    @Environment(Nav.self) private var nav

    var body: some View {
        let me = store.me()
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                TodayPanel(me: me)

                group("Learn") {
                    row(.today)
                    row(.course)
                    row(.review, count: me.reviewsDue)
                }
                group("Practice") {
                    row(.problems)
                    row(.patterns)
                }
                group("Progress") {
                    row(.stats)
                    row(.rewards, count: store.rewardsWaiting)
                }
            }
            .padding(.horizontal, 10).padding(.top, 4).padding(.bottom, 12)
        }
        .scrollIndicators(.never)
        .safeAreaInset(edge: .bottom, spacing: 0) { ProfileRow(me: me) }
    }

    private func group(_ title: String, @ViewBuilder _ rows: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased()).font(.system(size: 10.5, weight: .semibold)).tracking(0.8).foregroundStyle(.muted.opacity(0.8))
                .padding(.horizontal, 10).padding(.bottom, 4)
            rows()
        }
    }

    private func row(_ r: Route, count: Int = 0) -> some View {
        // topics and boss fights live under Course
        let inCourse = switch nav.selection { case .topic, .boss: true; default: false }
        return SidebarRow(title: r.title, icon: r.icon, active: nav.selection == r || (r == .course && inCourse), count: count) { nav.go(r) }
    }
}

private struct SidebarRow: View {
    let title, icon: String
    var iconTint: Color?
    let active: Bool
    var count = 0
    var dim = false
    var small = false
    let action: () -> Void
    @State private var hover = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Image(systemName: icon)
                    .font(.system(size: small ? 11 : 13, weight: .medium))
                    .foregroundStyle(active ? Color.brand : iconTint ?? (hover ? .primary : Color.muted))
                    .frame(width: 18)
                Text(title).lineLimit(1)
                    .foregroundStyle(active || hover ? .primary : dim ? Color.muted.opacity(0.7) : Color.muted)
                    .fontWeight(active ? .semibold : .regular)
                Spacer(minLength: 4)
                if count > 0 {
                    Text("\(count)").font(.system(size: 11, weight: .semibold).monospacedDigit()).foregroundStyle(.brand)
                        .padding(.horizontal, 6).padding(.vertical, 1)
                        .background(Color.brand.opacity(0.15), in: .capsule)
                }
            }
            .font(small ? .callout : .body)
            .padding(.horizontal, 10).frame(height: small ? 28 : 32)
            .glassEffect(active ? .regular.tint(Color.brand.opacity(0.14)) : .identity, in: .rect(cornerRadius: 10, style: .continuous))
            .background(!active && hover ? Color.white.opacity(0.05) : .clear, in: .rect(cornerRadius: 10, style: .continuous))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .onHover { hover = $0 }
    }
}

private struct TodayPanel: View {
    @Environment(Activity.self) private var activity
    let me: Me

    var body: some View {
        let (secs, done, streak) = me.today(pending: activity.pending)
        let goal = Streak.dailyGoal
        let today = Dates.local()
        let days = me.streak.thisWeek.map { d in d.date == today ? StreakState.Day(date: d.date, seconds: secs, qualifies: done) : d }
        let goalDays = days.filter(\.qualifies).count

        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Ring(pct: Double(secs) / Double(goal), size: 42, lineWidth: 4.5, label: false)
                    if done { Image(systemName: "checkmark").font(.system(size: 13, weight: .bold)).foregroundStyle(Color.success) }
                    else { Text("\(secs / 60)").font(.system(size: 13, weight: .semibold, design: .rounded)).monospacedDigit() }
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(done ? "Goal done" : "of \(goal / 60) min").font(.system(.headline, design: .rounded))
                    Text(done ? "\(secs / 60) min today" : "\((goal - secs + 59) / 60) min to go").font(.caption).foregroundStyle(.muted).monospacedDigit()
                }
                .lineLimit(1)
                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 0) {
                    ForEach(Array(days.enumerated()), id: \.offset) { i, d in
                        let isToday = d.date == today
                        VStack(spacing: 5) {
                            Circle()
                                .fill(d.qualifies ? Color.success : d.seconds > 0 ? Color.brand.opacity(0.55) : Color.white.opacity(0.08))
                                .frame(width: 10, height: 10)
                            Text(["M", "T", "W", "T", "F", "S", "S"][i])
                                .font(.system(size: 9, weight: isToday ? .heavy : .medium))
                                .foregroundStyle(isToday ? Color.brand : Color.muted)
                        }
                        .frame(maxWidth: .infinity)
                        .opacity(d.date > today ? 0.45 : 1)
                        .help("\(d.date): \(d.seconds / 60) min")
                    }
                }
                HStack {
                    Text("\(Text("\(min(goalDays, Streak.daysPerWeek))").fontWeight(.semibold))\(Text(" / \(Streak.daysPerWeek) goal days").foregroundStyle(.muted))")
                        .font(.caption).monospacedDigit()
                    Spacer()
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                        Text("\(streak)").monospacedDigit()
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(streak > 0 ? Color.warning : Color.muted)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .glassEffect(streak > 0 ? .regular.tint(Color.warning.opacity(0.18)) : .regular, in: .capsule)
                    .help("\(streak)-day streak")
                }
            }
        }
        .padding(14)
        .glassEffect(.regular, in: .rect(cornerRadius: 18, style: .continuous))
    }
}

private struct ProfileRow: View {
    @Environment(\.openSettings) private var openSettings
    let me: Me
    @State private var hover = false

    var body: some View {
        Button { openSettings() } label: {
            HStack(spacing: 10) {
                Avatar(size: 34, image: me.avatar)
                VStack(alignment: .leading, spacing: 1) {
                    Text(me.name).font(.callout.weight(.semibold)).lineLimit(1)
                    Text("@\(me.username) · Lv \(me.level.level)").font(.caption).foregroundStyle(.muted).lineLimit(1)
                }
                Spacer(minLength: 4)
                Image(systemName: "gearshape.fill").font(.system(size: 13)).foregroundStyle(hover ? .primary : Color.muted)
            }
            .padding(10)
            .background(hover ? Color.hover : Color.surface, in: .rect(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(.hairline))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .onHover { hover = $0 }
        .help("Settings (⌘,)")
        .padding(.horizontal, 10).padding(.bottom, 10).padding(.top, 6)
    }
}
