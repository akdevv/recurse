// Recurse palette: the web app's tokens (web/src/index.css). Dark only, like the web.
import AppKit
import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(red: Double(hex >> 16 & 0xff) / 255, green: Double(hex >> 8 & 0xff) / 255, blue: Double(hex & 0xff) / 255)
    }
}

extension ShapeStyle where Self == Color {
    static var brand: Color { Color(hex: 0x3fbfae) } // --primary (teal)
    static var brandInk: Color { Color(hex: 0x06201c) } // --primary-foreground
    static var success: Color { Color(hex: 0x8ccb6e) }
    static var warning: Color { Color(hex: 0xd9bc5e) }
    static var danger: Color { Color(hex: 0xe0707a) }

    static var canvas: Color { Color(hex: 0x0b0f11) } // --background
    static var surface: Color { Color(hex: 0x12171a) } // --card
    static var raised: Color { Color(hex: 0x192024) } // --secondary
    static var hover: Color { Color(hex: 0x1f282d) } // --accent
    static var hairline: Color { Color(hex: 0x242c31) } // --border
    static var muted: Color { Color(hex: 0x86949a) } // --muted-foreground
    static var sidebarBg: Color { Color(hex: 0x0e1316) }
}

/// One Dark, like the web editor.
enum CodeColors {
    static let keyword = NSColor(Color(hex: 0xc678dd))
    static let builtin = NSColor(Color(hex: 0x56b6c2))
    static let string = NSColor(Color(hex: 0x98c379))
    static let comment = NSColor(Color(hex: 0x7f848e))
    static let number = NSColor(Color(hex: 0xd19a66))
    static let definition = NSColor(Color(hex: 0x61afef))
    static let text = NSColor(Color(hex: 0xabb2bf))
}
