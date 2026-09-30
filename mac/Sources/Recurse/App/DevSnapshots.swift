// Dev check of the real UI, no Screen Recording permission needed (an app may capture its own windows):
//   RECURSE_SNAPSHOT=<dir> RECURSE_ROUTES="today,today@scroll,review@reveal,topic:x,problem:y,rewards:trophies"
// For each route: <n>-<route>.png (the composited window, glass included) and <n>-<route>-toolbar.txt
// (header items and their frames). "@reveal" presses ⌘↵ first, "@scroll" (or "@y<offset>") scrolls the page down. Quits when done.
import AppKit
import ScreenCaptureKit
import SwiftUI

@MainActor
enum DevSnapshots {
    static var problemTab: String?

    static func run(nav: Nav, store: Store, activity: Activity) async {
        let env = ProcessInfo.processInfo.environment
        guard let dir = env["RECURSE_SNAPSHOT"] else { return }
        // RECURSE_SIZE=1400x900: a bigger window, wide enough to show the sidebar
        if let size = env["RECURSE_SIZE"]?.split(separator: "x").compactMap({ Double($0) }), size.count == 2,
           let w = NSApp.windows.first(where: { $0.isVisible && $0.toolbar != nil }) {
            w.setContentSize(NSSize(width: size[0], height: size[1]))
            // collapsed sidebar: its toolbar button says "Show Sidebar"
            if w.toolbar?.items.contains(where: { $0.label == "Show Sidebar" }) == true {
                NSApp.sendAction(#selector(NSSplitViewController.toggleSidebar(_:)), to: nil, from: nil)
            }
        }
        for (i, spec) in (env["RECURSE_ROUTES"] ?? "today").split(separator: ",").enumerated() {
            // "@y2400" scrolls to that offset; "@scroll" is @y360
            let offset = spec.firstMatch(of: /@y(\d+)/).flatMap { Double($0.output.1) } ?? (spec.contains("@scroll") ? 360 : nil)
            let scroll = offset != nil, reveal = spec.contains("@reveal")
            let parts = spec.replacing(/@y\d+/, with: "").replacingOccurrences(of: "@scroll", with: "").replacingOccurrences(of: "@reveal", with: "").replacingOccurrences(of: "@open", with: "")
                .split(separator: ":", maxSplits: 1).map(String.init)
            switch parts[0] {
            case "review": nav.go(.review)
            case "course": nav.go(.course)
            case "problems": nav.go(.problems)
            case "patterns": nav.go(.patterns)
            case "stats": nav.go(.stats)
            case "rewards":
                UserDefaults.standard.set(parts.count > 1 ? parts[1] : "path", forKey: "rewardsTab")
                nav.go(.rewards)
            case "boss": nav.go(.boss(parts[1]))
            case "topic": nav.go(.topic(parts[1]))
            case "back": nav.back()
            case "forward": nav.forward()
            case "swipe": // swipe:0.4 freezes a back swipe that far along
                NotificationCenter.default.post(name: .devSwipe, object: CGFloat(Double(parts[1]) ?? 0.5))
            case "problem": // problem:<id>:<tab> opens it on that tab (statement, hints, tutor, solutions, submissions)
                let bits = parts[1].split(separator: ":").map(String.init)
                problemTab = bits.count > 1 ? bits[1] : nil
                nav.go(.problem(bits[0]))
            case "settings": // the ⌘, window; settings:<tab> picks its tab
                UserDefaults.standard.set(parts.count > 1 ? parts[1] : "general", forKey: "settingsTab")
                if let appMenu = NSApp.mainMenu?.items.first?.submenu,
                   let i = appMenu.items.firstIndex(where: { $0.keyEquivalent == "," }) { appMenu.performActionForItem(at: i) }
            case "menubar": // <n>-menubar-item.png: the item in a mock menu bar. Its menu can't be captured: opening it
                // tracks modally and nothing else runs until it closes
                let bar = HStack(spacing: 14) {
                    HStack(spacing: 4) { MenuBarLabel() }
                    Image(systemName: "wifi")
                    Image(systemName: "battery.75percent")
                    Image(systemName: "switch.2")
                    Text("Thu 1 Oct  10:42")
                }
                .font(.system(size: 13, weight: .medium)).foregroundStyle(.white)
                .padding(.horizontal, 14).frame(height: 30)
                .background(Color(white: 0.16))
                .environment(store).environment(activity)
                let renderer = ImageRenderer(content: bar)
                renderer.scale = 3
                if let cg = renderer.cgImage {
                    try? NSBitmapImageRep(cgImage: cg).representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: "\(dir)/\(i)-menubar-item.png"))
                }
            case "chest": // the opening sheet for the first unopened chest; "chest@open" also opens it
                nav.go(.rewards)
                if let c = store.chests().first(where: { $0.openedAt == nil }) { store.chestQueue = [c.id] }
            default: nav.go(.today)
            }
            try? await Task.sleep(for: .seconds(2))
            let settings = parts[0] == "settings"
            guard let window = NSApp.windows.first(where: {
                $0.isVisible && (settings ? $0.identifier?.rawValue.contains("Settings") == true : $0.toolbar != nil && $0.identifier?.rawValue.contains("Settings") != true)
            }) else { continue }
            if reveal, let e = NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: .command, timestamp: 0,
                                                windowNumber: window.windowNumber, context: nil, characters: "\r",
                                                charactersIgnoringModifiers: "\r", isARepeat: false, keyCode: 36) {
                window.performKeyEquivalent(with: e)
                try? await Task.sleep(for: .seconds(1))
            }
            if spec.contains("@open"), let sheet = window.attachedSheet,
               let e = NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: [], timestamp: 0, windowNumber: sheet.windowNumber,
                                        context: nil, characters: "\r", charactersIgnoringModifiers: "\r", isARepeat: false, keyCode: 36) {
                sheet.performKeyEquivalent(with: e)
                try? await Task.sleep(for: .seconds(1.5))
            }
            if scroll, let sv = largestScrollView(in: window.contentView) {
                let end = max(0, (sv.documentView?.frame.height ?? 0) - sv.contentView.bounds.height)
                sv.contentView.scroll(to: NSPoint(x: 0, y: min(offset ?? 360, end)))
                sv.reflectScrolledClipView(sv.contentView)
                try? await Task.sleep(for: .seconds(1))
            }
            let name = "\(i)-\(parts[0])\(reveal ? "-revealed" : "")\(spec.contains("@open") ? "-opened" : "")\(offset.map { "-y\(Int($0))" } ?? "")"
            dumpToolbar(window, to: "\(dir)/\(name)-toolbar.txt")
            await capture(window, to: URL(fileURLWithPath: dir).appending(path: "\(name).png"))
            if parts[0] == "chest" { store.chestQueue = [] }
            if settings { window.close() }
        }
        // what the widget reads (its container is off-limits to other processes)
        if let w = WidgetSnapshot.load(), let data = try? JSONEncoder().encode(w) { try? data.write(to: URL(fileURLWithPath: "\(dir)/widget.json")) }
        NSApp.terminate(nil)
    }

    private static func largestScrollView(in view: NSView?) -> NSScrollView? {
        guard let view else { return nil }
        var best = view as? NSScrollView
        for sub in view.subviews {
            if let s = largestScrollView(in: sub), s.frame.height * s.frame.width > (best.map { $0.frame.height * $0.frame.width } ?? 0) { best = s }
        }
        return best
    }

    private static func dumpToolbar(_ window: NSWindow, to path: String) {
        guard let tb = window.toolbar else { return }
        let lines = tb.items.map { item -> String in
            let view = (item as? NSSearchToolbarItem)?.searchField ?? item.view
            return "\(item.itemIdentifier.rawValue) frame=\(view.map { NSStringFromRect($0.convert($0.bounds, to: nil)) } ?? "-") label=\(item.label)"
        }
        try? (["window=\(NSStringFromSize(window.frame.size))"] + lines).joined(separator: "\n").write(toFile: path, atomically: true, encoding: .utf8)
    }

    private static func capture(_ window: NSWindow, to url: URL) async {
        do {
            let content = try await SCShareableContent.currentProcess
            guard let w = content.windows.first(where: { $0.windowID == CGWindowID(window.windowNumber) }) else { return }
            let config = SCStreamConfiguration()
            config.width = Int(w.frame.width * 2)
            config.height = Int(w.frame.height * 2)
            config.showsCursor = false
            let image = try await SCScreenshotManager.captureImage(contentFilter: SCContentFilter(desktopIndependentWindow: w), configuration: config)
            try NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:])?.write(to: url)
        } catch {
            try? "capture failed: \(error)".write(to: url.appendingPathExtension("txt"), atomically: true, encoding: .utf8)
        }
    }
}
