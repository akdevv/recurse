import SwiftUI

struct SettingsView: View {
    @Environment(Store.self) private var store
    @Environment(Reminders.self) private var reminders
    @State private var s = Settings()
    @State private var loaded = false
    @State private var atLogin = Reminders.openAtLogin
    @AppStorage("menuBar") private var menuBar = true
    @State private var permission = ""

    private static let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    @AppStorage("settingsTab") private var tab = "general"

    var body: some View {
        TabView(selection: $tab) {
            Tab("General", systemImage: "gearshape", value: "general") { general }
            Tab("Reminders", systemImage: "bell.badge", value: "reminders") { remindersTab }
            Tab("Rewards", systemImage: "gift", value: "rewards") { RewardsTab() }
            Tab("Data", systemImage: "externaldrive", value: "data") { DataTab { s = store.settings() } }
            Tab("Updates", systemImage: "arrow.down.circle", value: "updates") { UpdatesTab() }
        }
        .frame(width: 500)
        .onAppear {
            if !loaded { s = store.settings(); loaded = true }
            // don't open with the name field focused and its text selected
            DispatchQueue.main.async { NSApp.keyWindow?.makeFirstResponder(nil) }
        }
        .onChange(of: s) { _, new in
            guard loaded else { return }
            var new = new
            let saved = store.settings()
            if new.name.trimmingCharacters(in: .whitespaces).isEmpty { new.name = saved.name } // the name can't be cleared
            if new.username.isEmpty { new.username = saved.username }
            store.saveSettings(new)
            if new.reminders { Task { _ = await reminders.requestPermission() } }
            reminders.schedule()
        }
    }

