import SwiftUI

struct GlassTabs: View {
    struct Tab: Identifiable {
        let id, title: String
        var icon: String?
    }
    @Binding var selection: String
    let tabs: [Tab]
    @Namespace private var ns

    var body: some View {
        GlassEffectContainer(spacing: 4) {
            HStack(spacing: 2) {
                ForEach(tabs) { t in
                    let on = selection == t.id
                    Button { withAnimation(.bouncy(duration: 0.35)) { selection = t.id } } label: {
                        Group {
                            if let icon = t.icon { Label(t.title, systemImage: icon) } else { Text(t.title) }
                        }
                        .font(.callout.weight(on ? .semibold : .regular))
                        .foregroundStyle(on ? .primary : .secondary)
                        .padding(.horizontal, 11).padding(.vertical, 6)
                        // glass on the label itself so it's drawn underneath the text; the "pill" id slides between tabs
                        .glassEffect(on ? .regular : .identity, in: .capsule)
                        .glassEffectID(on ? "pill" : t.id, in: ns)
                        .contentShape(.capsule)
                    }
                    .buttonStyle(.plain)
                    .fixedSize()
                }
            }
            .padding(3)
        }
    }
}

/// Segmented tabs with a Liquid Glass pill that lifts on press, follows a drag and settles on the nearest tab.
struct Segments: View {
    @Binding var selection: String
    let options: [(id: String, title: String)]
    var small = false
    @State private var frames: [String: CGRect] = [:]
    @State private var dragX: CGFloat?
    @State private var lifted = false

    var body: some View {
        let under = dragX.map(nearest) ?? selection
        let rest = frames[under] ?? frames[selection] ?? .zero
        let pill = dragX.map { x in
            let lo = (frames.values.map(\.minX).min() ?? 0) + rest.width / 2
            let hi = (frames.values.map(\.maxX).max() ?? 0) - rest.width / 2
            return CGRect(x: min(max(x, lo), hi) - rest.width / 2, y: rest.minY, width: rest.width, height: rest.height)
        } ?? rest

        let pad = small ? 3.0 : 4.0
        let lift = lifted ? pad - 0.5 : 0
        HStack(spacing: 2) {
            ForEach(options, id: \.id) { o in
                let on = under == o.id
                Text(o.title).font((small ? Font.caption : .callout).weight(on ? .semibold : .regular))
                    .foregroundStyle(on ? .primary : .secondary)
                    .scaleEffect(on && lifted ? 1.08 : 1)
                    .padding(.horizontal, small ? 10 : 12).frame(height: small ? 22 : 28)
                    .contentShape(.capsule)
                    .onGeometryChange(for: CGRect.self) { $0.frame(in: .named("segments")) } action: { frames[o.id] = $0 }
                    .accessibilityElement()
                    .accessibilityLabel(o.title)
                    .accessibilityAddTraits(selection == o.id ? [.isButton, .isSelected] : .isButton)
                    .accessibilityAction { selection = o.id }
            }
        }
        // the pill is a background layer: lifting it never resizes the track
        .background(alignment: .topLeading) {
            Capsule().fill(.clear)
                .frame(width: pill.width + lift * 2, height: pill.height + lift * 2)
                .glassEffect(lifted ? .clear.interactive() : .regular.tint(.white.opacity(0.1)).interactive(), in: .capsule)
                .overlay {
                    Capsule().strokeBorder(LinearGradient(colors: [.white.opacity(lifted ? 0.55 : 0), .white.opacity(lifted ? 0.08 : 0)],
                                                          startPoint: .top, endPoint: .bottom), lineWidth: 1)
                }
                .shadow(color: .black.opacity(lifted ? 0.3 : 0), radius: 4, y: 1.5)
                .offset(x: pill.minX - lift, y: pill.minY - lift)
                .opacity(frames.isEmpty ? 0 : 1)
        }
        .coordinateSpace(.named("segments"))
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named("segments"))
                .onChanged { g in
                    if dragX == nil {
                        withAnimation(.spring(duration: 0.3, bounce: 0.25)) {
                            lifted = true
                            dragX = g.location.x
                        }
                    } else {
                        withAnimation(.interactiveSpring(duration: 0.22)) { dragX = g.location.x }
                    }
                }
                .onEnded { g in
                    let id = nearest(g.location.x)
                    withAnimation(.bouncy(duration: 0.45, extraBounce: 0.15)) {
                        selection = id
                        dragX = nil
                        lifted = false
                    }
                }
        )
        .padding(small ? 3 : 4)
        .glassEffect(.regular, in: .capsule)
        .fixedSize()
    }

    private func nearest(_ x: CGFloat) -> String {
        options.min { abs((frames[$0.id]?.midX ?? 0) - x) < abs((frames[$1.id]?.midX ?? 0) - x) }?.id ?? selection
    }
}

struct FilterField: View {
    @Binding var text: String
    let prompt: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass").foregroundStyle(.muted)
            TextField(prompt, text: $text).textFieldStyle(.plain)
            if !text.isEmpty {
                Button { text = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.muted) }.buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14).frame(height: 36)
        .glassEffect(.regular, in: .capsule)
    }
}

struct ClearFiltersButton: View {
    let action: () -> Void
    var body: some View {
        Button { withAnimation(.snappy(duration: 0.25)) { action() } } label: {
            Label("Clear", systemImage: "xmark").font(.caption.weight(.medium))
                .padding(.horizontal, 10).frame(height: 26)
                .glassEffect(.regular.interactive(), in: .capsule)
                .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .help("Clear all filters")
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
}

struct TextArea: View {
    @Binding var text: String
    let placeholder: String
    var minHeight: CGFloat = 120
    var body: some View {
        TextEditor(text: $text)
            .font(.body)
            .writingToolsBehavior(.disabled)
            .scrollContentBackground(.hidden)
            .padding(10)
            .frame(minHeight: minHeight)
            .background(Color.canvas.opacity(0.55), in: .rect(cornerRadius: 10, style: .continuous))
            .overlay(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder).foregroundStyle(.muted.opacity(0.8)).padding(.horizontal, 15).padding(.vertical, 10).allowsHitTesting(false)
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(.hairline))
    }
}

/// A plain button that hands its label the hover state (for web-style row highlights).
struct HoverButton<Label: View>: View {
    var enabled = true
    let action: () -> Void
    @ViewBuilder let label: (Bool) -> Label
    @State private var hover = false

    var body: some View {
        Button(action: action) { label(hover && enabled).contentShape(.rect) }
            .buttonStyle(.plain)
            .disabled(!enabled)
            .onHover { hover = $0 }
            .animation(.easeOut(duration: 0.12), value: hover)
    }
}
