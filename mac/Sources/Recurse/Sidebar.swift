// Sidebar in the web app's layout (brand, today panel, grouped nav, profile row), on the system glass sidebar.
import SwiftUI

struct Sidebar: View {
    @Environment(Store.self) private var store
    @Environment(Nav.self) private var nav
    @State private var expanded: Set<String> = []

    var body: some View {
        let me = store.me()
        let modules = store.moduleViews()
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 10) {
                    Image(nsImage: NSApp.applicationIconImage).resizable().frame(width: 28, height: 28)
                    Text("Recurse").font(.headline)
                }
                .padding(.horizontal, 10)

                TodayPanel(me: me)

                group("Learn") {
                    row(.today, "Today", "house")
                    row(.course, "Course", "map")
                    row(.review, "Review", "arrow.counterclockwise", count: me.reviewsDue)
                }
                group("Practice") {
                    row(.problems, "Problems", "checklist")
                    row(.patterns, "Patterns", "square.on.circle")
                }
                group("Progress") {
                    row(.stats, "Stats", "chart.bar")
                    row(.rewards, "Rewards", "gift", count: store.rewardsWaiting)
                }
                group("Modules") {
                    ForEach(modules) { m in moduleRows(m) }
                }
            }
            .padding(.horizontal, 10).padding(.top, 4).padding(.bottom, 12)
        }
        .scrollIndicators(.never)
        .safeAreaInset(edge: .bottom, spacing: 0) { ProfileRow(me: me) }
        .onAppear {
            // open the module you're working in
            if expanded.isEmpty, let cur = modules.first(where: { $0.unlocked && !$0.complete }) { expanded = [cur.id] }
        }
        .onChange(of: nav.selection) { _, r in
            if case .topic(let tid) = r, let m = modules.first(where: { $0.module.topics.contains(tid) }) { expanded.insert(m.id) }
            if case .boss(let mid) = r { expanded.insert(mid) }
        }
    }

    private func group(_ title: String, @ViewBuilder _ rows: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased()).font(.system(size: 10.5, weight: .semibold)).tracking(0.8).foregroundStyle(.muted.opacity(0.8))
                .padding(.horizontal, 10).padding(.bottom, 4)
            rows()
        }
    }

    private func row(_ r: Route, _ title: String, _ icon: String, count: Int = 0) -> some View {
        SidebarRow(title: title, icon: icon, active: nav.selection == r, count: count) { nav.go(r) }
    }

    @ViewBuilder
    private func moduleRows(_ m: ModuleView) -> some View {
        let open = expanded.contains(m.id)
        let done = m.topics.filter(\.status.complete).count
        Button {
            withAnimation(.snappy(duration: 0.2)) { if open { expanded.remove(m.id) } else { expanded.insert(m.id) } }
        } label: {
            HStack(spacing: 8) {
                Text(String(format: "%02d", m.module.number))
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(m.complete ? Color.success : m.unlocked ? Color.brand : Color.muted)
                    .frame(width: 18, alignment: .leading)
                Text(m.module.title).lineLimit(1).foregroundStyle(m.unlocked ? .primary : Color.muted)
                Spacer(minLength: 4)
                if m.unlocked {
                    Text("\(done)/\(m.topics.count)").font(.caption2.monospacedDigit()).foregroundStyle(.muted)
                } else {
                    Image(systemName: "lock.fill").font(.system(size: 9)).foregroundStyle(.muted.opacity(0.7))
                }
                Image(systemName: "chevron.right").font(.system(size: 9, weight: .semibold)).foregroundStyle(.muted)
                    .rotationEffect(.degrees(open ? 90 : 0))
            }
            .font(.callout)
            .padding(.horizontal, 10).frame(height: 28)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)

        if open {
            VStack(alignment: .leading, spacing: 1) {
                ForEach(m.topics) { t in
                    SidebarRow(title: t.topic.title, icon: t.status.complete ? "checkmark.circle.fill"
                               : t.status.lessonDone || t.status.solved > 0 ? "circle.dashed" : "circle",
                               iconTint: t.status.complete ? .success : nil, active: nav.selection == .topic(t.id),
                               dim: !t.topic.ready, small: true) { nav.go(.topic(t.id)) }
                }
                SidebarRow(title: "Boss fight", icon: "figure.fencing", iconTint: m.complete ? .warning : nil,
                           active: nav.selection == .boss(m.id), dim: !m.complete, small: true) { nav.go(.boss(m.id)) }
            }
            .padding(.leading, 14)
            .overlay(alignment: .leading) { Rectangle().fill(.hairline).frame(width: 1).padding(.leading, 18).padding(.vertical, 4) }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
}

/// A nav row: teal icon + raised background when active, muted otherwise, teal count pill.
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
                    .fontWeight(active ? .medium : .regular)
                Spacer(minLength: 4)
                if count > 0 {
                    Text("\(count)").font(.system(size: 11, weight: .semibold).monospacedDigit()).foregroundStyle(.brand)
                        .padding(.horizontal, 6).padding(.vertical, 1)
                        .background(Color.brand.opacity(0.15), in: .capsule)
                }
            }
            .font(small ? .callout : .body)
            .padding(.horizontal, 10).frame(height: small ? 26 : 30)
            .background(active ? AnyShapeStyle(.raised) : hover ? AnyShapeStyle(Color.raised.opacity(0.5)) : AnyShapeStyle(.clear),
                        in: .rect(cornerRadius: 8, style: .continuous))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .onHover { hover = $0 }
    }
}