    private var general: some View {
        let me = store.me()
        return Form {
            Section {
                HStack(spacing: 14) {
                    Avatar(size: 44, image: s.avatar).padding(2).overlay(Circle().strokeBorder(.white.opacity(0.14)))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(s.name.isEmpty ? "You" : s.name).font(.headline)
                        Text("Level \(me.level.level) · \(me.level.title) · \(me.xp) XP").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    PhotoButtons(avatar: $s.avatar)
                }
                .padding(.vertical, 4)
                TextField("Name", text: $s.name, prompt: Text("Your name"))
                TextField("Username", text: Binding(get: { s.username }, set: { s.username = Settings.clean($0) }), prompt: Text("username"))
            }

            Section {
                LabeledContent("Study days") {
                    HStack(spacing: 5) {
                        ForEach(0..<7, id: \.self) { d in DayChip(label: Self.days[d], on: dayBinding(d)) }
                    }
                }
            } footer: {
                Text("Reminders come on these days. Other days only get a couple, and only while the week can still hit 5 goal days.")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section {
                Toggle("Open Recurse at login", isOn: $atLogin)
                    .onChange(of: atLogin) { _, on in Reminders.openAtLogin = on; atLogin = Reminders.openAtLogin }
                Toggle("Show in the menu bar", isOn: $menuBar)
            } footer: {
                Text("Reminders only fire while Recurse is running. Closing the window keeps it in the Dock; quit it (⌘Q) to stop them.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .settingsPane()
    }

    private var remindersTab: some View {
        Form {
            Section {
                Toggle("Daily reminders", isOn: $s.reminders)
                LabeledContent("Between") {
                    HStack(spacing: 8) {
                        timeField("From", \.start)
                        Text("and").foregroundStyle(.secondary)
                        timeField("Until", \.end)
                    }
                    .labelsHidden()
                }
                .disabled(!s.reminders)
                LabeledContent("Next reminder") {
                    Text(reminders.nextAt.map { $0.formatted(date: .omitted, time: .shortened) } ?? (s.reminders ? "Nothing more today" : "Off"))
                        .monospacedDigit()
                }
            } footer: {
                Text("A few nudges spread across your study days, never outside these hours.").font(.caption).foregroundStyle(.secondary)
            }

            Section {
                HStack {
                    Button("Send a Test") {
                        Task {
                            permission = await reminders.requestPermission() ? "" : "Notifications are off for Recurse in System Settings."
                            reminders.sendTest()
                        }
                    }
                    Button("Snooze 1 Hour") { reminders.snooze() }.disabled(!s.reminders)
                    Spacer()
                }
                .buttonBorderShape(.capsule)
                if !permission.isEmpty {
                    Label(permission, systemImage: "exclamationmark.triangle.fill").font(.callout).foregroundStyle(.danger)
                }
            }
        }
        .settingsPane()
    }

    private func dayBinding(_ d: Int) -> Binding<Bool> {
        Binding(get: { s.plannedDays.contains(d) },
                set: { on in if on { s.plannedDays.append(d); s.plannedDays.sort() } else { s.plannedDays.removeAll { $0 == d } } })
    }

    /// Stored as "HH:MM" strings.
    private func timeField(_ label: String, _ key: WritableKeyPath<Settings.Window, String>) -> some View {
        DatePicker(label, selection: Binding(
            get: { ReminderTiming.at(.now, s.window[keyPath: key]) },
            set: { d in
                let c = Calendar.current.dateComponents([.hour, .minute], from: d)
                s.window[keyPath: key] = String(format: "%02d:%02d", c.hour!, c.minute!)
            }), displayedComponents: .hourAndMinute)
    }
}

private struct DayChip: View {
    let label: String
    @Binding var on: Bool

    var body: some View {
        Button { withAnimation(.snappy(duration: 0.2)) { on.toggle() } } label: {
            Text(label.prefix(1)).font(.callout.weight(.semibold))
                .foregroundStyle(on ? Color.brandInk : Color.secondary)
                .frame(width: 28, height: 28)
                .background(Circle().fill(on ? Color.brand : Color.raised))
                .overlay(Circle().strokeBorder(on ? .clear : Color.hairline))
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .help(label)
        .accessibilityLabel(label)
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}

private struct DataTab: View {
    @Environment(Store.self) private var store
    @Environment(Reminders.self) private var reminders
    let restored: () -> Void
    @State private var confirm: URL?
    @State private var status = ""

    var body: some View {
        Form {
            Section {
                LabeledContent("Back up everything") {
                    Button("Export…") { export() }
                }
                LabeledContent("Restore a backup") {
                    Button("Import…") {
                        let panel = NSOpenPanel()
                        panel.allowedContentTypes = [.data]
                        if panel.runModal() == .OK { confirm = panel.url }
                    }
                }
            } footer: {
                Text("A backup is one file with all your progress, settings and photo. Importing replaces what's here; the current data is saved to Backups first.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section {
                LabeledContent("Stored in") {
                    Button("Show in Finder") { NSWorkspace.shared.activateFileViewerSelecting([Paths.db]) }
                }
                if !status.isEmpty { Text(status).font(.callout).foregroundStyle(.secondary) }
            } footer: {
                Text("Your data lives outside the app, so updating or reinstalling Recurse keeps it.").font(.caption).foregroundStyle(.secondary)
            }
        }
        .settingsPane()
        .alert("Replace your data with this backup?", isPresented: Binding(get: { confirm != nil }, set: { if !$0 { confirm = nil } })) {
            Button("Replace", role: .destructive) { if let url = confirm { restore(url) } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your current progress is saved to Backups first, so you can undo this by importing that file.")
        }
    }

    private func export() {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "Recurse Backup \(Dates.local()).recurse"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try store.exportData(to: url)
            status = "Exported to \(url.lastPathComponent)."
        } catch { status = error.localizedDescription }
    }

    private func restore(_ url: URL) {
        do {
            try store.importData(from: url)
            reminders.schedule()
            restored()
            status = "Restored from \(url.lastPathComponent)."
        } catch { status = error.localizedDescription }
    }
}

private struct UpdatesTab: View {
    @State private var latest: Updates.Release?
    @State private var busy = false
    @State private var status = ""

    var body: some View {
        let current = Updates.current
        let newer = latest.map { l in current.map { Updates.isNewer(l.version, than: $0) } ?? true } ?? false
        Form {
            Section {
                LabeledContent("Installed", value: current ?? "Development build")
                if let latest { LabeledContent("Latest on GitHub", value: latest.version) }
                HStack {
                    Button("Check for Updates") { check() }.disabled(busy)
                    if newer {
                        Button("Download and Install") { install() }.buttonStyle(.borderedProminent).disabled(busy || current == nil)
                    }
                    Spacer()
                    if busy { ProgressView().controlSize(.small) }
                }
                if !status.isEmpty { Text(status).font(.callout).foregroundStyle(.secondary) }
            } footer: {
                Text("Your progress is kept across updates. You can also [download it from GitHub](\(Updates.releasesPage)).")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .settingsPane()
        .task { if latest == nil { check() } }
    }

    private func check() {
        busy = true
        status = ""
        Task {
            do {
                let l = try await Updates.latest()
                latest = l
                if let c = Updates.current, !Updates.isNewer(l.version, than: c) { status = "You're up to date." }
            } catch { status = error.localizedDescription }
            busy = false
        }
    }

    private func install() {
        guard let latest else { return }
        busy = true
        status = "Downloading \(latest.version)…"
        Task {
            do { try await Updates.install(latest) } catch { status = error.localizedDescription }
            busy = false
        }
    }
}

private struct RewardsTab: View {
    @Environment(Store.self) private var store
    @State private var editing: RewardState?

    var body: some View {
        Form {
            Section {
                ForEach(store.rewardPath()) { x in
                    HStack(spacing: 12) {
                        ArtImage(name: x.item.icon, size: 34)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(x.item.title).lineLimit(1)
                            Text(x.def.label).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                        }
                        Spacer()
                        Button("Edit") { editing = x }
                    }
                }
            } footer: {
                Text("Each milestone unlocks a real treat. Pick one, or add your own; choose the last one early so it's there to work towards.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(height: 540)
        .sheet(item: $editing) { RewardEditor(x: $0) }
    }
}

private struct RewardEditor: View {
    @Environment(Store.self) private var store
    @Environment(\.dismiss) private var dismiss
    let x: RewardState
    @State private var item: RewardItem

    init(x: RewardState) {
        self.x = x
        _item = State(initialValue: x.item)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Reward for \(x.def.label)").font(.title3.weight(.semibold))
                Text("Pick something, or add your own. Choose it now so it's there to work towards.").font(.callout).foregroundStyle(.secondary)
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 8)], spacing: 8) {
                ForEach(RewardItem.presets, id: \.icon) { p in tile(p.icon, p.title) { item = p } }
                tile("custom", "Your own") { if item.icon != "custom" { item = RewardItem(title: "") } }
            }
            VStack(alignment: .leading, spacing: 10) {
                TextField("Title", text: $item.title, prompt: Text("What you'll get"))
                TextField("Note", text: $item.note, prompt: Text("A line to keep you going (optional)"))
            }
            .textFieldStyle(.roundedBorder)
            HStack {
                Button("Reset to Default") {
                    store.setReward(x.id, nil)
                    dismiss()
                }
                .disabled(!x.custom)
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }.keyboardShortcut(.cancelAction)
                Button("Save") {
                    store.setReward(x.id, item == x.def.item ? nil : item)
                    dismiss()
                }
                .buttonStyle(.borderedProminent).keyboardShortcut(.defaultAction)
                .disabled(item.title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 480)
    }

    private func tile(_ icon: String, _ title: String, pick: @escaping () -> Void) -> some View {
        let on = item.icon == icon
        return Button(action: pick) {
            VStack(spacing: 6) {
                ArtImage(name: icon, size: 44)
                Text(title).font(.caption).lineLimit(1).foregroundStyle(on ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 10)
            .background(on ? Color.brand.opacity(0.12) : Color.raised.opacity(0.5), in: .rect(cornerRadius: 10, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(on ? Color.brand.opacity(0.6) : Color.hairline))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

private extension View {
    func settingsPane() -> some View {
        formStyle(.grouped).scrollDisabled(true).fixedSize(horizontal: false, vertical: true)
    }
}
