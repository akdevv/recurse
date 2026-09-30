import AppKit
import ScreenCaptureKit
import SwiftUI

/// A page as it looked: the whole window (sidebar included) and where the page sat in it (top-left origin).
struct PageShot {
    let image: NSImage
    let page: CGRect
}

/// Two-finger swipe between pages, the way Safari and NSPageController's stack-history style do it: going back,
/// the page follows your fingers off to the right, uncovering the previous one; going forward, the next page slides
/// in from the right. It runs on snapshots, so the real page only changes, hidden, once the swipe lands.
/// Uses the system's swipe tracking (springs, thresholds, and the "Swipe between pages" Trackpad setting).
struct SwipeBack: View {
    @Environment(Nav.self) private var nav
    @State private var swipe: Swipe?
    @State private var monitor: Any?

    private struct Swipe {
        let back: Bool
        var now: PageShot? // the page you're on; nothing shows until it's in hand
        let other: PageShot? // where you're going
        var amount: CGFloat = 0 // 0…1 of the way there
    }

    var body: some View {
        GeometryReader { geo in
            if let s = swipe, let now = s.now {
                let base = s.back ? s.other : now, top = s.back ? now : s.other
                let shift = s.back ? s.amount : 1 - s.amount // how far the top page is pushed right
                ZStack(alignment: .topLeading) {
                    Color.canvas
                    if let base { Image(nsImage: base.image).resizable().frame(width: geo.size.width, height: geo.size.height) }
                    Color.black.opacity(0.25 * (1 - shift)) // the page underneath sits in shade until uncovered
                    if let top {
                        crop(top, in: geo.size)
                            .shadow(color: .black.opacity(0.5 * (1 - shift)), radius: 20, x: -6)
                            .offset(x: shift * top.page.width)
                    }
                    // the snapshots' header strip holds their old toolbar; the live one sits here instead
                    LinearGradient(stops: [.init(color: .canvas, location: 0.75), .init(color: .canvas.opacity(0), location: 1)],
                                   startPoint: .top, endPoint: .bottom)
                        .frame(height: HeaderFade.header + HeaderFade.trail)
                        .padding(.leading, (base ?? now).page.minX)
                }
                .transition(.opacity)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear(perform: install)
        .onDisappear { if let monitor { NSEvent.removeMonitor(monitor) } }
        .onReceive(NotificationCenter.default.publisher(for: .devSwipe)) { n in begin(back: true, amount: n.object as? CGFloat ?? 0.5) }
    }

    /// Just the page, cut out of its window snapshot and left where it was.
    private func crop(_ shot: PageShot, in size: CGSize) -> some View {
        Image(nsImage: shot.image).resizable().frame(width: size.width, height: size.height)
            .offset(x: -shot.page.minX, y: -shot.page.minY)
            .frame(width: shot.page.width, height: shot.page.height, alignment: .topLeading)
            .clipped()
            .offset(x: shot.page.minX, y: shot.page.minY)
    }

    private func begin(back: Bool, amount: CGFloat = 0) {
        let camera = PageCamera.shared
        swipe = Swipe(back: back, now: camera.latest, other: back ? nav.backShot : nav.forwardShot, amount: amount)
        guard camera.latest == nil else { camera.paused = true; return }
        Task { // just arrived: no shot yet
            let shot = await camera.take()
            camera.paused = true
            swipe?.now = shot
        }
    }

    private func install() {
        guard monitor == nil else { return }
        monitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { e in
            guard e.phase == .began, swipe == nil, NSEvent.isSwipeTrackingFromScrollEventsEnabled,
                  abs(e.scrollingDeltaX) > abs(e.scrollingDeltaY) * 1.5,
                  !Self.scrollsHorizontally(e) else { return e }
            let toBack = e.scrollingDeltaX > 0
            guard toBack ? nav.canGoBack : nav.canGoForward else { return e }
            begin(back: toBack)
            var landed = false
            e.trackSwipeEvent(options: .lockDirection, dampenAmountThresholdMin: toBack ? 0 : -1, max: toBack ? 1 : 0) { gesture, phase, complete, _ in
                // after you let go, the system keeps calling with the amount springing to 0 or ±1
                swipe?.amount = abs(gesture)
                if phase == .ended { landed = true }
                if complete { finish(landed) }
            }
            return nil
        }
    }

    private func finish(_ landed: Bool) {
        guard let s = swipe else { return }
        guard landed else { end(); return }
        var quiet = Transaction()
        quiet.disablesAnimations = true
        withTransaction(quiet) { s.back ? nav.back() : nav.forward() }
        // the snapshot stays up while the real page (and a returning sidebar) settles underneath it
        Task {
            try? await Task.sleep(for: .milliseconds(350))
            end()
        }
    }

    private func end() {
        withAnimation(.easeOut(duration: 0.15)) { swipe = nil }
        PageCamera.shared.paused = false
        PageCamera.shared.poke()
    }

    /// Leave the gesture to content that scrolls sideways (code, wide examples, visualizations) unless it's at
    /// its left edge.
    private static func scrollsHorizontally(_ e: NSEvent) -> Bool {
        guard let window = e.window, let hit = window.contentView?.hitTest(e.locationInWindow) else { return false }
        var v: NSView? = hit
        while let view = v {
            if let sv = view as? NSScrollView, let doc = sv.documentView,
               doc.frame.width > sv.contentView.bounds.width + 1, sv.contentView.bounds.origin.x > 0 {
                return true
            }
            v = view.superview
        }
        return false
    }
}

/// Keeps a fresh snapshot of the current page, so there's one ready the moment you leave it or start a swipe.
/// ScreenCaptureKit is the only thing that draws SwiftUI's glass and layers (cacheDisplay and layer.render come
/// out blank) and it's async, so the shot is retaken shortly after things settle: a page change, resize, click, key or scroll.
@MainActor
final class PageCamera {
    static let shared = PageCamera()
    weak var nsWindow: NSWindow?
    var page: CGRect = .zero // the page area, window coordinates (top-left origin)
    private(set) var latest: PageShot?
    var paused = false // a swipe is on screen
    private var generation = 0
    private var pending: Task<Void, Never>?
    private var window: SCWindow?
    private var monitor: Any?

    func pageChanged() {
        generation += 1
        latest = nil
        poke()
    }

    func poke() {
        pending?.cancel()
        pending = Task {
            try? await Task.sleep(for: .milliseconds(600))
            guard !Task.isCancelled, let shot = await take() else { return }
            latest = shot
        }
    }

    func take() async -> PageShot? {
        guard !paused, let nsWindow, nsWindow.isVisible, let root = nsWindow.contentView else { return nil }
        let started = generation, page = page
        do {
            if window?.windowID != CGWindowID(nsWindow.windowNumber) {
                window = try await SCShareableContent.currentProcess.windows.first { $0.windowID == CGWindowID(nsWindow.windowNumber) }
            }
            guard let window else { return nil }
            let config = SCStreamConfiguration()
            config.width = Int(window.frame.width * nsWindow.backingScaleFactor)
            config.height = Int(window.frame.height * nsWindow.backingScaleFactor)
            config.showsCursor = false
            let image = try await SCScreenshotManager.captureImage(contentFilter: SCContentFilter(desktopIndependentWindow: window), configuration: config)
            guard started == generation, !paused else { return nil } // moved on (or a swipe began) mid-capture
            return PageShot(image: NSImage(cgImage: image, size: root.bounds.size), page: page)
        } catch {
            window = nil
            return nil
        }
    }

    fileprivate func watch() {
        guard monitor == nil else { return }
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp, .keyUp, .scrollWheel]) { [weak self] e in
            self?.poke()
            return e
        }
    }
}

/// Sits behind the page area and tells the camera where it is and which window it's in.
struct PageFrame: View {
    var body: some View {
        GeometryReader { geo in
            Color.clear
                .onChange(of: geo.frame(in: .global), initial: true) { _, f in
                    PageCamera.shared.page = f
                    PageCamera.shared.poke() // sidebar shown/hidden, window resized
                }
                .background(WindowProbe())
        }
    }
}

private struct WindowProbe: NSViewRepresentable {
    final class Probe: NSView {
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if let window { PageCamera.shared.nsWindow = window }
        }
    }

    func makeNSView(context _: Context) -> Probe {
        PageCamera.shared.watch()
        return Probe()
    }

    func updateNSView(_: Probe, context _: Context) {}
}

extension Notification.Name {
    static let devSwipe = Notification.Name("RecurseDevSwipe") // DevSnapshots: freeze a back swipe part way
}
