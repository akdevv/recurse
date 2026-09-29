import AppKit
import SwiftUI

/// Python editor: NSTextView with highlighting, 4-space tabs and auto-indent.
struct CodeEditor: NSViewRepresentable {
    @Binding var text: String

    static let font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> NSScrollView {
        let scroll = NSTextView.scrollableTextView()
        let tv = scroll.documentView as! NSTextView
        tv.delegate = context.coordinator
        tv.font = Self.font
        tv.isRichText = false
        tv.allowsUndo = true
        tv.isAutomaticQuoteSubstitutionEnabled = false
        tv.isAutomaticDashSubstitutionEnabled = false
        tv.isAutomaticTextReplacementEnabled = false
        tv.isAutomaticSpellingCorrectionEnabled = false
        tv.isContinuousSpellCheckingEnabled = false
        tv.smartInsertDeleteEnabled = false
        tv.textContainerInset = NSSize(width: 8, height: 10)
        tv.drawsBackground = false
        scroll.drawsBackground = false
        // no soft wrap: code reads better scrolled
        tv.isHorizontallyResizable = true
        tv.textContainer?.widthTracksTextView = false
        tv.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
        scroll.hasHorizontalScroller = true
        let para = NSMutableParagraphStyle()
        para.lineSpacing = 3
        tv.defaultParagraphStyle = para
        tv.typingAttributes = [.font: Self.font, .foregroundColor: NSColor.labelColor, .paragraphStyle: para]
        tv.string = text
        context.coordinator.highlight(tv)
        let ruler = LineNumbers(textView: tv)
        scroll.verticalRulerView = ruler
        scroll.hasVerticalRuler = true
        scroll.rulersVisible = true
        return scroll
    }

    func updateNSView(_ scroll: NSScrollView, context: Context) {
        let tv = scroll.documentView as! NSTextView
        context.coordinator.parent = self
        if tv.string != text {
            tv.string = text
            context.coordinator.highlight(tv)
        }
    }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CodeEditor
        init(_ p: CodeEditor) { parent = p }

        func textDidChange(_ n: Notification) {
            let tv = n.object as! NSTextView
            parent.text = tv.string
            highlight(tv)
            tv.enclosingScrollView?.verticalRulerView?.needsDisplay = true
        }

        func highlight(_ tv: NSTextView) {
            guard let storage = tv.textStorage else { return }
            let s = tv.string
            storage.beginEditing()
            let all = NSRange(location: 0, length: storage.length)
            storage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: all)
            storage.addAttribute(.font, value: CodeEditor.font, range: all)
            for (r, k) in Python.spans(s) {
                storage.addAttribute(.foregroundColor, value: Python.color(k), range: NSRange(r, in: s))
            }
            storage.endEditing()
        }

        func textView(_ tv: NSTextView, doCommandBy sel: Selector) -> Bool {
            if sel == #selector(NSResponder.insertTab(_:)) {
                tv.insertText("    ", replacementRange: tv.selectedRange())
                return true
            }
            if sel == #selector(NSResponder.insertNewline(_:)) {
                // keep the current line's indent, one more level after a ':'
                let ns = tv.string as NSString
                let line = ns.substring(with: ns.lineRange(for: NSRange(location: tv.selectedRange().location, length: 0)))
                var indent = String(line.prefix { $0 == " " })
                let head = line.trimmingCharacters(in: .newlines)
                if head.trimmingCharacters(in: .whitespaces).hasSuffix(":") { indent += "    " }
                tv.insertText("\n" + indent, replacementRange: tv.selectedRange())
                return true
            }
            if sel == #selector(NSResponder.deleteBackward(_:)) {
                // backspace in leading whitespace removes a whole indent level
                let r = tv.selectedRange()
                let ns = tv.string as NSString
                let lineStart = ns.lineRange(for: NSRange(location: r.location, length: 0)).location
                let before = ns.substring(with: NSRange(location: lineStart, length: r.location - lineStart))
                if r.length == 0, !before.isEmpty, before.allSatisfy({ $0 == " " }) {
                    let n = before.count % 4 == 0 ? 4 : before.count % 4
                    tv.insertText("", replacementRange: NSRange(location: r.location - n, length: n))
                    return true
                }
            }
            return false
        }
    }
}

/// Gutter with line numbers (tracebacks point at them).
final class LineNumbers: NSRulerView {
    private let font = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)

    init(textView: NSTextView) {
        super.init(scrollView: textView.enclosingScrollView, orientation: .verticalRuler)
        clientView = textView
        ruleThickness = 36
        // repaint while scrolling
        textView.enclosingScrollView?.contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(forName: NSView.boundsDidChangeNotification, object: textView.enclosingScrollView?.contentView,
                                               queue: .main) { [weak self] _ in MainActor.assumeIsolated { self?.needsDisplay = true } }
    }

    required init(coder: NSCoder) { fatalError() }

    override func draw(_ dirtyRect: NSRect) { drawHashMarksAndLabels(in: dirtyRect) } // no ruler chrome, just numbers

    override func drawHashMarksAndLabels(in _: NSRect) {
        guard let tv = clientView as? NSTextView, let lm = tv.layoutManager, let tc = tv.textContainer else { return }
        let ns = tv.string as NSString
        let visible = lm.characterRange(forGlyphRange: lm.glyphRange(forBoundingRect: tv.visibleRect, in: tc), actualGlyphRange: nil)
        var line = ns.substring(to: visible.location).reduce(1) { $1 == "\n" ? $0 + 1 : $0 }
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.tertiaryLabelColor]
        let draw = { (n: Int, fragmentY: CGFloat, height: CGFloat) in
            let y = self.convert(NSPoint(x: 0, y: fragmentY + tv.textContainerOrigin.y), from: tv).y
            let s = NSAttributedString(string: "\(n)", attributes: attrs)
            s.draw(at: NSPoint(x: self.ruleThickness - s.size().width - 8, y: y + (height - s.size().height) / 2 - 1.5))
        }
        var i = visible.location
        while i < NSMaxRange(visible) || (i == visible.location && ns.length == 0) {
            let lr = ns.lineRange(for: NSRange(location: i, length: 0))
            if ns.length > 0 {
                let r = lm.lineFragmentRect(forGlyphAt: lm.glyphIndexForCharacter(at: lr.location), effectiveRange: nil)
                draw(line, r.minY, r.height)
            }
            line += 1
            if NSMaxRange(lr) <= i { break }
            i = NSMaxRange(lr)
        }
        // the empty line after a trailing newline (where the cursor sits after Enter)
        if ns.length == 0 || (ns.hasSuffix("\n") && NSMaxRange(visible) == ns.length) {
            let r = lm.extraLineFragmentRect
            draw(line, r.minY, max(r.height, 17))
        }
    }
}
