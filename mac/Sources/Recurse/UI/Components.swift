import SwiftUI

extension Difficulty {
    var color: Color {
        switch self {
        case .easy: .success
        case .medium: .warning
        case .hard: .danger
        }
    }
    var short: String { self == .medium ? "Med" : rawValue }
}

struct DifficultyBadge: View {
    let d: Difficulty?
    var body: some View {
        if let d {
            Text(d.rawValue).font(.caption.weight(.medium)).foregroundStyle(d.color)
                .padding(.horizontal, 7).padding(.vertical, 2)
                .background(d.color.opacity(0.12), in: .capsule)
        }
    }
}

struct StatusIcon: View {
    let status: String
    var body: some View {
        let done = Store.isSolved(status), started = status == "in-progress"
        Image(systemName: done ? "checkmark.circle.fill" : started ? "circle.dashed" : "circle")
            .foregroundStyle(done ? Color.success : started ? Color.brand : Color.secondary.opacity(0.5))
    }
}

struct Ring: View {
    let pct: Double
    var size: CGFloat = 64
    var lineWidth: CGFloat = 5
    var label = true
    var body: some View {
        let done = pct >= 1
        ZStack {
            Circle().stroke(.quaternary, lineWidth: lineWidth)
            Circle().trim(from: 0, to: min(1, pct))
                .stroke(AngularGradient(colors: done ? [.success.opacity(0.75), .success, .success.opacity(0.75)] : [.brand.opacity(0.55), .brand, Color(hex: 0x7ad6c9), .brand.opacity(0.55)], center: .center),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            if !label {} else if done { Image(systemName: "checkmark").font(.system(size: size * 0.28, weight: .bold)).foregroundStyle(.success) }
            else { Text("\(Int(pct * 100))%").font(.system(size: size * 0.22, weight: .semibold, design: .rounded).monospacedDigit()) }
        }
        .frame(width: size, height: size)
        .animation(.easeOut, value: pct)
    }
}

extension View {
    func card(padding: CGFloat = 16) -> some View {
        self.padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .surface()
    }

    /// The solid card look used across the app: surface fill, hairline border, 14pt continuous corners.
    /// `clip` for cards whose rows or hover fills run edge to edge.
    @ViewBuilder
    func surface(clip: Bool = false, border: Color = .hairline) -> some View {
        let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)
        if clip {
            background(.surface, in: shape).clipShape(shape).overlay(shape.strokeBorder(border))
        } else {
            background(.surface, in: shape).overlay(shape.strokeBorder(border))
        }
    }

}

struct Backdrop: View {
    let tint: Color
    var body: some View {
        MeshGradient(width: 3, height: 2, points: [[0, 0], [0.5, 0], [1, 0], [0, 1], [0.6, 1], [1, 1]], colors: [
            tint.opacity(0.22), tint.opacity(0.1), Color(hex: 0x7aa2f7).opacity(0.1),
            .clear, .clear, .clear,
        ])
        .mask(LinearGradient(colors: [.black, .black.opacity(0)], startPoint: .top, endPoint: .bottom))
        .allowsHitTesting(false)
    }
}

struct SectionHeader: View {
    let n: Int
    let title: String
    let done: Bool
    var subtitle: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(done ? Color.success.opacity(0.15) : Color.primary.opacity(0.06))
                    if done { Image(systemName: "checkmark").font(.caption.bold()).foregroundStyle(.success) }
                    else { Text("\(n)").font(.caption.weight(.semibold).monospacedDigit()).foregroundStyle(.secondary) }
                }
                .frame(width: 24, height: 24)
                Text(title).font(.title2.weight(.semibold))
            }
            if let subtitle { Text(subtitle).font(.callout).foregroundStyle(.secondary).padding(.leading, 34) }
        }
    }
}

struct StatCard: View {
    let label: String
    let tint: Color
    let value, total: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(label).font(.callout.weight(.medium)).foregroundStyle(.secondary)
                Spacer()
                Text("\(value)\(Text(" / \(total)").foregroundStyle(.muted))")
                    .font(.system(.title3, design: .rounded).weight(.semibold)).monospacedDigit()
            }
            ProgressView(value: Double(value), total: Double(max(1, total))).tint(tint)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .surface()
    }
}

struct ProblemRow: View {
    @Environment(Nav.self) private var nav
    let p: TopicProblem

    var body: some View {
        HoverButton(enabled: p.available) { nav.go(.problem(p.id)) } label: { hover in
            HStack(spacing: 10) {
                StatusIcon(status: p.status).font(.system(size: 12))
                Text(p.title).font(.system(size: 13)).lineLimit(1)
                    .foregroundStyle(p.available ? Color.primary.opacity(0.85) : Color.muted)
                if p.role != .core { Text(p.role.rawValue.capitalized).font(.caption2.weight(.medium)).foregroundStyle(.muted) }
                Spacer(minLength: 8)
                if !p.available { Image(systemName: "lock").font(.system(size: 9)).foregroundStyle(.muted) }
                if let d = p.difficulty { Text(d.short).font(.system(size: 11, weight: .medium)).foregroundStyle(d.color) }
            }
            .padding(.horizontal, 8).frame(height: 28)
            .background(hover ? Color.hover : .clear, in: .rect(cornerRadius: 7, style: .continuous))
        }
    }
}

extension Array {
    subscript(safe i: Int) -> Element? { indices.contains(i) ? self[i] : nil }
}

func fmtClock(_ s: Int) -> String {
    let s = max(0, s)
    return s >= 3600 ? String(format: "%d:%02d:%02d", s / 3600, s / 60 % 60, s % 60) : String(format: "%d:%02d", s / 60, s % 60)
}

func scoreTone(_ s: Int) -> Color { s >= 4 ? .success : s >= 3 ? .warning : .danger }

func days(_ n: Int) -> String { n == 1 ? "1 day" : "\(n) days" }

struct SheetID: Identifiable { let id: Int }

func short(_ iso: String) -> String { Dates.fromIso(iso)?.formatted(.dateTime.day().month()) ?? "" }
