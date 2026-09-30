import SwiftUI

struct WelcomeView: View {
    @Environment(Store.self) private var store
    @Environment(Reminders.self) private var reminders
    @State private var s = Settings()
    @State private var err = ""

    var body: some View {
        let ready = !s.name.trimmingCharacters(in: .whitespaces).isEmpty && !s.username.isEmpty
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                Text("Welcome to Recurse").font(.largeTitle.weight(.semibold))
                Text("Learn DSA one focused half hour at a time.").foregroundStyle(.secondary)
            }

            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    AvatarPicker(avatar: $s.avatar)
                    if s.avatar != nil {
                        Button("Use default") { withAnimation(.snappy) { s.avatar = nil } }
                            .buttonStyle(.plain).font(.caption).foregroundStyle(.secondary)
                    }
                }
                VStack(alignment: .leading, spacing: 12) {
                    field("Name") { TextField("", text: $s.name, prompt: Text("Your name")) }
                    field("Username") {
                        TextField("", text: Binding(get: { s.username }, set: { s.username = Settings.clean($0) }), prompt: Text("username"))
                    }
                }
                .textFieldStyle(.plain)
                Button { start() } label: { Text("Get Started").frame(maxWidth: .infinity) }
                    .buttonStyle(.glassProminent).controlSize(.extraLarge)
                    .keyboardShortcut(.defaultAction)
                    .disabled(!ready)
            }
            .padding(28)
            .frame(width: 380)
            .glassEffect(.regular, in: .rect(cornerRadius: 26, style: .continuous))

            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Text("Used Recurse before?")
                    Button("Restore a backup") { restore() }.buttonStyle(.plain).underline()
                }
                .font(.caption).foregroundStyle(.secondary)
                if !err.isEmpty { Text(err).font(.caption).foregroundStyle(.danger) }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { AmbientBackdrop(family: .ocean) }
        .toolbar(removing: .title)
        .onAppear { s = store.settings() }
    }

    private func field(_ label: String, @ViewBuilder _ input: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label).font(.caption.weight(.medium)).foregroundStyle(.secondary)
            input()
                .padding(.horizontal, 12).frame(height: 36)
                .background(Color.canvas.opacity(0.55), in: .rect(cornerRadius: 10, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(.hairline))
        }
    }

    private func start() {
        s.name = s.name.trimmingCharacters(in: .whitespaces)
        store.saveSettings(s)
        store.tourPending = true
    }

    /// A backup without a name (an old one) stays here with its details filled in.
    private func restore() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.data]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try store.importData(from: url)
            reminders.schedule()
            s = store.settings()
            err = ""
        } catch { err = error.localizedDescription }
    }
}

private struct AvatarPicker: View {
    @Binding var avatar: Data?
    @State private var hover = false

    var body: some View {
        Button { if let png = PhotoButtons.pick() { withAnimation(.snappy) { avatar = png } } } label: {
            Avatar(size: 96, image: avatar)
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(width: 30, height: 30)
                        .glassEffect(.regular.interactive(), in: .circle)
                        .offset(x: 2, y: 2)
                }
                .scaleEffect(hover ? 1.03 : 1)
                .animation(.snappy(duration: 0.2), value: hover)
        }
        .buttonStyle(.plain)
        .onHover { hover = $0 }
        .help(avatar == nil ? "Choose a photo" : "Change photo")
    }
}