/// Today's ring and minutes, the day streak, and this week's goal days.
private struct TodayPanel: View {
    @Environment(Activity.self) private var activity
    let me: Me

    var body: some View {
        let secs = me.streak.todaySeconds + activity.pending
        let goal = Streak.dailyGoal
        // today joins the streak the moment the live ring fills
        let streak = me.streak.dayStreak + (!me.streak.todayDone && secs >= goal ? 1 : 0)
        let week = min(Streak.daysPerWeek, me.streak.thisWeekDays)
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Ring(pct: Double(secs) / Double(goal), size: 30, lineWidth: 4, label: false)
                Text("\(Text("\(secs / 60)").fontWeight(.semibold))\(Text(" / \(goal / 60) min").foregroundStyle(.muted))")
                    .font(.callout.monospacedDigit())
                Spacer()
                Label("\(streak)", systemImage: "flame.fill")
                    .labelStyle(.titleAndIcon)
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .foregroundStyle(streak > 0 ? Color.warning : Color.muted)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background((streak > 0 ? Color.warning : Color.raised).opacity(streak > 0 ? 0.12 : 1), in: .capsule)
                    .help("Day streak")
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("This week").foregroundStyle(.muted)
                    Spacer()
                    Text("\(Text("\(week)").fontWeight(.medium))\(Text(" / \(Streak.daysPerWeek) days").foregroundStyle(.muted))").monospacedDigit()
                }
                .font(.caption)
                HStack(spacing: 4) {
                    ForEach(0..<Streak.daysPerWeek, id: \.self) { i in
                        Capsule().fill(i < week ? Color.success : Color.raised).frame(height: 4)
                    }
                }
            }
        }
        .padding(12)
        .background(.surface.opacity(0.7), in: .rect(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(.hairline))
    }
}

/// Avatar, name and level; opens Settings.
private struct ProfileRow: View {
    @Environment(\.openSettings) private var openSettings
    let me: Me
    @State private var hover = false

    var body: some View {
        Button { openSettings() } label: {
            HStack(spacing: 10) {
                Text(String(me.username.prefix(1)).uppercased())
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.brandInk)
                    .frame(width: 32, height: 32)
                    .background(LinearGradient(colors: [.warning, .brand], startPoint: .topLeading, endPoint: .bottomTrailing), in: .circle)
                VStack(alignment: .leading, spacing: 1) {
                    Text(me.username).font(.callout.weight(.medium)).lineLimit(1)
                    Text("Lv \(me.level.level) · \(me.level.title)").font(.caption).foregroundStyle(.muted).lineLimit(1)
                }
                Spacer()
                Image(systemName: "gearshape").foregroundStyle(hover ? .primary : Color.muted)
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
            .background(hover ? Color.raised.opacity(0.6) : .clear, in: .rect(cornerRadius: 10, style: .continuous))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .onHover { hover = $0 }
        .help("Settings (⌘,)")
        .padding(10)
        .overlay(alignment: .top) { Rectangle().fill(.hairline).frame(height: 1) }
    }
}
