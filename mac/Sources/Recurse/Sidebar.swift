// Sidebar in the web app's layout (today panel, grouped nav, profile row), on the system glass sidebar.
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

    private func row(_ r: Route, _ title: String, _ icon: String, count: Int = 0) -> some View {
        // topics and boss fights live under Course
        let inCourse = switch nav.selection { case .topic, .boss: true; default: false }
        return SidebarRow(title: title, icon: icon, active: nav.selection == r || (r == .course && inCourse), count: count) { nav.go(r) }
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

/// Avatar, name and level; opens Settings. A solid card so it doesn't float on the glass.
private struct ProfileRow: View {
    @Environment(\.openSettings) private var openSettings
    let me: Me
    @State private var hover = false

    var body: some View {
        Button { openSettings() } label: {
            HStack(spacing: 10) {
                Avatar(size: 34)
                VStack(alignment: .leading, spacing: 1) {
                    Text(me.username).font(.callout.weight(.semibold)).lineLimit(1)
                    Text("Lv \(me.level.level) · \(me.level.title)").font(.caption).foregroundStyle(.muted).lineLimit(1)
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

/// The web app's avatar.svg (gold face with glasses on dark teal), drawn natively on its 36×36 grid.
struct Avatar: View {
    var size: CGFloat = 32

    var body: some View {
        Canvas { ctx, sz in
            ctx.scaleBy(x: sz.width / 36, y: sz.height / 36)
            let ink = Color(hex: 0x0b0f11), blue = Color(hex: 0x7aa2f7)
            func about(_ deg: Double) -> CGAffineTransform {
                CGAffineTransform(translationX: -18, y: -18).concatenating(.init(rotationAngle: deg * .pi / 180)).concatenating(.init(translationX: 18, y: 18))
            }
            ctx.fill(Path(CGRect(x: 0, y: 0, width: 36, height: 36)), with: .color(Color(hex: 0x0f2a27)))
            ctx.fill(Path(ellipseIn: CGRect(x: 21, y: -3, width: 18, height: 18)), with: .color(blue.opacity(0.18)))
            // face: scale, tilt 18° about the centre, shift down-right
            let face = CGAffineTransform(scaleX: 0.9, y: 0.9).concatenating(about(18)).concatenating(.init(translationX: 5, y: 8))
            ctx.fill(Path(roundedRect: CGRect(x: 0, y: 0, width: 36, height: 36), cornerRadius: 9).applying(face), with: .color(.warning))
            // features: tilt 9°, shift down 1
            let f = about(9).concatenating(.init(translationX: 0, y: 1))
            for x in [12.3, 23.7] {
                ctx.fill(Path(ellipseIn: CGRect(x: x - 1.3, y: 18.7, width: 2.6, height: 2.6)).applying(f), with: .color(blue.opacity(0.45)))
            }
            for x in [13.5, 20.5] {
                ctx.fill(Path(roundedRect: CGRect(x: x, y: 15, width: 2, height: 3), cornerRadius: 1).applying(f), with: .color(ink))
            }
            var glasses = Path()
            glasses.addEllipse(in: CGRect(x: 11.6, y: 13.6, width: 5.8, height: 5.8))
            glasses.addEllipse(in: CGRect(x: 18.6, y: 13.6, width: 5.8, height: 5.8))
            glasses.move(to: CGPoint(x: 17.4, y: 16.5))
            glasses.addLine(to: CGPoint(x: 18.6, y: 16.5))
            ctx.stroke(glasses.applying(f), with: .color(ink), lineWidth: 1)
            var smile = Path()
            smile.move(to: CGPoint(x: 14.5, y: 21.5))
            smile.addCurve(to: CGPoint(x: 21.5, y: 21.5), control1: CGPoint(x: 16.1, y: 23.5), control2: CGPoint(x: 19.9, y: 23.5))
            ctx.stroke(smile.applying(f), with: .color(ink), style: StrokeStyle(lineWidth: 1.3, lineCap: .round))
        }
        .frame(width: size, height: size)
        .clipShape(.circle)
        .overlay(Circle().strokeBorder(.hairline))
    }
}
