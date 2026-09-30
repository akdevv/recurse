import AppKit
import SwiftUI

struct MenuBarLabel: View {
    @Environment(Store.self) private var store
    @Environment(Activity.self) private var activity

    var body: some View {
        let (secs, done, streak) = store.me().today(pending: activity.pending)
        Image(nsImage: Self.ring(Double(secs) / Double(Streak.dailyGoal), done: done)).renderingMode(.template)
        Text("\(secs / 60)m  \(Image(systemName: "flame.fill")) \(streak)").monospacedDigit()
    }

    /// A template image, so the menu bar tints it for light/dark and highlights it like the system's own items.
    private static func ring(_ pct: Double, done: Bool) -> NSImage {
        let image = NSImage(size: NSSize(width: 16, height: 16), flipped: false) { r in
            let rect = r.insetBy(dx: 1.75, dy: 1.75), c = NSPoint(x: rect.midX, y: rect.midY)
            let track = NSBezierPath(ovalIn: rect)
            track.lineWidth = 2.5
            NSColor.black.withAlphaComponent(0.3).setStroke()
            track.stroke()
            NSColor.black.setStroke()
            if pct > 0 {
                let arc = NSBezierPath()
                arc.appendArc(withCenter: c, radius: rect.width / 2, startAngle: 90, endAngle: 90 - 360 * min(pct, 1), clockwise: true)
                arc.lineWidth = 2.5
                arc.lineCapStyle = .round
                arc.stroke()
            }
            if done {
                let check = NSBezierPath()
                check.move(to: NSPoint(x: c.x - 2.6, y: c.y))
                check.line(to: NSPoint(x: c.x - 0.6, y: c.y - 2))
                check.line(to: NSPoint(x: c.x + 2.8, y: c.y + 2.2))
                check.lineWidth = 1.6
                check.lineCapStyle = .round
                check.lineJoinStyle = .round
                check.stroke()
            }
            return true
        }
        image.isTemplate = true
        return image
    }
}

struct MenuBarMenu: View {
    @Environment(Store.self) private var store
    @Environment(Activity.self) private var activity
    @Environment(Nav.self) private var nav
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        let me = store.me()
        let (secs, done, streak) = me.today(pending: activity.pending)
        let goal = Streak.dailyGoal / 60
        let next = store.nextAction(store.moduleViews(), reviews: false)

        Text(done ? "\(secs / 60) min today · goal done" : "\(secs / 60) of \(goal) min today · \(goal - secs / 60) to go")
        Text("\(streak)-day streak")
        Divider()
        Button { open(next.route) } label: {
            Label(next.kind == .browse ? "Browse the Course" : "\(verb(next.kind)): \(next.title)", systemImage: icon(next.kind))
        }
        .keyboardShortcut("l")
        if me.reviewsDue > 0 {
            Button { open(.review) } label: {
                Label("Review · \(me.reviewsDue) due", systemImage: "arrow.counterclockwise")
            }
            .keyboardShortcut("r")
        }
        Divider()
        Button("Open Recurse") { open(nil) }.keyboardShortcut("o")
        Button("Settings…") {
            NSApp.activate()
            openSettings()
        }
        .keyboardShortcut(",")
        Divider()
        Button("Quit Recurse") { NSApp.terminate(nil) }.keyboardShortcut("q")
    }

    private func verb(_ k: NextAction.Kind) -> String {
        switch k {
        case .learn: "Learn"
        case .solve: "Solve"
        case .finish, .review, .browse: "Continue"
        }
    }

    private func icon(_ k: NextAction.Kind) -> String {
        switch k {
        case .learn: "book"
        case .solve: "chevron.left.forwardslash.chevron.right"
        case .finish, .review: "play.fill"
        case .browse: "map"
        }
    }

    private func open(_ route: Route?) {
        openWindow(id: "main")
        NSApp.activate()
        if let route { nav.go(route) }
    }
}
